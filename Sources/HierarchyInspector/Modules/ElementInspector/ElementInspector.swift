//
//  ElementInspector.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum ElementInspector {
    static var configuration = Configuration()
}

extension ElementInspector {
    struct Configuration {
        let animationDuration: TimeInterval = 0.2
        
        var appearance = Appearance()
    }
}

extension ElementInspector {
    struct Appearance {
        
        var thumbnailBackgroundStyle: ThumbnailBackgroundStyle = .medium
        
        let horizontalMargins: CGFloat = 26
        
        let verticalMargins: CGFloat = 13
        
        var tintColor: UIColor = .systemPurple
        
        var textColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .label
            }
            #endif
            
            return .darkText
        }()
        
        var secondaryTextColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            }
            #endif
            
            return UIColor.darkText.withAlphaComponent(0.6)
        }()
        
        
        var tertiaryTextColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .tertiaryLabel
            }
            #endif
            
            return UIColor.darkText.withAlphaComponent(0.3)
        }()
        
        var margins: NSDirectionalEdgeInsets {
            .margins(
                horizontal: horizontalMargins,
                vertical: verticalMargins
            )
        }
        
        var panelPreferredCompressedSize: CGSize {
            CGSize(
                width: min(UIScreen.main.bounds.width, 414),
                height: .zero
            )
        }
        
        var panelBackgroundColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .secondarySystemBackground
            }
            #endif
            
            return .groupTableViewBackground
        }()
        
        var panelHighlightBackgroundColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .tertiarySystemBackground
            }
            #endif
            
            return .white
        }()
        
        func titleFont(forRelativeDepth relativeDepth: Int) -> UIFont {
            switch relativeDepth {
            case 0:
                return UIFont.preferredFont(forTextStyle: .title3).bold()

            case 1:
                return UIFont.preferredFont(forTextStyle: .body).bold()

            case 2:
                return UIFont.preferredFont(forTextStyle: .callout).bold()

            case 3:
                return UIFont.preferredFont(forTextStyle: .subheadline).bold()

            default:
                return UIFont.preferredFont(forTextStyle: .footnote)
            }
        }
    }
}
