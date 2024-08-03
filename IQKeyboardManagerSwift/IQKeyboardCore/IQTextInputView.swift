//
//  IQTextInputView.swift
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

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public protocol IQTextInputView where Self: UIView, Self: UITextInputTraits {

    @available(iOS 16.0, *)
    @objc var iqIsFindInteractionEnabled: Bool { get }

    @available(iOS 16.0, *)
    @objc var iqFindInteraction: UIFindInteraction? { get }

    @objc var returnKeyType: UIReturnKeyType { get set }
    @objc var keyboardAppearance: UIKeyboardAppearance { get set }

    @objc var iqIsEnabled: Bool { get }

    @objc var inputAccessoryView: UIView? { get set }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension UITextField: IQTextInputView {

    @available(iOS 16.0, *)
    public var iqIsFindInteractionEnabled: Bool { false }

    @available(iOS 16.0, *)
    public var iqFindInteraction: UIFindInteraction? { nil }

    public var iqIsEnabled: Bool { isEnabled }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension UITextView: IQTextInputView {
    @available(iOS 16.0, *)
    public var iqIsFindInteractionEnabled: Bool { isFindInteractionEnabled }

    @available(iOS 16.0, *)
    public var iqFindInteraction: UIFindInteraction? { findInteraction }

    public var iqIsEnabled: Bool { isEditable }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension UISearchBar: IQTextInputView {

    @available(iOS 16.0, *)
    public var iqIsFindInteractionEnabled: Bool { false }

    @available(iOS 16.0, *)
    public var iqFindInteraction: UIFindInteraction? { nil }

    public var iqIsEnabled: Bool {
        if #available(iOS 16.4, *) {
            return isEnabled
        } else {
            return searchTextField.isEnabled
        }
    }
}
