//
//  IQKeyboardInfo.swift
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
// swiftlint:disable:next line_length
@available(*, deprecated, message: "Please use `IQKeyboardNotification` independently from https://github.com/hackiftekhar/IQKeyboardNotification. IQKeyboardListener will be removed from this library in future release.")
public struct IQKeyboardInfoDeprecated: Equatable {
    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.event == rhs.event &&
        lhs.endFrame.equalTo(rhs.endFrame)
    }

    @objc public enum Event: Int, CaseIterable {
        case willShow
        case didShow
        case willChangeFrame
        case didChangeFrame
        case willHide
        case didHide

        @MainActor
        public var notification: Notification.Name {
            switch self {
            case .willShow:
                return UIResponder.keyboardWillShowNotification
            case .didShow:
                return UIResponder.keyboardDidShowNotification
            case .willChangeFrame:
                return UIResponder.keyboardWillChangeFrameNotification
            case .didChangeFrame:
                return UIResponder.keyboardDidChangeFrameNotification
            case .willHide:
                return UIResponder.keyboardWillHideNotification
            case .didHide:
                return UIResponder.keyboardDidHideNotification
            }
        }
    }

    public let event: Event

    /// `keyboardIsLocalUserInfoKey`.
    public let isLocal: Bool

    /// `UIKeyboardFrameBeginUserInfoKey`.
    public let beginFrame: CGRect

    /// `UIKeyboardFrameEndUserInfoKey`.
    public let endFrame: CGRect

    public var frame: CGRect { endFrame }

    /// `UIKeyboardAnimationDurationUserInfoKey`.
    public let animationDuration: TimeInterval

    /// `UIKeyboardAnimationCurveUserInfoKey`.
    public let animationCurve: UIView.AnimationCurve

    public var animationOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
    }

    public var isVisible: Bool {
        endFrame.height > 0
    }

    internal init(notification: Notification?, event: Event) {
        self.event = event

        let screenBounds: CGRect
        if let screen: UIScreen = notification?.object as? UIScreen {
            screenBounds = screen.bounds
        } else {
            screenBounds = UIScreen.main.bounds
        }

        if let info: [AnyHashable: Any] = notification?.userInfo {

            if let value = info[UIResponder.keyboardIsLocalUserInfoKey] as? Bool {
                isLocal = value
            } else {
                isLocal = true
            }

            //  Getting keyboard animation.
            if let curveValue: Int = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
               let curve: UIView.AnimationCurve = UIView.AnimationCurve(rawValue: curveValue) {
                animationCurve = curve
            } else {
                animationCurve = .easeOut
            }

            //  Getting keyboard animation duration
            if let duration: TimeInterval = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
               duration != 0.0 {
                animationDuration = duration
            } else {
                animationDuration = 0.25
            }

            if let beginKeyboardFrame: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
                beginFrame = Self.getKeyboardFrame(of: beginKeyboardFrame, inScreenBounds: screenBounds)
            } else {
                beginFrame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
            }

            if let endKeyboardFrame: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                endFrame = Self.getKeyboardFrame(of: endKeyboardFrame, inScreenBounds: screenBounds)
            } else {
                endFrame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
            }
        } else {
            isLocal = true
            animationCurve = .easeOut
            animationDuration = 0.25
            beginFrame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
            endFrame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
        }
    }

    @MainActor
    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {

//        if let timing = UIView.AnimationCurve.RawValue(exactly: animationCurve.rawValue),
//           let curve = UIView.AnimationCurve(rawValue: timing) {
//            let animator = UIViewPropertyAnimator(duration: animationDuration, curve: curve) {
//                transition()
//            }
//            animator.addCompletion { _ in
//                completion?()
//            }
//            animator.isUserInteractionEnabled = true
//            animator.startAnimation()
//        } else {
        var animationOptions: UIView.AnimationOptions = self.animationOptions
        animationOptions.formUnion(.allowUserInteraction)
        animationOptions.formUnion(.beginFromCurrentState)
        UIView.animate(withDuration: animationDuration, delay: 0,
                       options: animationOptions,
                       animations: transition,
                       completion: { _ in
            completion?()
        })
//        }
    }

    private static func getKeyboardFrame(of rect: CGRect, inScreenBounds screenBounds: CGRect) -> CGRect {
        var finalFrame: CGRect = rect
        // If this is floating keyboard
        if finalFrame.width < screenBounds.width,
           finalFrame.maxY < screenBounds.height {
            finalFrame.size = CGSize(width: finalFrame.size.width, height: 0)
        } else {
            // (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
            // Calculating actual keyboard covered size respect to window,
            // keyboard frame may be different when hardware keyboard is attached
            let keyboardHeight = CGFloat.maximum(screenBounds.height - finalFrame.minY, 0)
            finalFrame.size = CGSize(width: finalFrame.size.width, height: keyboardHeight)
        }

        return finalFrame
    }

    // MARK: Deprecated

    @available(*, deprecated, renamed: "event")
    public var name: Event { event }

    @available(*, deprecated, renamed: "isVisible")
    public var keyboardShowing: Bool { isVisible }
}
