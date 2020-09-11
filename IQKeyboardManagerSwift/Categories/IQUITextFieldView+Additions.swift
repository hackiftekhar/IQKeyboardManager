//
//  IQUITextFieldView+Additions.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-20 Iftekhar Qurashi.
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

// import Foundation - UIKit contains Foundation
import UIKit

/**
Uses default keyboard distance for textField.
*/
public let kIQUseDefaultKeyboardDistance = CGFloat.greatestFiniteMagnitude

/**
UIView category for managing UITextField/UITextView
*/
@objc public extension UIView {

    private struct AssociatedKeys {
        static var keyboardDistanceFromTextField = "keyboardDistanceFromTextField"
        static var ignoreSwitchingByNextPrevious = "ignoreSwitchingByNextPrevious"
        static var enableMode = "enableMode"
        static var shouldResignOnTouchOutsideMode = "shouldResignOnTouchOutsideMode"
    }

    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    var keyboardDistanceFromTextField: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardDistanceFromTextField) as? CGFloat ?? kIQUseDefaultKeyboardDistance
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardDistanceFromTextField, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     If shouldIgnoreSwitchingByNextPrevious is true then library will ignore this textField/textView while moving to other textField/textView using keyboard toolbar next previous buttons. Default is false
     */
    var ignoreSwitchingByNextPrevious: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ignoreSwitchingByNextPrevious) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.ignoreSwitchingByNextPrevious, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Override Enable/disable managing distance between keyboard and textField behaviour for this particular textField.
     */
    var enableMode: IQEnableMode {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.enableMode) as? IQEnableMode ?? .default
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.enableMode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Override resigns Keyboard on touching outside of UITextField/View behaviour for this particular textField.
     */
    var shouldResignOnTouchOutsideMode: IQEnableMode {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shouldResignOnTouchOutsideMode) as? IQEnableMode ?? .default
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldResignOnTouchOutsideMode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
