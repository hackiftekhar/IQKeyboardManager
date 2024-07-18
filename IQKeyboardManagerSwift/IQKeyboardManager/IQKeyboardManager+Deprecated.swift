//
//  IQKeyboardManager.swift
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

// swiftlint:disable unused_setter_value
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "resignOnTouchOutside")
    @objc var shouldResignOnTouchOutside: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    @objc func registerTextFieldViewClass(_ aClass: UIView.Type,
                                          didBeginEditingNotificationName: String,
                                          didEndEditingNotificationName: String) {
    }

    @available(*, unavailable, message: "This feature has been removed due to few compatibility problems")
    @objc func unregisterTextFieldViewClass(_ aClass: UIView.Type,
                                            didBeginEditingNotificationName: String,
                                            didEndEditingNotificationName: String) {
    }
}

@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    @available(*, unavailable, renamed: "keyboardConfiguration.overrideAppearance")
    @objc var overrideKeyboardAppearance: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "keyboardConfiguration.appearance")
    @objc var keyboardAppearance: UIKeyboardAppearance {
        get { .default }
        set { }
    }
}

// swiftlint:disable line_length
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    typealias SizeBlock = (_ size: CGSize) -> Void

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc func unregisterKeyboardSizeChange(identifier: AnyHashable) {}

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc var keyboardShowing: Bool { false }

    @available(*, unavailable, message: "This feature has been moved to IQKeyboardListener, use it directly by creating new instance")
    @objc var keyboardFrame: CGRect { .zero }
}
// swiftlint:enable line_length
// swiftlint:enable unused_setter_value
