//
//  IQKeyboardReturnKeyHandler.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import IQKeyboardCore

// swiftlint:disable file_length
/**
Manages the return key to work like next/done in a view hierarchy.
*/

@available(iOSApplicationExtension, unavailable)
// swiftlint:disable:next line_length
@available(*, deprecated, message: "Please use `IQKeyboardReturnManager` independently from https://github.com/hackiftekhar/IQKeyboardReturnManager. IQKeyboardReturnKeyHandler will be removed from this library in future release.")
@MainActor
// swiftlint:disable type_body_length
@objcMembers public final class IQKeyboardReturnKeyHandler: NSObject, UITextFieldDelegate, UITextViewDelegate {

    // MARK: Private variables
    private var textInputViewInfoCache: [IQTextInputViewInfoModel] = []

    // MARK: Settings

    /**
     Delegate of textInputView
     */
    public weak var delegate: (any UITextFieldDelegate & UITextViewDelegate)?

    /**
     Set the last textInputView return key type. Default is UIReturnKeyDefault.
     */
    public var lastTextInputViewReturnKeyType: UIReturnKeyType = .default {

        didSet {
            if let activeModel = textInputViewInfoCache.first(where: {
                guard let textInputView = $0.textInputView else {
                    return false
                }
                return textInputView.isFirstResponder
            }), let view: any IQTextInputView = activeModel.textInputView {
                updateReturnKey(textInputView: view)
            }
        }
    }

    public var dismissTextViewOnReturn: Bool = false

    // MARK: Initialization/De-initialization

    public override init() {
        super.init()
    }

    /**
     Add all the textFields available in UIViewController's view.
     */
    @available(*, deprecated, message: "Please use addResponderSubviews(of:recursive:)")
    public init(controller: UIViewController) {
        super.init()

        addResponderSubviews(of: controller.view, recursive: true)
    }

    deinit {

        //        for model in textInputViewInfoCache {
        //            model.restore()
        //        }

        textInputViewInfoCache.removeAll()
    }

    // MARK: Registering/Unregistering textInputView

    /**
     Should pass TextInputView instance. Assign textInputView delegate to self, change it's returnKeyType.

     @param view TextInputView object to register.
     */
    public func add(textInputView: any IQTextInputView) {

        let model = IQTextInputViewInfoModel(textInputView: textInputView)
        textInputViewInfoCache.append(model)

        if let view: UITextField = textInputView as? UITextField {
            view.delegate = self
        } else if let view: UITextView = textInputView as? UITextView {
            view.delegate = self
        }
    }

    /**
     Should pass TextInputView instance. Restore it's textInputView delegate and it's returnKeyType.

     @param view TextInputView object to unregister.
     */
    public func remove(textInputView: any IQTextInputView) {

        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return }

