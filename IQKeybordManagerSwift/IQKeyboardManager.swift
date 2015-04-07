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

/**
    @author Iftekhar Qurashi

    @related hack.iftekhar@gmail.com

    @class IQKeyboardManager

    @abstract Keyboard TextField/TextView Manager. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

/*  @const kIQDoneButtonToolbarTag         Default tag for toolbar with Done button            -1002.   */
let  kIQDoneButtonToolbarTag : Int          =   -1002
/*  @const kIQPreviousNextButtonToolbarTag Default tag for toolbar with Previous/Next buttons  -1005.   */
let  kIQPreviousNextButtonToolbarTag : Int  =   -1005

class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    
    /******************UIKeyboard handling*************************/
    
    /** @abstract enable/disable the keyboard manager. Default is YES(Enabled when class loads in `+(void)load` method.    */
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
    
    /** @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.    */
    var keyboardDistanceFromTextField: CGFloat {
        
        set {
            _privateKeyboardDistanceFromTextField =  max(0, newValue)
            _IQShowLog("keyboardDistanceFromTextField: \(_privateKeyboardDistanceFromTextField)")
        }
        get {
            return _privateKeyboardDistanceFromTextField
        }
    }

    /** @abstract Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.   */
    var preventShowingBottomBlankSpace = true
    
    
    /******************IQToolbar handling*************************/

    /** @abstract Automatic add the IQToolbar functionality. Default is YES.    */
    var enableAutoToolbar: Bool = true {
        
        didSet {

            enableAutoToolbar ?addToolbarIfRequired():removeToolbarIfRequired()

            var enableToolbar = enableAutoToolbar ? "Yes" : "NO"

            _IQShowLog("enableAutoToolbar: \(enableToolbar)")
        }
    }
    
    /** @abstract AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.   */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /** @abstract If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO. */
    var shouldToolbarUsesTextFieldTintColor = false
    
    /** @abstract If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.    */
    var shouldShowTextFieldPlaceholder = true
    
    /** @abstract placeholder Font. Default is nil. */
    var placeholderFont: UIFont?
    
    
    /******************UITextView handling*************************/

    /** @abstract Adjust textView's frame when it is too big in height. Default is NO.  */
    var canAdjustTextView = false

    
    /*********UIKeyboard appearance overriding********************/

    /** @abstract override the keyboardAppearance for all textField/textView. Default is NO.    */
    var overrideKeyboardAppearance = false
    
    /** @abstract if overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.   */
    var keyboardAppearance = UIKeyboardAppearance.Default

    
    /*********UITextField/UITextView Resign handling**************/

    /** @abstract Resigns Keyboard on touching outside of UITextField/View. Default is NO. Enabling/disable gesture */
    var shouldResignOnTouchOutside: Bool = false {
        
        didSet {
            _tapGesture.enabled = shouldResignOnTouchOutside
            
            let shouldResign = shouldResignOnTouchOutside ? "Yes" : "NO"
            
            _IQShowLog("shouldResignOnTouchOutside: \(shouldResign)")
        }
    }
    

    /*******************UISound handling*************************/

    /** @abstract If YES, then it plays inputClick sound on next/previous/done click.   */
    var shouldPlayInputClicks = false
    
    
    /****************UIAnimation handling***********************/

    /** @abstract   If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
        @discussion Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.    */
    var shouldAdoptDefaultKeyboardAnimation = true


