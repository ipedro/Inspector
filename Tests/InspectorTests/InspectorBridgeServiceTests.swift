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
        dateProvider: @escaping InspectorMCPBridgeService.DateProvider = Date.init
    ) -> InspectorMCPBridgeService {
        InspectorMCPBridgeService(
            availabilityProvider: { availability },
            snapshotProvider: { snapshot },
            snapshotLimitProvider: { snapshotLimit },
            snapshotRenderer: snapshotRenderer,
            dateProvider: dateProvider
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

    init(
        expirationDate: Date = Date().addingTimeInterval(60),
        nodes: [ViewHierarchyElementReference]
    ) {
        self.expirationDate = expirationDate
        viewHierarchy = nodes
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
