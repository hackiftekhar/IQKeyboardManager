//
//  IQKeyboardManager+UITextFieldViewNotification.swift
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
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQKeyboardManager {

    @MainActor
    private struct AssociatedKeys {
        static var resignOnTouchOutside: Int = 0
        static var resignGesture: Int = 0
        static var disabledTouchResignedClasses: Int = 0
        static var enabledTouchResignedClasses: Int = 0
        static var touchResignedGestureIgnoreClasses: Int = 0
    }

    /**
     Resigns Keyboard on touching outside of UITextField/View. Default is NO.
     */
    @objc var resignOnTouchOutside: Bool {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedKeys.resignOnTouchOutside) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.resignOnTouchOutside,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateResignGestureState()
            showLog("resignOnTouchOutside: \(newValue ? "Yes" : "NO")")
        }
    }

    /** TapGesture to resign keyboard on view's touch.
     It's a readonly property and exposed only for adding/removing dependencies
     if your added gesture does have collision with this one
     */
    @objc var resignGesture: UITapGestureRecognizer {

        if let gesture = objc_getAssociatedObject(self, &AssociatedKeys.resignGesture) as? UITapGestureRecognizer {
            return gesture
        }

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        gesture.isEnabled = false
        objc_setAssociatedObject(self, &AssociatedKeys.resignGesture, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // Registering one time only
        registerActiveStateChangeForTouchOutside()

        return gesture
    }

    // swiftlint:disable line_length
    /**
     Disabled classes to ignore resignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    @objc var disabledTouchResignedClasses: [UIViewController.Type] {
        get {
            if let classes = objc_getAssociatedObject(self, &AssociatedKeys.disabledTouchResignedClasses) as? [UIViewController.Type] {
                return classes
            } else {
                return [UIAlertController.self, UIInputViewController.self]
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.disabledTouchResignedClasses,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Enabled classes to forcefully enable 'resignOnTouchOutside' property.
     Class should be kind of UIViewController
     . If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    @objc var enabledTouchResignedClasses: [UIViewController.Type] {
        get {
            if let classes = objc_getAssociatedObject(self, &AssociatedKeys.enabledTouchResignedClasses) as? [UIViewController.Type] {
                return classes
            } else {
                return []
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.enabledTouchResignedClasses,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     if resignOnTouchOutside is enabled then you can customize the behavior
     to not recognize gesture touches on some specific view subclasses.
     Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    @objc var touchResignedGestureIgnoreClasses: [UIView.Type] {
        get {
            if let classes = objc_getAssociatedObject(self, &AssociatedKeys.touchResignedGestureIgnoreClasses) as? [UIView.Type] {
                return classes
            } else {
                return [UIControl.self, UINavigationBar.self]
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.touchResignedGestureIgnoreClasses,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // swiftlint:enable line_length

    /**
    Resigns currently first responder field.
    */
    @discardableResult
    @objc func resignFirstResponder() -> Bool {

        guard let textFieldRetain: UIView = activeConfiguration.textInputViewInfo?.textInputView else {
            return false
        }

        // Resigning first responder
        guard textFieldRetain.resignFirstResponder() else {
            showLog("Refuses to resign first responder: \(textFieldRetain)")
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            // If it refuses to resign then becoming it first responder again for getting notifications callback.
            textFieldRetain.becomeFirstResponder()
            return false
        }
        return true
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQKeyboardManager: UIGestureRecognizerDelegate {

    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    @objc private func tapRecognized(_ gesture: UITapGestureRecognizer) {

        guard gesture.state == .ended else { return }

        // Resigning currently responder textField.
        resignFirstResponder()
    }

    /** Note: returning YES is guaranteed to allow simultaneous recognition.
     returning NO is not guaranteed to prevent simultaneous recognition,
     as the other gesture's delegate may return YES.
     */
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                        shouldRecognizeSimultaneouslyWith
                                        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /**
     To not detect touch events in a subclass of UIControl,
     these may have added their own selector for specific work
     */
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                        shouldReceive touch: UITouch) -> Bool {
        // (Bug ID: #145)
        // Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)

        for ignoreClass in touchResignedGestureIgnoreClasses where touch.view?.isKind(of: ignoreClass) ?? false {
            return false
        }

        return true
    }
}
