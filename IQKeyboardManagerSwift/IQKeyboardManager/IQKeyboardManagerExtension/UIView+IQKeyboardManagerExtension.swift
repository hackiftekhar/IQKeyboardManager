//
//  UIView+IQKeyboardManagerExtension.swift
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

@available(iOSApplicationExtension, unavailable)
@MainActor
private struct AssociatedKeys {
    static var distanceFromKeyboard: Int = 0
    static var enableMode: Int = 0
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIView {
    nonisolated static let defaultKeyboardDistance: CGFloat = .greatestFiniteMagnitude
}

@available(iOSApplicationExtension, unavailable)
@available(*, unavailable, renamed: "UIView.defaultKeyboardDistance")
nonisolated public let kIQUseDefaultKeyboardDistance: CGFloat = .greatestFiniteMagnitude

/**
 TextInputView category for managing distance handling
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardExtension where Base: IQTextInputView {

    /**
     To set customized distance from keyboard for textInputView. Can't be less than zero
     */
    var distanceFromKeyboard: CGFloat {
        get {
            if let base = base {
                if let value = objc_getAssociatedObject(base, &AssociatedKeys.distanceFromKeyboard) as? CGFloat {
                    return value
                }
            }
            return UIView.defaultKeyboardDistance
        }
        set(newValue) {
            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.distanceFromKeyboard,
                                         newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /**
     Override Enable/disable managing distance between
     keyboard and textInputView behavior for this particular textInputView.
     */
    var enableMode: IQEnableMode {
        get {
            if let base = base {
                return objc_getAssociatedObject(base, &AssociatedKeys.enableMode) as? IQEnableMode ?? .default
            }
            return .default
        }
        set(newValue) {
            if let base = base {
                objc_setAssociatedObject(base, &AssociatedKeys.enableMode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension UIView {
    @available(*, unavailable, renamed: "iq.distanceFromKeyboard")
    var keyboardDistanceFromTextField: CGFloat {
        get { 0 }
        set { }
    }

    @available(*, unavailable, renamed: "iq.enableMode")
    var enableMode: IQEnableMode {
        get { .default }
        set { }
    }
}
// swiftlint:enable unused_setter_value
