//
//  IQKeyboardManager+Deprecated.swift
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
@objc public extension IQKeyboardManager {

    @available(*, deprecated, renamed: "keyboardDistance")
    var keyboardDistanceFromTextField: CGFloat {
        get { keyboardDistance }
        set { keyboardDistance = newValue }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    func registerTextFieldViewClass(_ aClass: UIView.Type,
                                    didBeginEditingNotificationName: String,
                                    didEndEditingNotificationName: String) {
    }

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    func unregisterTextFieldViewClass(_ aClass: UIView.Type,
                                      didBeginEditingNotificationName: String,
                                      didEndEditingNotificationName: String) {
    }
}

// swiftlint:disable line_length
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardManager {

    typealias SizeBlock = (_ size: CGSize) -> Void

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    func unregisterKeyboardSizeChange(identifier: AnyHashable) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    var keyboardShowing: Bool { false }

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    var keyboardFrame: CGRect { .zero }
}
// swiftlint:enable line_length
