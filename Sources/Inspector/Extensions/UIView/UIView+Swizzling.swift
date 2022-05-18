import UIKit

extension UIView {
    // MARK: - Did Move To Superview

    @objc func inspector_swizzledLayoutSubviews() {
        inspector_swizzledLayoutSubviews()

        Inspector.sharedInstance.contextMenuPresenter?.addInteraction(to: self)
    }

    private static let swizzleLayoutSubviewsImplementation: Void = {
        let instance: UIView = UIView()

        let aClass: AnyClass! = object_getClass(instance)

        let originalMethod = class_getInstanceMethod(aClass, #selector(layoutSubviews))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(UIView.inspector_swizzledLayoutSubviews))

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
