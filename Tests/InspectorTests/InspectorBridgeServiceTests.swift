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
        snapshotRenderer: InspectorBridgeSnapshotRendering = InspectorBridgeSnapshotRenderer(),
        dateProvider: @escaping InspectorMCPBridgeService.DateProvider = Date.init,
        librariesProvider: @escaping InspectorMCPBridgeService.LibrariesProvider = { _ in [] }
    ) -> InspectorMCPBridgeService {
        InspectorMCPBridgeService(
            availabilityProvider: { availability },
            snapshotProvider: { snapshot },
            snapshotLimitProvider: { snapshotLimit },
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
    private let rows: [MockSectionRow]

    init(rows: [MockSectionRow]) {
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
    private let internalView: Bool
    private let systemContainer: Bool
    private let className: String
    private let classNameWithoutQualifiers: String
    private let elementName: String
    private let displayName: String
    private let canPresentOnTop: Bool
    private let interactionEnabled: Bool
    private let identifier: String?

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
        isUserInteractionEnabled: Bool = true
    ) {
        self.kind = kind
        self.object = object
        _depth = depth
        frameValue = frame
        canInspect = false
        internalView = false
        systemContainer = false
        self.className = className
        classNameWithoutQualifiers = className
        self.elementName = elementName
        self.displayName = displayName
        canPresentOnTop = false
        interactionEnabled = isUserInteractionEnabled
        identifier = accessibilityIdentifier
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
    var _isInternalView: Bool { internalView }
    var _isSystemContainer: Bool { systemContainer }
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
