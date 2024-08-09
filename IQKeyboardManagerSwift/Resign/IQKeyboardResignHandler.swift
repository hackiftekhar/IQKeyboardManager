//
//  IQKeyboardResignHandler.swift
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
import IQTextInputViewNotification

@available(iOSApplicationExtension, unavailable)
@MainActor
@objcMembers internal final class IQKeyboardResignHandler: NSObject {

    let textInputViewObserver: IQTextInputViewNotification = .init()

    /**
     Resigns Keyboard on touching outside of TextInputView. Default is NO.
    */
    public var resignOnTouchOutside: Bool = false {

        didSet {
            resignGesture.isEnabled = privateResignOnTouchOutside()

            IQKeyboardManager.shared.showLog("resignOnTouchOutside: \(resignOnTouchOutside ? "Yes" : "No")")
        }
    }

    /** TapGesture to resign keyboard on view's touch.
     It's a readonly property and exposed only for adding/removing dependencies
     if your added gesture does have collision with this one
     */
    public var resignGesture: UITapGestureRecognizer = .init()

    /**
     Disabled classes to ignore resignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    public var disabledTouchResignedClasses: [UIViewController.Type] = [
        UIAlertController.self,
        UIInputViewController.self
    ]

    /**
     Enabled classes to forcefully enable 'resignOnTouchOutside' property.
     Class should be kind of UIViewController
     . If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    public var enabledTouchResignedClasses: [UIViewController.Type] = []

    /**
     if resignOnTouchOutside is enabled then you can customize the behavior
     to not recognize gesture touches on some specific view subclasses.
     Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    public var touchResignedGestureIgnoreClasses: [UIView.Type] = [
        UIControl.self,
        UINavigationBar.self
    ]

    /**
    Resigns currently first responder field.
    */
    @discardableResult
    public func resignFirstResponder() -> Bool {

        guard let textInputView: any IQTextInputView = textInputViewObserver.textInputView else {
            return false
        }

        // Resigning first responder
        guard textInputView.resignFirstResponder() else {
//            showLog("Refuses to resign first responder: \(textInputView)")
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            // If it refuses to resign then becoming it first responder again for getting notifications callback.
            textInputView.becomeFirstResponder()
            return false
        }
        return true
    }

    public override init() {
        super.init()

        resignGesture.addTarget(self, action: #selector(self.tapRecognized(_:)))
        resignGesture.cancelsTouchesInView = false
        resignGesture.delegate = self
        resignGesture.isEnabled = false

        addTextInputViewObserver()
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension IQKeyboardResignHandler: UIGestureRecognizerDelegate {

    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    private func tapRecognized(_ gesture: UITapGestureRecognizer) {

        if gesture.state == .ended {

            // Resigning currently responder textInputView.
            resignFirstResponder()
        }
    }

    /** Note: returning YES is guaranteed to allow simultaneous recognition.
     returning NO is not guaranteed to prevent simultaneous recognition,
     as the other gesture's delegate may return YES.
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /**
     To not detect touch events in a subclass of UIControl,
     these may have added their own selector for specific work
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        // (Bug ID: #145)
        // Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)

        for ignoreClass in touchResignedGestureIgnoreClasses where touch.view?.isKind(of: ignoreClass) ?? false {
            return false
        }

        return true
    }
}
