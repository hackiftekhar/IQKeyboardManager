//
//  IQUITextFieldView+Additions.swift
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
import IQKeyboardManagerBaseWrapper

@available(iOSApplicationExtension, unavailable)
@MainActor
private struct AssociatedKeys {
    static var ignoreSwitchingByNextPrevious: Int = 0
}

/**
UIView category for managing UITextField/UITextView
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIView {

    /**
     If ignoreSwitchingByNextPrevious is true then library will ignore this textField/textView
     while moving to other textField/textView using keyboard toolbar next previous buttons.
     Default is false
     */
    var ignoreSwitchingByNextPrevious: Bool {
        get {
            if let base = base {
                return objc_getAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious) as? Bool ?? false
            }
            return false
        }
        set(newValue) {
            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious,
                                         newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

/**
UIView category for managing UITextField/UITextView
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIView {

    /**
    Returns all siblings of the receiver which canBecomeFirstResponder.
    */
    func responderSiblings() -> [UIView] {

        // Array of (UITextField/UITextView's).
        var tempTextFields: [UIView] = []

        //    Getting all siblings
        if let siblings: [UIView] = base?.superview?.subviews {
            for textField in siblings {
                if textField == base || !textField.iq.ignoreSwitchingByNextPrevious,
                    textField.iq.canBecomeFirstResponder() {
                    tempTextFields.append(textField)
                }
            }
        }

        return tempTextFields
    }

    /**
    Returns all deep subViews of the receiver which canBecomeFirstResponder.
    */
    func deepResponderViews() -> [UIView] {

        // Array of (UITextField/UITextView's).
        var textfields: [UIView] = []

        for textField in base?.subviews ?? [] {

            if textField == base || !textField.iq.ignoreSwitchingByNextPrevious,
               textField.iq.canBecomeFirstResponder() {
                textfields.append(textField)
            }
            // Sometimes there are hidden or disabled views and textField inside them still recorded,
            // so we added some more validations here (Bug ID: #458)
            // Uncommented else (Bug ID: #625)
            else if textField.subviews.count != 0,
                    base?.isUserInteractionEnabled == true,
                    base?.isHidden == false, base?.alpha != 0.0 {
                for deepView in textField.iq.deepResponderViews() {
                    textfields.append(deepView)
                }
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textfields.sorted(by: { (view1: UIView, view2: UIView) -> Bool in

            let frame1: CGRect = view1.convert(view1.bounds, to: base)
            let frame2: CGRect = view2.convert(view2.bounds, to: base)

            if frame1.minY != frame2.minY {
                return frame1.minY < frame2.minY
            } else {
                return frame1.minX < frame2.minX
            }
        })
    }

    private func canBecomeFirstResponder() -> Bool {

        var canBecomeFirstResponder: Bool = false

        if base?.conforms(to: (any UITextInput).self) == true {
            //  Setting toolbar to keyboard.
            if let textView: UITextView = base as? UITextView {
                canBecomeFirstResponder = textView.isEditable
            } else if let textField: UITextField = base as? UITextField {
                canBecomeFirstResponder = textField.isEnabled
            }
        }

        if canBecomeFirstResponder {
            canBecomeFirstResponder = base?.isUserInteractionEnabled == true &&
            base?.isHidden == false &&
            base?.alpha != 0.0 &&
            !isAlertViewTextField() &&
            textFieldSearchBar() == nil
        }

        return canBecomeFirstResponder
    }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@objc public extension UIView {
    @available(*, unavailable, renamed: "iq.ignoreSwitchingByNextPrevious")
    var ignoreSwitchingByNextPrevious: Bool {
        get { false }
        set { }
    }
}
// swiftlint:enable unused_setter_value
