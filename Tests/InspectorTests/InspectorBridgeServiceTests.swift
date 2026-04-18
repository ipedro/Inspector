#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import XCTest

final class InspectorBridgeServiceTests: XCTestCase {
    func testQueryReturnsGuaranteedPhaseOneFields() throws {
        let window = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let viewController = MockReference.viewController(className: "PlaygroundViewController", displayName: "Playground", elementName: "Playground", accessibilityIdentifier: "vc")
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")

        link(parent: window, child: viewController)
        link(parent: viewController, child: label)

        let response = try makeService(
            snapshot: MockSnapshot(nodes: [window, viewController, label])
        ).query()

        XCTAssertEqual(response.nodes.count, 3)

        let labelNode = try XCTUnwrap(response.nodes.first { $0.accessibilityIdentifier == "greeting" })
        XCTAssertEqual(labelNode.nodeKind, .view)
        XCTAssertEqual(labelNode.className, "UILabel")
        XCTAssertEqual(labelNode.backingObjectType, "UILabel")
        XCTAssertEqual(labelNode.displayName, "Greeting Label")
        XCTAssertEqual(labelNode.elementName, "Greeting")
        XCTAssertEqual(labelNode.frame, label._frame.wrappedValue)
        XCTAssertFalse(labelNode.isHidden)
        XCTAssertTrue(labelNode.isUserInteractionEnabled)
        XCTAssertEqual(labelNode.depth, 2)
        XCTAssertEqual(labelNode.childCount, 0)
        XCTAssertEqual(labelNode.childHandles.count, 0)
        XCTAssertNotNil(labelNode.parentHandle)
    }

    func testQueryFiltersByStructuredFields() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let button = MockReference.view(className: "UIButton", displayName: "CTA Button", elementName: "CTA", accessibilityIdentifier: "cta")

        let snapshot = MockSnapshot(nodes: [label, button])
        let service = makeService(snapshot: snapshot)