//Private variables
    /*******************************************/

    /** To save UITextField/UITextView object voa textField/textView notifications. */
    private weak var    _textFieldView: UIView?
    
    /** used with canAdjustTextView boolean. */
    private var         _textFieldViewIntialFrame = CGRectZero
    
    /** To save rootViewController.view.frame. */
    private var         _topViewBeginRect = CGRectZero
    
    /** used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
    private var         _isTextFieldViewFrameChanged = false
    
    /** To save rootViewController */
    private weak var    _rootViewController: UIViewController?

    /*******************************************/

    /** Variable to save lastScrollView that was scrolled. */
    private weak var    _lastScrollView: UIScrollView?
    
    /** LastScrollView's initial contentOffset. */
    private var         _startingContentOffset = CGPointZero
    
    /** LastScrollView's initial contentInsets. */
    private var         _startingContentInsets = UIEdgeInsetsZero
    
    /*******************************************/

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    private var         _kbShowNotification: NSNotification?
    
    /** Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    private var         _isKeyboardShowing = false
    
    /** To save keyboard size. */
    private var         _kbSize = CGSizeZero
    
    /** To save keyboard animation duration. */
    private var         _animationDuration = 0.25
    
    /** To mimic the keyboard animation */
    private var         _animationCurve = UIViewAnimationOptions.CurveEaseOut
    
    /*******************************************/

    /** TapGesture to resign keyboard on view's touch. */
    private var         _tapGesture: UITapGestureRecognizer!
    
    /*******************************************/
    
    /** To use with keyboardDistanceFromTextField. */
    private var         _privateKeyboardDistanceFromTextField: CGFloat = 10.0
    
    /*******************************************/
    
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
    }

    /** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
    override class func load() {
        super.load()
        
        //Enabling IQKeyboardManager.
        IQKeyboardManager.sharedManager().enable = true
    }
    
    deinit {
        //  Disable the keyboard manager.
        enable = false

        //Removing notification observers on dealloc.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*  Automatically called first time from the `+(void)load` method. */
    class func sharedManager() -> IQKeyboardManager {
        
        struct Static {
            //Singleton instance. Initializing keyboard manger.
            static let kbManager = IQKeyboardManager()
        }
        
        /** @return Returns the default singleton instance. */
        return Static.kbManager
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
                frame.size = unwrappedController.view.size
            }
            
            //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                
                //  Setting it's new frame
                unwrappedController.view.frame = frame
                self._IQShowLog("Set \(controller?._IQDescription()) frame to : \(frame)")

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
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        
        var move : CGFloat = 0.0
        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        
        //  Calculating move position. Common for both normal and special cases.
        switch interfaceOrientation {
        case UIInterfaceOrientation.LandscapeLeft:
            move = min(textFieldViewRect.x - (statusBarFrame.width+5), textFieldViewRect.right - (window.width-_kbSize.width))
        case UIInterfaceOrientation.LandscapeRight:
            move = min(window.width - textFieldViewRect.right - (statusBarFrame.width+5), _kbSize.width - textFieldViewRect.x)
        case UIInterfaceOrientation.Portrait:
            move = min(textFieldViewRect.y - (statusBarFrame.height+5), textFieldViewRect.bottom - (window.height-_kbSize.height))
        case UIInterfaceOrientation.PortraitUpsideDown:
            move = min(window.height - textFieldViewRect.bottom - (statusBarFrame.height+5), _kbSize.height - textFieldViewRect.y)
        default:
            break
        }
        
        _IQShowLog("Need to move: \(move)")

        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
        let superScrollView = textFieldView.superScrollView()
        
        //If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastScrollView = _lastScrollView {
            //If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")

                lastScrollView.contentInset = _startingContentInsets
                lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                _startingContentInsets = UIEdgeInsetsZero
                _startingContentOffset = CGPointZero
                _lastScrollView = nil
            } else if superScrollView != lastScrollView {     //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")
                
                lastScrollView.contentInset = _startingContentInsets
                lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                _lastScrollView = superScrollView
                _startingContentInsets = superScrollView!.contentInset
                _startingContentOffset = superScrollView!.contentOffset
                
                _IQShowLog("Saving New \(lastScrollView._IQDescription()) contentInset : \(_startingContentInsets) and contentOffset : \(_startingContentOffset)")
            }
            //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        } else if let unwrappedSuperScrollView = superScrollView {    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
            _lastScrollView = unwrappedSuperScrollView
            _startingContentInsets = unwrappedSuperScrollView.contentInset
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
                if move > 0 ? move > -scrollView.contentOffset.y : scrollView.contentOffset.y>0 {
                    
                    //Getting lastViewRect.
                    if let lastViewRect = lastView.superview?.convertRect(lastView.frame, toView: scrollView) {
                        
                        //Calculating the expected Y offset from move and scrollView's contentOffset.
                        var shouldOffsetY = scrollView.contentOffset.y - min(scrollView.contentOffset.y,-move)
                        
                        //Rearranging the expected Y offset according to the view.
                        shouldOffsetY = min(shouldOffsetY, lastViewRect.y /*-5*/)   //-5 is for good UI.//Commenting -5 Bug ID #69
                        
                        //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                        move -= (shouldOffsetY-scrollView.contentOffset.y)
                        
                        //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                        UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                            
                            self._IQShowLog("Adjusting \(scrollView.contentOffset.y-shouldOffsetY) to \(scrollView._IQDescription()) ContentOffset")
                            
                            self._IQShowLog("Remaining Move: \(move)")
                            
                            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, shouldOffsetY)
                            }) { (animated:Bool) -> Void in }
                    }
                    
                    //  Getting next lastView & superScrollView.
                    lastView = scrollView
                    superScrollView = lastView.superScrollView()
                
                } else {
                    break
                }
            }

            if let lastScrollViewRect = lastScrollView.superview?.convertRect(lastScrollView.frame, toView: window) {
                
                //Updating contentInset
                var bottom : CGFloat = 0.0
                
                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:
                    bottom = _kbSize.width-(window.width - lastScrollViewRect.right)
                case UIInterfaceOrientation.LandscapeRight:
                    bottom = _kbSize.width - lastScrollViewRect.x
                case UIInterfaceOrientation.Portrait:
                    bottom = _kbSize.height-(window.height - lastScrollViewRect.bottom)
                case UIInterfaceOrientation.PortraitUpsideDown:
                    bottom = _kbSize.height - lastScrollViewRect.y
                default:
                    break
                }
                
                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                var movedInsets = lastScrollView.contentInset
                
                movedInsets.bottom = max(_startingContentInsets.bottom, bottom)
                
                _IQShowLog("\(lastScrollView._IQDescription()) old ContentInset : \(lastScrollView.contentInset)")
                
                lastScrollView.contentInset = movedInsets
                
                _IQShowLog("\(lastScrollView._IQDescription()) new ContentInset : \(lastScrollView.contentInset)")
            }
        }
        //Going ahead. No else if.
        
        //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen).
        //If we have permission to adjust the textView, then let's do it on behalf of user.  (Enhancement ID: #15)
        //Added _isTextFieldViewFrameChanged. (Bug ID: #92)
        if canAdjustTextView == true && textFieldView is UITextView == true && _isTextFieldViewFrameChanged == false {
            var textViewHeight = textFieldView.height
 
            switch interfaceOrientation {
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                textViewHeight = min(textViewHeight, (window.width-_kbSize.width-(statusBarFrame.width+5)))
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                textViewHeight = min(textViewHeight, (window.height-_kbSize.height-(statusBarFrame.height+5)))
            default:
                break
            }
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in

                self._IQShowLog("\(textFieldView._IQDescription()) Old Frame : \(textFieldView.frame)")

                textFieldView.height = textViewHeight
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
                rootViewRect.y -= move
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if preventShowingBottomBlankSpace == true {
                    var minimumY: CGFloat = 0
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                        minimumY = window.width-rootViewRect.height-statusBarFrame.width-(_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                        minimumY = (window.height-rootViewRect.height-statusBarFrame.height)/2-(_kbSize.height-keyboardDistanceFromTextField)
                    default:
                        break
                    }
                    
                    rootViewRect.y = max(rootViewRect.y, minimumY)
                }
                
                _IQShowLog("Moving Upward")
                //  Setting adjusted rootViewRect
                setRootViewFrame(rootViewRect)
            } else {  //  Negative
                //  Calculating disturbed distance. Pull Request #3
                let disturbDistance = rootViewRect.y - _topViewBeginRect.y
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if disturbDistance < 0 {
                    // We should only manipulate y.
                    rootViewRect.y -= max(move, disturbDistance)

                    _IQShowLog("Moving Downward")
                    //  Setting adjusted rootViewRect
                    setRootViewFrame(rootViewRect)
                }
            }
        } else {  //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
            //  Positive or zero.
            if move >= 0 {

                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= move
                case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += move
                case UIInterfaceOrientation.Portrait:            rootViewRect.y -= move
                case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += move
                default :
                    break
                }
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if preventShowingBottomBlankSpace == true {
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft:
                        rootViewRect.x = max(rootViewRect.x, min(0, -_kbSize.width+keyboardDistanceFromTextField))
                    case UIInterfaceOrientation.LandscapeRight:
                        rootViewRect.x = min(rootViewRect.x, +_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait:
                        rootViewRect.y = max(rootViewRect.y, min(0, -_kbSize.height+keyboardDistanceFromTextField))
                    case UIInterfaceOrientation.PortraitUpsideDown:
                        rootViewRect.y = min(rootViewRect.y, +_kbSize.height-keyboardDistanceFromTextField)
                    default:
                        break
                    }
                }

                _IQShowLog("Moving Upward")
                //  Setting adjusted rootViewRect
                setRootViewFrame(rootViewRect)
            } else {  //  Negative
                var disturbDistance : CGFloat = 0
                
                switch interfaceOrientation {
                case UIInterfaceOrientation.LandscapeLeft:
                    disturbDistance = rootViewRect.x - _topViewBeginRect.x
                case UIInterfaceOrientation.LandscapeRight:
                    disturbDistance = _topViewBeginRect.x - rootViewRect.x
                case UIInterfaceOrientation.Portrait:
                    disturbDistance = rootViewRect.y - _topViewBeginRect.y
                case UIInterfaceOrientation.PortraitUpsideDown:
                    disturbDistance = _topViewBeginRect.y - rootViewRect.y
                default :
                    break
                }
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if disturbDistance < 0 {

                    switch interfaceOrientation {
                    case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= max(move, disturbDistance)
                    case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += max(move, disturbDistance)
                    case UIInterfaceOrientation.Portrait:            rootViewRect.y -= max(move, disturbDistance)
                    case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += max(move, disturbDistance)
                    default :
                        break
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
                    /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
                    http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                    #if IQ_IS_XCODE_BELOW_6_1
                        _animationCurve = UIViewAnimationOptions.fromRaw(curve)!
                        #else
                        _animationCurve = UIViewAnimationOptions(rawValue: curve)
                    #endif
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
            if let rect = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
                _kbSize = rect.size
                
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
            
            // Adding Keyboard distance from textField.
            switch interfaceOrientation {
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                _kbSize.width += keyboardDistanceFromTextField
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                _kbSize.height += keyboardDistanceFromTextField
            default :
                break
            }
        }
        
        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if CGSizeEqualToSize(_kbSize, oldKBSize) == false {
            
            //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            if _textFieldView?.viewController() is UITableViewController == false && _textFieldView?.isAlertViewTextField() == false {
                adjustFrame()
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
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                
                lastScrollView.contentInset = self._startingContentInsets
                lastScrollView.contentOffset = self._startingContentOffset
                
                self._IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(self._startingContentInsets) and contentOffset to : \(self._startingContentOffset)")

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView = self._lastScrollView?.superScrollView()
                
                while let scrollView = superScrollView {

                    let contentSize = CGSizeMake(max(scrollView.contentSize.width, scrollView.width), max(scrollView.contentSize.height, scrollView.height))
                    
                    let minimumY = contentSize.height-scrollView.height
                    
                    if minimumY < scrollView.contentOffset.y {
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, minimumY)
                        
                        self._IQShowLog("Restoring \(scrollView._IQDescription()) contentOffset to : \(self._startingContentOffset)")
                    }
                    
                    superScrollView = superScrollView?.superScrollView()
                }
                }) { (finished) -> Void in }
        }
        
        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        if CGRectEqualToRect(_topViewBeginRect, CGRectZero) == false {
            
            if let rootViewController = _rootViewController {
                
                if IQ_IS_IOS8_OR_GREATER == true {
                    _topViewBeginRect.size = rootViewController.view.size
                }
                
                //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    
                    self._IQShowLog("Restoring \(rootViewController._IQDescription()) frame to : \(self._topViewBeginRect)")
                    
                    //  Setting it's new frame
                    rootViewController.view.frame = self._topViewBeginRect
                    
                    }) { (finished) -> Void in }
                
                _rootViewController = nil
            }
        }
        
        //Reset all values
        _lastScrollView = nil
        _kbSize = CGSizeZero
        _startingContentInsets = UIEdgeInsetsZero
        _startingContentOffset = CGPointZero
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    func keyboardDidHide(notification:NSNotification) {

        _IQShowLog("****** \(__FUNCTION__) started ******")
        
        _topViewBeginRect = CGRectZero

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    func textFieldViewDidBeginEditing(notification:NSNotification) {

        _IQShowLog("****** \(__FUNCTION__) started ******")

        //  Getting object
        _textFieldView = notification.object as? UIView
        
        if overrideKeyboardAppearance == true {
            
            if _textFieldView is UITextField == true {
                (_textFieldView as UITextField).keyboardAppearance = keyboardAppearance
            } else if _textFieldView is UITextView == true {
                (_textFieldView as UITextView).keyboardAppearance = keyboardAppearance
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
                
                UIView.animateWithDuration(0.00001, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (finished) -> Void in

                        if let textFieldRetain = self._textFieldView {
                            textFieldRetain.resignFirstResponder()
                            textFieldRetain.becomeFirstResponder()
                        }
                })
            } else {
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
        
        //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if _textFieldView?.viewController()? is UITableViewController  == false && _textFieldView?.isAlertViewTextField() == false {

            //  keyboard is already showing. adjust frame.
            adjustFrame()
        }

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    func textFieldViewDidEndEditing(notification:NSNotification) {
        
        _IQShowLog("****** \(__FUNCTION__) started ******")

        _textFieldView?.window?.removeGestureRecognizer(_tapGesture) //  (Enhancement ID: #14)
        
        // We check if there's a change in original frame or not.
        if _isTextFieldViewFrameChanged == true {
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                self._isTextFieldViewFrameChanged = false
                
                self._IQShowLog("Restoring \(self._textFieldView?._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")

                self._textFieldView?.frame = self._textFieldViewIntialFrame
                }, completion: { (finished) -> Void in })
        }
        
        //Setting object to nil
        _textFieldView = nil

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /* UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
    func textFieldViewDidChange(notification:NSNotification) {  //  (Bug ID: #18)
        
        let textView = notification.object as UITextView
        
        let line = textView .caretRectForPosition(textView.selectedTextRange?.start)
        
        let overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top)
        
        //Added overflow conditions (Bug ID: 95)
        if overflow > 0.0 && overflow < CGFloat(FLT_MAX) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            var offset = textView.contentOffset
            offset.y += overflow + 7 // leave 7 pixels margin
            
            // Cannot animate with setContentOffset:animated: or caret will not appear
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                textView.contentOffset = offset
            }, completion: { (finished) -> Void in })
        }
    }
    
    /**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    func willChangeStatusBarOrientation(notification:NSNotification) {
        
        _IQShowLog("****** \(__FUNCTION__) started ******")
        
        //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
        if _isTextFieldViewFrameChanged == true {
            if let textFieldView = _textFieldView {
                //Due to orientation callback we need to set it's original position.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                    textFieldView.frame = self._textFieldViewIntialFrame
                    
                    self._IQShowLog("Restoring \(textFieldView._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")
                    
                    self._isTextFieldViewFrameChanged = false
                    }, completion: { (finished) -> Void in })
            }
        }

        _IQShowLog("****** \(__FUNCTION__) ended ******")
    }
    
    /** Resigning on tap gesture. */
    func tapRecognized(gesture: UITapGestureRecognizer) {

        if gesture.state == UIGestureRecognizerState.Ended {
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

    /** Resigning textField. */
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
    
    /**	Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews()-> NSArray? {
        
        var tableView : UIView? = _textFieldView?.superTableView()
        if tableView == nil {
            tableView = tableView?.superCollectionView()
        }
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = tableView {     //   (Enhancement ID: #22)
            return unwrappedTableView.deepResponderViews()
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
    
    /**	previousAction. */
    func previousAction (segmentedControl : AnyObject?) {

        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.currentDevice().playInputClick()
        }
        
        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                if textFields.containsObject(textFieldRetain) == true {
                    //Getting index of current textField.
                    let index = textFields.indexOfObject(textFieldRetain)
                    
                    //If it is not first textField. then it's previous object becomeFirstResponder.
                    if index > 0 {
                        
                        let nextTextField = textFields[index-1] as UIView
                        
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

    /**	nextAction. */
    func nextAction (segmentedControl : AnyObject?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.currentDevice().playInputClick()
        }
        
        
        //Getting all responder view's.
        if let textFields = responderViews() {
            if let  textFieldRetain = _textFieldView {
                if textFields.containsObject(textFieldRetain) == true {

                    //Getting index of current textField.
                    let index = textFields.indexOfObject(textFieldRetain)
                    
                    //If it is not last textField. then it's next object becomeFirstResponder.
                    if index < textFields.count-1 {
                        
                        let nextTextField = textFields[index+1] as UIView
                        
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
    
    /** Add toolbar if it is required to add on textFields and it's siblings. */
    private func addToolbarIfRequired() {
        
        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            //	If only one object is found, then adding only Done button.
            if siblings.count == 1 {
                let textField = siblings.firstObject as UIView
                
                //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
                if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                    
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    textField.addDoneOnKeyboardWithTarget(self, action: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                    textField.inputAccessoryView?.tag = kIQDoneButtonToolbarTag //  (Bug ID: #78)
                    
                    //Setting toolbar tintColor.    //  (Enhancement ID: #30)
                    if shouldToolbarUsesTextFieldTintColor == true {
                        
                        textField.inputAccessoryView?.tintColor = textField.tintColor
                    }
                    
                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                        
                        (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont
                    }
                }
            } else if siblings.count != 0 {
                
                //	If more than 1 textField is found. then adding previous/next/done buttons on it.
                for textField in siblings as [UIView] {
                    
                    //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
                    if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag {
                        
                        //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                        textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: "previousAction:", nextAction: "nextAction:", doneAction: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                        textField.inputAccessoryView?.tag = kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
                        
                        //Setting toolbar tintColor //  (Enhancement ID: #30)
                        if shouldToolbarUsesTextFieldTintColor == true {
                            textField.inputAccessoryView?.tintColor = textField.tintColor
                        }
                        
                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                            (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont
                        }
                    }
                    
                    //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
                    if textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                        //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                        //	If firstTextField, then previous should not be enabled.
                        if siblings[0] as UIView == textField {
                            textField.setEnablePrevious(false, isNextEnabled: true)
                        } else if siblings.lastObject as UIView  == textField {   //	If lastTextField then next should not be enaled.
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
            
            for view in siblings as [UIView] {

                let toolbar = view.inputAccessoryView

                if toolbar is IQToolbar == true  && (toolbar?.tag == kIQDoneButtonToolbarTag || toolbar?.tag == kIQPreviousNextButtonToolbarTag) {
                    
                    if view is UITextField == true {
                        let textField = view as UITextField
                        textField.inputAccessoryView = nil
                    } else if view is UITextView == true {
                        let textView = view as UITextView
                        textView.inputAccessoryView = nil
                    }
                }
            }
        }
    }
    
    private func _IQShowLog(logString: String) {
        
         let showLog = true
        
        if showLog == true {
            println("IQKeyboardManager: " + logString)
        }
    }
}

