//
//  IQKeyboardManager+Resign.swift
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

    @MainActor
    private struct AssociatedKeys {
        static var resignHandler: Int = 0
    }

    internal var resignHandler: IQKeyboardResignHandler {
        if let object = objc_getAssociatedObject(self, &AssociatedKeys.resignHandler)
            as? IQKeyboardResignHandler {
            return object
        }

        let object: IQKeyboardResignHandler = .init()
        objc_setAssociatedObject(self, &AssociatedKeys.resignHandler,
                                 object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return object
    }

    /**
     Resigns Keyboard on touching outside TextInputView. Default is NO.
     */
    var resignOnTouchOutside: Bool {
        get { resignHandler.resignOnTouchOutside }
        set { resignHandler.resignOnTouchOutside = newValue }
    }

    /** TapGesture to resign keyboard on view's touch.
     It's a readonly property and exposed only for adding/removing dependencies
     if your added gesture does have collision with this one
     */
    var resignGesture: UITapGestureRecognizer {
        get { resignHandler.resignGesture }
        set { resignHandler.resignGesture = newValue }
    }

    /**
     Disabled classes to ignore resignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    var disabledTouchResignedClasses: [UIViewController.Type] {
        get { resignHandler.disabledTouchResignedClasses }
        set { resignHandler.disabledTouchResignedClasses = newValue }
    }

    /**
     Enabled classes to forcefully enable 'resignOnTouchOutside' property.
     Class should be kind of UIViewController
     . If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    var enabledTouchResignedClasses: [UIViewController.Type] {
        get { resignHandler.enabledTouchResignedClasses }
        set { resignHandler.enabledTouchResignedClasses = newValue }
    }

    /**
     if resignOnTouchOutside is enabled then you can customize the behavior
     to not recognize gesture touches on some specific view subclasses.
     Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    var touchResignedGestureIgnoreClasses: [UIView.Type] {
        get { resignHandler.touchResignedGestureIgnoreClasses }
        set { resignHandler.touchResignedGestureIgnoreClasses = newValue }
    }

    /**
     Resigns currently first responder field.
     */
    @discardableResult
    func resignFirstResponder() -> Bool {
        resignHandler.resignFirstResponder()
    }
}
