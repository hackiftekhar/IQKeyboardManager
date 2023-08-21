//
//  IQKeyboardManager.swift
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
import CoreGraphics
import QuartzCore

// MARK: IQToolbar tags

/**
Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html (OLD DOCUMENTATION) LINK

https://developer.apple.com/documentation/uikit/keyboards_and_input/adjusting_your_layout_with_keyboard_layout_guide
*/

@available(iOSApplicationExtension, unavailable)
@objc public final class IQKeyboardManager: NSObject {

    /**
    Returns the default singleton instance.
    */
    @objc public static let shared: IQKeyboardManager = .init()

    // MARK: UIKeyboard handling

    /**
    Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
    */
    @objc public var enable: Bool = false {

        didSet {
            // If not enable, enable it.
            if enable, !oldValue {
                // If keyboard is currently showing.
                if keyboardInfo.keyboardShowing {
                    optimizedAdjustPosition()
                } else {
                    restorePosition()
                }
                showLog("Enabled")
            } else if !enable, oldValue {   // If not disable, desable it.
                keyboardWillHide(nil)
                showLog("Disabled")
            }
        }
    }

    /**
    To set keyboard distance from textField. can't be less than zero. Default is 10.0.
    */
    @objc public var keyboardDistanceFromTextField: CGFloat = 10.0

    // MARK: IQToolbar handling

    /**
    Automatic add the IQToolbar functionality. Default is YES.
    */
    @objc public var enableAutoToolbar: Bool = true {
        didSet {
            if privateIsEnableAutoToolbar() {
                addToolbarIfRequired()
            } else {
                removeToolbarIfRequired()
            }

            showLog("enableAutoToolbar: \(enableAutoToolbar ? "Yes" : "NO")")
        }
    }

    /**
    Configurations related to the toolbar display over the keyboard.
    */
    @objc public let toolbarConfiguration: IQToolbarConfiguration = .init()

    /**
    Buttons configuration displayed on the toolbar, the selector parameter is ignored in below configuration
    */
    @objc public var toolbarPreviousBarButtonItemConfiguration: IQBarButtonItemConfiguration?
    @objc public var toolbarNextBarButtonItemConfiguration: IQBarButtonItemConfiguration?
    @objc public var toolbarDoneBarButtonItemConfiguration: IQBarButtonItemConfiguration?

    /**
    Configuration related to keyboard appearance
    */
    @objc public let keyboardConfiguration: IQKeyboardConfiguration = .init()

    // MARK: UITextField/UITextView Next/Previous/Resign handling

    /**
    Resigns Keyboard on touching outside of UITextField/View. Default is NO.
    */
    @objc public var resignOnTouchOutside: Bool = false {

        didSet {
            resignFirstResponderGesture.isEnabled = privateResignOnTouchOutside()

            showLog("resignOnTouchOutside: \(resignOnTouchOutside ? "Yes" : "NO")")
        }
    }

    /** TapGesture to resign keyboard on view's touch. It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one */
    @objc public lazy var resignFirstResponderGesture: UITapGestureRecognizer = {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self

        return tapGesture
    }()

    /*******************************************/

    /**
    Resigns currently first responder field.
    */
    @discardableResult
    @objc public func resignFirstResponder() -> Bool {

        guard let textFieldRetain = textFieldView else {
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

    // MARK: UISound handling

    /**
    If YES, then it plays inputClick sound on next/previous/done click.
    */
    @objc public var playInputClicks: Bool = true

    // MARK: UIAnimation handling

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    @objc public var layoutIfNeededOnUpdate: Bool = false

    // MARK: Class Level disabling methods

    /**
     Disable distance handling within the scope of disabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**
     Enable distance handling within the scope of enabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController. If same Class is added in disabledDistanceHandlingClasses list, then enabledDistanceHandlingClasses will be ignored.
     */
    @objc public var enabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes. Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledToolbarClasses: [UIViewController.Type] = []

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes. Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController. If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    @objc public var enabledToolbarClasses: [UIViewController.Type] = []

    /**
     Allowed subclasses of UIView to add all inner textField, this will allow to navigate between textField contains in different superview. Class should be kind of UIView.
     */
    @objc public var toolbarPreviousNextAllowedClasses: [UIView.Type] = []

    /**
     Disabled classes to ignore resignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    @objc public var disabledTouchResignedClasses: [UIViewController.Type] = []

    /**
     Enabled classes to forcefully enable 'resignOnTouchOutsite' property. Class should be kind of UIViewController. If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    @objc public var enabledTouchResignedClasses: [UIViewController.Type] = []

    /**
     if resignOnTouchOutside is enabled then you can customise the behaviour to not recognise gesture touches on some specific view subclasses. Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    @objc public var touchResignedGestureIgnoreClasses: [UIView.Type] = []

    // MARK: Third Party Library support
    /// Add TextField/TextView Notifications customised Notifications. For example while using YYTextView https://github.com/ibireme/YYText

    /**
    Add/Remove customised Notification for third party customised TextField/TextView. Please be aware that the Notification object must be idential to UITextField/UITextView Notification objects and customised TextField/TextView support must be idential to UITextField/UITextView.
    @param didBeginEditingNotificationName This should be identical to UITextViewTextDidBeginEditingNotification
    @param didEndEditingNotificationName This should be identical to UITextViewTextDidEndEditingNotification
    */

    @objc public func registerTextFieldViewClass(_ aClass: UIView.Type, didBeginEditingNotificationName: String, didEndEditingNotificationName: String) {

        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldViewDidBeginEditing(_:)), name: Notification.Name(rawValue: didBeginEditingNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldViewDidEndEditing(_:)), name: Notification.Name(rawValue: didEndEditingNotificationName), object: nil)
    }

