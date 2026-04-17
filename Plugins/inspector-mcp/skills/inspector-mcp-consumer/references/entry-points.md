# Entry Points

Use this reference to choose where Inspector bridge setup belongs in a consumer app.

## UIKit with SceneDelegate

Best placement:
- `scene(_:willConnectTo:options:)`

Pattern:

```swift
import Inspector
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }

        var configuration = InspectorConfiguration.config(
            enableMCPBridge: true,
            snapshotExpiration: 300
        )
        configuration.snapshotMaxCount = 8
        Inspector.setConfiguration(configuration)

        Inspector.start()
    }
}
```

If the app already has `Inspector.setCustomization(...)`, keep it before `Inspector.start()`.

## UIKit with AppDelegate and no scenes

Best placement:
- `application(_:didFinishLaunchingWithOptions:)`

Pattern:

```swift
import Inspector
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        var configuration = InspectorConfiguration.config(
            enableMCPBridge: true,
            snapshotExpiration: 300
        )
        configuration.snapshotMaxCount = 8
        Inspector.setConfiguration(configuration)

        Inspector.start()
        return true
    }
}
```

## SwiftUI App Lifecycle

Preferred approach:
- keep startup deterministic by routing through `UIApplicationDelegateAdaptor`

Pattern:

```swift
import Inspector
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        var configuration = InspectorConfiguration.config(
            enableMCPBridge: true,
            snapshotExpiration: 300
        )
        configuration.snapshotMaxCount = 8
        Inspector.setConfiguration(configuration)

        Inspector.start()
        return true
    }
}

@main
struct ConsumerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Existing Inspector Integration

If the app already uses Inspector:
- patch the existing config path
- do not add a second `Inspector.start()`
- preserve existing customization and presentation hooks

## Existing Gating

If the app already gates Inspector behind:
- `#if DEBUG`
- custom compile conditions
- simulator checks

keep that pattern unless the task explicitly says to widen availability.