        XCTAssertEqual(
            try service.query(.init(classNameContains: "Label")).nodes.map(\.className),
            ["UILabel"]
        )
        XCTAssertEqual(
            try service.query(.init(displayNameContains: "CTA")).nodes.map(\.displayName),
            ["CTA Button"]
        )
        XCTAssertEqual(
            try service.query(.init(elementNameContains: "Greeting")).nodes.map(\.elementName),
            ["Greeting"]
        )
        XCTAssertEqual(
            try service.query(.init(accessibilityIdentifierEquals: "cta")).nodes.map(\.accessibilityIdentifier),
            ["cta"]
        )
    }

    func testResolveRejectsExpiredHandleAsStale() throws {
        var now = Date()
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let snapshot = MockSnapshot(
            expirationDate: now.addingTimeInterval(1),
            nodes: [label]
        )

        let service = makeService(
            snapshot: snapshot,
            dateProvider: { now }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        now = now.addingTimeInterval(2)

        XCTAssertThrowsError(try service.resolve(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testResolveRejectsSemanticallyDriftedHandleAsStale() throws {
        let window = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let child = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        link(parent: window, child: child)

        let service = makeService(snapshot: MockSnapshot(nodes: [window, child]))
        let handle = try XCTUnwrap(service.query().nodes.first { $0.accessibilityIdentifier == "greeting" }?.handle)

        child._depth = 5

        XCTAssertThrowsError(try service.resolve(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testResetInvalidatesExistingHandles() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(snapshot: MockSnapshot(nodes: [label]))
        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        service.reset()

        XCTAssertThrowsError(try service.resolve(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testRefreshHandleRebindsExpiredHandleUsingRememberedSemanticReference() throws {
        var now = Date()

        let firstWindow = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let firstChild = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        link(parent: firstWindow, child: firstChild)

        let secondWindow = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let secondChild = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        link(parent: secondWindow, child: secondChild)

        var currentSnapshot: any InspectorBridgeSnapshotProtocol = MockSnapshot(
            expirationDate: now.addingTimeInterval(1),
            nodes: [firstWindow, firstChild]
        )

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { currentSnapshot },
            dateProvider: { now }
        )

        let handle = try XCTUnwrap(service.query().nodes.first { $0.accessibilityIdentifier == "greeting" }?.handle)
        now = now.addingTimeInterval(2)
        currentSnapshot = MockSnapshot(
            expirationDate: now.addingTimeInterval(60),
            nodes: [secondWindow, secondChild]
        )

        let refreshed = try service.refreshHandle(handle)
        XCTAssertTrue(refreshed.rebound)

        let resolved = try service.resolve(refreshed.handle)
        XCTAssertEqual(resolved.accessibilityIdentifier, "greeting")
    }

    func testRefreshHandleRejectsAmbiguousSemanticReference() throws {
        let leftRoot = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let rightRoot = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let left = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let right = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        link(parent: leftRoot, child: left)
        link(parent: rightRoot, child: right)

        let service = makeService(snapshot: MockSnapshot(nodes: [leftRoot, left, rightRoot, right]))
        let query = try service.query(.init(accessibilityIdentifierEquals: "greeting"))
        let semanticReference = try XCTUnwrap(query.nodes.first?.semanticReference)

        XCTAssertThrowsError(try service.refreshHandle(nil, semanticReference: semanticReference)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .ambiguousSemanticReference)
        }
    }

    func testSubtreeReturnsRootAndDescendantsThroughRequestedDepth() throws {
        let root = MockReference.window(className: "UIWindow", displayName: "Window", elementName: "Window", accessibilityIdentifier: "window")
        let parent = MockReference.view(className: "UIStackView", displayName: "Content Stack View", elementName: "Content", accessibilityIdentifier: "content")
        let child = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let grandchild = MockReference.view(className: "UIImageView", displayName: "Icon", elementName: "Icon", accessibilityIdentifier: "icon")
        link(parent: root, child: parent)
        link(parent: parent, child: child)
        link(parent: child, child: grandchild)

        let service = makeService(snapshot: MockSnapshot(nodes: [root, parent, child, grandchild]))
        let handle = try XCTUnwrap(service.query(.init(accessibilityIdentifierEquals: "content")).nodes.first?.handle)

        let subtree = try service.subtree(handle, maxDepth: 1)
        XCTAssertEqual(subtree.nodes.count, 2)
        XCTAssertEqual(subtree.nodes.first?.accessibilityIdentifier, "content")
        XCTAssertEqual(subtree.nodes.last?.accessibilityIdentifier, "greeting")
    }

    func testQueryRejectsDisabledAvailability() {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .disabled, snapshot: MockSnapshot(nodes: [label]))

        XCTAssertThrowsError(try service.query()) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .disabled)
        }
    }

    func testQueryRejectsNotStartedAvailability() {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .notStarted, snapshot: MockSnapshot(nodes: [label]))

        XCTAssertThrowsError(try service.query()) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .notStarted)
        }
    }

    func testQueryReportsRuntimeSnapshotUnavailableWhenSnapshotProviderReturnsNil() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { nil }
        )

        XCTAssertThrowsError(try service.query()) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.runtimeSnapshotUnavailable)
            )
        }
    }

    func testResolveRejectsDisabledAvailability() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .disabled, snapshot: MockSnapshot(nodes: [label]))
        let handle = InspectorBridgeHandle(rawValue: "token")

        XCTAssertThrowsError(try service.resolve(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .disabled)
        }
    }

    func testResolveRejectsNotStartedAvailability() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .notStarted, snapshot: MockSnapshot(nodes: [label]))
        let handle = InspectorBridgeHandle(rawValue: "token")

        XCTAssertThrowsError(try service.resolve(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .notStarted)
        }
    }

    func testSnapshotReturnsRuntimeSnapshotArtifact() throws {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.text = "Inspector"
        viewController.view.addSubview(label)
        viewController.view.layoutIfNeeded()

        let liveReference = ViewHierarchyElement(with: label)
        let service = makeService(
            snapshot: MockSnapshot(nodes: [liveReference])
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let artifact = try service.snapshot(handle)

        XCTAssertEqual(artifact.handle, handle)
        XCTAssertTrue(FileManager.default.fileExists(atPath: artifact.pngURL.path),
                      "snapshot artifact must exist on disk")

        let magic = try Data(contentsOf: artifact.pngURL).prefix(8)
        XCTAssertEqual(Array(magic), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
                       "snapshot artifact must be a valid PNG file")
        XCTAssertEqual(artifact.size.width, label.bounds.width)
        XCTAssertEqual(artifact.size.height, label.bounds.height)
    }

    func testSnapshotRejectsExpiredHandleAsStale() throws {
        var now = Date()
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let snapshot = MockSnapshot(
            expirationDate: now.addingTimeInterval(1),
            nodes: [label]
        )

        let service = makeService(
            snapshot: snapshot,
            dateProvider: { now }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        now = now.addingTimeInterval(2)

        XCTAssertThrowsError(try service.snapshot(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testSnapshotRejectsDisabledAvailability() {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .disabled, snapshot: MockSnapshot(nodes: [label]))

        XCTAssertThrowsError(try service.snapshot(.init(rawValue: "token"))) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .disabled)
        }
    }

    func testSnapshotRejectsNotStartedAvailability() {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(availability: .notStarted, snapshot: MockSnapshot(nodes: [label]))

        XCTAssertThrowsError(try service.snapshot(.init(rawValue: "token"))) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .notStarted)
        }
    }

    func testSnapshotReportsLostConnectionWhenUnderlyingViewIsMissing() {
        let renderer = InspectorBridgeSnapshotRenderer()
        let reference = MockReference.view(className: "UILabel", displayName: "Greeting", elementName: "Greeting", accessibilityIdentifier: nil)
        reference.underlyingView = nil

        XCTAssertThrowsError(
            try renderer.snapshot(for: reference, handle: .init(rawValue: "token"), afterScreenUpdates: true)
        ) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.lostConnection)
            )
        }
    }

    func testSnapshotReportsNoWindowForDetachedView() {
        let renderer = InspectorBridgeSnapshotRenderer()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let reference = ViewHierarchyElement(with: view)

        XCTAssertThrowsError(
            try renderer.snapshot(for: reference, handle: .init(rawValue: "token"), afterScreenUpdates: true)
        ) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.noWindow)
            )
        }
    }

    func testSnapshotReportsFrameIsEmptyForZeroSizedView() {
        let renderer = InspectorBridgeSnapshotRenderer()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        let view = UIView(frame: .zero)
        viewController.view.addSubview(view)

        let reference = ViewHierarchyElement(with: view)

        XCTAssertThrowsError(
            try renderer.snapshot(for: reference, handle: .init(rawValue: "token"), afterScreenUpdates: true)
        ) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.frameIsEmpty)
            )
        }
    }

    func testSnapshotReportsHiddenForHiddenView() {
        let renderer = InspectorBridgeSnapshotRenderer()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.isHidden = true
        viewController.view.addSubview(view)

        let reference = ViewHierarchyElement(with: view)

        XCTAssertThrowsError(
            try renderer.snapshot(for: reference, handle: .init(rawValue: "token"), afterScreenUpdates: true)
        ) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.isHidden)
            )
        }
    }

    func testSnapshotReportsCaptureFailedWhenSnapshotViewReturnsNil() {
        let renderer = InspectorBridgeSnapshotRenderer()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        let view = NilSnapshotView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        viewController.view.addSubview(view)

        let reference = ViewHierarchyElement(with: view)

        XCTAssertThrowsError(
            try renderer.snapshot(for: reference, handle: .init(rawValue: "token"), afterScreenUpdates: true)
        ) { error in
            XCTAssertEqual(
                error as? InspectorBridgeError,
                .snapshotUnavailable(.captureFailed)
            )
        }
    }

    func testQueryAndResolveMarshalWorkToMainThread() {
        let expectation = expectation(description: "query and resolve observed on main thread")
        expectation.expectedFulfillmentCount = 2

        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let service = makeService(snapshot: MockSnapshot(nodes: [label]))

        service.operationObserver = { operation, isMainThread in
            guard operation == .query || operation == .resolve else {
                return
            }

            XCTAssertTrue(isMainThread)
            expectation.fulfill()
        }

        DispatchQueue.global().async {
            do {
                let handle = try XCTUnwrap(service.query().nodes.first?.handle)
                _ = try service.resolve(handle)
            }
            catch {
                XCTFail("unexpected error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSnapshotMarshalsWorkToMainThread() {
        let expectation = expectation(description: "snapshot observed on main thread")

        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        let renderer = RecordingSnapshotRenderer()
        let service = makeService(
            snapshot: MockSnapshot(nodes: [label]),
            snapshotRenderer: renderer
        )

        service.operationObserver = { operation, isMainThread in
            guard operation == .snapshot else {
                return
            }

            XCTAssertTrue(isMainThread)
            expectation.fulfill()
        }

        DispatchQueue.global().async {
            do {
                let handle = try XCTUnwrap(service.query().nodes.first?.handle)
                _ = try service.snapshot(handle)
            }
            catch {
                XCTFail("unexpected error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(renderer.lastInvocationWasOnMainThread)
    }

    func testSnapshotRetentionHonorsConfiguredLimit() throws {
        let label1 = MockReference.view(className: "UILabel", displayName: "Label 1", elementName: "Label 1", accessibilityIdentifier: "label-1")
        let label2 = MockReference.view(className: "UILabel", displayName: "Label 2", elementName: "Label 2", accessibilityIdentifier: "label-2")

        var currentSnapshot: (any InspectorBridgeSnapshotProtocol)? = MockSnapshot(nodes: [label1])
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { currentSnapshot },
            snapshotLimitProvider: { 1 }
        )

        let firstHandle = try XCTUnwrap(service.query().nodes.first?.handle)

        currentSnapshot = MockSnapshot(nodes: [label2])
        _ = try service.query()

        XCTAssertThrowsError(try service.resolve(firstHandle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testSnapshotRendererPrunesOldestPNGs() throws {
        let fileManager = FileManager.default
        let directory = inspectorSnapshotsDirectoryURL()
        try? fileManager.removeItem(at: directory)

        let renderer = InspectorBridgeSnapshotRenderer(
            artifactLimitProvider: { 3 },
            dateProvider: Date.init
        )
        let reference = try makeLiveReference()

        var urls: [URL] = []
        for _ in 0..<4 {
            let artifact = try renderer.snapshot(
                for: reference,
                handle: InspectorBridgeHandle(rawValue: UUID().uuidString),
                afterScreenUpdates: true
            )
            urls.append(artifact.pngURL)
            // Spread mtimes so ring buffer ordering is deterministic
            Thread.sleep(forTimeInterval: 0.05)
        }

        let remaining = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(remaining.count, 3, "ring buffer must cap at 3 files")
        XCTAssertFalse(fileManager.fileExists(atPath: urls[0].path),
                       "oldest file should have been pruned")
        XCTAssertTrue(fileManager.fileExists(atPath: urls[3].path),
                      "newest file must remain")

        addTeardownBlock {
            try? fileManager.removeItem(at: directory)
        }
    }

    // MARK: - Helpers

    private func makeLiveReference() throws -> ViewHierarchyElementReference {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        window.addSubview(view)
        return ViewHierarchyElement(with: view)
    }

    private func makeService(
        availability: InspectorBridgeRuntimeAvailability = .active,
        snapshot: any InspectorBridgeSnapshotProtocol,
        snapshotLimit: Int = 1,
        stateCaptureLimit: Int = 8,
        snapshotRenderer: InspectorBridgeSnapshotRendering = InspectorBridgeSnapshotRenderer(),
        dateProvider: @escaping InspectorMCPBridgeService.DateProvider = Date.init,
        librariesProvider: @escaping InspectorMCPBridgeService.LibrariesProvider = { _ in [] }
    ) -> InspectorMCPBridgeService {
        InspectorMCPBridgeService(
            availabilityProvider: { availability },
            snapshotProvider: { snapshot },
            snapshotLimitProvider: { snapshotLimit },
            stateCaptureLimitProvider: { stateCaptureLimit },
            snapshotRenderer: snapshotRenderer,
            dateProvider: dateProvider,
            librariesProvider: librariesProvider
        )
    }

    private func link(parent: MockReference, child: MockReference) {
        child.parent = parent
        parent.children.append(child)
    }
}

private final class MockSnapshot: InspectorBridgeSnapshotProtocol {
    let expirationDate: Date
    let viewHierarchy: [ViewHierarchyElementReference]
    let availableLayers: [ViewHierarchyLayer: Int]

    init(
        expirationDate: Date = Date().addingTimeInterval(60),
        nodes: [ViewHierarchyElementReference],
        availableLayers: [ViewHierarchyLayer: Int] = [:]
    ) {
        self.expirationDate = expirationDate
        viewHierarchy = nodes
        self.availableLayers = availableLayers
    }
}

private final class MockLibrary: InspectorElementLibraryProtocol {
    let targetClass: AnyClass = UIView.self
    private let rows: [InspectorElementSectionDataSource]

    init(rows: [InspectorElementSectionDataSource]) {
        self.rows = rows
    }

    func sections(for object: NSObject) -> InspectorElementSections {
        [InspectorElementSection(title: "Mock Section", rows: rows)]
    }
}

private final class MockSectionRow: InspectorElementSectionDataSource {
    var title: String
    var subtitle: String?
    var properties: [InspectorElementProperty]
    var customClass: InspectorElementSectionView.Type? { nil }
    var state: InspectorElementSectionState = .expanded
    var titleAccessoryProperty: InspectorElementProperty? { nil }

    init(title: String = "Mock Row", subtitle: String? = nil, properties: [InspectorElementProperty]) {
        self.title = title
        self.subtitle = subtitle
        self.properties = properties
    }
}

private final class MockReference: ViewHierarchyElementReference {
    enum Kind {
        case window
        case viewController
        case view
    }

    let kind: Kind
    var parent: ViewHierarchyElementReference?
    var children: [ViewHierarchyElementReference] = []
    var _depth: Int
    var isCollapsed: Bool = false

    private let object: NSObject
    private let frameValue: CGRect
    private let canInspect: Bool
    private let className: String
    private let classNameWithoutQualifiers: String
    private let elementName: String
    private let displayName: String
    private let canPresentOnTop: Bool
    private let interactionEnabled: Bool
    private let identifier: String?
    private let internalViewFlag: Bool
    private let systemContainerFlag: Bool

    var underlyingView: UIView?
    var underlyingViewControllerValue: UIViewController?
    var hidden: Bool = false

    init(
        kind: Kind,
        object: NSObject,
        depth: Int,
        frame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20),
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?,
        isUserInteractionEnabled: Bool = true,
        isInternalView: Bool = false,
        isSystemContainer: Bool = false
    ) {
        self.kind = kind
        self.object = object
        _depth = depth
        frameValue = frame
        canInspect = false
        self.className = className
        classNameWithoutQualifiers = className
        self.elementName = elementName
        self.displayName = displayName
        canPresentOnTop = false
        interactionEnabled = isUserInteractionEnabled
        identifier = accessibilityIdentifier
        internalViewFlag = isInternalView
        systemContainerFlag = isSystemContainer
        underlyingView = object as? UIView
        underlyingViewControllerValue = object as? UIViewController
    }

    static func window(
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?
    ) -> MockReference {
        MockReference(
            kind: .window,
            object: UIWindow(frame: UIScreen.main.bounds),
            depth: 0,
            className: className,
            displayName: displayName,
            elementName: elementName,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    static func viewController(
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?
    ) -> MockReference {
        let viewController = UIViewController()
        viewController.loadViewIfNeeded()

        return MockReference(
            kind: .viewController,
            object: viewController,
            depth: 1,
            className: className,
            displayName: displayName,
            elementName: elementName,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    static func view(
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?
    ) -> MockReference {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.accessibilityIdentifier = accessibilityIdentifier

        return MockReference(
            kind: .view,
            object: view,
            depth: 2,
            className: className,
            displayName: displayName,
            elementName: elementName,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    var _underlyingObject: NSObject? { object }
    var _underlyingView: UIView? { underlyingView }
    var underlyingViewController: UIViewController? { underlyingViewControllerValue }
    func hasChanges(inRelationTo identifier: UUID) -> Bool { false }
    var _latestSnapshotIdentifier: UUID { .init() }
    var iconImage: UIImage? { nil }
    var cachedIconImage: UIImage? { nil }
    var _canHostContextMenuInteraction: Bool { false }
    var _objectIdentifier: ObjectIdentifier { ObjectIdentifier(object) }
    var _canHostInspectorView: Bool { canInspect }
    var _isInternalView: Bool { internalViewFlag }
    var _isSystemContainer: Bool { systemContainerFlag }
    var _className: String { className }
    var _classNameWithoutQualifiers: String { classNameWithoutQualifiers }
    var _elementName: String { elementName }
    var _displayName: String { displayName }
    var _canPresentOnTop: Bool { canPresentOnTop }
    var isUserInteractionEnabled: Bool { interactionEnabled }
    var _frame: HashableBox<CGRect> { .init(wrappedValue: frameValue) }
    var accessibilityIdentifier: String? { identifier }
    var _issues: [ViewHierarchyIssue] { [] }
    var _constraintElements: [LayoutConstraintElement] { [] }
    var _shortElementDescription: String { displayName }
    var _elementDescription: String { displayName }
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle { .unspecified }
    var traitCollection: UITraitCollection { UITraitCollection() }
    var isHidden: Bool {
        get { hidden }
        set { hidden = newValue }
    }
}

private final class NilSnapshotView: UIView {
    override func snapshotView(afterScreenUpdates: Bool) -> UIView? {
        nil
    }
}

private final class TapActionTarget: NSObject {
    private(set) var primaryActionCount = 0
    private(set) var touchUpInsideCount = 0

    @objc func primaryActionTriggered() {
        primaryActionCount += 1
    }

    @objc func touchUpInside() {
        touchUpInsideCount += 1
    }
}

// MARK: - inspect(_:)

extension InspectorBridgeServiceTests {
    func testBridgeInspectReturnsHandleForLiveView() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        window.addSubview(view)
        let element = ViewHierarchyElement(with: view)

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [element]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let returned = try service.inspect(handle)
        XCTAssertEqual(returned, handle)

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgeInspectRejectsUnknownHandle() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { nil }
        )
        let handle = InspectorBridgeHandle(rawValue: "UNKNOWN")

        XCTAssertThrowsError(try service.inspect(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testBridgeInspectRejectsDeallocatedView() throws {
        let element: ViewHierarchyElement = {
            let view = UIView()
            return ViewHierarchyElement(with: view) // view deallocates when closure returns
        }()

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [element]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        XCTAssertThrowsError(try service.inspect(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
        }
    }

    func testBridgeLayersReturnsOnlyPopulatedLayersSortedByTitle() throws {
        let wireframes = ViewHierarchyLayer.wireframes
        let controls = ViewHierarchyLayer.controls
        let emptyTables = ViewHierarchyLayer.tables

        var toggledFlags: [String: Bool] = [wireframes.name: true, controls.name: false]

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: {
                MockSnapshot(
                    nodes: [],
                    availableLayers: [wireframes: 3, controls: 2, emptyTables: 0]
                )
            },
            layerToggler: { _ in },
            layerActiveProvider: { toggledFlags[$0.name] ?? false }
        )

        let layers = try service.layers()

        XCTAssertEqual(layers.map(\.name), [controls.name, wireframes.name],
                       "expect only populated layers sorted by localized title")
        XCTAssertEqual(layers.first(where: { $0.name == wireframes.name })?.active, true)
        XCTAssertEqual(layers.first(where: { $0.name == controls.name })?.active, false)
        XCTAssertEqual(layers.first?.displayName, controls.description)
    }

    func testBridgeLayersReturnsEmptyWhenSnapshotProviderReturnsNil() throws {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { nil }
        )

        XCTAssertTrue(try service.layers().isEmpty)
    }

    func testBridgeLayersRejectsDisabledAvailability() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .disabled },
            snapshotProvider: { MockSnapshot(nodes: []) }
        )

        XCTAssertThrowsError(try service.layers()) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .disabled)
        }
    }

    func testBridgeToggleLayerInvokesTogglerAndReportsIntendedState() throws {
        let wireframes = ViewHierarchyLayer.wireframes
        var active = false
        var toggleCount = 0

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [], availableLayers: [wireframes: 5]) },
            layerToggler: { layer in
                XCTAssertEqual(layer.name, wireframes.name)
                active.toggle()
                toggleCount += 1
            },
            layerActiveProvider: { _ in active }
        )

        let firstState = try service.toggleLayer(name: wireframes.name)
        XCTAssertEqual(firstState.name, wireframes.name)
        XCTAssertEqual(firstState.displayName, wireframes.description)
        XCTAssertTrue(firstState.active, "expect intended state after first toggle to be active=true")
        XCTAssertEqual(toggleCount, 1)

        let secondState = try service.toggleLayer(name: wireframes.name)
        XCTAssertFalse(secondState.active, "expect intended state after second toggle to be active=false")
        XCTAssertEqual(toggleCount, 2)
    }

    func testBridgeToggleLayerReportsIntendedStateEvenWhenTogglerIsAsync() throws {
        let wireframes = ViewHierarchyLayer.wireframes

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [], availableLayers: [wireframes: 5]) },
            layerToggler: { _ in /* simulate async — do nothing synchronously */ },
            layerActiveProvider: { _ in false } // still false when queried synchronously after
        )

        let state = try service.toggleLayer(name: wireframes.name)
        XCTAssertTrue(state.active,
                      "intended state must be reported regardless of async toggler latency")
    }

    func testBridgeToggleLayerRejectsUnknownName() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [], availableLayers: [.wireframes: 1]) }
        )

        XCTAssertThrowsError(try service.toggleLayer(name: "not-a-layer")) { error in
            guard case let .internalFailure(message) = error as? InspectorBridgeError else {
                XCTFail("expected internalFailure, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("not-a-layer"))
        }
    }

    func testBridgeToggleLayerRejectsMissingSnapshot() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { nil }
        )

        XCTAssertThrowsError(try service.toggleLayer(name: "wireframes")) { error in
            guard case .internalFailure = error as? InspectorBridgeError else {
                XCTFail("expected internalFailure, got \(error)")
                return
            }
        }
    }

    func testBridgeToggleLayerRejectsNotStartedAvailability() {
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .notStarted },
            snapshotProvider: { MockSnapshot(nodes: []) }
        )

        XCTAssertThrowsError(try service.toggleLayer(name: "wireframes")) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .notStarted)
        }
    }

    func testBridgeInspectRejectsNonViewReference() throws {
        let nonViewRef = MockReference(
            kind: .view,
            object: NSObject(),
            depth: 0,
            className: "NSObject",
            displayName: "NSObject",
            elementName: "NSObject",
            accessibilityIdentifier: nil
        )

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [nonViewRef]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        XCTAssertThrowsError(try service.inspect(handle)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .unsupportedTarget)
        }
    }

    func testBridgeTapDispatchesPrimaryActionTriggeredWhenAvailable() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        let target = TapActionTarget()
        button.addTarget(target, action: #selector(TapActionTarget.primaryActionTriggered), for: .primaryActionTriggered)
        button.addTarget(target, action: #selector(TapActionTarget.touchUpInside), for: .touchUpInside)
        window.addSubview(button)

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [ViewHierarchyElement(with: button)]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let returned = try service.tap(handle)

        XCTAssertEqual(returned, handle)
        XCTAssertEqual(target.primaryActionCount, 1)
        XCTAssertEqual(target.touchUpInsideCount, 0,
                       "tap must dispatch exactly one event and prefer primaryActionTriggered")

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgeTapFallsBackToTouchUpInside() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        let target = TapActionTarget()
        button.addTarget(target, action: #selector(TapActionTarget.touchUpInside), for: .touchUpInside)
        window.addSubview(button)

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [ViewHierarchyElement(with: button)]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        _ = try service.tap(handle)

        XCTAssertEqual(target.primaryActionCount, 0)
        XCTAssertEqual(target.touchUpInsideCount, 1)

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgeTapRejectsGestureBackedNonControlView() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()

        let tappedView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        tappedView.isUserInteractionEnabled = true
        tappedView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        window.addSubview(tappedView)

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [ViewHierarchyElement(with: tappedView)]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        XCTAssertThrowsError(try service.tap(handle)) { error in
            guard case let .internalFailure(message) = error as? InspectorBridgeError else {
                XCTFail("expected internalFailure, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("UIControl") || message.contains("tappable"))
        }

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgeTapRejectsDisabledControl() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        button.isEnabled = false
        let target = TapActionTarget()
        button.addTarget(target, action: #selector(TapActionTarget.touchUpInside), for: .touchUpInside)
        window.addSubview(button)

        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [ViewHierarchyElement(with: button)]) }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        XCTAssertThrowsError(try service.tap(handle)) { error in
            guard case let .internalFailure(message) = error as? InspectorBridgeError else {
                XCTFail("expected internalFailure, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("enabled") || message.contains("interact"))
        }
        XCTAssertEqual(target.touchUpInsideCount, 0)

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgeListPropertiesProjectsSupportedEditableProperties() throws {
        let view = UIView()
        view.accessibilityIdentifier = "editable-view"
        let reference = ViewHierarchyElement(with: view)

        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Hidden", isOn: { view.isHidden }) { view.isHidden = $0 },
                        .textField(title: "Identifier", placeholder: nil, axis: .vertical, value: { view.accessibilityIdentifier }) { view.accessibilityIdentifier = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let response = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)

        let properties = response.sections.flatMap { $0.rows }.flatMap { $0.properties }
        XCTAssertEqual(properties.count, 2)
        XCTAssertEqual(properties.map(\.title), ["Hidden", "Identifier"])
        XCTAssertEqual(properties.map(\.kind), [InspectorBridgeEditablePropertyKind.toggle, InspectorBridgeEditablePropertyKind.textField])
        XCTAssertNotNil(properties.first?.propertyRef)
    }

    func testBridgeListPropertiesSupportsBindingBackedRows() throws {
        final class BindingRow: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Binding Row"
            let sectionBinding: InspectorSectionBinding? = .init(
                descriptor: .init(id: "binding-row"),
                fields: [
                    .init(
                        descriptor: .init(id: "enabled", title: "Enabled", kind: .toggle, value: .bool, editability: .editable),
                        read: { .bool(true) },
                        write: { _ in }
                    )
                ]
            )
        }

        let bindingService = makeService(
            snapshot: MockSnapshot(nodes: [MockReference.view(className: "UIView", displayName: "Binding", elementName: "Binding", accessibilityIdentifier: "binding-view")]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [BindingRow()])]
            }
        )

        let bindingHandle = try XCTUnwrap(bindingService.query().nodes.first?.handle)
        let response = try bindingService.listProperties(for: bindingHandle, panel: InspectorBridgeEditablePanel.attributes)
        let properties = response.sections.flatMap { $0.rows }.flatMap { $0.properties }
        XCTAssertEqual(properties.map { $0.title }, ["Enabled"])
    }

    func testBridgeSetPropertyAppliesHandlerAndInvalidatesPropertyRefs() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Hidden", isOn: { view.isHidden }) { view.isHidden = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        let result = try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.bool(true))
        XCTAssertTrue(result.applied)
        XCTAssertTrue(view.isHidden)

        XCTAssertThrowsError(try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.bool(false))) { error in
            XCTAssertEqual(error as? InspectorBridgeError, InspectorBridgeError.stalePropertyReference)
        }
    }

    func testBridgeSetPropertyAppliesBindingWriter() throws {
        let reference = MockReference.view(className: "UIView", displayName: "Binding", elementName: "Binding", accessibilityIdentifier: "binding-view")
        var value = false
        final class BindingRow: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Binding Row"
            let bindingProvider: () -> InspectorSectionBinding?

            init(bindingProvider: @escaping () -> InspectorSectionBinding?) {
                self.bindingProvider = bindingProvider
            }

            var sectionBinding: InspectorSectionBinding? { bindingProvider() }
        }

        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    BindingRow {
                        InspectorSectionBinding(
                            descriptor: .init(id: "binding-row"),
                            fields: [
                                .init(
                                    descriptor: .init(id: "enabled", title: "Enabled", kind: .toggle, value: .bool, editability: .editable),
                                    read: { .bool(value) },
                                    write: { newValue in
                                        guard case let .bool(updated) = newValue else { return }
                                        value = updated
                                    }
                                )
                            ]
                        )
                    }
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        let result = try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.bool(true))
        XCTAssertTrue(result.applied)
        XCTAssertTrue(value)
    }

    func testBridgeSetPropertyRejectsWrongValueKind() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Hidden", isOn: { view.isHidden }) { view.isHidden = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        XCTAssertThrowsError(try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.number(1))) { error in
            guard case let .invalidPropertyValue(message) = error as? InspectorBridgeError else {
                XCTFail("expected invalidPropertyValue, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("does not match"))
        }
    }

    func testBridgeSetPropertyRejectsOutOfRangeStepperValue() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        var alphaValue: CGFloat = 1
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .cgFloatStepper(title: "Alpha", value: { alphaValue }, range: { 0...1 }, stepValue: { 0.1 }) { alphaValue = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        XCTAssertThrowsError(try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.number(2))) { error in
            guard case let .invalidPropertyValue(message) = error as? InspectorBridgeError else {
                XCTFail("expected invalidPropertyValue, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("range"))
        }
    }

    func testBridgeListPropertiesIncludesReadOnlyWhenRequested() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Read Only Hidden", isOn: { view.isHidden }, handler: nil)
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        let withoutReadOnly = try service.listProperties(
            for: handle,
            panel: InspectorBridgeEditablePanel.attributes,
            includeReadOnly: false
        )
        XCTAssertTrue(withoutReadOnly.sections.isEmpty)

        let withReadOnly = try service.listProperties(
            for: handle,
            panel: InspectorBridgeEditablePanel.attributes,
            includeReadOnly: true
        )
        let property = try XCTUnwrap(withReadOnly.sections.first?.rows.first?.properties.first)
        XCTAssertEqual(property.title, "Read Only Hidden")
        XCTAssertFalse(property.editable)
    }

    func testBridgeSetPropertyRejectsReadOnlyProperty() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Read Only Hidden", isOn: { view.isHidden }, handler: nil)
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(
            for: handle,
            panel: InspectorBridgeEditablePanel.attributes,
            includeReadOnly: true
        )
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        XCTAssertThrowsError(
            try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.bool(true))
        ) { error in
            guard case let .internalFailure(message) = error as? InspectorBridgeError else {
                XCTFail("expected internalFailure, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("read-only"))
        }
    }

    func testBridgeSetPropertyRejectsStalePropertyRefAfterSnapshotExpiry() throws {
        var now = Date()
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        let snapshot = MockSnapshot(
            expirationDate: now.addingTimeInterval(1),
            nodes: [reference]
        )
        let service = makeService(
            snapshot: snapshot,
            dateProvider: { now },
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .switch(title: "Hidden", isOn: { view.isHidden }) { view.isHidden = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        now = now.addingTimeInterval(2)

        XCTAssertThrowsError(
            try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.bool(true))
        ) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .stalePropertyReference)
        }
    }

    func testBridgeSetPropertyRejectsInvalidSelectionIndex() throws {
        let view = UIView()
        let reference = ViewHierarchyElement(with: view)
        var selection: Int? = 0
        let service = makeService(
            snapshot: MockSnapshot(nodes: [reference]),
            librariesProvider: { panel in
                guard panel == InspectorBridgeEditablePanel.attributes else { return [] }
                return [MockLibrary(rows: [
                    MockSectionRow(properties: [
                        .optionsList(
                            title: "Content Mode",
                            options: ["Scale To Fill", "Aspect Fit"],
                            selectedIndex: { selection }
                        ) { selection = $0 }
                    ])
                ])]
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let list = try service.listProperties(for: handle, panel: InspectorBridgeEditablePanel.attributes)
        let propertyRef = try XCTUnwrap(list.sections.first?.rows.first?.properties.first?.propertyRef)

        XCTAssertThrowsError(
            try service.setProperty(reference: propertyRef, value: InspectorBridgePropertyMutationValue.selection(5))
        ) { error in
            guard case let .invalidPropertyValue(message) = error as? InspectorBridgeError else {
                XCTFail("expected invalidPropertyValue, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("out of bounds"))
        }
    }

    func testBridgeListActionsProjectsSupportedActions() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        window.addSubview(view)
        let reference = ViewHierarchyElement(with: view)

        let service = makeService(snapshot: MockSnapshot(nodes: [reference]))
        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let response = try service.listActions(for: handle)

        XCTAssertFalse(response.actions.isEmpty)
        XCTAssertTrue(response.actions.contains { $0.kind == .inspect })
        XCTAssertTrue(response.actions.contains { $0.kind == .showHighlight })

        addTeardownBlock { window.isHidden = true }
    }

    func testBridgePerformActionInvokesExecutorAndInvalidatesActionRefs() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let reference = ViewHierarchyElement(with: view)
        var performedActions: [String] = []
        let service = InspectorMCPBridgeService(
            availabilityProvider: { .active },
            snapshotProvider: { MockSnapshot(nodes: [reference]) },
            actionExecutor: { action, _ in
                performedActions.append(action.title)
            }
        )

        let handle = try XCTUnwrap(service.query().nodes.first?.handle)
        let actions = try service.listActions(for: handle)
        let actionRef = try XCTUnwrap(actions.actions.first?.actionRef)

        let result = try service.performAction(reference: actionRef)
        XCTAssertTrue(result.performed)
        XCTAssertEqual(performedActions.count, 1)

        XCTAssertThrowsError(try service.performAction(reference: actionRef)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleActionReference)
        }
    }

    func testBridgePerformActionMapsDriftedOwnerToStaleActionReference() throws {
        let parent = MockReference.view(className: "UIView", displayName: "Parent", elementName: "Parent", accessibilityIdentifier: "parent")
        let child = MockReference.view(className: "UIView", displayName: "Child", elementName: "Child", accessibilityIdentifier: "child")
        link(parent: parent, child: child)

        let service = makeService(snapshot: MockSnapshot(nodes: [parent, child]))
        let handle = try XCTUnwrap(service.query().nodes.first { $0.accessibilityIdentifier == "child" }?.handle)
        let actions = try service.listActions(for: handle)
        let actionRef = try XCTUnwrap(actions.actions.first?.actionRef)

        child._depth = 9

        XCTAssertThrowsError(try service.performAction(reference: actionRef)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleActionReference)
        }
    }

    func testBridgeAssertPropertyReportsMatchingBooleanNodeProperty() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        label.hidden = true
        let service = makeService(snapshot: MockSnapshot(nodes: [label]))
        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        let result = try service.assertProperty(handle, property: .isHidden, expected: .bool(true))
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.actualBool, true)
    }

    func testBridgeAssertVisibleFailsForHiddenNode() throws {
        let label = MockReference.view(className: "UILabel", displayName: "Greeting Label", elementName: "Greeting", accessibilityIdentifier: "greeting")
        label.hidden = true
        let service = makeService(snapshot: MockSnapshot(nodes: [label]))
        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        let result = try service.assertVisible(handle)
        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.isHidden)
    }

    func testBridgeAssertPropertyReportsInternalViewFlag() throws {
        let internalNode = MockReference(
            kind: .view,
            object: UIView(),
            depth: 0,
            className: "_UITextLayoutCanvasView",
            displayName: "Internal",
            elementName: "Internal",
            accessibilityIdentifier: "internal",
            isInternalView: true
        )
        let service = makeService(snapshot: MockSnapshot(nodes: [internalNode]))
        let handle = try XCTUnwrap(service.query().nodes.first?.handle)

        let result = try service.assertProperty(handle, property: .isInternalView, expected: .bool(true))
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.actualBool, true)
    }

    func testBridgeAssertHierarchyContainsUsesMinimumCount() throws {
        let a = MockReference.view(className: "UIButton", displayName: "A", elementName: "A", accessibilityIdentifier: "a")
        let b = MockReference.view(className: "UIButton", displayName: "B", elementName: "B", accessibilityIdentifier: "b")
        let service = makeService(snapshot: MockSnapshot(nodes: [a, b]))

        let result = try service.assertHierarchyContains(
            .init(classNameContains: "UIButton"),
            minimumCount: 2
        )
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.matchCount, 2)
    }

    func testQueryFiltersByInternalAndSystemFlags() throws {
        let internalNode = MockReference(
            kind: .view,
            object: UIView(),
            depth: 0,
            className: "_UITextLayoutCanvasView",
            displayName: "Internal",
            elementName: "Internal",
            accessibilityIdentifier: "internal",
            isInternalView: true
        )
        let systemNode = MockReference(
            kind: .view,
            object: UIView(),
            depth: 0,
            className: "_UIRemoteKeyboardPlaceholderView",
            displayName: "System",
            elementName: "System",
            accessibilityIdentifier: "system",
            isInternalView: true,
            isSystemContainer: true
        )
        let appNode = MockReference.view(className: "UIButton", displayName: "App", elementName: "App", accessibilityIdentifier: "app")

        let service = makeService(snapshot: MockSnapshot(nodes: [internalNode, systemNode, appNode]))

        let internalMatches = try service.query(.init(isInternalView: true))
        XCTAssertEqual(internalMatches.nodes.count, 2)

        let systemMatches = try service.query(.init(isSystemContainer: true))
        XCTAssertEqual(systemMatches.nodes.count, 1)
        XCTAssertEqual(systemMatches.nodes.first?.accessibilityIdentifier, "system")
    }

    func testCaptureStateAndDiffStatesReportChangedNode() throws {
        let node = MockReference.view(className: "UIButton", displayName: "Button", elementName: "Button", accessibilityIdentifier: "button")
        let snapshot = MockSnapshot(nodes: [node])
        let service = makeService(snapshot: snapshot)

        let before = try service.captureState()
        node.hidden = true
        let after = try service.captureState()
        let diff = try service.diffStates(before: before.stateRef, after: after.stateRef)

        XCTAssertEqual(diff.changedCount, 1)
        XCTAssertTrue(diff.entries.contains { $0.kind == .changed && $0.accessibilityIdentifier == "button" })
    }

    func testCaptureStateSupportsDuplicateSiblings() throws {
        let parent = MockReference.view(className: "UIView", displayName: "Parent", elementName: "Parent", accessibilityIdentifier: "parent")
        let childA = MockReference.view(className: "UILabel", displayName: "Label", elementName: "Label", accessibilityIdentifier: nil)
        let childB = MockReference.view(className: "UILabel", displayName: "Label", elementName: "Label", accessibilityIdentifier: nil)
        link(parent: parent, child: childA)
        link(parent: parent, child: childB)

        let service = makeService(snapshot: MockSnapshot(nodes: [parent, childA, childB]))
        let state = try service.captureState()

        XCTAssertEqual(state.nodeCount, 3)
    }

    func testDiffStatesRejectsEvictedStateReference() throws {
        let node = MockReference.view(className: "UIButton", displayName: "Button", elementName: "Button", accessibilityIdentifier: "button")
        let service = makeService(snapshot: MockSnapshot(nodes: [node]), stateCaptureLimit: 1)

        let first = try service.captureState()
        let second = try service.captureState()

        XCTAssertNotEqual(first.stateRef, second.stateRef)
        XCTAssertThrowsError(try service.diffStates(before: first.stateRef, after: second.stateRef)) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .staleStateReference)
        }
    }

    func testScenarioLifecycleAndDiffAgainstCurrentState() throws {
        let node = MockReference.view(className: "UIButton", displayName: "Button", elementName: "Button", accessibilityIdentifier: "button")
        let service = makeService(snapshot: MockSnapshot(nodes: [node]))

        let saved = try service.saveScenario(named: "baseline")
        XCTAssertEqual(saved.name, "baseline")
        XCTAssertEqual(try service.listScenarios().map(\.name), ["baseline"])

        node.hidden = true
        let diff = try service.diffScenario(named: "baseline")
        XCTAssertEqual(diff.name, "baseline")
        XCTAssertEqual(diff.changedCount, 1)

        try service.deleteScenario(named: "baseline")
        XCTAssertTrue(try service.listScenarios().isEmpty)

        XCTAssertThrowsError(try service.diffScenario(named: "baseline")) { error in
            XCTAssertEqual(error as? InspectorBridgeError, .unknownScenario)
        }
    }
}

