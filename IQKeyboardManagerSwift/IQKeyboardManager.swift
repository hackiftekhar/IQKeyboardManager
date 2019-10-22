//
//  IQKeyboardManager.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
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
import CoreGraphics
import UIKit
import QuartzCore

///---------------------
/// MARK: IQToolbar tags
///---------------------

/**
Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

@objc public class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    /**
    Default tag for toolbar with Done button   -1002.
    */
    private static let  kIQDoneButtonToolbarTag         =   -1002
    
    /**
    Default tag for toolbar with Previous/Next buttons -1005.
    */
    private static let  kIQPreviousNextButtonToolbarTag =   -1005

    /**
     Invalid point value.
     */
    private static let  kIQCGPointInvalid = CGPoint.init(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)

    ///---------------------------
    ///  MARK: UIKeyboard handling
    ///---------------------------
    
    /**
    Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
    */
    @objc public var enable = false {
        
        didSet {
            //If not enable, enable it.
            if enable == true &&
                oldValue == false {
                //If keyboard is currently showing. Sending a fake notification for keyboardWillHide to retain view's original position.
                if let notification = _kbShowNotification {
                    keyboardWillShow(notification)
                }
                showLog("Enabled")
            } else if enable == false &&
                oldValue == true {   //If not disable, desable it.
                keyboardWillHide(nil)
                showLog("Disabled")
            }
        }
    }
    
    private func privateIsEnabled() -> Bool {
        
        var isEnabled = enable
        
//        let enableMode = _textFieldView?.enableMode
//
//        if enableMode == .enabled {
//            isEnabled = true
//        } else if enableMode == .disabled {
//            isEnabled = false
//        } else {
        
            if var textFieldViewController = _textFieldView?.viewContainingController() {
                
                //If it is searchBar textField embedded in Navigation Bar
                if _textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                    textFieldViewController = topController
                }
                
                if isEnabled == false {
                    
                    //If viewController is kind of enable viewController class, then assuming it's enabled.
                    for enabledClass in enabledDistanceHandlingClasses {
                        
                        if textFieldViewController.isKind(of: enabledClass) {
                            isEnabled = true
                            break
                        }
                    }
                }
                
                if isEnabled == true {
                    
                    //If viewController is kind of disabled viewController class, then assuming it's disabled.
                    for disabledClass in disabledDistanceHandlingClasses {
                        
                        if textFieldViewController.isKind(of: disabledClass) {
                            isEnabled = false
                            break
                        }
                    }
                    
                    //Special Controllers
                    if isEnabled == true {
                        
                        let classNameString = NSStringFromClass(type(of: textFieldViewController.self))
                        
                        //_UIAlertControllerTextFieldViewController
                        if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                            isEnabled = false
                        }
                    }
                }
            }