        let model = textInputViewInfoCache.remove(at: index)
        model.restore()
    }

    /**
     Add all the TextInputView responderView's.

     @param view object to register all it's responder subviews.
     */
    public func addResponderSubviews(of view: UIView, recursive: Bool) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            add(textInputView: view)
        }
    }

    /**
     Remove all the TextInputView responderView's.

     @param view object to unregister all it's responder subviews.
     */
    public func removeResponderSubviews(of view: UIView, recursive: Bool) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            remove(textInputView: view)
        }
    }

    @discardableResult
    public func goToNextResponderOrResign(from textInputView: any IQTextInputView) -> Bool {

        guard let textInfoCache: IQTextInputViewInfoModel = nextResponderFromTextInputView(textInputView),
              let textInputView = textInfoCache.textInputView else {
            textInputView.resignFirstResponder()
            return true
        }

        textInputView.becomeFirstResponder()
        return false
    }

    // MARK: Internal Functions

    internal func nextResponderFromTextInputView(_ textInputView: some IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let currentIndex: Int = textInputViewCachedInfoIndex(textInputView),
              currentIndex < textInputViewInfoCache.count - 1 else { return nil }

        let candidates = Array(textInputViewInfoCache[currentIndex+1..<textInputViewInfoCache.count])

        return candidates.first {
            guard let inputView = $0.textInputView,
                  inputView.isUserInteractionEnabled,
                  !inputView.isHidden, inputView.alpha != 0.0
            else { return false }

            return inputView.iqIsEnabled
        }
    }

    internal func textInputViewCachedInfoIndex(_ textInputView: some IQTextInputView) -> Int? {
        return textInputViewInfoCache.firstIndex {
            guard let inputView = $0.textInputView else { return false }
            return inputView == textInputView
        }
    }

    internal func textInputViewCachedInfo(_ textInputView: some IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return nil }
        return textInputViewInfoCache[index]
    }

    internal func updateReturnKey(textInputView: some IQTextInputView) {

        let returnKey: UIReturnKeyType
        if nextResponderFromTextInputView(textInputView) != nil {
            returnKey = .next
        } else {
            returnKey = lastTextInputViewReturnKeyType
        }

        if textInputView.returnKeyType != returnKey {
            // If it's the last textInputView in responder view, else next
            textInputView.returnKeyType = returnKey
            textInputView.reloadInputViews()
        }
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "lastTextInputViewReturnKeyType")
    public var lastTextFieldReturnKeyType: UIReturnKeyType {
        get { lastTextInputViewReturnKeyType }
        set { lastTextInputViewReturnKeyType = newValue }
    }

    @available(*, deprecated, renamed: "add(textInputView:)")
    public func addTextFieldView(_ textInputView: any IQTextInputView) {
        add(textInputView: textInputView)
    }

    @available(*, deprecated, renamed: "remove(textInputView:)")
    public func removeTextFieldView(_ textInputView: any IQTextInputView) {
        remove(textInputView: textInputView)
    }

    @available(*, deprecated, renamed: "addResponderSubviews(of:recursive:)")
    public func addResponderFromView(_ view: UIView, recursive: Bool = true) {
        addResponderSubviews(of: view, recursive: recursive)
    }

    @available(*, deprecated, renamed: "removeResponderSubviews(of:recursive:)")
    public func removeResponderFromView(_ view: UIView, recursive: Bool = true) {
        removeResponderSubviews(of: view, recursive: recursive)
    }

    // MARK: UITextFieldDelegate

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        var returnValue: Bool = true

        if delegate == nil,
           let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            if textFieldDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldBeginEditing(_:))) {
                returnValue = textFieldDelegate.textFieldShouldBeginEditing?(textField) ?? false
            }
        }

        if returnValue {
            updateReturnKey(textInputView: textField)
        }

        return returnValue
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            if textFieldDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldEndEditing(_:))) {
                return textFieldDelegate.textFieldShouldEndEditing?(textField) ?? false
            }
        }

        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidBeginEditing?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector: Selector = #selector((any UITextFieldDelegate).textField(_:shouldChangeCharactersIn:
                                                                                    replacementString:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textField?(textField,
                                                    shouldChangeCharactersIn: range,
                                                    replacementString: string) ?? false
            }
        }
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            if textFieldDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldClear(_:))) {
                return textFieldDelegate.textFieldShouldClear?(textField) ?? false
            }
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        var isReturn: Bool = true

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            if textFieldDelegate.responds(to: #selector((any UITextFieldDelegate).textFieldShouldReturn(_:))) {
                isReturn = textFieldDelegate.textFieldShouldReturn?(textField) ?? false
            }
        }

        if isReturn {
            goToNextResponderOrResign(from: textField)
            return true
        } else {
            return goToNextResponderOrResign(from: textField)
        }
    }

    // MARK: UITextViewDelegate

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        var returnValue: Bool = true

        if delegate == nil,
           let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector((any UITextViewDelegate).textViewShouldBeginEditing(_:))) {
                returnValue = textViewDelegate.textViewShouldBeginEditing?(textView) ?? false
            }
        }

        if returnValue {
            updateReturnKey(textInputView: textView)
        }

        return returnValue
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector((any UITextViewDelegate).textViewShouldEndEditing(_:))) {
                return textViewDelegate.textViewShouldEndEditing?(textView) ?? false
            }
        }

        return true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidEndEditing?(textView)
    }

    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {

        var shouldChange = true

        if delegate == nil {

            if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
                let selector = #selector((any UITextViewDelegate).textView(_:shouldChangeTextIn:replacementText:))
                if textViewDelegate.responds(to: selector) {
                    shouldChange = (textViewDelegate.textView?(textView,
                                                               shouldChangeTextIn: range,
                                                               replacementText: text)) ?? true
                }
            }
        }

        if self.dismissTextViewOnReturn, text == "\n" {
            goToNextResponderOrResign(from: textView)
            return false
        }

        return shouldChange
    }

    public func textViewDidChange(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChange?(textView)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChangeSelection?(textView)
    }

    @available(iOS, deprecated: 17.0)
    public func textView(_ aTextView: UITextView,
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector: Selector = #selector(textView as
                                               (UITextView, URL, NSRange, UITextItemInteraction) -> Bool)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange,
                                                  interaction: interaction) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 17.0)
    public func textView(_ aTextView: UITextView,
                         shouldInteractWith textAttachment: NSTextAttachment,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector: Selector = #selector(textView as
                                               (UITextView, NSTextAttachment, NSRange, UITextItemInteraction)
                                               -> Bool)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange,
                                                  interaction: interaction) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    public func textView(_ aTextView: UITextView,
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector(textView as (UITextView, URL, NSRange) -> Bool)) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    public func textView(_ aTextView: UITextView,
                         shouldInteractWith textAttachment: NSTextAttachment,
                         in characterRange: NSRange) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector(textView as (UITextView, NSTextAttachment, NSRange) -> Bool)) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange) ?? false
            }
        }

        return true
    }

    // MARK: @available(iOS 16.0, *)

    @available(iOS 16.0, *)
    public func textView(_ aTextView: UITextView,
                         editMenuForTextIn range: NSRange,
                         suggestedActions: [UIMenuElement]) -> UIMenu? {

        guard delegate == nil else { return nil }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {

            let selector: Selector = #selector(textView as
                                               (UITextView, NSRange, [UIMenuElement]) -> UIMenu?)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  editMenuForTextIn: range,
                                                  suggestedActions: suggestedActions)
            }
        }

        return nil
    }

    @available(iOS 16.0, *)
    public func textView(_ aTextView: UITextView,
                         willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willPresentEditMenuWith: animator)
    }

    @available(iOS 16.0, *)
    public func textView(_ aTextView: UITextView,
                         willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willDismissEditMenuWith: animator)
    }