// MARK: - Inspector.stop() clears snapshots directory

extension InspectorBridgeServiceTests {
    func testInspectorStopClearsSnapshotsDirectory() throws {
        let fileManager = FileManager.default
        let directory = inspectorSnapshotsDirectoryURL()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let sentinel = directory.appendingPathComponent("sentinel.png")
        try Data([0x89]).write(to: sentinel)

        Inspector.sharedInstance.stop()

        XCTAssertFalse(fileManager.fileExists(atPath: directory.path),
                       "Inspector.stop() must remove the snapshots directory")

        addTeardownBlock {
            Inspector.sharedInstance.start()
        }
    }
}

// MARK: - cleanupInspectorSnapshotsDirectory

extension InspectorBridgeServiceTests {
    func testCleanupInspectorSnapshotsDirectoryRemovesDirectory() throws {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("inspector-snapshots", isDirectory: true)

        try? fileManager.removeItem(at: url)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        let sentinel = url.appendingPathComponent("sentinel.png")
        try Data([0x89]).write(to: sentinel)
        XCTAssertTrue(fileManager.fileExists(atPath: sentinel.path))

        cleanupInspectorSnapshotsDirectory()

        XCTAssertFalse(fileManager.fileExists(atPath: sentinel.path),
                       "cleanup must remove the inspector-snapshots directory contents")
        XCTAssertFalse(fileManager.fileExists(atPath: url.path),
                       "cleanup must remove the inspector-snapshots directory itself")
    }
}

private final class RecordingSnapshotRenderer: InspectorBridgeSnapshotRendering {
    private(set) var lastInvocationWasOnMainThread = false

    func snapshot(
        for reference: ViewHierarchyElementReference,
        handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool
    ) throws -> InspectorBridgeSnapshotArtifact {
        lastInvocationWasOnMainThread = Thread.isMainThread
        return InspectorBridgeSnapshotArtifact(
            handle: handle,
            pngURL: URL(fileURLWithPath: "/tmp/inspector-snapshots/fixture-\(UUID().uuidString).png"),
            size: CGSize(width: 10, height: 10),
            deviceScale: 2,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }
}
#endif
