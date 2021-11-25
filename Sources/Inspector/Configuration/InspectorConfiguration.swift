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

public struct InspectorConfiguration {
    public var appearance: Appearance = .init()

    public var keyCommands: KeyCommandSettings = .init()

    public var snapshotExpirationTimeInterval: TimeInterval = 0.5

    public var showAllViewSearchQuery: String = "*"

    public var nonInspectableClassNames: [String] = []

    public var isSwizzlingEnabled: Bool

    var colorStyle: InspectorColorStyle {
        guard let keyWindow = Inspector.host?.keyWindow else { return .dark }

        if #available(iOS 13.0, *) {
            switch (keyWindow.overrideUserInterfaceStyle, keyWindow.traitCollection.userInterfaceStyle) {
            case (.dark, _),
                 (.unspecified, .dark):
                return .dark
            default:
                return .light
            }
        }

        return .dark
    }

    let knownSystemContainers: [String] = [
        "UIDropShadowView",
        "UIEditingOverlayViewController",
        "UILayoutContainerView",
        "UITransitionView",
        "UIWindow",
        // Navigaiton
        "UINavigationTransitionView",
        "UIViewControllerWrapperView",
        // Swift UI
        "HostingScrollView",
        "PlatformGroupContainer",
        "PlatformViewHost",
        "_UIHostingView",
    ]

    let blockLists = BlockLists()
}

extension InspectorConfiguration {
    struct BlockLists {
        var contextMenuInteraction: [String] = [
            "UIDropShadowView",
            "UITransitionView",
            "UIWindow",
            "_UIModernBarButton",
        ]

        var inspectorViewHost: [String] = [
            "UIEditingOverlayGestureView",
            "UIInputSetContainerView",
            "UIRemoteKeyboardWindow",
            "UITableViewCellContentView",
            "UITextEffectsWindow",
            "_UIPageViewControllerContentView",
            "_UIQueuingScrollView",
            "UIVisualEffectView"
        ]

        var inspectorSuperviewHost: [String] = [
            "_UIQueuingScrollView",
            "UIButton"
        ]

        var propertyNames = [
            "UINavigationBar._contentViewHidden",
            "UITextView.PINEntrySeparatorIndexes",
            "UITextView.acceptsDictationSearchResults",
            "UITextView.acceptsEmoji",
            "UITextView.acceptsFloatingKeyboard",
            "UITextView.acceptsInitialEmojiKeyboard",
            "UITextView.acceptsPayloads",
            "UITextView.acceptsSplitKeyboard",
            "UITextView.autocapitalizationType",
            "UITextView.autocorrectionContext",
            "UITextView.autocorrectionType",
            "UITextView.contentsIsSingleValue",
            "UITextView.deferBecomingResponder",
            "UITextView.disableHandwritingKeyboard",
            "UITextView.disableInputBars",
            "UITextView.disablePrediction",
            "UITextView.displaySecureEditsUsingPlainText",
            "UITextView.displaySecureTextUsingPlainText",
            "UITextView.emptyContentReturnKeyType",
            "UITextView.enablesReturnKeyAutomatically",
            "UITextView.enablesReturnKeyOnNonWhiteSpaceContent",
            "UITextView.floatingKeyboardEdgeInsets",
            "UITextView.forceDefaultDictationInfo",
            "UITextView.forceDictationKeyboardType",
            "UITextView.forceFloatingKeyboard",
            "UITextView.hasDefaultContents",
            "UITextView.hidePrediction",
            "UITextView.inputContextHistory",
            "UITextView.insertionPointColor",
            "UITextView.insertionPointWidth",
            "UITextView.isCarPlayIdiom",
            "UITextView.isSingleLineDocument",
            "UITextView.keyboardAppearance",
            "UITextView.keyboardType",
            "UITextView.learnsCorrections",
            "UITextView.loadKeyboardsForSiriLanguage",
            "UITextView.passwordRules",
            "UITextView.preferOnlineDictation",
            "UITextView.preferredKeyboardStyle",
            "UITextView.recentInputIdentifier",
            "UITextView.responseContext",
            "UITextView.returnKeyGoesToNextResponder",
            "UITextView.returnKeyType",
            "UITextView.selectionBarColor",
            "UITextView.selectionBorderColor",
            "UITextView.selectionBorderWidth",
            "UITextView.selectionCornerRadius",
            "UITextView.selectionDragDotImage",
            "UITextView.selectionEdgeInsets",
            "UITextView.selectionHighlightColor",
            "UITextView.shortcutConversionType",
            "UITextView.showDictationButton",
            "UITextView.smartDashesType",
            "UITextView.smartInsertDeleteType",
            "UITextView.smartQuotesType",
            "UITextView.spellCheckingType",
            "UITextView.supplementalLexicon",
            "UITextView.supplementalLexiconAmbiguousItemIcon",
            "UITextView.suppressReturnKeyStyling",
            "UITextView.textContentType",
            "UITextView.textLoupeVisibility",
            "UITextView.textScriptType",
            "UITextView.textSelectionBehavior",
            "UITextView.textSuggestionDelegate",
            "UITextView.textTrimmingSet",
            "UITextView.underlineColorForSpelling",
            "UITextView.underlineColorForTextAlternatives",
            "UITextView.useAutomaticEndpointing",
            "UITextView.useInterfaceLanguageForLocalization",
            "UITextView.validTextRange",
            "UITextField.textTrimmingSet",
            "WKContentView._wk_printedDocument",
            "WKWebView._wk_printedDocument"
        ]
    }
}
