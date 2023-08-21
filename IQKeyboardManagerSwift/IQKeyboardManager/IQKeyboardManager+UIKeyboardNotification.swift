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

import UIKit

// MARK: UIKeyboard Notifications
@available(iOSApplicationExtension, unavailable)
public extension IQKeyboardManager {

    typealias SizeBlock = (_ size: CGSize) -> Void

    private final class KeyboardSizeObserver: NSObject {
        weak var observer: NSObject?
        var sizeHandler: (_ size: CGSize) -> Void

        init(observer: NSObject?, sizeHandler: @escaping (_ size: CGSize) -> Void) {
            self.observer = observer
            self.sizeHandler = sizeHandler
        }
    }

    private struct AssociatedKeys {
        static var keyboardSizeObservers: Int = 0
        static var keyboardLastNotifySize: Int = 0
        static var keyboardInfo: Int = 0
    }

    private var keyboardLastNotifySize: CGSize {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardLastNotifySize) as? CGSize ?? .zero
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardLastNotifySize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var keyboardSizeObservers: [AnyHashable: SizeBlock] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.keyboardSizeObservers) as? [AnyHashable: SizeBlock] ?? [:]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardSizeObservers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock) {
        keyboardSizeObservers[identifier] = sizeHandler
    }

    @objc func unregisterKeyboardSizeChange(identifier: AnyHashable) {
        keyboardSizeObservers[identifier] = nil
    }

    internal func notifyKeyboardSize(size: CGSize) {

        guard !size.equalTo(keyboardLastNotifySize) else {
            return
        }

        keyboardLastNotifySize = size

        for block in keyboardSizeObservers.values {
            block(size)
        }
    }

    /**
     This contains information related to keyboard.
     */
    private(set) var keyboardInfo: IQKeyboardInfo {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.keyboardInfo) as? IQKeyboardInfo) ?? IQKeyboardInfo(notification: nil, name: .didHide)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /*  UIKeyboardWillShowNotification. */
    @objc internal func keyboardWillShow(_ notification: Notification) {

        let oldKeyboardInfo: IQKeyboardInfo = self.keyboardInfo
        self.keyboardInfo = IQKeyboardInfo(notification: notification, name: .willShow)

        notifyKeyboardSize(size: keyboardInfo.frame.size)
        showLog("UIKeyboard Frame: \(keyboardInfo.frame)")

        guard privateIsEnabled() else {
            restorePosition()
            rootControllerConfiguration = nil
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)

        showLog("Notification Object:\(notification.object ?? "NULL")")

        //  (Bug ID: #5)
        if let textFieldView: UIView = textFieldView,
           rootControllerConfiguration == nil {

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            if let controller: UIViewController = textFieldView.iq.parentContainerViewController() {

                if rootControllerConfigurationWhilePopGestureRecognizerActive?.rootController == controller {
                    rootControllerConfiguration = rootControllerConfigurationWhilePopGestureRecognizerActive
                } else {
                    rootControllerConfiguration = .init(rootController: controller)
                }

                rootControllerConfigurationWhilePopGestureRecognizerActive = nil

                if let rootControllerConfiguration = rootControllerConfiguration {
                    self.showLog("Saving \(rootControllerConfiguration.rootController) beginning origin: \(rootControllerConfiguration.beginOrigin)")
                }
            }
        }

        // If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if keyboardInfo != oldKeyboardInfo {

            // If textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).

            if keyboardInfo.keyboardShowing,
               let textFieldView: UIView = textFieldView,
                !textFieldView.iq.isAlertViewTextField() {

                //  keyboard is already showing. adjust position.
                optimizedAdjustPosition()
            }
        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /*  UIKeyboardDidShowNotification. */
    @objc internal func keyboardDidShow(_ notification: Notification) {

//        let oldKeyboardInfo: IQKeyboardInfo = self.keyboardInfo
        self.keyboardInfo = IQKeyboardInfo(notification: notification, name: .didShow)

        guard privateIsEnabled(),
              let textFieldView: UIView = textFieldView,
              let parentController: UIViewController = textFieldView.iq.parentContainerViewController(),
              (parentController.modalPresentationStyle == UIModalPresentationStyle.formSheet || parentController.modalPresentationStyle == UIModalPresentationStyle.pageSheet),
              !textFieldView.iq.isAlertViewTextField() else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification.object ?? "NULL")")

//        if keyboardInfo != oldKeyboardInfo {
            self.optimizedAdjustPosition()
//        }

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    @objc internal func keyboardWillHide(_ notification: Notification?) {

        self.keyboardInfo = IQKeyboardInfo(notification: notification, name: .willHide)

        // If not enabled then do nothing.
        guard privateIsEnabled() else {
            return
        }

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification?.object ?? "NULL")")

        // Commented due to #56. Added all the conditions below to handle WKWebView's textFields.    (Bug ID: #56)
        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        //    if (_textFieldView == nil)   return

        // Restoring the contentOffset of the lastScrollView
        if let lastScrollViewConfiguration: IQScrollViewConfiguration = lastScrollViewConfiguration {

            keyboardInfo.animate(alongsideTransition: {

                if lastScrollViewConfiguration.hasChanged {
                    if lastScrollViewConfiguration.scrollView.contentInset != lastScrollViewConfiguration.startingContentInsets {
                        self.showLog("Restoring contentInset to: \(lastScrollViewConfiguration.startingContentInsets)")
                    }

                    if lastScrollViewConfiguration.scrollView.iq.restoreContentOffset,
                       !lastScrollViewConfiguration.scrollView.contentOffset.equalTo(lastScrollViewConfiguration.startingContentOffset) {
                        self.showLog("Restoring contentOffset to: \(lastScrollViewConfiguration.startingContentOffset)")
                    }

                    self.keyboardInfo.animate(alongsideTransition: {
                        lastScrollViewConfiguration.restore(for: self.textFieldView)
                    })
                }

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView: UIScrollView? = lastScrollViewConfiguration.scrollView

                while let scrollView: UIScrollView = superScrollView {

                    let contentSize: CGSize = CGSize(width: max(scrollView.contentSize.width, scrollView.frame.width), height: max(scrollView.contentSize.height, scrollView.frame.height))

                    let minimumY: CGFloat = contentSize.height - scrollView.frame.height

                    if minimumY < scrollView.contentOffset.y {

                        let newContentOffset: CGPoint = CGPoint(x: scrollView.contentOffset.x, y: minimumY)
                        if !scrollView.contentOffset.equalTo(newContentOffset) {

                            let animatedContentOffset: Bool = self.textFieldView?.iq.superviewOf(type: UIStackView.self, belowView: scrollView) != nil  //  (Bug ID: #1365, #1508, #1541)

                            if animatedContentOffset {
                                scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                            } else {
                                scrollView.contentOffset = newContentOffset
                            }

                            self.showLog("Restoring contentOffset to: \(newContentOffset)")
                        }
                    }

                    superScrollView = scrollView.iq.superviewOf(type: UIScrollView.self) as? UIScrollView
                }
            })
        }

        restorePosition()

        // Reset all values
        self.lastScrollViewConfiguration = nil
        notifyKeyboardSize(size: keyboardInfo.frame.size)
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }

    @objc internal func keyboardDidHide(_ notification: Notification) {

        self.keyboardInfo = IQKeyboardInfo(notification: notification, name: .didHide)

        let startTime: CFTimeInterval = CACurrentMediaTime()
        showLog("⌨️>>>>> \(#function) started >>>>>", indentation: 1)
        showLog("Notification Object:\(notification.object ?? "NULL")")

        rootControllerConfiguration = nil
        notifyKeyboardSize(size: keyboardInfo.frame.size)

        let elapsedTime: CFTimeInterval = CACurrentMediaTime() - startTime
        showLog("⌨️<<<<< \(#function) ended: \(elapsedTime) seconds <<<<<", indentation: -1)
    }
}
