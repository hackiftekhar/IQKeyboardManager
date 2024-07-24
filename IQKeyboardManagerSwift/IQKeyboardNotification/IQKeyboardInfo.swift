//
//  IQKeyboardInfo.swift
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
public struct IQKeyboardInfo: Equatable {
    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.frame.equalTo(rhs.frame)
    }

    @objc public enum Name: Int {
        case willShow
        case didShow
        case willHide
        case didHide
        case willChangeFrame
        case didChangeFrame
    }

    public let name: Name

    /** To save keyboard frame. */
    public let frame: CGRect

    /** To save keyboard animation duration. */
    public let animationDuration: TimeInterval

    /** To mimic the keyboard animation */
    public let animationCurve: UIView.AnimationCurve

    public var keyboardShowing: Bool {
        frame.height > 0
    }

    public init(notification: Notification?, name: Name) {
        self.name = name

        let screenBounds: CGRect
        if let screen: UIScreen = notification?.object as? UIScreen {
            screenBounds = screen.bounds
        } else {
            screenBounds = UIScreen.main.bounds
        }

        if let info: [AnyHashable: Any] = notification?.userInfo {

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

            //  Getting UIKeyboardSize.
            if var kbFrame: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

                // If this is floating keyboard
                if kbFrame.width < screenBounds.width,
                   kbFrame.maxY < screenBounds.height {
                    kbFrame.size = CGSize(width: kbFrame.size.width, height: 0)
                } else {
                    // (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
                    // Calculating actual keyboard covered size respect to window,
                    // keyboard frame may be different when hardware keyboard is attached
                    let keyboardHeight = CGFloat.maximum(screenBounds.height - kbFrame.minY, 0)
                    kbFrame.size = CGSize(width: kbFrame.size.width, height: keyboardHeight)
                }

                frame = kbFrame
            } else {
                frame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
            }
        } else {
            animationCurve = .easeOut
            animationDuration = 0.25
            frame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 0)
        }
    }

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
        var animationOptions: UIView.AnimationOptions = .init(rawValue: UInt(animationCurve.rawValue << 16))
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
}
