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

@available(iOSApplicationExtension, unavailable)
@MainActor
private struct AssociatedKeys {
    static var distanceFromKeyboard: Int = 0
    static var ignoreSwitchingByNextPrevious: Int = 0
    static var enableMode: Int = 0
    static var resignOnTouchOutsideMode: Int = 0
}

@available(iOSApplicationExtension, unavailable)
extension UIView: IQKeyboardManagerCompatible {

    public static let defaultKeyboardDistance: CGFloat = CGFloat.greatestFiniteMagnitude
}

@available(iOSApplicationExtension, unavailable)
@available(*, unavailable, renamed: "UIView.defaultKeyboardDistance")
public let kIQUseDefaultKeyboardDistance = CGFloat.greatestFiniteMagnitude

/**
UIView category for managing UITextField/UITextView
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIView {

    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    var distanceFromKeyboard: CGFloat {
        get {
            if let value = objc_getAssociatedObject(base, &AssociatedKeys.distanceFromKeyboard) as? CGFloat {
                return value
            } else {
                return UIView.defaultKeyboardDistance
            }
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.distanceFromKeyboard,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     If ignoreSwitchingByNextPrevious is true then library will ignore this textField/textView
     while moving to other textField/textView using keyboard toolbar next previous buttons.
     Default is false
     */
    var ignoreSwitchingByNextPrevious: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.ignoreSwitchingByNextPrevious,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Override Enable/disable managing distance between keyboard and textField behavior for this particular textField.
     */
    var enableMode: IQEnableMode {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.enableMode) as? IQEnableMode ?? .default
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.enableMode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Override resigns Keyboard on touching outside of UITextField/View behavior for this particular textField.
     */
    var resignOnTouchOutsideMode: IQEnableMode {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.resignOnTouchOutsideMode) as? IQEnableMode ?? .default
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.resignOnTouchOutsideMode,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@objc public extension UIView {
    @available(*, unavailable, renamed: "iq.distanceFromKeyboard")
    var keyboardDistanceFromTextField: CGFloat {
        get { 0 }
        set { }
    }

    @available(*, unavailable, renamed: "iq.ignoreSwitchingByNextPrevious")
    var ignoreSwitchingByNextPrevious: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "iq.enableMode")
    var enableMode: IQEnableMode {
        get { .default }
        set { }
    }

    @available(*, unavailable, renamed: "iq.resignOnTouchOutsideMode")
    var shouldResignOnTouchOutsideMode: IQEnableMode {
        get { .default }
        set { }
    }
}
// swiftlint:enable unused_setter_value
