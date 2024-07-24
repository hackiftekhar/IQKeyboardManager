//
//  IQKeyboardReturnKeyHandler.swift
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

/**
Manages the return key to work like next/done in a view hierarchy.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQKeyboardReturnKeyHandler: NSObject {

    // MARK: Settings

    /**
    Delegate of textField/textView.
    */
    @objc public weak var delegate: (any UITextFieldDelegate & UITextViewDelegate)?

    /**
    Set the last textfield return key type. Default is UIReturnKeyDefault.
    */
    @objc public var lastTextFieldReturnKeyType: UIReturnKeyType = UIReturnKeyType.default {

        didSet {
            for model in textFieldInfoCache {
                if let view: UIView = model.textFieldView {
                    updateReturnKeyTypeOnTextField(view)
                }
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

        textFieldInfoCache.removeAll()
    }

    // MARK: Private variables
    private var textFieldInfoCache: [IQTextFieldViewInfoModel] = []

    // MARK: Private Functions
    internal func textFieldViewCachedInfo(_ textField: UIView) -> IQTextFieldViewInfoModel? {

        for model in textFieldInfoCache {

            if let view: UIView = model.textFieldView {
                if view == textField {
                    return model
                }
            }
        }

        return nil
    }

    internal func updateReturnKeyTypeOnTextField(_ view: UIView) {

        guard let index: Int = textFieldInfoCache.firstIndex(where: { $0.textFieldView == view}) else { return }

        let isLast: Bool = index == textFieldInfoCache.count - 1

        let returnKey: UIReturnKeyType = isLast ? lastTextFieldReturnKeyType: UIReturnKeyType.next
        if let view: UITextField = view as? UITextField, view.returnKeyType != returnKey {

            // If it's the last textInputView in responder view, else next
            view.returnKeyType = returnKey
            view.reloadInputViews()
        } else if let view: UITextView = view as? UITextView, view.returnKeyType != returnKey {

            // If it's the last textInputView in responder view, else next
            view.returnKeyType = returnKey
            view.reloadInputViews()
        }
    }

    // MARK: Registering/Unregistering textFieldView

    /**
    Should pass UITextField/UITextView instance. Assign textFieldView delegate to self, change it's returnKeyType.

    @param view UITextField/UITextView object to register.
    */
    @objc public func addTextFieldView(_ view: UIView) {

        if let textField: UITextField = view as? UITextField {
            let model = IQTextFieldViewInfoModel(textField: textField)
            textFieldInfoCache.append(model)
            textField.delegate = self

        } else if let textView: UITextView = view as? UITextView {
            let model = IQTextFieldViewInfoModel(textView: textView)
            textFieldInfoCache.append(model)
            textView.delegate = self
        }
    }

    /**
    Should pass UITextField/UITextView instance. Restore it's textFieldView delegate and it's returnKeyType.
    
    @param view UITextField/UITextView object to unregister.
    */
    @objc public func removeTextFieldView(_ view: UIView) {

        if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(view) {
            model.restore()

            if let index: Int = textFieldInfoCache.firstIndex(where: { $0.textFieldView == view}) {
                textFieldInfoCache.remove(at: index)
            }
        }
    }

    /**
    Add all the UITextField/UITextView responderView's.
    
    @param view UIView object to register all it's responder subviews.
    */
    @objc public func addResponderFromView(_ view: UIView, recursive: Bool = true) {

        let textFields: [UIView]
        if recursive {
            textFields = view.deepResponderSubviews()
        } else {
            textFields = view.responderSubviews()
        }

        for textField in textFields {

            addTextFieldView(textField)
        }
    }

    /**
    Remove all the UITextField/UITextView responderView's.
    
    @param view UIView object to unregister all it's responder subviews.
    */
    @objc public func removeResponderFromView(_ view: UIView, recursive: Bool = true) {

        let textFields: [UIView]
        if recursive {
            textFields = view.deepResponderSubviews()
        } else {
            textFields = view.responderSubviews()
        }

        for textField in textFields {

            removeTextFieldView(textField)
        }
    }

    @discardableResult
    internal func goToNextResponderOrResign(_ view: UIView) -> Bool {

        guard let index: Int = textFieldInfoCache.firstIndex(where: { $0.textFieldView == view}) else { return false }

        let isNotLast: Bool = index != textFieldInfoCache.count - 1

        if isNotLast, let textFieldView = textFieldInfoCache[index+1].textFieldView {
            textFieldView.becomeFirstResponder()
            return false
        } else {
            view.resignFirstResponder()
            return true
        }
    }
}

fileprivate extension UIView {

    func responderSubviews() -> [UIView] {

        // Array of TextInputViews.
        var textInputViews: [UIView] = []

        for view in subviews {

            var canBecomeFirstResponder: Bool = false

            if view.conforms(to: (any UITextInput).self) == true {
                //  Setting toolbar to keyboard.
                if let view: UITextView = view as? UITextView {
                    canBecomeFirstResponder = view.isEditable
                } else if let view: UITextField = view as? UITextField {
                    canBecomeFirstResponder = view.isEnabled
                }
            }

            // Sometimes there are hidden or disabled views and textInputView inside them still recorded,
            // so we added some more validations here
            if canBecomeFirstResponder,
               self.isUserInteractionEnabled == true,
               self.isHidden == false, self.alpha != 0.0 {
                textInputViews.append(view)
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textInputViews.sorted(by: { (view1: UIView, view2: UIView) -> Bool in

            let frame1: CGRect = view1.convert(view1.bounds, to: self)
            let frame2: CGRect = view2.convert(view2.bounds, to: self)

            if frame1.minY != frame2.minY {
                return frame1.minY < frame2.minY
            } else {
                return frame1.minX < frame2.minX
            }
        })
    }

    func deepResponderSubviews() -> [UIView] {

        // Array of TextInputViews.
        var textInputViews: [UIView] = []

        for view in subviews {

            var canBecomeFirstResponder: Bool = false

            if view.conforms(to: (any UITextInput).self) == true {
                //  Setting toolbar to keyboard.
                if let view: UITextView = view as? UITextView {
                    canBecomeFirstResponder = view.isEditable
                } else if let view: UITextField = view as? UITextField {
                    canBecomeFirstResponder = view.isEnabled
                }
            }

            if canBecomeFirstResponder {
                textInputViews.append(view)
            }
            // Sometimes there are hidden or disabled views and textInputView inside them still recorded,
            // so we added some more validations here (Bug ID: #458)
            // Uncommented else (Bug ID: #625)
            else if view.subviews.count != 0,
                    self.isUserInteractionEnabled == true,
                    self.isHidden == false, self.alpha != 0.0 {
                for deepView in view.deepResponderSubviews() {
                    textInputViews.append(deepView)
                }
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textInputViews.sorted(by: { (view1: UIView, view2: UIView) -> Bool in

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
