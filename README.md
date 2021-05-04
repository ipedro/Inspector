
[![](https://img.shields.io/github/license/ipedro/inspector)](https://github.com/ipedro/Inspector/blob/develop/LICENSE) 
![](https://img.shields.io/github/v/tag/ipedro/inspector?label=spm)

# 🕵🏽‍♂️ Inspector

![Inspector Demo](Documentation/inspector_demo.gif)

Inspector is a debugging library written in Swift.

* [Requirements](#requirements)
* [Installation](#installation)
  * [Swift Package Manager](#swift-package-manager)
* [Usage](#usage)
  * [Scene Delegate Example](#scene-delegate-example)
  * [App Delegate Example](#app-delegate-example)
  * [Pro tips:](#pro-tips) 
    * [Remove framework files from relases](#remove-framework-files-from-relases)
    * [Add Custom Actions](#add-custom-actions)
* [Credits](#credits)
* [License](#license)

## Requirements

* iOS 11.0+
* Xcode 11+
* Swift 5.3+

## Installation

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swisft code and is integrated into the swift compiler. It is in early development, but Inspector does support its use on supported platforms.

Once you have your Swift package set up, adding `Inspector` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`.

``` swift
dependencies: [
  .package(url: "https://github.com/ipedro/Inspector.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

After a [successful installation](#installation), all you have to do is:
* Extend your `SceneDelegate.swift` of `AppDelegate.swift` by conform to the `Inspectable Protocol`
* Import the `Inspector` framework in `SceneDelegate.swift` of `AppDelegate.swift`, and make sure it conforms to `InspectableProtocol`.
* Assign your class as delegate.

### Scene Delegate Example

``` swift
import UIKit

#if DEBUG
import Inspector

extension SceneDelegate: InspectableProtocol {}
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        #if DEBUG
        // Make your class the Inspector delegate when returning a scene
        Inspector.delegate = self
        #endif
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    (...)
}
```
### App Delegate Example

``` swift
import UIKit
#if DEBUG
import Inspector

extension AppDelegate: InspectableProtocol {}
#endif

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        // Make your class the Inspector delegate when returning a scene
        Inspector.delegate = self
        #endif

        return true
    }

    (...)
}
```

## Pro-tips

### Remove framework files from relases
In your app target, add a `New Run Script Phase`, and then use the following commands to remove all inspector related files from your release builds.

``` sh
# Run Script Phase that removes `Inspector` and all its dependecies from relase builds.

if [ $CONFIGURATION == "Release" ]; then
    echo "Removing Inspector and dependencies from $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/"

    find $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME -name "Inspector*" | grep . | xargs rm -rf
    find $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME -name "UIKeyCommandTableView*" | grep . | xargs rm -rf
    find $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME -name "UIKeyboardAnimatable*" | grep . | xargs rm -rf
    find $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME -name "UIKitOptions*" | grep . | xargs rm -rf
    find $TARGET_BUILD_DIR/$FULL_PRODUCT_NAME -name "ObjectAssociation*" | grep . | xargs rm -rf
fi

```

### Add Custom Actions

![Add Custom Actions](Documentation/custom_actions.png)

``` swift

var inspectorActionGroups: [Inspector.ActionGroup] {
	guard let window = window else { return [] }
	
	let storyboard = UIStoryboard(name: "Main", bundle: nil)
	let vc = storyboard.instantiateInitialViewController()
		                
	return [
		.actionGroup(
			title: "My custom actions",
			actions: [
		    	.action(
		        	title: "Reset",
		           	icon: .exampleActionIcon,
		           	keyCommand: .control(.shift(.key("r"))),
		           	closure: {
		                window.rootViewController = vc
		                window.inspectorManager?.restart()
		            }
				)
			]
		)
	]
}
```


## Credits

`Inspector` is owned and maintained by [Pedro Almeida](https://pedro.am). You can follow him on Twitter at [@ipedro](https://twitter.com/ipedro) for project updates and releases.

## License

`Inspector` is released under the MIT license. [See LICENSE](https://github.com/ipedro/Inspector/blob/master/LICENSE) for details.

