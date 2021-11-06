import UIKit

@available(iOS 13.0, *)
extension UIView {
    // MARK: - Did Move To Superview

    @objc func inspector_swizzledMethod() {
        inspector_swizzledMethod()

        Inspector.manager.addInteraction(to: self)
    }

    private static let swizzleLayoutSubviewsImplementation: Void = {
        let instance: UIView = UIView()

        let aClass: AnyClass! = object_getClass(instance)

        let originalMethod = class_getInstanceMethod(aClass, #selector(layoutSubviews))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(UIView.inspector_swizzledMethod))

        guard
            let originalMethod = originalMethod,
            let swizzledMethod = swizzledMethod
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static func startSwizzling() {
        _ = swizzleLayoutSubviewsImplementation
    }
}