    @objc public func unregisterTextFieldViewClass(_ aClass: UIView.Type, didBeginEditingNotificationName: String, didEndEditingNotificationName: String) {

        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: didBeginEditingNotificationName), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: didEndEditingNotificationName), object: nil)
    }

    /**************************************************************************************/
    internal struct WeakObjectContainer {
        weak var object: AnyObject?
    }

    /**************************************************************************************/

    // MARK: Initialization/Deinitialization

    /*  Singleton Object Initialization. */
    override init() {

        super.init()

        self.registerAllNotifications()

        // Creating gesture for resignOnTouchOutside. (Enhancement ID: #14)
        resignFirstResponderGesture.isEnabled = resignOnTouchOutside

        // Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay (Bug ID: #550)
        // If you experience exception breakpoint issue at below line then try these solutions https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
        let textField: UIView = UITextField()
        textField.iq.addDone(target: nil, action: #selector(self.doneAction(_:)))
        textField.iq.addPreviousNextDone(target: nil, previousAction: #selector(self.previousAction(_:)),
                                         nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)))

        disabledDistanceHandlingClasses.append(UITableViewController.self)
        disabledDistanceHandlingClasses.append(UIAlertController.self)
        disabledToolbarClasses.append(UIAlertController.self)
        disabledTouchResignedClasses.append(UIAlertController.self)
        toolbarPreviousNextAllowedClasses.append(UITableView.self)
        toolbarPreviousNextAllowedClasses.append(UICollectionView.self)
        toolbarPreviousNextAllowedClasses.append(IQPreviousNextView.self)
        touchResignedGestureIgnoreClasses.append(UIControl.self)
        touchResignedGestureIgnoreClasses.append(UINavigationBar.self)
    }

    deinit {
        //  Disable the keyboard manager.
        enable = false
    }

    /** Getting keyWindow. */
    internal func keyWindow() -> UIWindow? {

        if let keyWindow: UIWindow = textFieldView?.window {
            return keyWindow
        } else {

            struct Static {
                /** @abstract   Save keyWindow object for reuse.
                @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
                static weak var keyWindow: UIWindow?
            }

            var originalKeyWindow: UIWindow?

            #if swift(>=5.1)
            if #available(iOS 13, *) {
                originalKeyWindow = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })
            } else {
                originalKeyWindow = UIApplication.shared.keyWindow
            }
            #else
            originalKeyWindow = UIApplication.shared.keyWindow
            #endif

            // If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
            if let originalKeyWindow: UIWindow = originalKeyWindow {
                Static.keyWindow = originalKeyWindow
            }

            // Return KeyWindow
            return Static.keyWindow
        }
    }

    // MARK: Public Methods

    /*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
    @objc public func reloadLayoutIfNeeded() {

        guard privateIsEnabled(),
              keyboardInfo.keyboardShowing,
              rootControllerConfiguration != nil,
              let textFieldView: UIView = textFieldView,
              !textFieldView.iq.isAlertViewTextField() else {
                return
        }
        optimizedAdjustPosition()
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQKeyboardManager: UIGestureRecognizerDelegate {

    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {

        if gesture.state == .ended {

            // Resigning currently responder textField.
            resignFirstResponder()
        }
    }

    /** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145)

        for ignoreClass in touchResignedGestureIgnoreClasses where touch.view?.isKind(of: ignoreClass) ?? false {
            return false
        }

        return true
    }

}
