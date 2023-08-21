//
//  IQKeyboardInfo.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-20 Iftekhar Qurashi.
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
public struct IQKeyboardInfo: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.frame.equalTo(rhs.frame)
    }

    @objc public enum Name: Int {
        case willShow
        case didShow
        case willHide
        case didHide
//        case willChangeFrame
//        case didChangeFrame
    }

    public let name: Name

    /** To save keyboard rame. */
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
//        print("Notification Object:\(notification?.object ?? "NULL")")

        if let info = notification?.userInfo {

            //  Getting keyboard animation.
            if let curveValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                let curve = UIView.AnimationCurve(rawValue: curveValue) {
                animationCurve = curve
            } else {
                animationCurve = UIView.AnimationCurve.easeOut
            }

            //  Getting keyboard animation duration
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
            animationDuration = TimeInterval.maximum(duration, 0.25)
            let screen = (notification?.object as? UIScreen) ?? UIScreen.main

            //  Getting UIKeyboardSize.
            if var kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

                // Calculating actual keyboard covered size respect to window, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
                let intersectRect = kbFrame.intersection(screen.bounds)

                if intersectRect.isNull {
                    kbFrame.size = CGSize(width: kbFrame.size.width, height: 0)
                } else {
                    kbFrame.size = intersectRect.size
                }

                frame = kbFrame
            } else {
                frame = CGRect(x: 0, y: screen.bounds.height, width: screen.bounds.width, height: 0)
            }
        } else {
            animationCurve = UIView.AnimationCurve.easeOut
            animationDuration = 0.25
            let screen = UIScreen.main
            frame = CGRect(x: 0, y: screen.bounds.height, width: screen.bounds.width, height: 0)
        }
    }

    public func animate(alongsideTransition transition: @escaping () -> Void, completion: (() -> Void)? = nil) {

        if let timing = UIView.AnimationCurve.RawValue(exactly: animationCurve.rawValue),
           let curve = UIView.AnimationCurve(rawValue: timing) {
            let animator = UIViewPropertyAnimator(duration: animationDuration, curve: curve) {
                completion?()
            }
            animator.isUserInteractionEnabled = true
            animator.startAnimation()
        } else {
            var animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
            animationOptions.formUnion(.allowUserInteraction)
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: transition, completion: { _ in
                completion?()
            })
        }
    }
}
