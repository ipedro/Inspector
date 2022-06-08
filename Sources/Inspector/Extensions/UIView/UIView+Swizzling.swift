import UIKit

extension UIView {
    // MARK: - Did Move To didMoveToWindow

    private static let performSwizzling: Void = sizzle(#selector(didMoveToWindow), with: #selector(swizzled_didMoveToWindow))

    @objc func swizzled_didMoveToWindow() {
        swizzled_didMoveToWindow()

        if window == nil {
            Inspector.sharedInstance.contextMenuPresenter?.removeInteraction(from: self)
        }
        else {
            Inspector.sharedInstance.contextMenuPresenter?.addInteraction(to: self)
        }
    }

    private static func sizzle(_ aSelector: Selector, with otherSelector: Selector) {
        let instance = UIView()

        let aClass: AnyClass! = object_getClass(instance)

        let originalMethod = class_getInstanceMethod(aClass, aSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, otherSelector)

        guard
            let originalMethod = originalMethod,
            let swizzledMethod = swizzledMethod
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    static func startSwizzling() {
        _ = performSwizzling
    }
}
