//
//  IQUIScrollView+Additions.swift
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
    static var ignoreScrollingAdjustment: Int = 0
    static var ignoreContentInsetAdjustment: Int = 0
    static var restoreContentOffset: Int = 0
}

// swiftlint:disable identifier_name
// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
extension UIScrollView: IQKeyboardManagerCompatible {

    // This property is explicitly written otherwise we were having
    // compilation error when archiving
    public var iq: IQKeyboardManagerWrapper<UIView> {
        get { IQKeyboardManagerWrapper(self) }
        set {}
    }
}
// swiftlint:enable unused_setter_value
// swiftlint:enable identifier_name

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManagerWrapper where Base: UIScrollView {

    /**
     If YES, then scrollview will ignore scrolling (simply not scroll it) for adjusting textfield position.
     Default is NO.
     */
    var ignoreScrollingAdjustment: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.ignoreScrollingAdjustment) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.ignoreScrollingAdjustment,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     If YES, then scrollview will ignore content inset adjustment (simply not updating it) when keyboard is shown.
     Default is NO.
     */
    var ignoreContentInsetAdjustment: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.ignoreContentInsetAdjustment) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.ignoreContentInsetAdjustment,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     To set customized distance from keyboard for textField/textView. Can't be less than zero
     */
    var restoreContentOffset: Bool {
        get {
            return objc_getAssociatedObject(base, &AssociatedKeys.restoreContentOffset) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(base, &AssociatedKeys.restoreContentOffset,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@objc public extension UIScrollView {
    @available(*, unavailable, renamed: "iq.ignoreScrollingAdjustment")
    var shouldIgnoreScrollingAdjustment: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "iq.ignoreContentInsetAdjustment")
    var shouldIgnoreContentInsetAdjustment: Bool {
        get { false }
        set { }
    }

    @available(*, unavailable, renamed: "iq.restoreContentOffset")
    var shouldRestoreScrollViewContentOffset: Bool {
        get { false }
        set { }
    }
}
// swiftlint:enable unused_setter_value