#if swift(>=5.9)    // Xcode 15

    // MARK: @available(iOS 17.0, *)

    @available(iOS 17.0, *)
    public func textView(_ aTextView: UITextView,
                         primaryActionFor textItem: UITextItem,
                         defaultAction: UIAction) -> UIAction? {
        guard delegate == nil else { return nil }

        if let textViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector(textView as (UITextView, UITextItem, UIAction) -> UIAction?)) {
                return textViewDelegate.textView?(aTextView,
                                                  primaryActionFor: textItem,
                                                  defaultAction: defaultAction)
            }
        }

        return nil
    }

    @available(iOS 17.0, *)
    public func textView(_ aTextView: UITextView,
                         menuConfigurationFor textItem: UITextItem,
                         defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        guard delegate == nil else { return nil }

        if let textViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector: Selector = #selector(textView as (UITextView, UITextItem, UIMenu)
                                               -> UITextItem.MenuConfiguration?)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  menuConfigurationFor: textItem,
                                                  defaultMenu: defaultMenu)
            }
        }

        return nil
    }

    @available(iOS 17.0, *)
    public func textView(_ textView: UITextView,
                         textItemMenuWillDisplayFor textItem: UITextItem,
                         animator: any UIContextMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillDisplayFor: textItem, animator: animator)
    }

    @available(iOS 17.0, *)
    public func textView(_ textView: UITextView,
                         textItemMenuWillEndFor textItem: UITextItem,
                         animator: any UIContextMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillEndFor: textItem, animator: animator)
    }
#endif

#if swift(>=6.0)    // Xcode 16

    @available(iOS 18.0, *)
    public func textViewWritingToolsWillBegin(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewWritingToolsWillBegin?(textView)
    }

    @available(iOS 18.0, *)
    public func textViewWritingToolsDidEnd(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewWritingToolsDidEnd?(textView)
    }

    @available(iOS 18.0, *)
    public func textView(_ textView: UITextView,
                         writingToolsIgnoredRangesInEnclosingRange enclosingRange: NSRange) -> [NSValue] {
        guard delegate == nil else { return [] }

        if let textViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector(textView as (UITextView, NSRange) -> [NSValue])) {
                return textViewDelegate.textView?(aTextView,
                                                  writingToolsIgnoredRangesInEnclosingRange: enclosingRange)
            }
        }
        return []
    }
#endif
}
// swiftlint:enable type_body_length

@available(iOSApplicationExtension, unavailable)
@MainActor
fileprivate extension UIView {

    func responderSubviews(recursive: Bool) -> [any IQTextInputView] {

        // Array of TextInputViews.
        var textInputViews: [any IQTextInputView] = []
        for view in subviews {

            if let view = view as? IQTextInputView {
                textInputViews.append(view)
            }
            // Sometimes there are hidden or disabled views and textInputView inside them still recorded,
            // so we added some more validations here (Bug ID: #458)
            // Uncommented else (Bug ID: #625)
            else if recursive, !view.subviews.isEmpty {
                let deepResponders = view.responderSubviews(recursive: recursive)
                textInputViews.append(contentsOf: deepResponders)
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textInputViews.sorted(by: { (view1: any IQTextInputView, view2: any IQTextInputView) -> Bool in

            let frame1: CGRect = view1.convert(view1.bounds, to: self)
            let frame2: CGRect = view2.convert(view2.bounds, to: self)

            if frame1.minY != frame2.minY {
                return frame1.minY < frame2.minY
            } else {
                return frame1.minX < frame2.minX
            }
        })
    }
}
// swiftlint:enable file_length
