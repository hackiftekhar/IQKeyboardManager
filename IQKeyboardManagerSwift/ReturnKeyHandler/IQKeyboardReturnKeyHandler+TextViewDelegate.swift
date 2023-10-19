//
//  IQKeyboardReturnKeyHandler+TextViewDelegate.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// MARK: UITextViewDelegate
@available(iOSApplicationExtension, unavailable)
extension IQKeyboardReturnKeyHandler: UITextViewDelegate {

    @objc public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(UITextViewDelegate.textViewShouldBeginEditing(_:))) {
                    return unwrapDelegate.textViewShouldBeginEditing?(textView) ?? false
                }
            }
        }

        return true
    }

    @objc public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(UITextViewDelegate.textViewShouldEndEditing(_:))) {
                    return unwrapDelegate.textViewShouldEndEditing?(textView) ?? false
                }
            }
        }

        return true
    }

    @objc public func textViewDidBeginEditing(_ textView: UITextView) {
        updateReturnKeyTypeOnTextField(textView)

        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidBeginEditing?(textView)
    }

    @objc public func textViewDidEndEditing(_ textView: UITextView) {

        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidEndEditing?(textView)
    }

    @objc public func textView(_ textView: UITextView,
                               shouldChangeTextIn range: NSRange,
                               replacementText text: String) -> Bool {

        var isReturn = true

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                let selector: Selector = #selector(UITextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))
                if unwrapDelegate.responds(to: selector) {
                    isReturn = (unwrapDelegate.textView?(textView,
                                                         shouldChangeTextIn: range,
                                                         replacementText: text)) ?? false
                }
            }
        }

        if isReturn, text == "\n" {
            isReturn = goToNextResponderOrResign(textView)
        }

        return isReturn
    }

    @objc public func textViewDidChange(_ textView: UITextView) {

        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChange?(textView)
    }

    @objc public func textViewDidChangeSelection(_ textView: UITextView) {

        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChangeSelection?(textView)
    }

    @objc public func textView(_ aTextView: UITextView,
                               shouldInteractWith URL: URL,
                               in characterRange: NSRange,
                               interaction: UITextItemInteraction) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                let selector: Selector = #selector(textView as
                                                   (UITextView, URL, NSRange, UITextItemInteraction) -> Bool)
                if unwrapDelegate.responds(to: selector) {
                    return unwrapDelegate.textView?(aTextView,
                                                    shouldInteractWith: URL,
                                                    in: characterRange,
                                                    interaction: interaction) ?? false
                }
            }
        }

        return true
    }

    @objc public func textView(_ aTextView: UITextView,
                               shouldInteractWith textAttachment: NSTextAttachment,
                               in characterRange: NSRange,
                               interaction: UITextItemInteraction) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                let selector: Selector = #selector(textView as
                                                   (UITextView, NSTextAttachment, NSRange, UITextItemInteraction)
                                                   -> Bool)
                if unwrapDelegate.responds(to: selector) {
                    return unwrapDelegate.textView?(aTextView,
                                                    shouldInteractWith: textAttachment,
                                                    in: characterRange,
                                                    interaction: interaction) ?? false
                }
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    @objc public func textView(_ aTextView: UITextView,
                               shouldInteractWith URL: URL,
                               in characterRange: NSRange) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, URL, NSRange) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView,
                                                    shouldInteractWith: URL,
                                                    in: characterRange) ?? false
                }
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    @objc public func textView(_ aTextView: UITextView,
                               shouldInteractWith textAttachment: NSTextAttachment,
                               in characterRange: NSRange) -> Bool {

        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, NSTextAttachment, NSRange) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView,
                                                    shouldInteractWith: textAttachment,
                                                    in: characterRange) ?? false
                }
            }
        }

        return true
    }
}

#if swift(>=5.7)
@available(iOS 16.0, *)
@available(iOSApplicationExtension, unavailable)
extension IQKeyboardReturnKeyHandler {
    public func textView(_ aTextView: UITextView,
                         editMenuForTextIn range: NSRange,
                         suggestedActions: [UIMenuElement]) -> UIMenu? {
        if delegate == nil {

            if let unwrapDelegate: UITextViewDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {

                let selector: Selector = #selector(textView as
                                                   (UITextView, NSRange, [UIMenuElement]) -> UIMenu?)
                if unwrapDelegate.responds(to: selector) {
                    return unwrapDelegate.textView?(aTextView,
                                                    editMenuForTextIn: range,
                                                    suggestedActions: suggestedActions)
                }
            }
        }

        return nil
    }

    public func textView(_ aTextView: UITextView, willPresentEditMenuWith animator: UIEditMenuInteractionAnimating) {
        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willPresentEditMenuWith: animator)
    }

    public func textView(_ aTextView: UITextView, willDismissEditMenuWith animator: UIEditMenuInteractionAnimating) {
        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willDismissEditMenuWith: animator)
    }
}
#endif

#if swift(>=5.9)
@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
extension IQKeyboardReturnKeyHandler {

    public func textView(_ aTextView: UITextView,
                         primaryActionFor textItem: UITextItem,
                         defaultAction: UIAction) -> UIAction? {
        if delegate == nil {

            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, UITextItem, UIAction) -> UIAction?)) {
                    return unwrapDelegate.textView?(aTextView,
                                                    primaryActionFor: textItem,
                                                    defaultAction: defaultAction)
                }
            }
        }

        return nil
    }

    public func textView(_ aTextView: UITextView,
                         menuConfigurationFor textItem: UITextItem,
                         defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        if delegate == nil {

            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                let selector: Selector = #selector(textView as (UITextView, UITextItem, UIMenu)
                                                   -> UITextItem.MenuConfiguration?)
                if unwrapDelegate.responds(to: selector) {
                    return unwrapDelegate.textView?(aTextView,
                                                    menuConfigurationFor: textItem,
                                                    defaultMenu: defaultMenu)
                }
            }
        }

        return nil
    }

    public func textView(_ textView: UITextView,
                         textItemMenuWillDisplayFor textItem: UITextItem,
                         animator: UIContextMenuInteractionAnimating) {
        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillDisplayFor: textItem, animator: animator)
    }

    public func textView(_ textView: UITextView,
                         textItemMenuWillEndFor textItem: UITextItem,
                         animator: UIContextMenuInteractionAnimating) {
        var aDelegate: UITextViewDelegate? = delegate

        if aDelegate == nil {

            if let model = textFieldViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillEndFor: textItem, animator: animator)
    }
}
#endif
