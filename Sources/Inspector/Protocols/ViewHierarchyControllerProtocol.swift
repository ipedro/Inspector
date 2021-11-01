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

import UIKit

/// A protocol that maps the public properties of a UIViewController.
protocol ViewHierarchyControllerProtocol {
    var className: String { get }
    var classNameWithoutQualifiers: String{ get }
    var additionalSafeAreaInsets: UIEdgeInsets { get }
    var definesPresentationContext: Bool { get }
    var disablesAutomaticKeyboardDismissal: Bool { get }
    var edgesForExtendedLayout: UIRectEdge { get }
    var editButtonItem: UIBarButtonItem { get }
    var extendedLayoutIncludesOpaqueBars: Bool { get }
    var focusGroupIdentifier: String? { get }
    var isBeingPresented: Bool { get }
    var isEditing: Bool { get }
    var isModalInPresentation: Bool { get }
    var isSystemContainer: Bool { get }
    var isViewLoaded: Bool { get }
    var modalPresentationStyle: UIModalPresentationStyle { get }
    var modalTransitionStyle: UIModalTransitionStyle { get }
    var navigationItem: UINavigationItem { get }
    var nibName: String? { get }
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle { get }
    var performsActionsWhilePresentingModally: Bool { get }
    var preferredContentSize: CGSize { get }
    var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { get }
    var prefersHomeIndicatorAutoHidden: Bool { get }
    var prefersPointerLocked: Bool { get }
    var prefersStatusBarHidden: Bool { get }
    var providesPresentationContextTransitionStyle: Bool { get }
    var restorationClassName: String? { get }
    var restorationIdentifier: String? { get }
    var restoresFocusAfterTransition: Bool { get }
    var shouldAutomaticallyForwardAppearanceMethods: Bool { get }
    var systemMinimumLayoutMargins: NSDirectionalEdgeInsets { get }
    var title: String? { get }
    var traitCollection: UITraitCollection { get }
    var viewRespectsSystemMinimumLayoutMargins: Bool { get }
}
