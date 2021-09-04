//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Inspector
import UIKit
import UIKitOptions

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        Inspector.host = self

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

// MARK: - InspectorHostable

extension SceneDelegate: InspectorHostable {
    var inspectorElementLibraries: [InspectorElementLibraryProtocol]? { ExampleElementLibrary.allCases }

    var inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer]? {
        [
            .controls,
            .buttons,
            .staticTexts + .images,
            .layer(
                name: "Without accessibility identifier",
                filter: {
                    guard let accessibilityIdentifier = $0.accessibilityIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                        return true
                    }
                    return accessibilityIdentifier.isEmpty
                }
            )
        ]
    }

    var inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme? {
        .colorScheme { view in
            switch view {
            case is CustomButton:
                return .systemPink

            default:
                return Inspector.ViewHierarchyColorScheme.default.color(for: view)
            }
        }
    }

    var inspectorCommandGroups: [Inspector.CommandsGroup]? {
        guard let window = window else {
            return nil
        }

        return [
            .group(
                title: "My custom actions",
                commands: [
                    Inspector.Command(
                        title: {
                            switch window.traitCollection.userInterfaceStyle {
                            case .light:
                                return "Switch to dark mode"
                            case .dark:
                                return "Switch to light mode"
                            default:
                                return "Stop forcing theme"
                            }
                        }(),
                        icon: .exampleCommandIcon,
                        keyCommandOptions: .control(.shift(.key("i"))),
                        closure: {
                            switch window.traitCollection.userInterfaceStyle {
                            case .dark:
                                window.overrideUserInterfaceStyle = .light
                            case .light:
                                window.overrideUserInterfaceStyle = .dark
                            default:
                                window.overrideUserInterfaceStyle = .unspecified
                            }
                        }
                    ),
                    Inspector.Command(
                        title: "Reset",
                        icon: .exampleCommandIcon,
                        keyCommandOptions: .control(.shift(.key("r"))),
                        closure: {
                            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let initialViewController = mainStoryboard.instantiateInitialViewController()

                            window.rootViewController = initialViewController
                            Inspector.restart()
                        }
                    ),
                    Inspector.Command(
                        title: "Open repository...",
                        icon: .exampleCommandIcon,
                        keyCommandOptions: .control(.shift(.key("g"))),
                        closure: {
                            UIApplication.shared.open(
                                URL(string: "https://github.com/ipedro/Inspector")!,
                                options: [:],
                                completionHandler: nil
                            )
                        }
                    )
                ]
            )
        ]
    }
}

// MARK: - Inspector Presentation Example

extension UIWindow {
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)

        guard motion == .motionShake else {
            return
        }

        presentInspector(animated: true)
    }
}

private extension UIImage {
    static let exampleCommandIcon = UIImage(named: "CustomAction_32")
}
