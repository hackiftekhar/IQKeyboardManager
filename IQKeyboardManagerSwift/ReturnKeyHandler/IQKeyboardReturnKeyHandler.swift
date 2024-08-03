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

/**
Manages the return key to work like next/done in a view hierarchy.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQKeyboardReturnKeyHandler: NSObject {

    // MARK: Private variables
    private var textInputViewInfoCache: [IQTextInputViewInfoModel] = []

    // MARK: Settings

    /**
     Delegate of textField/textView.
     */
    @objc public weak var delegate: (any UITextFieldDelegate & UITextViewDelegate)?

    @objc public var dismissTextViewOnReturn: Bool = false

    /**
     Set the last textfield return key type. Default is UIReturnKeyDefault.
     */
    @objc public var lastTextFieldReturnKeyType: UIReturnKeyType = UIReturnKeyType.default {

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

    // MARK: Initialization/De-initialization

    @objc public override init() {
        super.init()
    }

    /**
     Add all the textFields available in UIViewController's view.
     */
    @objc public init(controller: UIViewController) {
        super.init()

        addResponderFromView(controller.view)
    }

    deinit {

        //        for model in textFieldInfoCache {
        //            model.restore()
        //        }

        textInputViewInfoCache.removeAll()
    }
}

// MARK: Registering/Unregistering textFieldView

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardReturnKeyHandler {

    /**
     Should pass UITextField/UITextView instance. Assign textFieldView delegate to self, change it's returnKeyType.

     @param view UITextField/UITextView object to register.
     */
    @objc func addTextFieldView(_ textInputView: any IQTextInputView) {

        let model = IQTextInputViewInfoModel(textInputView: textInputView)
        textInputViewInfoCache.append(model)

        if let view: UITextField = textInputView as? UITextField {
            view.delegate = self
        } else if let view: UITextView = textInputView as? UITextView {
            view.delegate = self
        }
    }

    /**
     Should pass UITextField/UITextView instance. Restore it's textFieldView delegate and it's returnKeyType.

     @param view UITextField/UITextView object to unregister.
     */
    @objc func removeTextFieldView(_ textInputView: any IQTextInputView) {

        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return }

        let model = textInputViewInfoCache.remove(at: index)
        model.restore()
    }

    /**
    Add all the UITextField/UITextView responderView's.

    @param view UIView object to register all it's responder subviews.
    */
    @objc func addResponderFromView(_ view: UIView, recursive: Bool = true) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            addTextFieldView(view)
        }
    }

    /**
    Remove all the UITextField/UITextView responderView's.

    @param view UIView object to unregister all it's responder subviews.
    */
    @objc func removeResponderFromView(_ view: UIView, recursive: Bool = true) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            removeTextFieldView(view)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardReturnKeyHandler {
    @discardableResult
    func goToNextResponderOrResign(from textInputView: any IQTextInputView) -> Bool {

        guard let textInfoCache: IQTextInputViewInfoModel = nextResponderFromTextInputView(textInputView),
              let textInputView = textInfoCache.textInputView else {
            textInputView.resignFirstResponder()
            return true
        }

        textInputView.becomeFirstResponder()
        return false
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardReturnKeyHandler {

    func nextResponderFromTextInputView(_ textInputView: any IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let currentIndex: Int = textInputViewCachedInfoIndex(textInputView),
                currentIndex < textInputViewInfoCache.count - 1 else { return nil }

        let candidates: [IQTextInputViewInfoModel] = Array(textInputViewInfoCache[currentIndex+1..<textInputViewInfoCache.count])

        return candidates.first {
            guard let inputView = $0.textInputView,
                  inputView.isUserInteractionEnabled,
                  !inputView.isHidden, inputView.alpha != 0.0
            else { return false }

            return inputView.iqIsEnabled
        }
    }

    func textInputViewCachedInfoIndex(_ textInputView: any IQTextInputView) -> Int? {
        return textInputViewInfoCache.firstIndex {
            guard let inputView = $0.textInputView else { return false }
            return inputView == textInputView
        }
    }

    func textInputViewCachedInfo(_ textInputView: any IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return nil }
        return textInputViewInfoCache[index]
    }

    func updateReturnKey(textInputView: any IQTextInputView) {

        let returnKey: UIReturnKeyType
        if nextResponderFromTextInputView(textInputView) != nil {
            returnKey = .next
        } else {
            returnKey = lastTextFieldReturnKeyType
        }

        if textInputView.returnKeyType != returnKey {
            // If it's the last textInputView in responder view, else next
            textInputView.returnKeyType = returnKey
            textInputView.reloadInputViews()
        }
    }
}

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
