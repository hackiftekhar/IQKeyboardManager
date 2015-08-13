//
//  IQKeyboardManager.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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

///---------------------
/// MARK: IQToolbar tags
///---------------------

/**
Default tag for toolbar with Done button   -1002.
*/
let  kIQDoneButtonToolbarTag : Int          =   -1002

/**
Default tag for toolbar with Previous/Next buttons -1005.
*/
let  kIQPreviousNextButtonToolbarTag : Int  =   -1005

/**
Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    
    ///---------------------------
    ///  MARK: UIKeyboard handling
    ///---------------------------
    
    /**
    Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
    */
    var enable: Bool = false {
        
        didSet {
            //If not enable, enable it.
            if enable == true && oldValue == false {
                //If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
                if _kbShowNotification != nil {
                    keyboardWillShow(_kbShowNotification)
                }
                _IQShowLog("enabled")
            } else if enable == false && oldValue == true {   //If not disable, desable it.
                keyboardWillHide(nil)
                _IQShowLog("disabled")
            }
        }
    }
    
    /**
    To set keyboard distance from textField. can't be less than zero. Default is 10.0.
    */
    var keyboardDistanceFromTextField: CGFloat {
        
        set {
            _privateKeyboardDistanceFromTextField =  max(0, newValue)
            _IQShowLog("keyboardDistanceFromTextField: \(_privateKeyboardDistanceFromTextField)")
        }
        get {
            return _privateKeyboardDistanceFromTextField
        }
    }

    /**
    Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.
    */
    var preventShowingBottomBlankSpace = true
    
    /**
    Returns the default singleton instance.
    */
    class func sharedManager() -> IQKeyboardManager {
        
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
    var enableAutoToolbar: Bool = true {
        
        didSet {

            enableAutoToolbar ?addToolbarIfRequired():removeToolbarIfRequired()

            let enableToolbar = enableAutoToolbar ? "Yes" : "NO"

            _IQShowLog("enableAutoToolbar: \(enableToolbar)")
        }
    }
    
    /**
    AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
    */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /**
    If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO.
    */
    var shouldToolbarUsesTextFieldTintColor = false
    
    /**
    If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
    */
    var shouldShowTextFieldPlaceholder = true
    
    /**
    Placeholder Font. Default is nil.
    */
    var placeholderFont: UIFont?
    
    
    ///--------------------------
    /// MARK: UITextView handling
    ///--------------------------
    
    /**
    Adjust textView's frame when it is too big in height. Default is NO.
    */
    var canAdjustTextView = false

    /**
    Adjust textView's contentInset to fix a bug. for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string Default is YES.
    */
    var shouldFixTextViewClip = true

    
    ///---------------------------------------
    /// MARK: UIKeyboard appearance overriding
    ///---------------------------------------

    /**
    Override the keyboardAppearance for all textField/textView. Default is NO.
    */
    var overrideKeyboardAppearance = false
    
    /**
    If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
    */
    var keyboardAppearance = UIKeyboardAppearance.Default

    
    ///-----------------------------------------------------------
    /// MARK: UITextField/UITextView Next/Previous/Resign handling
    ///-----------------------------------------------------------
    
    
    /**
    Resigns Keyboard on touching outside of UITextField/View. Default is NO.
    */
    var shouldResignOnTouchOutside: Bool = false {
        
        didSet {
            _tapGesture.enabled = shouldResignOnTouchOutside
            
            let shouldResign = shouldResignOnTouchOutside ? "Yes" : "NO"
            
            _IQShowLog("shouldResignOnTouchOutside: \(shouldResign)")
        }
    }
    
    /**
    Resigns currently first responder field.
    */
    func resignFirstResponder() {
        
        if let textFieldRetain = _textFieldView {
            
            //Resigning first responder
            let isResignFirstResponder = textFieldRetain.resignFirstResponder()
            
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            if isResignFirstResponder == false {
                //If it refuses to resign then becoming it first responder again for getting notifications callback.
                textFieldRetain.becomeFirstResponder()
                
                _IQShowLog("Refuses to resign first responder: \(_textFieldView?._IQDescription())")
            }
        }
    }
    
    /**
    Returns YES if can navigate to previous responder textField/textView, otherwise NO.
    */
    var canGoPrevious: Bool {
        
        get {
            //Getting all responder view's.
            if let textFields = responderViews() {
                if let  textFieldRetain = _textFieldView {
                    if textFields.containsObject(textFieldRetain) == true {
                        //Getting index of current textField.
                        let index = textFields.indexOfObject(textFieldRetain)
                        
                        //If it is not first textField. then it's previous object canBecomeFirstResponder.
                        if index > 0 {
                            
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
    
    /**
    Returns YES if can navigate to next responder textField/textView, otherwise NO.
    */
    var canGoNext: Bool {
        
        get {
            //Getting all responder view's.
            if let textFields = responderViews() {
                if let  textFieldRetain = _textFieldView {
                    if textFields.containsObject(textFieldRetain) == true {
                        
                        //Getting index of current textField.
                        let index = textFields.indexOfObject(textFieldRetain)
                        
                        //If it is not last textField. then it's next object canBecomeFirstResponder.
                        if index < textFields.count-1 {
                            
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
    
    /**
    Navigate to previous responder textField/textView.
    */
    func goPrevious() {
        
        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                if textFields.containsObject(textFieldRetain) == true {
                    //Getting index of current textField.
                    let index = textFields.indexOfObject(textFieldRetain)
                    
                    //If it is not first textField. then it's previous object becomeFirstResponder.
                    if index > 0 {
                        
                        let nextTextField = textFields[index-1] as! UIView
                        
                        let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                        
                        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                        if isAcceptAsFirstResponder == false {
                            //If next field refuses to become first responder then restoring old textField as first responder.
                            textFieldRetain.becomeFirstResponder()
                            
                            _IQShowLog("Refuses to become first responder: \(nextTextField._IQDescription())")
                        }
                    }
                }
            }
        }
    }
    
    /**
    Navigate to next responder textField/textView.
    */
    func goNext() {

        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                if textFields.containsObject(textFieldRetain) == true {
                    
                    //Getting index of current textField.
                    let index = textFields.indexOfObject(textFieldRetain)
                    
                    //If it is not last textField. then it's next object becomeFirstResponder.
                    if index < textFields.count-1 {
                        
                        let nextTextField = textFields[index+1] as! UIView
                        
                        let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                        
                        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                        if isAcceptAsFirstResponder == false {
                            //If next field refuses to become first responder then restoring old textField as first responder.
                            textFieldRetain.becomeFirstResponder()
                            
                            _IQShowLog("Refuses to become first responder: \(nextTextField._IQDescription())")
                        }
                    }
                }
            }
        }
    }
    
    /**	previousAction. */
    func previousAction (segmentedControl : AnyObject?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.currentDevice().playInputClick()
        }
        
        if canGoPrevious == true {
            goPrevious()
        }
    }
    
    /**	nextAction. */
    func nextAction (segmentedControl : AnyObject?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.currentDevice().playInputClick()
        }
        
        if canGoNext {
            goNext()
        }
    }
    
    /**	doneAction. Resigning current textField. */
    func doneAction (barButton : IQBarButtonItem?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.currentDevice().playInputClick()
        }
        
        //Resign textFieldView.
        resignFirstResponder()
    }
    
    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    func tapRecognized(gesture: UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.Ended {
            //Resigning currently responder textField.
            gesture.view?.endEditing(true)
        }
    }
    
    /** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145)
        return (touch.view is UIControl || touch.view is UINavigationBar) ? false : true
    }
    
    ///----------------------------
    /// MARK: UIScrollView handling
    ///----------------------------
    
    /**
    Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
    */
    var shouldRestoreScrollViewContentOffset = false

    
    ///-----------------------
    /// MARK: UISound handling
    ///-----------------------

    /**
    If YES, then it plays inputClick sound on next/previous/done click.
    */
    var shouldPlayInputClicks = false
    
    
    ///---------------------------
    /// MARK: UIAnimation handling
    ///---------------------------

    /**
    If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
    
    @warning Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.
    */
    var shouldAdoptDefaultKeyboardAnimation = true

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    var layoutIfNeededOnUpdate = false

    ///------------------------------------
    /// MARK: Class Level disabling methods
    ///------------------------------------
    
    /**
    Disable adjusting view in disabledClass
    
    @param disabledClass Class in which library should not adjust view to show textField.
    */
    func disableInViewControllerClass(disabledClass : AnyClass) {
        _disabledClasses.addObject(NSStringFromClass(disabledClass))
    }
    
    /**
    Re-enable adjusting textField in disabledClass
    
    @param disabledClass Class in which library should re-enable adjust view to show textField.
    */
    func removeDisableInViewControllerClass(disabledClass : AnyClass) {
        _disabledClasses.removeObject(NSStringFromClass(disabledClass))
    }
    
    /**
    Returns YES if ViewController class is disabled for library, otherwise returns NO.
    
    @param disabledClass Class which is to check for it's disability.
    */
    func isDisableInViewControllerClass(disabledClass : AnyClass) -> Bool {
        return _disabledClasses.containsObject(NSStringFromClass(disabledClass))
    }
    
    /**
    Disable automatic toolbar creation in in toolbarDisabledClass
    
    @param toolbarDisabledClass Class in which library should not add toolbar over textField.
    */
    func disableToolbarInViewControllerClass(toolbarDisabledClass : AnyClass) {
        _disabledToolbarClasses.addObject(NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Re-enable automatic toolbar creation in in toolbarDisabledClass
    
    @param toolbarDisabledClass Class in which library should re-enable automatic toolbar creation over textField.
    */
    func removeDisableToolbarInViewControllerClass(toolbarDisabledClass : AnyClass) {
        _disabledToolbarClasses.removeObject(NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Returns YES if toolbar is disabled in ViewController class, otherwise returns NO.
    
    @param toolbarDisabledClass Class which is to check for toolbar disability.
    */
    func isDisableToolbarInViewControllerClass(toolbarDisabledClass : AnyClass) -> Bool {
        return _disabledToolbarClasses.containsObject(NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Consider provided customView class as superView of all inner textField for calculating next/previous button logic.
    
    @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should consider all inner textField as siblings and add next/previous accordingly.
    */
    func considerToolbarPreviousNextInViewClass(toolbarPreviousNextConsideredClass : AnyClass) {
        _toolbarPreviousNextConsideredClass.addObject(NSStringFromClass(toolbarPreviousNextConsideredClass))
    }
    
    /**
    Remove Consideration for provided customView class as superView of all inner textField for calculating next/previous button logic.
    
    @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should remove consideration for all inner textField as superView.
    */
    func removeConsiderToolbarPreviousNextInViewClass(toolbarPreviousNextConsideredClass : AnyClass) {
        _toolbarPreviousNextConsideredClass.removeObject(NSStringFromClass(toolbarPreviousNextConsideredClass))
    }
    
    /**
    Returns YES if inner hierarchy is considered for previous/next in class, otherwise returns NO.
    
    @param toolbarPreviousNextConsideredClass Class which is to check for previous next consideration
    */
    func isConsiderToolbarPreviousNextInViewClass(toolbarPreviousNextConsideredClass : AnyClass) -> Bool {
        return _toolbarPreviousNextConsideredClass.containsObject(NSStringFromClass(toolbarPreviousNextConsideredClass))
    }


    /**************************************************************************************/
    ///------------------------
    /// MARK: Private variables
    ///------------------------

    /*******************************************/

    /** To save UITextField/UITextView object voa textField/textView notifications. */
    private weak var    _textFieldView: UIView?
    
    /** used with canAdjustTextView boolean. */
    private var         _textFieldViewIntialFrame = CGRectZero
    
    /** To save rootViewController.view.frame. */
    private var         _topViewBeginRect = CGRectZero
    
    /** To save rootViewController */
    private weak var    _rootViewController: UIViewController?
    
    /** used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
    private var         _isTextFieldViewFrameChanged = false
    
    /*******************************************/

    /** Variable to save lastScrollView that was scrolled. */
    private weak var    _lastScrollView: UIScrollView?
    
    /** LastScrollView's initial contentOffset. */
    private var         _startingContentOffset = CGPointZero
    
    /** LastScrollView's initial scrollIndicatorInsets. */
    private var         _startingScrollIndicatorInsets = UIEdgeInsetsZero
    
    /** LastScrollView's initial contentInsets. */
    private var         _startingContentInsets = UIEdgeInsetsZero
    
    /*******************************************/

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    private var         _kbShowNotification: NSNotification?
    
    /** To save keyboard size. */
    private var         _kbSize = CGSizeZero
    
    /** To save keyboard animation duration. */
    private var         _animationDuration = 0.25
    
    /** To mimic the keyboard animation */
    private var         _animationCurve = UIViewAnimationOptions.CurveEaseOut
    
    /** Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    private var         _isKeyboardShowing = false
    
    /*******************************************/

    /** TapGesture to resign keyboard on view's touch. */
    private var         _tapGesture: UITapGestureRecognizer!
    
    /*******************************************/
    
    /** Default toolbar tintColor to be used within the project. Default is black. */
    private var         _defaultToolbarTintColor = UIColor.blackColor()

    /*******************************************/
    
    /** Set of restricted classes for library */
    private var _disabledClasses  = NSMutableSet()
    
    /** Set of restricted classes for adding toolbar */
    private var _disabledToolbarClasses  = NSMutableSet()
    
    /** Set of permitted classes to add all inner textField as siblings */
    private var _toolbarPreviousNextConsideredClass  = NSMutableSet()
 
    /*******************************************/

    /** To use with keyboardDistanceFromTextField. */
    private var         _privateKeyboardDistanceFromTextField: CGFloat = 10.0
    
    /**************************************************************************************/
    
    
    ///--------------------------------------
    /// MARK: Initialization/Deinitialization
    ///--------------------------------------
    
    /*  Singleton Object Initialization. */
    override init() {
        
        super.init()

        //  Registering for keyboard notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",                name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",                name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:",                name: UIKeyboardDidHideNotification, object: nil)
        
        //  Registering for textField notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidBeginEditing:",    name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidEndEditing:",      name: UITextFieldTextDidEndEditingNotification, object: nil)
        
        //  Registering for textView notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidBeginEditing:",    name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidEndEditing:",      name: UITextViewTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidChange:",          name: UITextViewTextDidChangeNotification, object: nil)
        
        //  Registering for orientation changes notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willChangeStatusBarOrientation:",          name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)

        //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
        _tapGesture = UITapGestureRecognizer(target: self, action: "tapRecognized:")
        _tapGesture.delegate = self
        _tapGesture.enabled = shouldResignOnTouchOutside
        
        
        _disabledClasses.addObject(NSStringFromClass(UITableViewController))
        _toolbarPreviousNextConsideredClass.addObject(NSStringFromClass(UITableView))
        _toolbarPreviousNextConsideredClass.addObject(NSStringFromClass(UICollectionView))
    }
    
    
    /** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
//    override class func load() {
//        super.load()
//        
//        //Enabling IQKeyboardManager.
//        IQKeyboardManager.sharedManager().enable = true
//    }
    
    deinit {
        //  Disable the keyboard manager.
        enable = false

        //Removing notification observers on dealloc.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /** Getting keyWindow. */
    private func keyWindow() -> UIWindow? {
        
        if _textFieldView?.window != nil {
            return _textFieldView?.window
        } else {
            
            struct Static {
                /** @abstract   Save keyWindow object for reuse.
                @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
                static var keyWindow : UIWindow?
            }
            

            /*  (Bug ID: #23, #25, #73)   */
            let originalKeyWindow = UIApplication.sharedApplication().keyWindow
            
            //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
            if originalKeyWindow != nil && (Static.keyWindow == nil || Static.keyWindow != originalKeyWindow) {
                Static.keyWindow = originalKeyWindow
            }

            //Return KeyWindow
            return Static.keyWindow
        }
    }
    
    
    ///-----------------------
    /// MARK: Helper Functions
    ///-----------------------
    
    /*  Helper function to manipulate RootViewController's frame with animation. */
    private func setRootViewFrame(var frame: CGRect) {
        
        //  Getting topMost ViewController.
        var controller = _textFieldView?.topMostController()
        
        if controller == nil {
            controller = keyWindow()?.topMostController()
        }
        
        if let unwrappedController = controller {
            //frame size needs to be adjusted on iOS8 due to orientation structure changes.
            if IQ_IS_IOS8_OR_GREATER == true {
                frame.size = unwrappedController.view.frame.size
            }
            
            //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                
                //  Setting it's new frame
                unwrappedController.view.frame = frame
                self._IQShowLog("Set \(controller?._IQDescription()) frame to : \(frame)")
                
                //Animating content if needed (Bug ID: #204)
                if self.layoutIfNeededOnUpdate == true {
                    //Animating content (Bug ID: #160)
                    unwrappedController.view.setNeedsLayout()
                    unwrappedController.view.layoutIfNeeded()
                }
 
                
                }) { (animated:Bool) -> Void in}
        } else {  //  If can't get rootViewController then printing warning to user.
            _IQShowLog("You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager")
        }
    }
    
    /* Adjusting RootViewController's frame according to device orientation. */
    private func adjustFrame() {
        
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        if _textFieldView == nil {
            return
        }
        
        _IQShowLog("****** \(__FUNCTION__) %@ started ******")

        //  Boolean to know keyboard is showing/hiding
        _isKeyboardShowing = true
        
        //  Getting KeyWindow object.
        let optionalWindow = keyWindow()
        
        //  Getting RootViewController.  (Bug ID: #1, #4)
        var optionalRootController = _textFieldView?.topMostController()
        if optionalRootController == nil {
            optionalRootController = keyWindow()?.topMostController()
        }
        
        //  Converting Rectangle according to window bounds.
        let optionalTextFieldViewRect = _textFieldView?.superview?.convertRect(_textFieldView!.frame, toView: optionalWindow)

        if optionalRootController == nil || optionalWindow == nil || optionalTextFieldViewRect == nil {
            return
        }
        
        let rootController = optionalRootController!
        let window = optionalWindow!
        let textFieldView = _textFieldView!
        let textFieldViewRect = optionalTextFieldViewRect!
        
        //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
        let interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation

        //  Getting RootViewRect.
        var rootViewRect = rootController.view.frame

        //Getting statusBarFrame
        var topLayoutGuide : CGFloat = 0
        
       let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        
        switch interfaceOrientation {
        case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
            topLayoutGuide = CGRectGetWidth(statusBarFrame)
        case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
            topLayoutGuide = CGRectGetHeight(statusBarFrame)
        default:    break
        }

        var move : CGFloat = 0.0
        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        
        //  Calculating move position. Common for both normal and special cases.
        switch interfaceOrientation {
        case UIInterfaceOrientation.LandscapeLeft:
            move = min(CGRectGetMinX(textFieldViewRect)-(topLayoutGuide+5), CGRectGetMaxX(textFieldViewRect)-(CGRectGetWidth(window.frame)-_kbSize.width))
        case UIInterfaceOrientation.LandscapeRight:
            move = min(CGRectGetWidth(window.frame)-CGRectGetMaxX(textFieldViewRect)-(topLayoutGuide+5), _kbSize.width-CGRectGetMinX(textFieldViewRect))
        case UIInterfaceOrientation.Portrait:
            move = min(CGRectGetMinY(textFieldViewRect)-(topLayoutGuide+5), CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(window.frame)-_kbSize.height))
        case UIInterfaceOrientation.PortraitUpsideDown:
            move = min(CGRectGetHeight(window.frame)-CGRectGetMaxY(textFieldViewRect)-(topLayoutGuide+5), _kbSize.height-CGRectGetMinY(textFieldViewRect))
        default:    break
        }
        
        _IQShowLog("Need to move: \(move)")

        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
        let superScrollView : UIScrollView? = textFieldView.superviewOfClassType(UIScrollView) as? UIScrollView
        
        //If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastScrollView = _lastScrollView {
            //If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")

                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                    
                    lastScrollView.contentInset = self._startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                    }) { (animated:Bool) -> Void in }
                
                if shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                }
                
                _startingContentInsets = UIEdgeInsetsZero
                _startingScrollIndicatorInsets = UIEdgeInsetsZero
                _startingContentOffset = CGPointZero
                _lastScrollView = nil
            } else if superScrollView != lastScrollView {     //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")
                
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                    
                    lastScrollView.contentInset = self._startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                    }) { (animated:Bool) -> Void in }
                
                if shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                }

                _lastScrollView = superScrollView
                _startingContentInsets = superScrollView!.contentInset
                _startingScrollIndicatorInsets = superScrollView!.scrollIndicatorInsets
                _startingContentOffset = superScrollView!.contentOffset
                
                _IQShowLog("Saving New \(lastScrollView._IQDescription()) contentInset : \(_startingContentInsets) and contentOffset : \(_startingContentOffset)")
            }
            //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        } else if let unwrappedSuperScrollView = superScrollView {    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
            _lastScrollView = unwrappedSuperScrollView
            _startingContentInsets = unwrappedSuperScrollView.contentInset
            _startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
            _startingContentOffset = unwrappedSuperScrollView.contentOffset

            _IQShowLog("Saving \(unwrappedSuperScrollView._IQDescription()) contentInset : \(_startingContentInsets) and contentOffset : \(_startingContentOffset)")
        }


        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if let lastScrollView = _lastScrollView {
            //Saving
            var lastView = textFieldView
            var superScrollView = _lastScrollView
            
            while let scrollView = superScrollView {
                
                //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
                if move > 0 ? move > -scrollView.contentOffset.y - scrollView.contentInset.top : scrollView.contentOffset.y>0 {
                    
                    //Getting lastViewRect.
                    if let lastViewRect = lastView.superview?.convertRect(lastView.frame, toView: scrollView) {
                        
                        //Calculating the expected Y offset from move and scrollView's contentOffset.
                        var shouldOffsetY = scrollView.contentOffset.y - min(scrollView.contentOffset.y,-move)
                        
                        //Rearranging the expected Y offset according to the view.
                        shouldOffsetY = min(shouldOffsetY, lastViewRect.origin.y /*-5*/)   //-5 is for good UI.//Commenting -5 (Bug ID: #69)

                        
                        //[superScrollView superviewOfClassType:[UIScrollView class]] == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        //shouldOffsetY > 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                        if textFieldView is UITextView == true && scrollView.superviewOfClassType(UIScrollView) == nil && shouldOffsetY > 0 {
                            var maintainTopLayout : CGFloat = 0
                            
                            if let navigationBarFrame = textFieldView.viewController()?.navigationController?.navigationBar.frame {
                                maintainTopLayout = CGRectGetMaxY(navigationBarFrame)
                            }
                            
                            maintainTopLayout += 10.0 //For good UI
                            
                            //  Converting Rectangle according to window bounds.
                            if let currentTextFieldViewRect = textFieldView.superview?.convertRect(textFieldView.frame, toView: window) {
                                var expectedFixDistance = shouldOffsetY
                                
                                //Calculating expected fix distance which needs to be managed from navigation bar
                                switch interfaceOrientation {
                                case UIInterfaceOrientation.LandscapeLeft:
                                    expectedFixDistance = CGRectGetMinX(currentTextFieldViewRect) - maintainTopLayout
                                case UIInterfaceOrientation.LandscapeRight:
                                    expectedFixDistance = (CGRectGetWidth(window.frame)-CGRectGetMaxX(currentTextFieldViewRect)) - maintainTopLayout
                                case UIInterfaceOrientation.Portrait:
                                    expectedFixDistance = CGRectGetMinY(currentTextFieldViewRect) - maintainTopLayout
                                case UIInterfaceOrientation.PortraitUpsideDown:
                                    expectedFixDistance = (CGRectGetHeight(window.frame)-CGRectGetMaxY(currentTextFieldViewRect)) - maintainTopLayout
                                default:    break
                                }
                                
                                //Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                                shouldOffsetY = min(shouldOffsetY, scrollView.contentOffset.y + expectedFixDistance)

                                //Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic.
                                move = 0
                            }
                            else {
                                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                                move -= (shouldOffsetY-scrollView.contentOffset.y)
                            }
                        }
                        else
                        {
                            //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                            move -= (shouldOffsetY-scrollView.contentOffset.y)
                        }
                        
                        
                        
                        //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                        UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                        
                            self._IQShowLog("Adjusting \(scrollView.contentOffset.y-shouldOffsetY) to \(scrollView._IQDescription()) ContentOffset")
                            
                            self._IQShowLog("Remaining Move: \(move)")
                            
                            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, shouldOffsetY)
                            }) { (animated:Bool) -> Void in }
                    }
                    
                    //  Getting next lastView & superScrollView.
                    lastView = scrollView
                    superScrollView = lastView.superviewOfClassType(UIScrollView) as? UIScrollView
                } else {
                    break
                }
            }

            
            //Updating contentInset
            if let lastScrollViewRect = lastScrollView.superview?.convertRect(lastScrollView.frame, toView: window) {
                
                var bottom : CGFloat = 0.0
                
                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:
                    bottom = _kbSize.width-(CGRectGetWidth(window.frame)-CGRectGetMaxX(lastScrollViewRect))
                case UIInterfaceOrientation.LandscapeRight:
                    bottom = _kbSize.width-CGRectGetMinX(lastScrollViewRect)
                case UIInterfaceOrientation.Portrait:
                    bottom = _kbSize.height-(CGRectGetHeight(window.frame)-CGRectGetMaxY(lastScrollViewRect))
                case UIInterfaceOrientation.PortraitUpsideDown:
                    bottom = _kbSize.height-CGRectGetMinY(lastScrollViewRect)
                default:    break
                }
                
                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                var movedInsets = lastScrollView.contentInset
                
                movedInsets.bottom = max(_startingContentInsets.bottom, bottom)
                
                _IQShowLog("\(lastScrollView._IQDescription()) old ContentInset : \(lastScrollView.contentInset)")
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                    lastScrollView.contentInset = movedInsets

                    var newInset = lastScrollView.scrollIndicatorInsets
                    newInset.bottom = movedInsets.bottom - 10
                    lastScrollView.scrollIndicatorInsets = newInset

                    }) { (animated:Bool) -> Void in }

                //Maintaining contentSize
                if lastScrollView.contentSize.height < lastScrollView.frame.size.height {
                    var contentSize = lastScrollView.contentSize
                    contentSize.height = lastScrollView.frame.size.height
                    lastScrollView.contentSize = contentSize
                }
                
                _IQShowLog("\(lastScrollView._IQDescription()) new ContentInset : \(lastScrollView.contentInset)")
            }
        }
        //Going ahead. No else if.
        
        
        //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen)
        //_canAdjustTextView    If we have permission to adjust the textView, then let's do it on behalf of user  (Enhancement ID: #15)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        //_isTextFieldViewFrameChanged  If frame is not change by library in past  (Bug ID: #92)
        if canAdjustTextView == true && _lastScrollView == nil && textFieldView is UITextView == true && _isTextFieldViewFrameChanged == false {
            var textViewHeight = CGRectGetHeight(textFieldView.frame)
 
            switch interfaceOrientation {
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                textViewHeight = min(textViewHeight, (CGRectGetWidth(window.frame)-_kbSize.width-(topLayoutGuide+5)))
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                textViewHeight = min(textViewHeight, (CGRectGetHeight(window.frame)-_kbSize.height-(topLayoutGuide+5)))
            default:    break
            }
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve.union(UIViewAnimationOptions.BeginFromCurrentState)), animations: { () -> Void in

                self._IQShowLog("\(textFieldView._IQDescription()) Old Frame : \(textFieldView.frame)")

                var textFieldViewRect = textFieldView.frame
                textFieldViewRect.size.height = textViewHeight
                textFieldView.frame = textFieldViewRect
                self._isTextFieldViewFrameChanged = true

                self._IQShowLog("\(textFieldView._IQDescription()) New Frame : \(textFieldView.frame)")

                }, completion: { (finished) -> Void in })
        }
        
        //  Special case for iPad modalPresentationStyle.
        if rootController.modalPresentationStyle == UIModalPresentationStyle.FormSheet || rootController.modalPresentationStyle == UIModalPresentationStyle.PageSheet {
            
            _IQShowLog("Found Special case for Model Presentation Style: \(rootController.modalPresentationStyle)")

            //  Positive or zero.
            if move >= 0 {
                // We should only manipulate y.
                rootViewRect.origin.y -= move
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if preventShowingBottomBlankSpace == true {
                    var minimumY: CGFloat = 0
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                        minimumY = CGRectGetWidth(window.frame)-rootViewRect.size.height-topLayoutGuide-(_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                        minimumY = (CGRectGetHeight(window.frame)-rootViewRect.size.height-topLayoutGuide)/2-(_kbSize.height-keyboardDistanceFromTextField)
                    default:    break
                    }
                    
                    rootViewRect.origin.y = max(CGRectGetMinY(rootViewRect), minimumY)
                }
                
                _IQShowLog("Moving Upward")
                //  Setting adjusted rootViewRect
                setRootViewFrame(rootViewRect)
            } else {  //  Negative
                //  Calculating disturbed distance. Pull Request #3
                let disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect)
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if disturbDistance < 0 {
                    // We should only manipulate y.
                    rootViewRect.origin.y -= max(move, disturbDistance)

                    _IQShowLog("Moving Downward")
                    //  Setting adjusted rootViewRect
                    setRootViewFrame(rootViewRect)
                }
            }
        } else {  //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
            //  Positive or zero.
            if move >= 0 {

                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.origin.x -= move
                case UIInterfaceOrientation.LandscapeRight:      rootViewRect.origin.x += move
                case UIInterfaceOrientation.Portrait:            rootViewRect.origin.y -= move
                case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.origin.y += move
                default:    break
                }
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if preventShowingBottomBlankSpace == true {
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft:
                        rootViewRect.origin.x = max(rootViewRect.origin.x, min(0, -_kbSize.width+keyboardDistanceFromTextField))
                    case UIInterfaceOrientation.LandscapeRight:
                        rootViewRect.origin.x = min(rootViewRect.origin.x, +_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait:
                        rootViewRect.origin.y = max(rootViewRect.origin.y, min(0, -_kbSize.height+keyboardDistanceFromTextField))
                    case UIInterfaceOrientation.PortraitUpsideDown:
                        rootViewRect.origin.y = min(rootViewRect.origin.y, +_kbSize.height-keyboardDistanceFromTextField)
                    default:    break
                    }
                }

                _IQShowLog("Moving Upward")
                //  Setting adjusted rootViewRect
                setRootViewFrame(rootViewRect)
            } else {  //  Negative
                var disturbDistance : CGFloat = 0
                
                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:
                    disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(_topViewBeginRect)
                case UIInterfaceOrientation.LandscapeRight:
                    disturbDistance = CGRectGetMinX(_topViewBeginRect)-CGRectGetMinX(rootViewRect)
                case UIInterfaceOrientation.Portrait:
                    disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect)
                case UIInterfaceOrientation.PortraitUpsideDown:
                    disturbDistance = CGRectGetMinY(_topViewBeginRect)-CGRectGetMinY(rootViewRect)
                default:    break
                }
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if disturbDistance < 0 {

                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.origin.x -= max(move, disturbDistance)
                    case UIInterfaceOrientation.LandscapeRight:      rootViewRect.origin.x += max(move, disturbDistance)
                    case UIInterfaceOrientation.Portrait:            rootViewRect.origin.y -= max(move, disturbDistance)
                    case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.origin.y += max(move, disturbDistance)
                    default:    break
                    }

                    _IQShowLog("Moving Downward")
                    //  Setting adjusted rootViewRect
                    //  Setting adjusted rootViewRect
                    setRootViewFrame(rootViewRect)
                }
            }
        }
        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    
    ///-------------------------------
    /// MARK: UIKeyboard Notifications
    ///-------------------------------

    /*  UIKeyboardWillShowNotification. */
    func keyboardWillShow(notification : NSNotification?) -> Void {
        
        _kbShowNotification = notification

        if enable == false {
            return
        }
        
        _IQShowLog("****** \(__FUNCTION__) started ******")

        //Due to orientation callback we need to resave it's original frame.    //  (Bug ID: #46)
        //Added _isTextFieldViewFrameChanged check. Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed. (Bug ID: #92)
        if _isTextFieldViewFrameChanged == false {
            if let textFieldView = _textFieldView {
                _textFieldViewIntialFrame = textFieldView.frame
                _IQShowLog("Saving \(textFieldView._IQDescription()) Initial frame : \(_textFieldViewIntialFrame)")
            }
        }

        //  (Bug ID: #5)
        if CGRectEqualToRect(_topViewBeginRect, CGRectZero) == true {
            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            var rootController = _textFieldView?.topMostController()
            if rootController == nil {
                rootController = keyWindow()?.topMostController()
            }
            
            if let unwrappedRootController = rootController {
                _topViewBeginRect = unwrappedRootController.view.frame
                _IQShowLog("Saving \(unwrappedRootController._IQDescription()) beginning Frame: \(_topViewBeginRect)")
            } else {
                _topViewBeginRect = CGRectZero
            }
        }

        let oldKBSize = _kbSize

        if let info = notification?.userInfo {
            
            if shouldAdoptDefaultKeyboardAnimation {

                //  Getting keyboard animation.
                if let curve = info[UIKeyboardAnimationCurveUserInfoKey]?.unsignedLongValue {
                    _animationCurve = UIViewAnimationOptions(rawValue: curve)
                }
            } else {
                _animationCurve = UIViewAnimationOptions.CurveEaseOut
            }
            
            //  Getting keyboard animation duration
            if let duration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                
                //Saving animation duration
                if duration != 0.0 {
                    _animationDuration = duration
                }
            }
            
            //  Getting UIKeyboardSize.
            if let kbFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                _kbSize = kbFrame.size
                
                _IQShowLog("UIKeyboard Size : \(_kbSize)")
            }
        }
        
        //  Getting topMost ViewController.
        var topMostController = _textFieldView?.topMostController()
        
        if topMostController == nil {
            topMostController = keyWindow()?.topMostController()
        }

        if let topController = topMostController {
            //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
            let interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : topController.interfaceOrientation
            
            let _keyboardDistanceFromTextField = keyboardDistanceFromTextField
            //    let _keyboardDistanceFromTextField = (_textFieldView.keyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance)?_keyboardDistanceFromTextField:_textFieldView.keyboardDistanceFromTextField
            
            // Adding Keyboard distance from textField.
            switch interfaceOrientation {
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                _kbSize.width += _keyboardDistanceFromTextField
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                _kbSize.height += _keyboardDistanceFromTextField
            default:    break
            }
        }
        
        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if CGSizeEqualToSize(_kbSize, oldKBSize) == false {
            
            //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            
            if _textFieldView != nil && _textFieldView?.isAlertViewTextField() == false {
                
                //Getting textField viewController
                if let textFieldViewController = _textFieldView?.viewController() {
                    
                    var shouldIgnore = false
                    
                    for disabledClassString in _disabledClasses {
                        
                        //If viewController is kind of disabled viewController class, then ignoring to adjust view.
                        if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString as! String))) {
                            shouldIgnore = true
                            break
                        }
                    }
                    
                    //If shouldn't ignore.
                    if shouldIgnore == false  {
                        //  keyboard is already showing. adjust frame.
                        adjustFrame()
                    }
                }
            }
        }
        
        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    func keyboardWillHide(notification : NSNotification?) -> Void {
        
        //If it's not a fake notification generated by [self setEnable:NO].
        if notification != nil {
            _kbShowNotification = nil
        }
        
        //If not enabled then do nothing.
        if enable == false {
            return
        }
        
        _IQShowLog("****** \(__FUNCTION__) started ******")

        //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        //    if (_textFieldView == nil)   return

        //  Boolean to know keyboard is showing/hiding
        _isKeyboardShowing = false
        
        let info : [NSObject : AnyObject]? = notification?.userInfo
        
        //  Getting keyboard animation duration
        if let duration =  info?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            if duration != 0 {
                //  Setitng keyboard animation duration
                _animationDuration = duration
            }
        }
        
        //Restoring the contentOffset of the lastScrollView
        if let lastScrollView = _lastScrollView {
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                
                lastScrollView.contentInset = self._startingContentInsets
                lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                
                if self.shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.contentOffset = self._startingContentOffset
                }
                
                self._IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(self._startingContentInsets) and contentOffset to : \(self._startingContentOffset)")

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView = self._lastScrollView?.superviewOfClassType(UIScrollView) as? UIScrollView
                
                while let scrollView = superScrollView {

                    let contentSize = CGSizeMake(max(scrollView.contentSize.width, CGRectGetWidth(scrollView.frame)), max(scrollView.contentSize.height, CGRectGetHeight(scrollView.frame)))
                    
                    let minimumY = contentSize.height - CGRectGetHeight(scrollView.frame)
                    
                    if minimumY < scrollView.contentOffset.y {
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, minimumY)
                        
                        self._IQShowLog("Restoring \(scrollView._IQDescription()) contentOffset to : \(self._startingContentOffset)")
                    }
                    
                    superScrollView = superScrollView?.superviewOfClassType(UIScrollView) as? UIScrollView
                }
                }) { (finished) -> Void in }
        }
        
        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        if CGRectEqualToRect(_topViewBeginRect, CGRectZero) == false {
            
            if let rootViewController = _rootViewController {
                
                //frame size needs to be adjusted on iOS8 due to orientation API changes.
                if IQ_IS_IOS8_OR_GREATER == true {
                    _topViewBeginRect.size = rootViewController.view.frame.size
                }
                
                //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                    
                    self._IQShowLog("Restoring \(rootViewController._IQDescription()) frame to : \(self._topViewBeginRect)")
                    
                    //  Setting it's new frame
                    rootViewController.view.frame = self._topViewBeginRect
                    
                    //Animating content if needed (Bug ID: #204)
                    if self.layoutIfNeededOnUpdate == true {
                        //Animating content (Bug ID: #160)
                        rootViewController.view.setNeedsLayout()
                        rootViewController.view.layoutIfNeeded()
                    }
                    
                    }) { (finished) -> Void in }
                
                _rootViewController = nil
            }
        }
        
        //Reset all values
        _lastScrollView = nil
        _kbSize = CGSizeZero
        _startingContentInsets = UIEdgeInsetsZero
        _startingScrollIndicatorInsets = UIEdgeInsetsZero
        _startingContentOffset = CGPointZero
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }

    
    func keyboardDidHide(notification:NSNotification) {

        _IQShowLog("****** \(__FUNCTION__) started ******")
        
        _topViewBeginRect = CGRectZero

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    ///-------------------------------------------
    /// MARK: UITextField/UITextView Notifications
    ///-------------------------------------------

    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    func textFieldViewDidBeginEditing(notification:NSNotification) {

        _IQShowLog("****** \(__FUNCTION__) started ******")

        //  Getting object
        _textFieldView = notification.object as? UIView
        
        if overrideKeyboardAppearance == true {
            
            if let textFieldView = _textFieldView as? UITextField {
                //If keyboard appearance is not like the provided appearance
                if textFieldView.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    textFieldView.keyboardAppearance = keyboardAppearance
                    textFieldView.reloadInputViews()
                }
            } else if  let textFieldView = _textFieldView as? UITextView {
                //If keyboard appearance is not like the provided appearance
                if textFieldView.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    textFieldView.keyboardAppearance = keyboardAppearance
                    textFieldView.reloadInputViews()
                }
            }
        }
        
        // Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed.
        //Added _isTextFieldViewFrameChanged check. (Bug ID: #92)
        if _isTextFieldViewFrameChanged == false {
            if let textFieldView = _textFieldView {
                _textFieldViewIntialFrame = textFieldView.frame
                _IQShowLog("Saving \(textFieldView._IQDescription()) Initial frame : \(_textFieldViewIntialFrame)")
            }
        }
        
        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if enableAutoToolbar == true {

            _IQShowLog("adding UIToolbars if required")

            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if _textFieldView is UITextView == true && _textFieldView?.inputAccessoryView == nil {
                
                UIView.animateWithDuration(0.00001, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (finished) -> Void in

                        //On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                        self._textFieldView?.reloadInputViews()
                })
            } else {
                //Adding toolbar
                addToolbarIfRequired()
            }
        }

        if enable == false {
            _IQShowLog("****** \(__FUNCTION__) ended ******")
            return
        }
        
        _textFieldView?.window?.addGestureRecognizer(_tapGesture)    //   (Enhancement ID: #14)

        if _isKeyboardShowing == false {    //  (Bug ID: #5)

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            _rootViewController = _textFieldView?.topMostController()
            if _rootViewController == nil {
                _rootViewController = keyWindow()?.topMostController()
            }

            if let rootViewController = _rootViewController {
                
                _topViewBeginRect = rootViewController.view.frame
                
                _IQShowLog("Saving \(rootViewController._IQDescription()) beginning frame : \(_topViewBeginRect)")
            }
        }
        
        //If _textFieldView is inside ignored responder then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if _textFieldView != nil && _textFieldView?.isAlertViewTextField() == false {

            //Getting textField viewController
            if let textFieldViewController = _textFieldView?.viewController() {
                
                var shouldIgnore = false
                
                for disabledClassString in _disabledClasses {
                    
                    //If viewController is kind of disabled viewController class, then ignoring to adjust view.
                    if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString as! String))) {
                        shouldIgnore = true
                        break
                    }
                }
                
                //If shouldn't ignore.
                if shouldIgnore == false  {
                    //  keyboard is already showing. adjust frame.
                    adjustFrame()
                }
            }
        }

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    func textFieldViewDidEndEditing(notification:NSNotification) {
        
        _IQShowLog("****** \(__FUNCTION__) started ******")

        //Removing gesture recognizer   (Enhancement ID: #14)
        _textFieldView?.window?.removeGestureRecognizer(_tapGesture)
        
        // We check if there's a change in original frame or not.
        if _isTextFieldViewFrameChanged == true {
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                self._isTextFieldViewFrameChanged = false
                
                self._IQShowLog("Restoring \(self._textFieldView?._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")

                self._textFieldView?.frame = self._textFieldViewIntialFrame
                }, completion: { (finished) -> Void in })
        }
        
        //Setting object to nil
        _textFieldView = nil

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }

    /** UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
    func textFieldViewDidChange(notification:NSNotification) {  //  (Bug ID: #18)
        
        if  shouldFixTextViewClip {
            let textView = notification.object as! UITextView
            
            let line = textView .caretRectForPosition(textView.selectedTextRange?.start)
            
            let overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top)
            
            //Added overflow conditions (Bug ID: 95)
            if overflow > 0.0 && overflow < CGFloat(FLT_MAX) {
                // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
                // Scroll caret to visible area
                var offset = textView.contentOffset
                offset.y += overflow + 7 // leave 7 pixels margin
                
                // Cannot animate with setContentOffset:animated: or caret will not appear
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState.union(_animationCurve), animations: { () -> Void in
                    textView.contentOffset = offset
                    }, completion: { (finished) -> Void in })
            }
        }
    }

    
    ///------------------------------------------
    /// MARK: Interface Orientation Notifications
    ///------------------------------------------
    
    /**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    func willChangeStatusBarOrientation(notification:NSNotification) {
        
        _IQShowLog("****** \(__FUNCTION__) started ******")
        
        //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
        if _isTextFieldViewFrameChanged == true {
            if let textFieldView = _textFieldView {
                //Due to orientation callback we need to set it's original position.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve.union(UIViewAnimationOptions.BeginFromCurrentState)), animations: { () -> Void in
                    self._isTextFieldViewFrameChanged = false

                    self._IQShowLog("Restoring \(textFieldView._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")
                    
                    //Setting textField to it's initial frame
                    textFieldView.frame = self._textFieldViewIntialFrame
                    
                    }, completion: { (finished) -> Void in })
            }
        }

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    
    ///------------------
    /// MARK: AutoToolbar
    ///------------------
    
    /**	Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews()-> NSArray? {
        
        var superConsideredView : UIView?

        //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for disabledClassString in _toolbarPreviousNextConsideredClass {
            
                if _textFieldView?.superviewOfClassType(NSClassFromString(disabledClassString as! String)) != nil {
                    break
                }
        }
    
    //If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
        if superConsideredView != nil {
            return superConsideredView?.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            if let textFields = _textFieldView?.responderSiblings() {
                
                //Sorting textFields according to behaviour
                switch toolbarManageBehaviour {
                    //If autoToolbar behaviour is bySubviews, then returning it.
                case IQAutoToolbarManageBehaviour.BySubviews:   return textFields
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.ByTag:    return textFields.sortedArrayByTag()
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.ByPosition:    return textFields.sortedArrayByPosition()
                }
            } else {
                return nil
            }
        }
    }
    
    /** Add toolbar if it is required to add on textFields and it's siblings. */
    private func addToolbarIfRequired() {
        
        if let textFieldViewController = _textFieldView?.viewController() {
            
            for disabledClassString in _disabledToolbarClasses {
                
                if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString as! String))) {
                    
                    removeToolbarIfRequired()
                    return
                }
            }
        }
        
        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            //	If only one object is found, then adding only Done button.
            if siblings.count == 1 {
                let textField = siblings.firstObject as! UIView
                
                //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
                if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                    
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    textField.addDoneOnKeyboardWithTarget(self, action: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                    textField.inputAccessoryView?.tag = kIQDoneButtonToolbarTag //  (Bug ID: #78)
                }
                
                if textField.inputAccessoryView?.isKindOfClass(IQToolbar) == true && textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag {
                    
                    let toolbar = textField.inputAccessoryView as! IQToolbar
                    
                    //  Setting toolbar to keyboard.
                    if let _textField = textField as? UITextField {

                        //Bar style according to keyboard appearance
                        switch _textField.keyboardAppearance {

                        case UIKeyboardAppearance.Dark:
                            toolbar.barStyle = UIBarStyle.Black
                            toolbar.tintColor = UIColor.whiteColor()
                        default:
                            toolbar.barStyle = UIBarStyle.Default
                            toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textField.tintColor : _defaultToolbarTintColor
                        }
                    } else if let _textView = textField as? UITextView {

                        //Bar style according to keyboard appearance
                        switch _textView.keyboardAppearance {
                            
                        case UIKeyboardAppearance.Dark:
                            toolbar.barStyle = UIBarStyle.Black
                            toolbar.tintColor = UIColor.whiteColor()
                        default:
                            toolbar.barStyle = UIBarStyle.Default
                            toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textView.tintColor : _defaultToolbarTintColor
                        }
                    }

                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                        
                        let toolbar = textField.inputAccessoryView as! IQToolbar

                        //Updating placeholder font to toolbar.     //(Bug ID: #148)
                        if let _textField = textField as? UITextField {
                            
                            if toolbar.title != _textField.placeholder {
                                toolbar.title = _textField.placeholder
                            }

                        } else if let _textView = textField as? IQTextView {
                            
                            if toolbar.title != _textView.placeholder {
                                toolbar.title = _textView.placeholder
                            }
                        }

                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if placeholderFont != nil {
                            toolbar.titleFont = placeholderFont
                        }
                    }
                }
            } else if siblings.count != 0 {
                
                //	If more than 1 textField is found. then adding previous/next/done buttons on it.
                for textField in siblings as! [UIView] {
                    
                    //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
                    if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag {
                        
                        //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                        textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: "previousAction:", nextAction: "nextAction:", doneAction: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                        textField.inputAccessoryView?.tag = kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
                   }
                    
                    if textField.inputAccessoryView?.isKindOfClass(IQToolbar) == true && textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                        
                        let toolbar = textField.inputAccessoryView as! IQToolbar
                        
                        //  Setting toolbar to keyboard.
                        if let _textField = textField as? UITextField {
                            
                            //Bar style according to keyboard appearance
                            switch _textField.keyboardAppearance {
                                
                            case UIKeyboardAppearance.Dark:
                                toolbar.barStyle = UIBarStyle.Black
                                toolbar.tintColor = UIColor.whiteColor()
                            default:
                                toolbar.barStyle = UIBarStyle.Default
                                toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textField.tintColor : _defaultToolbarTintColor
                            }
                        } else if let _textView = textField as? UITextView {
                            
                            //Bar style according to keyboard appearance
                            switch _textView.keyboardAppearance {
                                
                            case UIKeyboardAppearance.Dark:
                                toolbar.barStyle = UIBarStyle.Black
                                toolbar.tintColor = UIColor.whiteColor()
                            default:
                                toolbar.barStyle = UIBarStyle.Default
                                toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textView.tintColor : _defaultToolbarTintColor
                            }
                        }
                        
                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                            
                            let toolbar = textField.inputAccessoryView as! IQToolbar
                            
                            //Updating placeholder font to toolbar.     //(Bug ID: #148)
                            if let _textField = textField as? UITextField {
                                
                                if toolbar.title != _textField.placeholder {
                                    toolbar.title = _textField.placeholder
                                }
                                
                            } else if let _textView = textField as? IQTextView {
                                
                                if toolbar.title != _textView.placeholder {
                                    toolbar.title = _textView.placeholder
                                }
                            }
                            
                            //Setting toolbar title font.   //  (Enhancement ID: #30)
                            if placeholderFont != nil {
                                toolbar.titleFont = placeholderFont
                            }
                        }
                    }
                    
                    //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
                    if textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                        //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                        //	If firstTextField, then previous should not be enabled.
                        if siblings[0] as! UIView == textField {
                            textField.setEnablePrevious(false, isNextEnabled: true)
                        } else if siblings.lastObject as! UIView  == textField {   //	If lastTextField then next should not be enaled.
                            textField.setEnablePrevious(true, isNextEnabled: false)
                        } else {
                            textField.setEnablePrevious(true, isNextEnabled: true)
                        }
                    }
                }
            }
        }
    }
    
    /** Remove any toolbar if it is IQToolbar. */
    private func removeToolbarIfRequired() {    //  (Bug ID: #18)
        
        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            for view in siblings as! [UIView] {
                
                let toolbar = view.inputAccessoryView
                
                if toolbar is IQToolbar == true  && (toolbar?.tag == kIQDoneButtonToolbarTag || toolbar?.tag == kIQPreviousNextButtonToolbarTag) {
                    
                    if view is UITextField == true {
                        let textField = view as! UITextField
                        textField.inputAccessoryView = nil
                    } else if view is UITextView == true {
                        let textView = view as! UITextView
                        textView.inputAccessoryView = nil
                    }
                }
            }
        }
    }
    
    private func _IQShowLog(logString: String) {
        
        #if IQKEYBOARDMANAGER_DEBUG
        println("IQKeyboardManager: " + logString)
        #endif
    }
}

