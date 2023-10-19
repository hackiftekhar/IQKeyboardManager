//
//  IQTextFieldViewInfo.swift
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
public struct IQTextFieldViewInfo: Equatable {

    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.textFieldView == rhs.textFieldView &&
        lhs.name == rhs.name
    }

    @MainActor
    @objc public enum Name: Int {
        case beginEditing
        case endEditing
    }

    public let name: Name

    public let textFieldView: UIView

    public init?(notification: Notification?, name: Name) {
        guard let view: UIView = notification?.object as? UIView else {
            return nil
        }

        guard !view.iq.isAlertViewTextField() else {
            return nil
        }

        self.name = name
        textFieldView = view
    }
}