//        }
        
        return isEnabled
    }
    
    /**
    To set keyboard distance from textField. can't be less than zero. Default is 10.0.
    */
    @objc public var keyboardDistanceFromTextField: CGFloat {
        
        set {
            _privateKeyboardDistanceFromTextField =  max(0, newValue)
            showLog("keyboardDistanceFromTextField: \(_privateKeyboardDistanceFromTextField)")
        }
        get {
            return _privateKeyboardDistanceFromTextField
        }
    }
    
    /**
     Boolean to know if keyboard is showing.
     */
    @objc public var keyboardShowing: Bool {
        
        return _privateIsKeyboardShowing
    }
    
    /**
     moved distance to the top used to maintain distance between keyboard and textField. Most of the time this will be a positive value.
     */
    @objc public var movedDistance: CGFloat {
        
        return _privateMovedDistance
    }
    
    /**
    Will be called then movedDistance will be changed
     */
    @objc public var movedDistanceChanged: ((CGFloat) -> Void)?

    /**
    Returns the default singleton instance.
    */
    @objc public class var shared: IQKeyboardManager {
        struct Static {
            //Singleton instance. Initializing keyboard manger.
            static let kbManager = IQKeyboardManager()
        }
        
        /** @return Returns the default singleton instance. */
        return Static.kbManager
    }
    
    ///-------------------------
    /// MARK: IQToolbar handling
    ///-------------------------
    
    /**
    Automatic add the IQToolbar functionality. Default is YES.
    */
    @objc public var enableAutoToolbar = true {
        
        didSet {

            privateIsEnableAutoToolbar() ? addToolbarIfRequired() : removeToolbarIfRequired()

            let enableToolbar = enableAutoToolbar ? "Yes" : "NO"

            showLog("enableAutoToolbar: \(enableToolbar)")
        }
    }
    
    private func privateIsEnableAutoToolbar() -> Bool {
        
        var enableToolbar = enableAutoToolbar
        
        if var textFieldViewController = _textFieldView?.viewContainingController() {
            
            //If it is searchBar textField embedded in Navigation Bar
            if _textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                textFieldViewController = topController
            }

            if enableToolbar == false {
                
                //If found any toolbar enabled classes then return.
                for enabledClass in enabledToolbarClasses {
                    
                    if textFieldViewController.isKind(of: enabledClass) {
                        enableToolbar = true
                        break
                    }
                }
            }
            
            if enableToolbar == true {
                
                //If found any toolbar disabled classes then return.
                for disabledClass in disabledToolbarClasses {
                    
                    if textFieldViewController.isKind(of: disabledClass) {
                        enableToolbar = false
                        break
                    }
                }
                
                //Special Controllers
                if enableToolbar == true {
                    
                    let classNameString = NSStringFromClass(type(of: textFieldViewController.self))
                    
                    //_UIAlertControllerTextFieldViewController
                    if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                        enableToolbar = false
                    }
                }
            }
        }

        return enableToolbar
    }

    /**
     /**
     IQAutoToolbarBySubviews:   Creates Toolbar according to subview's hirarchy of Textfield's in view.
     IQAutoToolbarByTag:        Creates Toolbar according to tag property of TextField's.
     IQAutoToolbarByPosition:   Creates Toolbar according to the y,x position of textField in it's superview coordinate.
     
     Default is IQAutoToolbarBySubviews.
     */
    AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
    */
    @objc public var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.bySubviews

    /**
    If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is default. Default is NO.
    */
    @objc public var shouldToolbarUsesTextFieldTintColor = false
    
    /**
    This is used for toolbar.tintColor when textfield.keyboardAppearance is UIKeyboardAppearanceDefault. If shouldToolbarUsesTextFieldTintColor is YES then this property is ignored. Default is nil and uses black color.
    */
    @objc public var toolbarTintColor: UIColor?

    /**
     This is used for toolbar.barTintColor. Default is nil.
     */
    @objc public var toolbarBarTintColor: UIColor?

    /**
     IQPreviousNextDisplayModeDefault:      Show NextPrevious when there are more than 1 textField otherwise hide.
     IQPreviousNextDisplayModeAlwaysHide:   Do not show NextPrevious buttons in any case.
     IQPreviousNextDisplayModeAlwaysShow:   Always show nextPrevious buttons, if there are more than 1 textField then both buttons will be visible but will be shown as disabled.
     */
    @objc public var previousNextDisplayMode = IQPreviousNextDisplayMode.default

    /**
     Toolbar previous/next/done button icon, If nothing is provided then check toolbarDoneBarButtonItemText to draw done button.
     */
    @objc public var toolbarPreviousBarButtonItemImage: UIImage?
    @objc public var toolbarNextBarButtonItemImage: UIImage?
    @objc public var toolbarDoneBarButtonItemImage: UIImage?

    /**
     Toolbar previous/next/done button text, If nothing is provided then system default 'UIBarButtonSystemItemDone' will be used.
     */
    @objc public var toolbarPreviousBarButtonItemText: String?
    @objc public var toolbarPreviousBarButtonItemAccessibilityLabel: String?
    @objc public var toolbarNextBarButtonItemText: String?
    @objc public var toolbarNextBarButtonItemAccessibilityLabel: String?
    @objc public var toolbarDoneBarButtonItemText: String?
    @objc public var toolbarDoneBarButtonItemAccessibilityLabel: String?

    /**
    If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
    */
    @objc public var shouldShowToolbarPlaceholder = true

    /**
    Placeholder Font. Default is nil.
    */
    @objc public var placeholderFont: UIFont?
    
    /**
     Placeholder Color. Default is nil. Which means lightGray
     */
    @objc public var placeholderColor: UIColor?
    
    /**
     Placeholder Button Color when it's treated as button. Default is nil.
     */
    @objc public var placeholderButtonColor: UIColor?

    ///--------------------------
    /// MARK: UITextView handling
    ///--------------------------
    
    /** used to adjust contentInset of UITextView. */
    private var         startingTextViewContentInsets = UIEdgeInsets()
    
    /** used to adjust scrollIndicatorInsets of UITextView. */
    private var         startingTextViewScrollIndicatorInsets = UIEdgeInsets()
    
    /** used with textView to detect a textFieldView contentInset is changed or not. (Bug ID: #92)*/
    private var         isTextViewContentInsetChanged = false

    ///---------------------------------------
    /// MARK: UIKeyboard appearance overriding
    ///---------------------------------------

    /**
    Override the keyboardAppearance for all textField/textView. Default is NO.
    */
    @objc public var overrideKeyboardAppearance = false
    
    /**
    If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
    */
    @objc public var keyboardAppearance = UIKeyboardAppearance.default

    ///-----------------------------------------------------------
    /// MARK: UITextField/UITextView Next/Previous/Resign handling
    ///-----------------------------------------------------------

    /**
    Resigns Keyboard on touching outside of UITextField/View. Default is NO.
    */
    @objc public var shouldResignOnTouchOutside = false {
        
        didSet {
            resignFirstResponderGesture.isEnabled = privateShouldResignOnTouchOutside()
            
            let shouldResign = shouldResignOnTouchOutside ? "Yes" : "NO"
            
            showLog("shouldResignOnTouchOutside: \(shouldResign)")
        }
    }
    
    /** TapGesture to resign keyboard on view's touch. It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one */
    @objc lazy public var resignFirstResponderGesture: UITapGestureRecognizer = {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self

        return tapGesture
    }()
    
    /*******************************************/
    
    private func privateShouldResignOnTouchOutside() -> Bool {
        
        var shouldResign = shouldResignOnTouchOutside
        
        let enableMode = _textFieldView?.shouldResignOnTouchOutsideMode
        
        if enableMode == .enabled {
            shouldResign = true
        } else if enableMode == .disabled {
            shouldResign = false
        } else {
            if var textFieldViewController = _textFieldView?.viewContainingController() {
                
                //If it is searchBar textField embedded in Navigation Bar
                if _textFieldView?.textFieldSearchBar() != nil, let navController = textFieldViewController as? UINavigationController, let topController = navController.topViewController {
                    textFieldViewController = topController
                }

                if shouldResign == false {
                    
                    //If viewController is kind of enable viewController class, then assuming shouldResignOnTouchOutside is enabled.
                    for enabledClass in enabledTouchResignedClasses {
                        
                        if textFieldViewController.isKind(of: enabledClass) {
                            shouldResign = true
                            break
                        }
                    }
                }
                
                if shouldResign == true {
                    
                    //If viewController is kind of disable viewController class, then assuming shouldResignOnTouchOutside is disable.
                    for disabledClass in disabledTouchResignedClasses {
                        
                        if textFieldViewController.isKind(of: disabledClass) {
                            shouldResign = false
                            break
                        }
                    }
                    
                    //Special Controllers
                    if shouldResign == true {
                        
                        let classNameString = NSStringFromClass(type(of: textFieldViewController.self))
                        
                        //_UIAlertControllerTextFieldViewController
                        if classNameString.contains("UIAlertController") && classNameString.hasSuffix("TextFieldViewController") {
                            shouldResign = false
                        }
                    }
                }
            }
        }
        
        return shouldResign
    }
    
    /**
    Resigns currently first responder field.
    */
    @objc @discardableResult public func resignFirstResponder() -> Bool {
        
        if let textFieldRetain = _textFieldView {
            
            //Resigning first responder
            let isResignFirstResponder = textFieldRetain.resignFirstResponder()
            
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            if isResignFirstResponder == false {
                //If it refuses to resign then becoming it first responder again for getting notifications callback.
                textFieldRetain.becomeFirstResponder()
                
                showLog("Refuses to resign first responder: \(textFieldRetain)")
            }
            
            return isResignFirstResponder
        }
        
        return false
    }
    
    /**
    Returns YES if can navigate to previous responder textField/textView, otherwise NO.
    */
    @objc public var canGoPrevious: Bool {
        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                
                //Getting index of current textField.
                if let index = textFields.firstIndex(of: textFieldRetain) {
                    
                    //If it is not first textField. then it's previous object canBecomeFirstResponder.
                    if index > 0 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    /**
    Returns YES if can navigate to next responder textField/textView, otherwise NO.
    */
    @objc public var canGoNext: Bool {
        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                //Getting index of current textField.
                if let index = textFields.firstIndex(of: textFieldRetain) {
                    
                    //If it is not first textField. then it's previous object canBecomeFirstResponder.
                    if index < textFields.count-1 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    /**
    Navigate to previous responder textField/textView.
    */
    @objc @discardableResult public func goPrevious() -> Bool {
        
        //Getting all responder view's.
        if let  textFieldRetain = _textFieldView {
            if let textFields = responderViews() {
                //Getting index of current textField.
                if let index = textFields.firstIndex(of: textFieldRetain) {
                    
                    //If it is not first textField. then it's previous object becomeFirstResponder.
                    if index > 0 {
                        
                        let nextTextField = textFields[index-1]
                        
                        let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                        
                        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                        if isAcceptAsFirstResponder == false {
                            //If next field refuses to become first responder then restoring old textField as first responder.
                            textFieldRetain.becomeFirstResponder()
                            
                            showLog("Refuses to become first responder: \(nextTextField)")
                        }
                        
                        return isAcceptAsFirstResponder
                    }
                }
            }
        }
        
        return false
    }
    
    /**
    Navigate to next responder textField/textView.
    */
    @objc @discardableResult public func goNext() -> Bool {

        //Getting all responder view's.
        if let  textFieldRetain = _textFieldView {
            if let textFields = responderViews() {
                //Getting index of current textField.
                if let index = textFields.firstIndex(of: textFieldRetain) {
                    //If it is not last textField. then it's next object becomeFirstResponder.
                    if index < textFields.count-1 {
                        
                        let nextTextField = textFields[index+1]
                        
                        let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                        
                        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                        if isAcceptAsFirstResponder == false {
                            //If next field refuses to become first responder then restoring old textField as first responder.
                            textFieldRetain.becomeFirstResponder()
                            
                            showLog("Refuses to become first responder: \(nextTextField)")
                        }
                        
                        return isAcceptAsFirstResponder
                    }
                }
            }
        }

        return false
    }
    
    /**	previousAction. */
    @objc internal func previousAction (_ barButton: IQBarButtonItem) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if canGoPrevious == true {
            
            if let textFieldRetain = _textFieldView {
                let isAcceptAsFirstResponder = goPrevious()
                
                var invocation = barButton.invocation
                var sender = textFieldRetain

                //Handling search bar special case
                do {
                    if let searchBar = textFieldRetain.textFieldSearchBar() {
                        invocation = searchBar.keyboardToolbar.previousBarButton.invocation
                        sender = searchBar
                    }
                }

                if isAcceptAsFirstResponder {
                    invocation?.invoke(from: sender)
                }
            }
        }
    }
    
    /**	nextAction. */
    @objc internal func nextAction (_ barButton: IQBarButtonItem) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if canGoNext == true {
            
            if let textFieldRetain = _textFieldView {
                let isAcceptAsFirstResponder = goNext()
                
                var invocation = barButton.invocation
                var sender = textFieldRetain

                //Handling search bar special case
                do {
                    if let searchBar = textFieldRetain.textFieldSearchBar() {
                        invocation = searchBar.keyboardToolbar.nextBarButton.invocation
                        sender = searchBar
                    }
                }

                if isAcceptAsFirstResponder {
                    invocation?.invoke(from: sender)
                }
            }
        }
    }
    
    /**	doneAction. Resigning current textField. */
    @objc internal func doneAction (_ barButton: IQBarButtonItem) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if let textFieldRetain = _textFieldView {
            //Resign textFieldView.
            let isResignedFirstResponder = resignFirstResponder()
            
            var invocation = barButton.invocation
            var sender = textFieldRetain

            //Handling search bar special case
            do {
                if let searchBar = textFieldRetain.textFieldSearchBar() {
                    invocation = searchBar.keyboardToolbar.doneBarButton.invocation
                    sender = searchBar
                }
            }

            if isResignedFirstResponder {
                invocation?.invoke(from: sender)
            }
        }
    }
    
    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {

            //Resigning currently responder textField.
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
        
        for ignoreClass in touchResignedGestureIgnoreClasses {
            
            if touch.view?.isKind(of: ignoreClass) == true {
                return false
            }
        }

        return true
    }
    
    ///-----------------------
    /// MARK: UISound handling
    ///-----------------------

    /**
    If YES, then it plays inputClick sound on next/previous/done click.
    */
    @objc public var shouldPlayInputClicks = true

    ///---------------------------
    /// MARK: UIAnimation handling
    ///---------------------------

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    @objc public var layoutIfNeededOnUpdate = false

    ///------------------------------------
    /// MARK: Class Level disabling methods
    ///------------------------------------
    
    /**
     Disable distance handling within the scope of disabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledDistanceHandlingClasses  = [UIViewController.Type]()
    
    /**
     Enable distance handling within the scope of enabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController. If same Class is added in disabledDistanceHandlingClasses list, then enabledDistanceHandlingClasses will be ignored.
     */
    @objc public var enabledDistanceHandlingClasses  = [UIViewController.Type]()
    
    /**
     Disable automatic toolbar creation within the scope of disabled toolbar viewControllers classes. Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController.
     */
    @objc public var disabledToolbarClasses  = [UIViewController.Type]()
    
    /**
     Enable automatic toolbar creation within the scope of enabled toolbar viewControllers classes. Within this scope, 'enableAutoToolbar' property is ignored. Class should be kind of UIViewController. If same Class is added in disabledToolbarClasses list, then enabledToolbarClasses will be ignore.
     */
    @objc public var enabledToolbarClasses  = [UIViewController.Type]()

    /**
     Allowed subclasses of UIView to add all inner textField, this will allow to navigate between textField contains in different superview. Class should be kind of UIView.
     */
    @objc public var toolbarPreviousNextAllowedClasses  = [UIView.Type]()
    
    /**
     Disabled classes to ignore 'shouldResignOnTouchOutside' property, Class should be kind of UIViewController.
     */
    @objc public var disabledTouchResignedClasses  = [UIViewController.Type]()
    
    /**
     Enabled classes to forcefully enable 'shouldResignOnTouchOutsite' property. Class should be kind of UIViewController. If same Class is added in disabledTouchResignedClasses list, then enabledTouchResignedClasses will be ignored.
     */
    @objc public var enabledTouchResignedClasses  = [UIViewController.Type]()
    
    /**
     if shouldResignOnTouchOutside is enabled then you can customise the behaviour to not recognise gesture touches on some specific view subclasses. Class should be kind of UIView. Default is [UIControl, UINavigationBar]
     */
    @objc public var touchResignedGestureIgnoreClasses  = [UIView.Type]()

    ///----------------------------------
    /// MARK: Third Party Library support
    /// Add TextField/TextView Notifications customised Notifications. For example while using YYTextView https://github.com/ibireme/YYText
    ///----------------------------------
    
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
    ///------------------------
    /// MARK: Private variables
    ///------------------------

    /*******************************************/

    /** To save UITextField/UITextView object voa textField/textView notifications. */
    private weak var    _textFieldView: UIView?
    
    /** To save rootViewController.view.frame.origin. */
    private var         _topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid

    /** To overcome with popGestureRecognizer issue Bug ID: #1361 */
    private weak var    _rootViewControllerWhilePopGestureRecognizerActive: UIViewController?
    private var         _topViewBeginOriginWhilePopGestureRecognizerActive = IQKeyboardManager.kIQCGPointInvalid

    /** To save rootViewController */
    private weak var    _rootViewController: UIViewController?
    
    /*******************************************/

    /** Variable to save lastScrollView that was scrolled. */
    private weak var    _lastScrollView: UIScrollView?
    
    /** LastScrollView's initial contentOffset. */
    private var         _startingContentOffset = CGPoint.zero
    
    /** LastScrollView's initial scrollIndicatorInsets. */
    private var         _startingScrollIndicatorInsets = UIEdgeInsets()
    
    /** LastScrollView's initial contentInsets. */
    private var         _startingContentInsets = UIEdgeInsets()
    
    /*******************************************/

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    private var         _kbShowNotification: Notification?
    
    /** To save keyboard rame. */
    private var         _kbFrame = CGRect.zero
    
    /** To save keyboard animation duration. */
    private var         _animationDuration: TimeInterval = 0.25
    
    /** To mimic the keyboard animation */
    #if swift(>=4.2)
    private var         _animationCurve: UIView.AnimationOptions = .curveEaseOut
    #else
    private var         _animationCurve: UIViewAnimationOptions = .curveEaseOut
    #endif

    /*******************************************/

    /** Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    private var         _privateIsKeyboardShowing = false

    private var         _privateMovedDistance: CGFloat = 0.0 {
        didSet {
            movedDistanceChanged?(_privateMovedDistance)
        }
    }
    
    /** To use with keyboardDistanceFromTextField. */
    private var         _privateKeyboardDistanceFromTextField: CGFloat = 10.0
    
    /** To know if we have any pending request to adjust view position. */
    private var         _privateHasPendingAdjustRequest = false

    /**************************************************************************************/
    
    ///--------------------------------------
    /// MARK: Initialization/Deinitialization
    ///--------------------------------------
    
    /*  Singleton Object Initialization. */
    override init() {
        
        super.init()

        self.registerAllNotifications()

        //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
        resignFirstResponderGesture.isEnabled = shouldResignOnTouchOutside
        
        //Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay (Bug ID: #550)
        //If you experience exception breakpoint issue at below line then try these solutions https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
        let textField = UITextField()
        textField.addDoneOnKeyboardWithTarget(nil, action: #selector(self.doneAction(_:)))
        textField.addPreviousNextDoneOnKeyboardWithTarget(nil, previousAction: #selector(self.previousAction(_:)), nextAction: #selector(self.nextAction(_:)), doneAction: #selector(self.doneAction(_:)))
        
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
    
    /** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
    /** It doesn't work from Swift 1.2 */
//    override public class func load() {
//        super.load()
//        
//        //Enabling IQKeyboardManager.
//        IQKeyboardManager.shared.enable = true
//    }
    
    deinit {
        //  Disable the keyboard manager.
        enable = false

        //Removing notification observers on dealloc.
        NotificationCenter.default.removeObserver(self)
    }
    
    /** Getting keyWindow. */
    private func keyWindow() -> UIWindow? {
        
        if let keyWindow = _textFieldView?.window {
            return keyWindow
        } else {
            
            struct Static {
                /** @abstract   Save keyWindow object for reuse.
                @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
                static weak var keyWindow: UIWindow?
            }

            //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
            if let originalKeyWindow = UIApplication.shared.keyWindow,
                (Static.keyWindow == nil || Static.keyWindow != originalKeyWindow) {
                Static.keyWindow = originalKeyWindow
            }

            //Return KeyWindow
            return Static.keyWindow
        }
    }

    ///-----------------------
    /// MARK: Helper Functions
    ///-----------------------
    
    private func optimizedAdjustPosition() {
        if _privateHasPendingAdjustRequest == false {
            _privateHasPendingAdjustRequest = true
            OperationQueue.main.addOperation {
                self.adjustPosition()
                self._privateHasPendingAdjustRequest = false
            }
        }
    }

    /* Adjusting RootViewController's frame according to interface orientation. */
    private func adjustPosition() {
        
        //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
        if _privateHasPendingAdjustRequest == true,
            let textFieldView = _textFieldView,
            let rootController = textFieldView.parentContainerViewController(),
            let window = keyWindow(),
            let textFieldViewRectInWindow = textFieldView.superview?.convert(textFieldView.frame, to: window),
            let textFieldViewRectInRootSuperview = textFieldView.superview?.convert(textFieldView.frame, to: rootController.view?.superview) {
            let startTime = CACurrentMediaTime()
            showLog("****** \(#function) started ******", indentation: 1)
            
            //  Getting RootViewOrigin.
            var rootViewOrigin = rootController.view.frame.origin
            
            //Maintain keyboardDistanceFromTextField
            var specialKeyboardDistanceFromTextField = textFieldView.keyboardDistanceFromTextField
            
            if let searchBar = textFieldView.textFieldSearchBar() {
                
                specialKeyboardDistanceFromTextField = searchBar.keyboardDistanceFromTextField
            }
            
            let newKeyboardDistanceFromTextField = (specialKeyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance) ? keyboardDistanceFromTextField : specialKeyboardDistanceFromTextField

            var kbSize = _kbFrame.size

            do {
                var kbFrame = _kbFrame

                kbFrame.origin.y -= newKeyboardDistanceFromTextField
                kbFrame.size.height += newKeyboardDistanceFromTextField

                //Calculating actual keyboard covered size respect to window, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
                let intersectRect = kbFrame.intersection(window.frame)
                
                if intersectRect.isNull {
                    kbSize = CGSize(width: kbFrame.size.width, height: 0)
                } else {
                    kbSize = intersectRect.size
                }
            }

            let statusBarHeight : CGFloat
            
            #if swift(>=5.1)
            if #available(iOS 13, *) {
                statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
            #else
            statusBarHeight = UIApplication.shared.statusBarFrame.height
            #endif

            let navigationBarAreaHeight: CGFloat = statusBarHeight + ( rootController.navigationController?.navigationBar.frame.height ?? 0)
            let layoutAreaHeight: CGFloat = rootController.view.layoutMargins.bottom

            let topLayoutGuide: CGFloat = max(navigationBarAreaHeight, layoutAreaHeight) + 5
            let bottomLayoutGuide: CGFloat = (textFieldView is UIScrollView && textFieldView.responds(to: #selector(getter: UITextView.isEditable))) ? 0 : rootController.view.layoutMargins.bottom  //Validation of textView for case where there is a tab bar at the bottom or running on iPhone X and textView is at the bottom.

            //  Move positive = textField is hidden.
            //  Move negative = textField is showing.
            //  Calculating move position.
            var move: CGFloat = min(textFieldViewRectInRootSuperview.minY-(topLayoutGuide), textFieldViewRectInWindow.maxY-(window.frame.height-kbSize.height)+bottomLayoutGuide)
            
            showLog("Need to move: \(move)")
            
            var superScrollView: UIScrollView?
            var superView = textFieldView.superviewOfClassType(UIScrollView.self) as? UIScrollView
            
            //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
            while let view = superView {
                
                if view.isScrollEnabled && view.shouldIgnoreScrollingAdjustment == false {
                    superScrollView = view
                    break
                } else {
                    //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                    superView = view.superviewOfClassType(UIScrollView.self) as? UIScrollView
                }
            }
            
            //If there was a lastScrollView.    //  (Bug ID: #34)
            if let lastScrollView = _lastScrollView {
                //If we can't find current superScrollView, then setting lastScrollView to it's original form.
                if superScrollView == nil {
                    
                    if lastScrollView.contentInset != self._startingContentInsets {
                        showLog("Restoring contentInset to: \(_startingContentInsets)")
                        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                            
                            lastScrollView.contentInset = self._startingContentInsets
                            lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                        })
                    }
                    
                    if lastScrollView.shouldRestoreScrollViewContentOffset == true && lastScrollView.contentOffset.equalTo(_startingContentOffset) == false {
                        showLog("Restoring contentOffset to: \(_startingContentOffset)")
                        
                        var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)

                        if #available(iOS 9, *) {
                            animatedContentOffset = textFieldView.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil
                        }

                        if animatedContentOffset {
                            lastScrollView.setContentOffset(_startingContentOffset, animated: UIView.areAnimationsEnabled)
                        } else {
                            lastScrollView.contentOffset = _startingContentOffset
                        }
                    }
                    
                    _startingContentInsets = UIEdgeInsets()
                    _startingScrollIndicatorInsets = UIEdgeInsets()
                    _startingContentOffset = CGPoint.zero
                    _lastScrollView = nil
                } else if superScrollView != lastScrollView {     //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
                    
                    if lastScrollView.contentInset != self._startingContentInsets {
                        showLog("Restoring contentInset to: \(_startingContentInsets)")
                        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                            
                            lastScrollView.contentInset = self._startingContentInsets
                            lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                        })
                    }
                    
                    if lastScrollView.shouldRestoreScrollViewContentOffset == true && lastScrollView.contentOffset.equalTo(_startingContentOffset) == false {
                        showLog("Restoring contentOffset to: \(_startingContentOffset)")
                        
                        var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)
                        
                        if #available(iOS 9, *) {
                            animatedContentOffset = textFieldView.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil
                        }
                        
                        if animatedContentOffset {
                            lastScrollView.setContentOffset(_startingContentOffset, animated: UIView.areAnimationsEnabled)
                        } else {
                            lastScrollView.contentOffset = _startingContentOffset
                        }
                    }
                    
                    _lastScrollView = superScrollView
                    if let scrollView = superScrollView {
                        _startingContentInsets = scrollView.contentInset
                        _startingContentOffset = scrollView.contentOffset

                        #if swift(>=5.1)
                        if #available(iOS 11.1, *) {
                            _startingScrollIndicatorInsets = scrollView.verticalScrollIndicatorInsets
                        } else {
                            _startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
                        }
                        #else
                        _startingScrollIndicatorInsets = scrollView.scrollIndicatorInsets
                        #endif
                    }
                    
                    showLog("Saving ScrollView New contentInset: \(_startingContentInsets) and contentOffset: \(_startingContentOffset)")
                }
                //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
            } else if let unwrappedSuperScrollView = superScrollView {    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
                _lastScrollView = unwrappedSuperScrollView
                _startingContentInsets = unwrappedSuperScrollView.contentInset
                _startingContentOffset = unwrappedSuperScrollView.contentOffset

                #if swift(>=5.1)
                if #available(iOS 11.1, *) {
                    _startingScrollIndicatorInsets = unwrappedSuperScrollView.verticalScrollIndicatorInsets
                } else {
                    _startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
                }
                #else
                _startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
                #endif

                showLog("Saving ScrollView contentInset: \(_startingContentInsets) and contentOffset: \(_startingContentOffset)")
            }
            
            //  Special case for ScrollView.
            //  If we found lastScrollView then setting it's contentOffset to show textField.
            if let lastScrollView = _lastScrollView {
                //Saving
                var lastView = textFieldView
                var superScrollView = _lastScrollView
                
                while let scrollView = superScrollView {
                    
                    var shouldContinue = false
                    
                    if move > 0 {
                        shouldContinue =  move > (-scrollView.contentOffset.y - scrollView.contentInset.top)

                    } else if let tableView = scrollView.superviewOfClassType(UITableView.self) as? UITableView {

                        shouldContinue = scrollView.contentOffset.y > 0
                        
                        if shouldContinue == true, let tableCell = textFieldView.superviewOfClassType(UITableViewCell.self) as? UITableViewCell, let indexPath = tableView.indexPath(for: tableCell), let previousIndexPath = tableView.previousIndexPath(of: indexPath) {
                            
                            let previousCellRect = tableView.rectForRow(at: previousIndexPath)
                            if previousCellRect.isEmpty == false {
                                let previousCellRectInRootSuperview = tableView.convert(previousCellRect, to: rootController.view.superview)
                                
                                move = min(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                            }
                        }
                    } else if let collectionView = scrollView.superviewOfClassType(UICollectionView.self) as? UICollectionView {
                        
                        shouldContinue = scrollView.contentOffset.y > 0
                        
                        if shouldContinue == true, let collectionCell = textFieldView.superviewOfClassType(UICollectionViewCell.self) as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: collectionCell), let previousIndexPath = collectionView.previousIndexPath(of: indexPath), let attributes = collectionView.layoutAttributesForItem(at: previousIndexPath) {

                            let previousCellRect = attributes.frame
                            if previousCellRect.isEmpty == false {
                                let previousCellRectInRootSuperview = collectionView.convert(previousCellRect, to: rootController.view.superview)
                                
                                move = min(0, previousCellRectInRootSuperview.maxY - topLayoutGuide)
                            }
                        }
                    } else {
                        
                        shouldContinue = textFieldViewRectInRootSuperview.origin.y < topLayoutGuide

                        if shouldContinue {
                            move = min(0, textFieldViewRectInRootSuperview.origin.y - topLayoutGuide)
                        }
                    }
                    
                    //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
                    if shouldContinue {
                        
                        var tempScrollView = scrollView.superviewOfClassType(UIScrollView.self) as? UIScrollView
                        var nextScrollView: UIScrollView?
                        while let view = tempScrollView {
                            
                            if view.isScrollEnabled && view.shouldIgnoreScrollingAdjustment == false {
                                nextScrollView = view
                                break
                            } else {
                                tempScrollView = view.superviewOfClassType(UIScrollView.self) as? UIScrollView
                            }
                        }
                        
                        //Getting lastViewRect.
                        if let lastViewRect = lastView.superview?.convert(lastView.frame, to: scrollView) {
                            
                            //Calculating the expected Y offset from move and scrollView's contentOffset.
                            var shouldOffsetY = scrollView.contentOffset.y - min(scrollView.contentOffset.y, -move)
                            
                            //Rearranging the expected Y offset according to the view.
                            shouldOffsetY = min(shouldOffsetY, lastViewRect.origin.y)
                            
                            //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                            //nextScrollView == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                            //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                            //shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                            if (textFieldView is UIScrollView && textFieldView.responds(to: #selector(getter: UITextView.isEditable))) &&
                                nextScrollView == nil &&
                                shouldOffsetY >= 0 {
                                
                                //  Converting Rectangle according to window bounds.
                                if let currentTextFieldViewRect = textFieldView.superview?.convert(textFieldView.frame, to: window) {
                                    
                                    //Calculating expected fix distance which needs to be managed from navigation bar
                                    let expectedFixDistance = currentTextFieldViewRect.minY - topLayoutGuide
                                    
                                    //Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                                    shouldOffsetY = min(shouldOffsetY, scrollView.contentOffset.y + expectedFixDistance)
                                    
                                    //Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic.
                                    move = 0
                                } else {
                                    //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                                    move -= (shouldOffsetY-scrollView.contentOffset.y)
                                }
                            } else {
                                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                                move -= (shouldOffsetY-scrollView.contentOffset.y)
                            }
                            
                            let newContentOffset = CGPoint(x: scrollView.contentOffset.x, y: shouldOffsetY)
                            
                            if scrollView.contentOffset.equalTo(newContentOffset) == false {

                                showLog("old contentOffset: \(scrollView.contentOffset) new contentOffset: \(newContentOffset)")
                                self.showLog("Remaining Move: \(move)")

                                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                                UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                                    
                                    var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)
                                    
                                    if #available(iOS 9, *) {
                                        animatedContentOffset = textFieldView.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil
                                    }

                                    if animatedContentOffset {
                                        scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                                    } else {
                                        scrollView.contentOffset = newContentOffset
                                    }
                                }) { _ in
                                    
                                    if scrollView is UITableView || scrollView is UICollectionView {
                                        //This will update the next/previous states
                                        self.addToolbarIfRequired()
                                    }
                                }
                            }
                        }
                        
                        //  Getting next lastView & superScrollView.
                        lastView = scrollView
                        superScrollView = nextScrollView
                    } else {
                        move = 0
                        break
                    }
                }
                
                //Updating contentInset
                if let lastScrollViewRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window) {
                    
                    let bottom: CGFloat = (kbSize.height-newKeyboardDistanceFromTextField)-(window.frame.height-lastScrollViewRect.maxY)
                    
                    // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                    
                    var bottomInset = max(_startingContentInsets.bottom, bottom)
                    
                    #if swift(>=4.0)
                    if #available(iOS 11, *) {
                        bottomInset -= lastScrollView.safeAreaInsets.bottom
                    }
                    #endif

                    var movedInsets = lastScrollView.contentInset
                    movedInsets.bottom = bottomInset

                    if lastScrollView.contentInset != movedInsets {
                        showLog("old ContentInset: \(lastScrollView.contentInset) new ContentInset: \(movedInsets)")

                        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                            lastScrollView.contentInset = movedInsets
                            
                            var newInset : UIEdgeInsets
                            
                            #if swift(>=5.1)
                            if #available(iOS 11.1, *) {
                                newInset = lastScrollView.verticalScrollIndicatorInsets
                            } else {
                                newInset = lastScrollView.scrollIndicatorInsets
                            }
                            #else
                            newInset = lastScrollView.scrollIndicatorInsets
                            #endif

                            newInset.bottom = movedInsets.bottom
                            lastScrollView.scrollIndicatorInsets = newInset
                        })
                    }
                }
            }
            //Going ahead. No else if.
            
            //Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
            //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
            //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
            if let textView = textFieldView as? UIScrollView, textFieldView.responds(to: #selector(getter: UITextView.isEditable)) {
                
//                CGRect rootSuperViewFrameInWindow = [_rootViewController.view.superview convertRect:_rootViewController.view.superview.bounds toView:keyWindow];
//
//                CGFloat keyboardOverlapping = CGRectGetMaxY(rootSuperViewFrameInWindow) - keyboardYPosition;
//
//                CGFloat textViewHeight = MIN(CGRectGetHeight(_textFieldView.frame), (CGRectGetHeight(rootSuperViewFrameInWindow)-topLayoutGuide-keyboardOverlapping));

                let keyboardYPosition = window.frame.height - (kbSize.height-newKeyboardDistanceFromTextField)
                var rootSuperViewFrameInWindow = window.frame
                if let rootSuperview = rootController.view.superview {
                    rootSuperViewFrameInWindow = rootSuperview.convert(rootSuperview.bounds, to: window)
                }
                
                let keyboardOverlapping = rootSuperViewFrameInWindow.maxY - keyboardYPosition
                
                let textViewHeight = min(textView.frame.height, rootSuperViewFrameInWindow.height-topLayoutGuide-keyboardOverlapping)
                
                if textView.frame.size.height-textView.contentInset.bottom>textViewHeight {
                    //_isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                    if self.isTextViewContentInsetChanged == false {
                        self.startingTextViewContentInsets = textView.contentInset
                        
                        #if swift(>=5.1)
                        if #available(iOS 11.1, *) {
                            self.startingTextViewScrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                        } else {
                            self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets
                        }
                        #else
                        self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets
                        #endif
                    }

                    self.isTextViewContentInsetChanged = true

                    var newContentInset = textView.contentInset
                    newContentInset.bottom = textView.frame.size.height-textViewHeight

                    #if swift(>=4.0)
                    if #available(iOS 11, *) {
                        newContentInset.bottom -= textView.safeAreaInsets.bottom
                    }
                    #endif

                    if textView.contentInset != newContentInset {
                        self.showLog("\(textFieldView) Old UITextView.contentInset: \(textView.contentInset) New UITextView.contentInset: \(newContentInset)")

                        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                            
                            textView.contentInset = newContentInset
                            textView.scrollIndicatorInsets = newContentInset
                        }, completion: { (_) -> Void in })
                    }
                }
            }
                
            //  +Positive or zero.
            if move >= 0 {
                
                rootViewOrigin.y = max(rootViewOrigin.y - move, min(0, -(kbSize.height-newKeyboardDistanceFromTextField)))

                if rootController.view.frame.origin.equalTo(rootViewOrigin) == false {
                    showLog("Moving Upward")
                    
                    UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                        
                        var rect = rootController.view.frame
                        rect.origin = rootViewOrigin
                        rootController.view.frame = rect
                        
                        //Animating content if needed (Bug ID: #204)
                        if self.layoutIfNeededOnUpdate == true {
                            //Animating content (Bug ID: #160)
                            rootController.view.setNeedsLayout()
                            rootController.view.layoutIfNeeded()
                        }
                        
                        self.showLog("Set \(rootController) origin to: \(rootViewOrigin)")
                    })
                }
                
                _privateMovedDistance = (_topViewBeginOrigin.y-rootViewOrigin.y)
            } else {  //  -Negative
                let disturbDistance: CGFloat = rootViewOrigin.y-_topViewBeginOrigin.y
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if disturbDistance <= 0 {
                    
                    rootViewOrigin.y -= max(move, disturbDistance)
                    
                    if rootController.view.frame.origin.equalTo(rootViewOrigin) == false {
                        showLog("Moving Downward")
                        //  Setting adjusted rootViewRect
                        //  Setting adjusted rootViewRect
                        
                        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                            
                            var rect = rootController.view.frame
                            rect.origin = rootViewOrigin
                            rootController.view.frame = rect
                            
                            //Animating content if needed (Bug ID: #204)
                            if self.layoutIfNeededOnUpdate == true {
                                //Animating content (Bug ID: #160)
                                rootController.view.setNeedsLayout()
                                rootController.view.layoutIfNeeded()
                            }
                            
                            self.showLog("Set \(rootController) origin to: \(rootViewOrigin)")
                        })
                    }
                    
                    _privateMovedDistance = (_topViewBeginOrigin.y-rootViewOrigin.y)
                }
            }
        
            let elapsedTime = CACurrentMediaTime() - startTime
            showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
        }
    }

    private func restorePosition() {
        
        _privateHasPendingAdjustRequest = false
        
        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        if _topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == false {
            
            if let rootViewController = _rootViewController {
                
                if rootViewController.view.frame.origin.equalTo(self._topViewBeginOrigin) == false {
                    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                    UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                        
                        self.showLog("Restoring \(rootViewController) origin to: \(self._topViewBeginOrigin)")
                        
                        //  Setting it's new frame
                        var rect = rootViewController.view.frame
                        rect.origin = self._topViewBeginOrigin
                        rootViewController.view.frame = rect
                        
                        //Animating content if needed (Bug ID: #204)
                        if self.layoutIfNeededOnUpdate == true {
                            //Animating content (Bug ID: #160)
                            rootViewController.view.setNeedsLayout()
                            rootViewController.view.layoutIfNeeded()
                        }
                    })
                }
                
                self._privateMovedDistance = 0
                
                if rootViewController.navigationController?.interactivePopGestureRecognizer?.state == .began {
                    self._rootViewControllerWhilePopGestureRecognizerActive = rootViewController
                    self._topViewBeginOriginWhilePopGestureRecognizerActive = self._topViewBeginOrigin
                }
                
                _rootViewController = nil
            }
        }
    }

    ///---------------------
    /// MARK: Public Methods
    ///---------------------
    
    /*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
    @objc public func reloadLayoutIfNeeded() {

        if privateIsEnabled() == true {
            if _privateIsKeyboardShowing == true,
                _topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == false,
                let textFieldView = _textFieldView,
                textFieldView.isAlertViewTextField() == false {
                optimizedAdjustPosition()
            }
        }
    }

    ///-------------------------------
    /// MARK: UIKeyboard Notifications
    ///-------------------------------

    /*  UIKeyboardWillShowNotification. */
    @objc internal func keyboardWillShow(_ notification: Notification?) {
        
        _kbShowNotification = notification

        //  Boolean to know keyboard is showing/hiding
        _privateIsKeyboardShowing = true
        
        let oldKBFrame = _kbFrame

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
                _animationCurve = .init(rawValue: curve)
            } else {
                _animationCurve = .curveEaseOut
            }
            
            //  Getting keyboard animation duration
            if let duration = info[durationUserInfoKey] as? TimeInterval {
                
                //Saving animation duration
                if duration != 0.0 {
                    _animationDuration = duration
                }
            } else {
                _animationDuration = 0.25
            }
            
            //  Getting UIKeyboardSize.
            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                
                _kbFrame = kbFrame
                showLog("UIKeyboard Frame: \(_kbFrame)")
            }
        }

        if privateIsEnabled() == false {
            return
        }
        
        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //  (Bug ID: #5)
        if let textFieldView = _textFieldView, _topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == true {
            
            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            _rootViewController = textFieldView.parentContainerViewController()
            if let controller = _rootViewController {
                
                if _rootViewControllerWhilePopGestureRecognizerActive == controller {
                    _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive
                } else {
                    _topViewBeginOrigin = controller.view.frame.origin
                }

                _rootViewControllerWhilePopGestureRecognizerActive = nil
                _topViewBeginOriginWhilePopGestureRecognizerActive = IQKeyboardManager.kIQCGPointInvalid
                
                self.showLog("Saving \(controller) beginning origin: \(self._topViewBeginOrigin)")
            }
        }

        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if _kbFrame.equalTo(oldKBFrame) == false {
            
            //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            
            if _privateIsKeyboardShowing == true,
                let textFieldView = _textFieldView,
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
        
        if let textFieldView = _textFieldView,
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
            _kbShowNotification = nil
        }
        
        //  Boolean to know keyboard is showing/hiding
        _privateIsKeyboardShowing = false
        
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
                    _animationDuration = duration
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
        if let lastScrollView = _lastScrollView {
            
            UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                
                if lastScrollView.contentInset != self._startingContentInsets {
                    self.showLog("Restoring contentInset to: \(self._startingContentInsets)")
                    lastScrollView.contentInset = self._startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                }
                
                if lastScrollView.shouldRestoreScrollViewContentOffset == true && lastScrollView.contentOffset.equalTo(self._startingContentOffset) == false {
                    self.showLog("Restoring contentOffset to: \(self._startingContentOffset)")
                    
                    var animatedContentOffset = false   //  (Bug ID: #1365, #1508, #1541)
                    
                    if #available(iOS 9, *) {
                        animatedContentOffset = self._textFieldView?.superviewOfClassType(UIStackView.self, belowView: lastScrollView) != nil
                    }
                    
                    if animatedContentOffset {
                        lastScrollView.setContentOffset(self._startingContentOffset, animated: UIView.areAnimationsEnabled)
                    } else {
                        lastScrollView.contentOffset = self._startingContentOffset
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
                                animatedContentOffset = self._textFieldView?.superviewOfClassType(UIStackView.self, belowView: scrollView) != nil
                            }
                            
                            if animatedContentOffset {
                                scrollView.setContentOffset(newContentOffset, animated: UIView.areAnimationsEnabled)
                            } else {
                                scrollView.contentOffset = newContentOffset
                            }
                            
                            self.showLog("Restoring contentOffset to: \(self._startingContentOffset)")
                        }
                    }
                    
                    superScrollView = scrollView.superviewOfClassType(UIScrollView.self) as? UIScrollView
                }
            })
        }
        
        restorePosition()
        
        //Reset all values
        _lastScrollView = nil
        _kbFrame = CGRect.zero
        _startingContentInsets = UIEdgeInsets()
        _startingScrollIndicatorInsets = UIEdgeInsets()
        _startingContentOffset = CGPoint.zero
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    @objc internal func keyboardDidHide(_ notification: Notification) {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)
        
        _topViewBeginOrigin = IQKeyboardManager.kIQCGPointInvalid
        
        _kbFrame = CGRect.zero

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
    
    ///-------------------------------------------
    /// MARK: UITextField/UITextView Notifications
    ///-------------------------------------------

    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    @objc internal func textFieldViewDidBeginEditing(_ notification: Notification) {

        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //  Getting object
        _textFieldView = notification.object as? UIView
        
        if overrideKeyboardAppearance == true {
            if let textInput = _textFieldView as? UITextInput {
                if textInput.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    if let textFieldView = _textFieldView as? UITextField {
                        textFieldView.keyboardAppearance = keyboardAppearance
                    } else if  let textFieldView = _textFieldView as? UITextView {
                        textFieldView.keyboardAppearance = keyboardAppearance
                    }
                    _textFieldView?.reloadInputViews()
                }
            }
        }
        
        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if privateIsEnableAutoToolbar() == true {

            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if let textView = _textFieldView as? UIScrollView, textView.responds(to: #selector(getter: UITextView.isEditable)),
                textView.inputAccessoryView == nil {
                
                UIView.animate(withDuration: 0.00001, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (_) -> Void in

                        //On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                        textView.reloadInputViews()
                })
            } else {
                //Adding toolbar
                addToolbarIfRequired()
            }
        } else {
            removeToolbarIfRequired()
        }

        resignFirstResponderGesture.isEnabled = privateShouldResignOnTouchOutside()
        _textFieldView?.window?.addGestureRecognizer(resignFirstResponderGesture)    //   (Enhancement ID: #14)

        if privateIsEnabled() == true {
            if _topViewBeginOrigin.equalTo(IQKeyboardManager.kIQCGPointInvalid) == true {    //  (Bug ID: #5)
                
                _rootViewController = _textFieldView?.parentContainerViewController()

                if let controller = _rootViewController {
                    
                    if _rootViewControllerWhilePopGestureRecognizerActive == controller {
                        _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive
                    } else {
                        _topViewBeginOrigin = controller.view.frame.origin
                    }
                    
                    _rootViewControllerWhilePopGestureRecognizerActive = nil
                    _topViewBeginOriginWhilePopGestureRecognizerActive = IQKeyboardManager.kIQCGPointInvalid

                    self.showLog("Saving \(controller) beginning origin: \(self._topViewBeginOrigin)")
                }
            }
            
            //If _textFieldView is inside ignored responder then do nothing. (Bug ID: #37, #74, #76)
            //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            if _privateIsKeyboardShowing == true,
                let textFieldView = _textFieldView,
                textFieldView.isAlertViewTextField() == false {
                
                //  keyboard is already showing. adjust position.
                optimizedAdjustPosition()
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
    
    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    @objc internal func textFieldViewDidEndEditing(_ notification: Notification) {
        
        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //Removing gesture recognizer   (Enhancement ID: #14)
        _textFieldView?.window?.removeGestureRecognizer(resignFirstResponderGesture)
        
        // We check if there's a change in original frame or not.
        
        if let textView = _textFieldView as? UIScrollView, textView.responds(to: #selector(getter: UITextView.isEditable)) {

            if isTextViewContentInsetChanged == true {
                self.isTextViewContentInsetChanged = false

                if textView.contentInset != self.startingTextViewContentInsets {
                    self.showLog("Restoring textView.contentInset to: \(self.startingTextViewContentInsets)")
                    
                    UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                        
                        //Setting textField to it's initial contentInset
                        textView.contentInset = self.startingTextViewContentInsets
                        textView.scrollIndicatorInsets = self.startingTextViewScrollIndicatorInsets
                        
                    }, completion: { (_) -> Void in })
                }
            }
        }
        
        //Setting object to nil
        _textFieldView = nil

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }

    ///---------------------------------------
    /// MARK: UIStatusBar Notification methods
    ///---------------------------------------
    
    /**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    @objc internal func willChangeStatusBarOrientation(_ notification: Notification) {

        let currentStatusBarOrientation : UIInterfaceOrientation
        #if swift(>=5.1)
        if #available(iOS 13, *) {
            currentStatusBarOrientation = keyWindow()?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        } else {
            currentStatusBarOrientation = UIApplication.shared.statusBarOrientation
        }
        #else
        currentStatusBarOrientation = UIApplication.shared.statusBarOrientation
        #endif

        #if swift(>=4.2)
        let statusBarUserInfoKey    = UIApplication.statusBarOrientationUserInfoKey
        #else
        let statusBarUserInfoKey    = UIApplicationStatusBarOrientationUserInfoKey
        #endif

        guard let statusBarOrientation = notification.userInfo?[statusBarUserInfoKey] as? Int, currentStatusBarOrientation.rawValue != statusBarOrientation else {
            return
        }
        
        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)
        
        //If textViewContentInsetChanged is saved then restore it.
        if let textView = _textFieldView as? UITextView, textView.responds(to: #selector(getter: UITextView.isEditable)) {
            
            if isTextViewContentInsetChanged == true {

                self.isTextViewContentInsetChanged = false

                if textView.contentInset != self.startingTextViewContentInsets {
                    UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
                        
                        self.showLog("Restoring textView.contentInset to: \(self.startingTextViewContentInsets)")
                        
                        //Setting textField to it's initial contentInset
                        textView.contentInset = self.startingTextViewContentInsets
                        textView.scrollIndicatorInsets = self.startingTextViewScrollIndicatorInsets
                        
                    }, completion: { (_) -> Void in })
                }
            }
        }

        restorePosition()

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
    
    ///------------------
    /// MARK: AutoToolbar
    ///------------------
    
    /**	Get all UITextField/UITextView siblings of textFieldView. */
    private func responderViews() -> [UIView]? {
        
        var superConsideredView: UIView?

        //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for disabledClass in toolbarPreviousNextAllowedClasses {
            
            superConsideredView = _textFieldView?.superviewOfClassType(disabledClass)
            
            if superConsideredView != nil {
                break
            }
        }
    
    //If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
        if let view = superConsideredView {
            return view.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            if let textFields = _textFieldView?.responderSiblings() {
                
                //Sorting textFields according to behaviour
                switch toolbarManageBehaviour {
                    //If autoToolbar behaviour is bySubviews, then returning it.
                case IQAutoToolbarManageBehaviour.bySubviews:   return textFields
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.byTag:    return textFields.sortedArrayByTag()
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.byPosition:    return textFields.sortedArrayByPosition()
                }
            } else {
                return nil
            }
        }
    }
    
    /** Add toolbar if it is required to add on textFields and it's siblings. */
    private func addToolbarIfRequired() {
        
        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //	Getting all the sibling textFields.
        if let siblings = responderViews(), !siblings.isEmpty {
            
            showLog("Found \(siblings.count) responder sibling(s)")
            
            if let textField = _textFieldView {
                //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
                //setInputAccessoryView: check   (Bug ID: #307)
                if textField.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
                    
                    if textField.inputAccessoryView == nil ||
                        textField.inputAccessoryView?.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag ||
                        textField.inputAccessoryView?.tag == IQKeyboardManager.kIQDoneButtonToolbarTag {
                        
                        let rightConfiguration: IQBarButtonItemConfiguration
                        
                        if let doneBarButtonItemImage = toolbarDoneBarButtonItemImage {
                            rightConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.doneAction(_:)))
                        } else if let doneBarButtonItemText = toolbarDoneBarButtonItemText {
                            rightConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.doneAction(_:)))
                        } else {
                            rightConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .done, action: #selector(self.doneAction(_:)))
                        }
                        rightConfiguration.accessibilityLabel = toolbarDoneBarButtonItemAccessibilityLabel ?? "Done"
                        
                        //	If only one object is found, then adding only Done button.
                        if (siblings.count <= 1 && previousNextDisplayMode == .default) || previousNextDisplayMode == .alwaysHide {
                            
                            textField.addKeyboardToolbarWithTarget(target: self, titleText: (shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder: nil), rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: nil, nextBarButtonConfiguration: nil)

                            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQDoneButtonToolbarTag //  (Bug ID: #78)
                            
                        } else if previousNextDisplayMode == .default || previousNextDisplayMode == .alwaysShow {
                            
                            let prevConfiguration: IQBarButtonItemConfiguration
                            
                            if let doneBarButtonItemImage = toolbarPreviousBarButtonItemImage {
                                prevConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.previousAction(_:)))
                            } else if let doneBarButtonItemText = toolbarPreviousBarButtonItemText {
                                prevConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.previousAction(_:)))
                            } else {
                                prevConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardPreviousImage() ?? UIImage()), action: #selector(self.previousAction(_:)))
                            }
                            prevConfiguration.accessibilityLabel = toolbarPreviousBarButtonItemAccessibilityLabel ?? "Previous"

                            let nextConfiguration: IQBarButtonItemConfiguration
                            
                            if let doneBarButtonItemImage = toolbarNextBarButtonItemImage {
                                nextConfiguration = IQBarButtonItemConfiguration(image: doneBarButtonItemImage, action: #selector(self.nextAction(_:)))
                            } else if let doneBarButtonItemText = toolbarNextBarButtonItemText {
                                nextConfiguration = IQBarButtonItemConfiguration(title: doneBarButtonItemText, action: #selector(self.nextAction(_:)))
                            } else {
                                nextConfiguration = IQBarButtonItemConfiguration(image: (UIImage.keyboardNextImage() ?? UIImage()), action: #selector(self.nextAction(_:)))
                            }
                            nextConfiguration.accessibilityLabel = toolbarNextBarButtonItemAccessibilityLabel ?? "Next"

                            textField.addKeyboardToolbarWithTarget(target: self, titleText: (shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder: nil), rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)

                            textField.inputAccessoryView?.tag = IQKeyboardManager.kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
                        }

                        let toolbar = textField.keyboardToolbar

                        //Setting toolbar tintColor //  (Enhancement ID: #30)
                        if shouldToolbarUsesTextFieldTintColor {
                            toolbar.tintColor = textField.tintColor
                        } else if let tintColor = toolbarTintColor {
                            toolbar.tintColor = tintColor
                        } else {
                            toolbar.tintColor = nil
                        }

                        //  Setting toolbar to keyboard.
                        if let textFieldView = textField as? UITextInput {
                            
                            //Bar style according to keyboard appearance
                            switch textFieldView.keyboardAppearance {
                                
                            case .dark?:
                                toolbar.barStyle = .black
                                toolbar.barTintColor = nil
                            default:
                                toolbar.barStyle = .default
                                toolbar.barTintColor = toolbarBarTintColor
                            }
                        }

                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if shouldShowToolbarPlaceholder == true &&
                            textField.shouldHideToolbarPlaceholder == false {
                            
                            //Updating placeholder font to toolbar.     //(Bug ID: #148, #272)
                            if toolbar.titleBarButton.title == nil ||
                                toolbar.titleBarButton.title != textField.drawingToolbarPlaceholder {
                                toolbar.titleBarButton.title = textField.drawingToolbarPlaceholder
                            }
                            
                            //Setting toolbar title font.   //  (Enhancement ID: #30)
                            if let font = placeholderFont {
                                toolbar.titleBarButton.titleFont = font
                            }

                            //Setting toolbar title color.   //  (Enhancement ID: #880)
                            if let color = placeholderColor {
                                toolbar.titleBarButton.titleColor = color
                            }
                            
                            //Setting toolbar button title color.   //  (Enhancement ID: #880)
                            if let color = placeholderButtonColor {
                                toolbar.titleBarButton.selectableTitleColor = color
                            }

                        } else {
                            
                            toolbar.titleBarButton.title = nil
                        }
                        
                        //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                        //	If firstTextField, then previous should not be enabled.
                        if siblings.first == textField {
                            if siblings.count == 1 {
                                textField.keyboardToolbar.previousBarButton.isEnabled = false
                                textField.keyboardToolbar.nextBarButton.isEnabled = false
                            } else {
                                textField.keyboardToolbar.previousBarButton.isEnabled = false
                                textField.keyboardToolbar.nextBarButton.isEnabled = true
                            }
                        } else if siblings.last  == textField {   //	If lastTextField then next should not be enaled.
                            textField.keyboardToolbar.previousBarButton.isEnabled = true
                            textField.keyboardToolbar.nextBarButton.isEnabled = false
                        } else {
                            textField.keyboardToolbar.previousBarButton.isEnabled = true
                            textField.keyboardToolbar.nextBarButton.isEnabled = true
                        }
                    }
                }
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
    
    /** Remove any toolbar if it is IQToolbar. */
    private func removeToolbarIfRequired() {    //  (Bug ID: #18)
        
        let startTime = CACurrentMediaTime()
        showLog("****** \(#function) started ******", indentation: 1)

        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            showLog("Found \(siblings.count) responder sibling(s)")

            for view in siblings {
                
                if let toolbar = view.inputAccessoryView as? IQToolbar {

                    //setInputAccessoryView: check   (Bug ID: #307)
                    if view.responds(to: #selector(setter: UITextField.inputAccessoryView)) &&
                        (toolbar.tag == IQKeyboardManager.kIQDoneButtonToolbarTag || toolbar.tag == IQKeyboardManager.kIQPreviousNextButtonToolbarTag) {
                        
                        if let textField = view as? UITextField {
                            textField.inputAccessoryView = nil
                        } else if let textView = view as? UITextView {
                            textView.inputAccessoryView = nil
                        }

                        view.reloadInputViews()
                    }
                }
            }
        }

        let elapsedTime = CACurrentMediaTime() - startTime
        showLog("****** \(#function) ended: \(elapsedTime) seconds ******", indentation: -1)
    }
    
    /**	reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
    @objc public func reloadInputViews() {
        
        //If enabled then adding toolbar.
        if privateIsEnableAutoToolbar() == true {
            self.addToolbarIfRequired()
        } else {
            self.removeToolbarIfRequired()
        }
    }
    
    ///------------------------------------
    /// MARK: Debugging & Developer options
    ///------------------------------------
    
    @objc public var enableDebugging = false

    /**
     @warning Use below methods to completely enable/disable notifications registered by library internally. Please keep in mind that library is totally dependent on NSNotification of UITextField, UITextField, Keyboard etc. If you do unregisterAllNotifications then library will not work at all. You should only use below methods if you want to completedly disable all library functions. You should use below methods at your own risk.
     */
    @objc public func registerAllNotifications() {

        #if swift(>=4.2)
        let UIKeyboardWillShow  = UIResponder.keyboardWillShowNotification
        let UIKeyboardDidShow   = UIResponder.keyboardDidShowNotification
        let UIKeyboardWillHide  = UIResponder.keyboardWillHideNotification
        let UIKeyboardDidHide   = UIResponder.keyboardDidHideNotification
        
        let UITextFieldTextDidBeginEditing  = UITextField.textDidBeginEditingNotification
        let UITextFieldTextDidEndEditing    = UITextField.textDidEndEditingNotification
        
        let UITextViewTextDidBeginEditing   = UITextView.textDidBeginEditingNotification
        let UITextViewTextDidEndEditing     = UITextView.textDidEndEditingNotification
        
        let UIApplicationWillChangeStatusBarOrientation = UIApplication.willChangeStatusBarOrientationNotification
        #else
        let UIKeyboardWillShow  = Notification.Name.UIKeyboardWillShow
        let UIKeyboardDidShow   = Notification.Name.UIKeyboardDidShow
        let UIKeyboardWillHide  = Notification.Name.UIKeyboardWillHide
        let UIKeyboardDidHide   = Notification.Name.UIKeyboardDidHide
        
        let UITextFieldTextDidBeginEditing  = Notification.Name.UITextFieldTextDidBeginEditing
        let UITextFieldTextDidEndEditing    = Notification.Name.UITextFieldTextDidEndEditing
        
        let UITextViewTextDidBeginEditing   = Notification.Name.UITextViewTextDidBeginEditing
        let UITextViewTextDidEndEditing     = Notification.Name.UITextViewTextDidEndEditing
        
        let UIApplicationWillChangeStatusBarOrientation = Notification.Name.UIApplicationWillChangeStatusBarOrientation
        #endif

        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIKeyboardDidHide, object: nil)
        
        //  Registering for UITextField notification.
        registerTextFieldViewClass(UITextField.self, didBeginEditingNotificationName: UITextFieldTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextFieldTextDidEndEditing.rawValue)
        
        //  Registering for UITextView notification.
        registerTextFieldViewClass(UITextView.self, didBeginEditingNotificationName: UITextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextViewTextDidEndEditing.rawValue)
        
        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.willChangeStatusBarOrientation(_:)), name: UIApplicationWillChangeStatusBarOrientation, object: UIApplication.shared)
    }

    @objc public func unregisterAllNotifications() {
        
        #if swift(>=4.2)
        let UIKeyboardWillShow  = UIResponder.keyboardWillShowNotification
        let UIKeyboardDidShow   = UIResponder.keyboardDidShowNotification
        let UIKeyboardWillHide  = UIResponder.keyboardWillHideNotification
        let UIKeyboardDidHide   = UIResponder.keyboardDidHideNotification
        
        let UITextFieldTextDidBeginEditing  = UITextField.textDidBeginEditingNotification
        let UITextFieldTextDidEndEditing    = UITextField.textDidEndEditingNotification
        
        let UITextViewTextDidBeginEditing   = UITextView.textDidBeginEditingNotification
        let UITextViewTextDidEndEditing     = UITextView.textDidEndEditingNotification
        
        let UIApplicationWillChangeStatusBarOrientation = UIApplication.willChangeStatusBarOrientationNotification
        #else
        let UIKeyboardWillShow  = Notification.Name.UIKeyboardWillShow
        let UIKeyboardDidShow   = Notification.Name.UIKeyboardDidShow
        let UIKeyboardWillHide  = Notification.Name.UIKeyboardWillHide
        let UIKeyboardDidHide   = Notification.Name.UIKeyboardDidHide
        
        let UITextFieldTextDidBeginEditing  = Notification.Name.UITextFieldTextDidBeginEditing
        let UITextFieldTextDidEndEditing    = Notification.Name.UITextFieldTextDidEndEditing
        
        let UITextViewTextDidBeginEditing   = Notification.Name.UITextViewTextDidBeginEditing
        let UITextViewTextDidEndEditing     = Notification.Name.UITextViewTextDidEndEditing
        
        let UIApplicationWillChangeStatusBarOrientation = Notification.Name.UIApplicationWillChangeStatusBarOrientation
        #endif

        //  Unregistering for keyboard notification.
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardDidHide, object: nil)

        //  Unregistering for UITextField notification.
        unregisterTextFieldViewClass(UITextField.self, didBeginEditingNotificationName: UITextFieldTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextFieldTextDidEndEditing.rawValue)
        
        //  Unregistering for UITextView notification.
        unregisterTextFieldViewClass(UITextView.self, didBeginEditingNotificationName: UITextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: UITextViewTextDidEndEditing.rawValue)
        
        //  Unregistering for orientation changes notification
        NotificationCenter.default.removeObserver(self, name: UIApplicationWillChangeStatusBarOrientation, object: UIApplication.shared)
    }

    private func showLog(_ logString: String, indentation: Int = 0) {
        
        struct Static {
            static var indentation = 0
        }

        if indentation < 0 {
            Static.indentation = max(0, Static.indentation + indentation)
        }

        if enableDebugging {

            var preLog = "IQKeyboardManager"

            for _ in 0 ... Static.indentation {
                preLog += "|\t"
            }
            print(preLog + logString)
        }

        if indentation > 0 {
            Static.indentation += indentation
        }
    }
}
