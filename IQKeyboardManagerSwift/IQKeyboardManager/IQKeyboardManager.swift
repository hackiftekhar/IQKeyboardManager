//
//  IQKeyboardManager.swift
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
import CoreGraphics
import QuartzCore

// MARK: IQToolbar tags

// swiftlint:disable line_length
// A generic version of KeyboardManagement. (OLD DOCUMENTATION) LINK
// https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
// https://developer.apple.com/documentation/uikit/keyboards_and_input/adjusting_your_layout_with_keyboard_layout_guide
// swiftlint:enable line_length

/**
Code-less drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView.
 Neither need to write any code nor any setup required and much more.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQKeyboardManager: NSObject {

    /**
    Returns the default singleton instance.
    */
    @MainActor
    @objc public static let shared: IQKeyboardManager = .init()

    // MARK: UIKeyboard handling

    /**
    Enable/disable managing distance between keyboard and textField.
     Default is YES(Enabled when class loads in `+(void)load` method).
    */
    @objc public var enable: Bool = false {

        didSet {
            // If not enable, enable it.
            if enable, !oldValue {
                // If keyboard is currently showing.
                if activeConfiguration.keyboardInfo.keyboardShowing {
                    adjustPosition()
                } else {
                    restorePosition()
                }
                showLog("Enabled")
            } else if !enable, oldValue {   // If not disable, disable it.
                restorePosition()
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
            reloadInputViews()
            showLog("enableAutoToolbar: \(enableAutoToolbar ? "Yes" : "NO")")
        }
    }

    internal var activeConfiguration: IQActiveConfiguration = .init()

    /**
    Configurations related to the toolbar display over the keyboard.
    */
    @objc public let toolbarConfiguration: IQToolbarConfiguration = .init()

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

    /** TapGesture to resign keyboard on view's touch.
     It's a readonly property and exposed only for adding/removing dependencies
     if your added gesture does have collision with this one
     */
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

        guard let textFieldRetain: UIView = activeConfiguration.textFieldViewInfo?.textFieldView else {
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
     Disable distance handling within the scope of disabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**
     Enable distance handling within the scope of enabled distance handling viewControllers classes.
     Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledDistanceHandlingClasses list,
     then enabledDistanceHandlingClasses will be ignored.
     */
    @objc public var enabledDistanceHandlingClasses: [UIViewController.Type] = []

    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledToolbarClasses: [UIViewController.Type] = []

    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes.
     Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    @objc public var enabledToolbarClasses: [UIViewController.Type] = []

    /**
     Allowed subclasses of UIView to add all inner textField,
     this will allow to navigate between textField contains in different superview.
     Class should be kind of UIView.
     */
    @objc public var toolbarPreviousNextAllowedClasses: [UIView.Type] = []

    /**
     Disabled classes to ignore resignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    @objc public var disabledTouchResignedClasses: [UIViewController.Type] = []

    /**
     Enabled classes to forcefully enable 'resignOnTouchOutside' property.
     Class should be kind of UIViewController
     . If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    @objc public var enabledTouchResignedClasses: [UIViewController.Type] = []

    /**
     if resignOnTouchOutside is enabled then you can customize the behavior
     to not recognize gesture touches on some specific view subclasses.
     Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    @objc public var touchResignedGestureIgnoreClasses: [UIView.Type] = []

    // MARK: Third Party Library support
    /// Add TextField/TextView Notifications customized Notifications.
    /// For example while using YYTextView https://github.com/ibireme/YYText

   /**************************************************************************************/

    // MARK: Initialization/De-initialization

    /*  Singleton Object Initialization. */
    override init() {

        super.init()

        self.addActiveConfigurationObserver()

        // Creating gesture for resignOnTouchOutside. (Enhancement ID: #14)
        resignFirstResponderGesture.isEnabled = resignOnTouchOutside

        disabledDistanceHandlingClasses.append(UITableViewController.self)
        disabledDistanceHandlingClasses.append(UIInputViewController.self)
        disabledDistanceHandlingClasses.append(UIAlertController.self)

        disabledToolbarClasses.append(UIAlertController.self)
        disabledToolbarClasses.append(UIInputViewController.self)

        disabledTouchResignedClasses.append(UIAlertController.self)
        disabledTouchResignedClasses.append(UIInputViewController.self)

        toolbarPreviousNextAllowedClasses.append(UITableView.self)
        toolbarPreviousNextAllowedClasses.append(UICollectionView.self)
        toolbarPreviousNextAllowedClasses.append(IQPreviousNextView.self)

        touchResignedGestureIgnoreClasses.append(UIControl.self)
        touchResignedGestureIgnoreClasses.append(UINavigationBar.self)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        // (Bug ID: #550)
        // Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay
        // If you experience exception breakpoint issue at below line then try these solutions
        // https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
        DispatchQueue.main.async {
            let textField: UIView = UITextField()
            textField.iq.addDone(target: nil, action: #selector(self.doneAction(_:)))
            textField.iq.addPreviousNextDone(target: nil, previousAction: #selector(self.previousAction(_:)),
                                             nextAction: #selector(self.nextAction(_:)),
                                             doneAction: #selector(self.doneAction(_:)))
        }
    }

    deinit {
        //  Disable the keyboard manager.
        enable = false
    }

    // MARK: Public Methods

    /*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
    @objc public func reloadLayoutIfNeeded() {

        guard privateIsEnabled(),
              activeConfiguration.keyboardInfo.keyboardShowing,
              activeConfiguration.isReady else {
                return
        }
        adjustPosition()
    }
}

@available(iOSApplicationExtension, unavailable)
extension IQKeyboardManager: UIGestureRecognizerDelegate {

    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    @objc private func tapRecognized(_ gesture: UITapGestureRecognizer) {

        if gesture.state == .ended {

            // Resigning currently responder textField.
            resignFirstResponder()
        }
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
