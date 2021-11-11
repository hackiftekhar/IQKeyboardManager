//
//  IQKeyboardManager+UIKeyboardNotification.swift
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

// import Foundation - UIKit contains Foundation
import UIKit

// MARK: UIKeyboard Notifications
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    private struct AssociatedKeys {
        static var keyboardShowing = "keyboardShowing"
        static var keyboardShowNotification = "keyboardShowNotification"
        static var keyboardFrame = "keyboardFrame"
        static var animationDuration = "animationDuration"
        static var animationCurve = "animationCurve"
    }

    /**
     Boolean to know if keyboard is showing.
     */
    @objc private(set) var keyboardShowing: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardShowing) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardShowing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    internal var keyboardShowNotification: Notification? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardShowNotification) as? Notification
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardShowNotification, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboard rame. */
    internal var keyboardFrame: CGRect {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardFrame) as? CGRect ?? .zero
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardFrame, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboard animation duration. */
    internal var animationDuration: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.animationDuration) as? TimeInterval ?? 0.25
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.animationDuration, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To mimic the keyboard animation */
    internal var animationCurve: UIView.AnimationOptions {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.animationCurve) as? UIView.AnimationOptions ?? .curveEaseOut
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.animationCurve, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /*  UIKeyboardWillShowNotification. */
    @objc internal func keyboardWillShow(_ notification: Notification?) {

        keyboardShowNotification = notification

        //  Boolean to know keyboard is showing/hiding
        keyboardShowing = true

        let oldKBFrame = keyboardFrame

        if let info = notification?.userInfo {

            //  Getting keyboard animation.
            if let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                animationCurve = UIView.AnimationOptions(rawValue: curve).union(.beginFromCurrentState)
            } else {
                animationCurve = UIView.AnimationOptions.curveEaseOut.union(.beginFromCurrentState)
            }

            //  Getting keyboard animation duration
            animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25

            //  Getting UIKeyboardSize.
            if let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

                keyboardFrame = kbFrame
                showLog("UIKeyboard Frame: \(keyboardFrame)")
            }
        }

        guard privateIsEnabled() else {
            restorePosition()
            topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid
            return
        }

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //  (Bug ID: #5)
        if let textFieldView = textFieldView, topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) {

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            rootViewController = textFieldView.parentContainerViewController()
            if let controller = rootViewController {

                if rootViewControllerWhilePopGestureRecognizerActive == controller {
                    topViewBeginOrigin = topViewBeginOriginWhilePopGestureRecognizerActive
                } else {
                    topViewBeginOrigin = controller.view.frame.origin
                }

                rootViewControllerWhilePopGestureRecognizerActive = nil
                topViewBeginOriginWhilePopGestureRecognizerActive = IQKeyboardManager.kIQCGPointInvalid

                self.showLog("Saving \(controller) beginning origin: \(self.topViewBeginOrigin)")
            }
        }

        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if keyboardFrame.equalTo(oldKBFrame) == false {

            //If textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).

            if keyboardShowing,
                let textFieldView = textFieldView,
                textFieldView.isAlertViewTextField() == false {

                //  keyboard is already showing. adjust position.
                optimizedAdjustPosition()
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    /*  UIKeyboardDidShowNotification. */
    @objc internal func keyboardDidShow(_ notification: Notification?) {

        guard privateIsEnabled(),
            let textFieldView = textFieldView,
            let parentController = textFieldView.parentContainerViewController(), (parentController.modalPresentationStyle == UIModalPresentationStyle.formSheet || parentController.modalPresentationStyle == UIModalPresentationStyle.pageSheet),
            textFieldView.isAlertViewTextField() == false else {
                return
        }

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        self.optimizedAdjustPosition()

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    @objc internal func keyboardWillHide(_ notification: Notification?) {

        //If it's not a fake notification generated by [self setEnable:NO].
        if notification != nil {
            keyboardShowNotification = nil
        }

        //  Boolean to know keyboard is showing/hiding
        keyboardShowing = false

        if let info = notification?.userInfo {

            //  Getting keyboard animation.
            if let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                animationCurve = UIView.AnimationOptions(rawValue: curve).union(.beginFromCurrentState)
            } else {
                animationCurve = UIView.AnimationOptions.curveEaseOut.union(.beginFromCurrentState)
            }

            //  Getting keyboard animation duration
            animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        }

        //If not enabled then do nothing.
        guard privateIsEnabled() else {
            return
        }

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //Commented due to #56. Added all the conditions below to handle WKWebView's textFields.    (Bug ID: #56)
        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        //    if (_textFieldView == nil)   return

        //Restoring the contentOffset of the lastScrollView
        if let lastScrollView = lastScrollView {

            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in

                if lastScrollView.contentInset != self.startingContentInsets {
                    self.showLog("Restoring contentInset to: \(self.startingContentInsets)")
                    lastScrollView.contentInset = self.startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self.startingScrollIndicatorInsets
                }

                if lastScrollView.shouldRestoreScrollViewContentOffset, !lastScrollView.contentOffset.equalTo(self.startingContentOffset) {
                    self.showLog("Restoring contentOffset to: \(self.startingContentOffset)")

                    let animatedContentOffset = self.textFieldView?.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                    if animatedContentOffset {
                        lastScrollView.setContentOffset(self.startingContentOffset, animated: UIView.areAnimationsEnabled)
                    } else {
                        lastScrollView.contentOffset = self.startingContentOffset
                    }
                }

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView: UIScrollView? = lastScrollView

                while let scrollView = superScrollView {

                    let contentSize = CGSize(width: max(scrollView.contentSize.width, scrollView.frame.width), height: max(scrollView.contentSize.height, scrollView.frame.height))

                    let minimumY = contentSize.height - scrollView.frame.height

                    if minimumY < scrollView.contentOffset.y {

                        let newContentOffset = CGPoint(x: scrollView.contentOffset.x, y: minimumY)
                        if scrollView.contentOffset.equalTo(newContentOffset) == false {

                            let animatedContentOffset = self.textFieldView?.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                            if animatedContentOffset {
                                scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                            } else {
                                scrollView.contentOffset = newContentOffset
                            }

                            self.showLog("Restoring contentOffset to: \(self.startingContentOffset)")
                        }
                    }

                    superScrollView = scrollView.superviewOfClassType(UIScrollView.self) as? UIScrollView
                }
            })
        }

        restorePosition()

        //Reset all values
        lastScrollView = nil
        keyboardFrame = CGRect.zero
        startingContentInsets = UIEdgeInsets()
        startingScrollIndicatorInsets = UIEdgeInsets()
        startingContentOffset = CGPoint.zero
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    @objc internal func keyboardDidHide(_ notification: Notification) {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid

        keyboardFrame = CGRect.zero

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
}
