//
//  PropertyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewModelProtocol {
    var inputs: [PropertyInspectorInput] { get }
}

final class PropertyInspectorViewModel: PropertyInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
    
    enum UIViewProperty: CaseIterable, Hashable {
        case contentMode
        case semanticContentAttribute
        case tag
        case isUserInteractionEnabled
        case isMultipleTouchEnabled
        case alpha
        case backgroundColor
        case tintColor
        case isOpaque
        case isHidden
        case clearsContextBeforeDrawing
        case clipsToBounds
        case autoresizesSubviews
    }
    
    lazy var inputs: [PropertyInspectorInput] = UIViewProperty.allCases.compactMap {
        guard let view = reference.view else {
            return nil
        }
        
        switch $0 {
        case .contentMode:
            return .optionSelector(
                title: "content mode",
                options: UIView.ContentMode.allCases,
                selectedIndex: UIView.ContentMode.allCases.firstIndex(of: view.contentMode)
            ) { [weak self] newValue in
                guard
                    let value = newValue,
                    let contentMode = UIView.ContentMode(rawValue: value)
                else {
                    return
                }
                
                self?.reference.view?.contentMode = contentMode
            }
            
        case .semanticContentAttribute:
            return .optionSelector(
                title: "semantic content",
                options: UISemanticContentAttribute.allCases,
                selectedIndex: UISemanticContentAttribute.allCases.firstIndex(of: view.semanticContentAttribute)
            ) { [weak self] newValue in
                guard
                    let value = newValue,
                    let semanticContentAttribute = UISemanticContentAttribute(rawValue: value)
                else {
                    return
                }
                
                self?.reference.view?.semanticContentAttribute = semanticContentAttribute
            }
            
        case .tag:
            return .integerStepper(
                title: "tag",
                value: view.tag,
                range: 0...100,
                stepValue: 1
            ) { [weak self] newValue in
                self?.reference.view?.tag = newValue
            }
            
        case .isUserInteractionEnabled:
            return .toggleButton(
                title: "user interaction enabled",
                isOn: view.isUserInteractionEnabled
            ) { [weak self] newValue in
                self?.reference.view?.isUserInteractionEnabled = newValue
            }
            
        case .isMultipleTouchEnabled:
            return .toggleButton(
                title: "multiple touch",
                isOn: view.isMultipleTouchEnabled
            ) { [weak self] newValue in
                self?.reference.view?.isMultipleTouchEnabled = newValue
            }
            
        case .alpha:
            return .doubleStepper(
                title: "alpha",
                value: Double(view.alpha),
                range: 0...1,
                stepValue: 0.05
            ) { [weak self] newValue in
                self?.reference.view?.alpha = CGFloat(newValue)
            }
            
        case .backgroundColor:
            return .colorPicker(
                title: "background",
                color: view.backgroundColor
            ) { [weak self] newValue in
                self?.reference.view?.backgroundColor = newValue
            }
            
        case .tintColor:
            return .colorPicker(
                title: "tint",
                color: view.tintColor
            ) { [weak self] newValue in
                self?.reference.view?.tintColor = newValue
            }
            
        case .isOpaque:
            return .toggleButton(
                title: "opaque",
                isOn: view.isOpaque
            ) { [weak self] newValue in
                self?.reference.view?.isOpaque = newValue
            }
            
        case .isHidden:
            return .toggleButton(
                title: "hidden",
                isOn: view.isHidden
            ) { [weak self] newValue in
                self?.reference.view?.isHidden = newValue
            }
            
        case .clearsContextBeforeDrawing:
            return .toggleButton(
                title: "clears graphic context",
                isOn: view.clearsContextBeforeDrawing
            ) { [weak self] newValue in
                self?.reference.view?.clearsContextBeforeDrawing = newValue
            }
            
        case .clipsToBounds:
            return .toggleButton(
                title: "clips to bounds",
                isOn: view.clipsToBounds
            ) { [weak self] newValue in
                self?.reference.view?.clipsToBounds = newValue
            }
            
        case .autoresizesSubviews:
            return .toggleButton(
                title: "autoresize subviews",
                isOn: view.autoresizesSubviews
            ) { [weak self] newValue in
                self?.reference.view?.autoresizesSubviews = newValue
            }
        }
    }
}


extension UISemanticContentAttribute: CaseIterable {
    public typealias AllCases = [UISemanticContentAttribute]
    
    public static var allCases: [UISemanticContentAttribute] {
        [
            .unspecified,
            .playback,
            .spatial,
            .forceLeftToRight,
            .forceRightToLeft
        ]
    }
}

extension UISemanticContentAttribute: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unspecified:
            return "unspecified"
            
        case .playback:
            return "playback"
            
        case .spatial:
            return "spatial"
            
        case .forceLeftToRight:
            return "force left to right"
            
        case .forceRightToLeft:
            return "force right to left"
            
        @unknown default:
            return "unknown"
        }
    }
}

extension UIView.ContentMode: CaseIterable {
    public typealias AllCases = [UIView.ContentMode]
    
    public static var allCases: [UIView.ContentMode] {
        [
            .scaleToFill,
            .scaleAspectFit,
            .scaleAspectFill,
            .redraw,
            .center,
            .top,
            .bottom,
            .left,
            .right,
            .topLeft,
            .topRight,
            .bottomLeft,
            .bottomRight
        ]
    }
}

extension UIView.ContentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .scaleToFill:
            return "scale to fill"
            
        case .scaleAspectFit:
            return "scale aspect fit"
            
        case .scaleAspectFill:
            return "scale aspect fill"
            
        case .redraw:
            return "redraw"
            
        case .center:
            return "center"
            
        case .top:
            return "top"
            
        case .bottom:
            return "bottom"
            
        case .left:
            return "left"
            
        case .right:
            return "right"
            
        case .topLeft:
            return "top left"
            
        case .topRight:
            return "top right"
            
        case .bottomLeft:
            return "bottom left"
            
        case .bottomRight:
            return "bottom right"
            
        @unknown default:
            return "unknown"
        }
    }
}
