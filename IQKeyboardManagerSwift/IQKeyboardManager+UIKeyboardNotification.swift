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

import Foundation

private var kIQKeyboardShowing              = "kIQKeyboardShowing"
private var kIQKeyboardShowNotification     = "kIQKeyboardShowNotification"
private var kIQKeyboardFrame                = "kIQKeyboardFrame"
private var kIQAnimationDuration            = "kIQAnimationDuration"
private var kIQAnimationCurve               = "kIQAnimationCurve"

// MARK: UIKeyboard Notifications
public extension IQKeyboardManager {

    /**
     Boolean to know if keyboard is showing.
     */
    @objc private(set) var keyboardShowing: Bool {
        get {
            return objc_getAssociatedObject(self, &kIQKeyboardShowing) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQKeyboardShowing, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    internal var keyboardShowNotification: Notification? {
        get {
            return objc_getAssociatedObject(self, &kIQKeyboardShowNotification) as? Notification
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQKeyboardShowNotification, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboard rame. */
    internal var keyboardFrame: CGRect {
        get {
            return objc_getAssociatedObject(self, &kIQKeyboardFrame) as? CGRect ?? .zero
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQKeyboardFrame, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /** To save keyboard animation duration. */
    internal var animationDuration: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &kIQAnimationDuration) as? TimeInterval ?? 0.25
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQAnimationDuration, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    #if swift(>=4.2)
    typealias  UIViewAnimationOptions = UIView.AnimationOptions
    #endif

    /** To mimic the keyboard animation */
    internal var animationCurve: UIViewAnimationOptions {
        get {
            return objc_getAssociatedObject(self, &kIQAnimationDuration) as? UIViewAnimationOptions ?? .curveEaseOut
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQAnimationDuration, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /*  UIKeyboardWillShowNotification. */
    @objc internal func keyboardWillShow(_ notification: Notification?) {

        keyboardShowNotification = notification

        //  Boolean to know keyboard is showing/hiding
        keyboardShowing = true

        let oldKBFrame = keyboardFrame

        if let info = notification?.userInfo {

            #if swift(>=4.2)
            let curveUserInfoKey    = UIResponder.keyboardAnimationCurveUserInfoKey
            let durationUserInfoKey = UIResponder.keyboardAnimationDurationUserInfoKey
            let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
            #else
            let curveUserInfoKey    = UIKeyboardAnimationCurveUserInfoKey
            let durationUserInfoKey = UIKeyboardAnimationDurationUserInfoKey
            let frameEndUserInfoKey = UIKeyboardFrameEndUserInfoKey
            #endif

            //  Getting keyboard animation.
            if let curve = info[curveUserInfoKey] as? UInt {
                animationCurve = UIViewAnimationOptions(rawValue: curve).union(.beginFromCurrentState)
            } else {
                animationCurve = UIViewAnimationOptions.curveEaseOut.union(.beginFromCurrentState)
            }

            //  Getting keyboard animation duration
            if let duration = info[durationUserInfoKey] as? TimeInterval {

                //Saving animation duration
                if duration != 0.0 {
                    animationDuration = duration
                }
            } else {
                animationDuration = 0.25
            }

            //  Getting UIKeyboardSize.
            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {

                keyboardFrame = kbFrame
                showLog("UIKeyboard Frame: \(keyboardFrame)")
            }
        }

        if privateIsEnabled() == false {
            restorePosition()
            topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid
            return
        }

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //  (Bug ID: #5)
        if let textFieldView = textFieldView, topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == true {

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

            if keyboardShowing == true,
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

        if privateIsEnabled() == false {
            return
        }

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        if let textFieldView = textFieldView,
            let parentController = textFieldView.parentContainerViewController(), (parentController.modalPresentationStyle == UIModalPresentationStyle.formSheet || parentController.modalPresentationStyle == UIModalPresentationStyle.pageSheet),
            textFieldView.isAlertViewTextField() == false {

            self.optimizedAdjustPosition()
        }

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

            #if swift(>=4.2)
            let durationUserInfoKey = UIResponder.keyboardAnimationDurationUserInfoKey
            #else
            let durationUserInfoKey = UIKeyboardAnimationDurationUserInfoKey
            #endif

            //  Getting keyboard animation duration
            if let duration =  info[durationUserInfoKey] as? TimeInterval {
                if duration != 0 {
                    //  Setitng keyboard animation duration
                    animationDuration = duration
                }
            }
        }

        //If not enabled then do nothing.
        if privateIsEnabled() == false {
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

                if lastScrollView.shouldRestoreScrollViewContentOffset == true && lastScrollView.contentOffset.equalTo(self.startingContentOffset) == false {
                    self.showLog("Restoring contentOffset to: \(self.startingContentOffset)")

                    var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)

                    if #available(iOS 9, *) {
                        animatedContentOffset = self.textFieldView?.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil
                    }

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

                            var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)

                            if #available(iOS 9, *) {
                                animatedContentOffset = self.textFieldView?.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil
                            }

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
