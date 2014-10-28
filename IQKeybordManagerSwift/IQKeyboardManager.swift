//
//  IQKeyboardManager.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

/*!
    @author Iftekhar Qurashi

    @related hack.iftekhar@gmail.com

    @class IQKeyboardManager

    @abstract Keyboard TextField/TextView Manager. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

/*  @const kIQDoneButtonToolbarTag         Default tag for toolbar with Done button            -1002.   */
let  kIQDoneButtonToolbarTag : NSInteger            =   -1002
/*  @const kIQPreviousNextButtonToolbarTag Default tag for toolbar with Previous/Next buttons  -1005.   */
let  kIQPreviousNextButtonToolbarTag : NSInteger    =   -1005

class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
//UIKeyboard handling
    /*! @abstract enable/disable the keyboard manager. Default is YES(Enabled when class loads in `+(void)load` method.    */
    var enable: Bool = false {
        
        didSet{
            
            //If not enable, enable it.
            if (enable == true && oldValue == false) {
                //If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
                if _kbShowNotification != nil {
                    keyboardWillShow(_kbShowNotification)
                }
            }
            //If not disable, desable it.
            else if (enable == false && oldValue == true) {
                keyboardWillHide(nil)
            }
        }
    }
    
    /*! @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.    */
    var keyboardDistanceFromTextField: CGFloat {
        
        set {
            _privateKeyboardDistanceFromTextField = max(0, newValue)
        }
        get {
            return _privateKeyboardDistanceFromTextField
        }
    }

    /*! @abstract Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.   */
    var preventShowingBottomBlankSpace = true
    
    //IQToolbar handling
    /*! @abstract Automatic add the IQToolbar functionality. Default is YES.    */
    var enableAutoToolbar: Bool = true {
        
        didSet {
            enableAutoToolbar ?addToolbarIfRequired():removeToolbarIfRequired()
        }
    }
    
    /*! @abstract AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.   */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /*! @abstract If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO. */
    var shouldToolbarUsesTextFieldTintColor = false
    
    /*! @abstract If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.    */
    var shouldShowTextFieldPlaceholder = true
    
    /*! @abstract placeholder Font. Default is nil. */
    var placeholderFont: UIFont?
    
    
//TextView handling
    /*! @abstract Adjust textView's frame when it is too big in height. Default is NO.  */
    var canAdjustTextView = false

    
//Keyboard appearance overriding
    /*! @abstract override the keyboardAppearance for all textField/textView. Default is NO.    */
    var overrideKeyboardAppearance = false
    
    /*! @abstract if overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.   */
    var keyboardAppearance = UIKeyboardAppearance.Default

    
//Resign handling
    /*! @abstract Resigns Keyboard on touching outside of UITextField/View. Default is NO.  */
    var shouldResignOnTouchOutside: Bool = false {
        
        didSet {
            _tapGesture.enabled = shouldResignOnTouchOutside
        }
    }
    
//Sound handling
    /*! @abstract If YES, then it plays inputClick sound on next/previous/done click.   */
    var shouldPlayInputClicks = false
    
    
//Animation handling
    /*! @abstract   If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
        @discussion Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.    */
    var shouldAdoptDefaultKeyboardAnimation = true


//Private variables
    /*******************************************/

    /*! To save UITextField/UITextView object voa textField/textView notifications. */
    private weak var    _textFieldView: UIView!
    
    /*! used with canAdjustTextView boolean. */
    private var         _textFieldViewIntialFrame: CGRect = CGRectZero
    
    /*! To save rootViewController.view.frame. */
    private var         _topViewBeginRect: CGRect = CGRectZero
    
    /*! used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
    private var         _isTextFieldViewFrameChanged: Bool = false
    
    /*******************************************/

    /*! Variable to save lastScrollView that was scrolled. */
    private weak var    _lastScrollView: UIScrollView?
    
    /*! LastScrollView's initial contentOffset. */
    private var         _startingContentOffset: CGPoint = CGPointZero
    
    /*******************************************/

    /*! To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    private var         _kbShowNotification: NSNotification!
    
    /*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    private var         _isKeyboardShowing: Bool = false
    
    /*! To save keyboard size. */
    private var         _kbSize: CGSize! = CGSizeZero
    
    /*! To save keyboard animation duration. */
    private var         _animationDuration: NSTimeInterval = 0.25
    
    /*! To mimic the keyboard animation */
    private var         _animationCurve: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseOut
    
    /*******************************************/

    /*! TapGesture to resign keyboard on view's touch. */
    private var         _tapGesture: UITapGestureRecognizer!
    
    /*! @abstract   Save keyWindow object for reuse.
        @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
    private var         _keyWindow: UIWindow!

    /*******************************************/
    
    /*! To use with keyboardDistanceFromTextField. */
    private var         _privateKeyboardDistanceFromTextField: CGFloat = 10.0
    
    /*******************************************/
    
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

    override class func load() {
        super.load()
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    deinit {
        enable = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    class func sharedManager() -> IQKeyboardManager {
        
        struct Static {
            static let kbManager : IQKeyboardManager = IQKeyboardManager()
        }
        
        /*! @return Returns the default singleton instance. */
        return Static.kbManager
    }

    /*! Getting keyWindow. */
    private func keyWindow() -> UIWindow {
        
        /*  (Bug ID: #23, #25, #73)   */
        let originalKeyWindow : UIWindow? = UIApplication.sharedApplication().keyWindow
       
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if originalKeyWindow != nil && _keyWindow != originalKeyWindow {
            _keyWindow = originalKeyWindow
        }
        
        //Return KeyWindow
        return _keyWindow
    }
    
    /*  Helper function to manipulate RootViewController's frame with animation. */
    private func setRootViewFrame(var frame: CGRect) {
    
        //  Getting topMost ViewController.
        var controller: UIViewController! = keyWindow().topMostController()
        
        //frame size needs to be adjusted on iOS8 due to orientation structure changes.
        if (IQ_IS_IOS8_OR_GREATER) {
            frame.size = controller.view.size
        }
        
        //  If can't get rootViewController then printing warning to user.
        if (controller == nil) {
            println("You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager")
        }
        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in

            //  Setting it's new frame
            controller.view.frame = frame

            }) { (animated:Bool) -> Void in}
    }

    
    /* Adjusting RootViewController's frame according to device orientation. */
    private func adjustFrame() {
        
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        if (_textFieldView == nil) {
            return
        }
        
        //  Boolean to know keyboard is showing/hiding
        _isKeyboardShowing = true
        
        //  Getting KeyWindow object.
        var window = keyWindow()
        //  Getting RootViewController.  (Bug ID: #1, #4)
        var rootController = keyWindow().topMostController()
        
        //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
        var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation

        //  Converting Rectangle according to window bounds.
        var textFieldViewRect : CGRect? = _textFieldView.superview?.convertRect(_textFieldView.frame, toView: window)
        //  Getting RootViewRect.
        var rootViewRect = rootController.view.frame
        //Getting statusBarFrame
        var statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        
        var move : CGFloat = 0
        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        
        //  Calculating move position. Common for both normal and special cases.
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            move = min((textFieldViewRect?.x)! - (statusBarFrame.width+5), (textFieldViewRect?.right)!-(window.width-_kbSize.width))
        case UIInterfaceOrientation.LandscapeRight:
            move = min(window.width - (textFieldViewRect?.right)! - (statusBarFrame.width+5), _kbSize.width - (textFieldViewRect?.x)!)
        case UIInterfaceOrientation.Portrait:
            move = min((textFieldViewRect?.y)! - (statusBarFrame.height+5), (textFieldViewRect?.bottom)! - (window.height-_kbSize.height))
        case UIInterfaceOrientation.PortraitUpsideDown:
            move = min(window.height - (textFieldViewRect?.bottom)! - (statusBarFrame.height+5), _kbSize.height - (textFieldViewRect?.y)!)
        default:
            break
        }
        
        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
        var superScrollView : UIScrollView? = _textFieldView.superScrollView()
        
        //If there was a lastScrollView.    //  (Bug ID: #34)
        if (_lastScrollView != nil) {
            //If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if (superScrollView == nil) {
                _lastScrollView?.setContentOffset(_startingContentOffset, animated: true)
                _lastScrollView = nil
                _startingContentOffset = CGPointZero
            }
            //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
            else if (superScrollView != _lastScrollView) {
                _lastScrollView?.setContentOffset(_startingContentOffset, animated: true)
                _lastScrollView = superScrollView
                _startingContentOffset = (superScrollView?.contentOffset)!
            }
            //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        }
            //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
        else if((superScrollView) != nil) {
            _lastScrollView = superScrollView
            _startingContentOffset = (superScrollView?.contentOffset)!
        }
        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (_lastScrollView != nil) {
            //Saving
            var lastView = _textFieldView
            var superScrollView : UIScrollView! = _lastScrollView
            
            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView != nil && move>0) {
                //Getting lastViewRect.
                var lastViewRect : CGRect! = lastView.superview?.convertRect(lastView.frame, toView: superScrollView)
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                var shouldOffsetY = superScrollView.contentOffset.y - min(superScrollView.contentOffset.y,-move)
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = min(shouldOffsetY, lastViewRect.y /*-5*/)   //-5 is for good UI.//Commenting -5 Bug ID #69
                
                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                move -= (shouldOffsetY-superScrollView.contentOffset.y)
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    
                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY)
                    }) { (animated:Bool) -> Void in }
                
                //  Getting next lastView & superScrollView.
                lastView = superScrollView
                superScrollView = lastView.superScrollView()
            }
        }
        //Going ahead. No else if.
        
        
        //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen).
        //If we have permission to adjust the textView, then let's do it on behalf of user.  (Enhancement ID: #15)
        //Added _isTextFieldViewFrameChanged. (Bug ID: #92)
        if ((canAdjustTextView == true) && (_textFieldView.isKindOfClass(UITextView) == true) && (_isTextFieldViewFrameChanged == false))
        {
            var textViewHeight: CGFloat = _textFieldView.height
 
            switch (interfaceOrientation) {
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                textViewHeight = min(textViewHeight, (window.width-_kbSize.width-(statusBarFrame.width+5)))
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                textViewHeight = min(textViewHeight, (window.height-_kbSize.height-(statusBarFrame.height+5)))
            default:
                break
            }
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in

                self._textFieldView.height = textViewHeight
                self._isTextFieldViewFrameChanged = true

                }, completion: { (finished) -> Void in
            })
        }
        
        //  Special case for iPad modalPresentationStyle.
        if (rootController.modalPresentationStyle == UIModalPresentationStyle.FormSheet || rootController.modalPresentationStyle == UIModalPresentationStyle.PageSheet) {
            //  Positive or zero.
            if (move>=0) {
                // We should only manipulate y.
                rootViewRect.y -= move
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if (preventShowingBottomBlankSpace == true)
                {
                    var minimumY: CGFloat = 0
                    
                    switch (interfaceOrientation)
                        {
                    case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                        minimumY = window.width-rootViewRect.height-statusBarFrame.width-(_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                        minimumY = (window.height-rootViewRect.height-statusBarFrame.height)/2-(_kbSize.height-keyboardDistanceFromTextField)
                    default:
                        break
                    }
                    
                    rootViewRect.y = max(rootViewRect.y, minimumY)
                }
                
                self.setRootViewFrame(rootViewRect)
            }
                //  Negative
            else {
                //  Calculating disturbed distance. Pull Request #3
                var disturbDistance = rootViewRect.y - _topViewBeginRect.y
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<0) {
                    // We should only manipulate y.
                    rootViewRect.y -= max(move, disturbDistance)
                    self.setRootViewFrame(rootViewRect)
                }
            }
        }
            //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
        else {
            //  Positive or zero.
            if (move>=0) {

                switch (interfaceOrientation) {
                case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= move
                case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += move
                case UIInterfaceOrientation.Portrait:            rootViewRect.y -= move
                case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += move
                default :
                    break
                }
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if (preventShowingBottomBlankSpace == true)
                {
                    switch (interfaceOrientation)
                        {
                    case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x = max(rootViewRect.x, -_kbSize.width+keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x = min(rootViewRect.x, +_kbSize.width-keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.Portrait:            rootViewRect.y = max(rootViewRect.y, -_kbSize.height+keyboardDistanceFromTextField)
                    case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y = min(rootViewRect.y, +_kbSize.height-keyboardDistanceFromTextField)
                    default:
                        break
                    }
                }

                //  Setting adjusted rootViewRect
                self.setRootViewFrame(rootViewRect)
            }
                //  Negative
            else {
                var disturbDistance : CGFloat = 0
                
                switch (interfaceOrientation) {
                case UIInterfaceOrientation.LandscapeLeft:
                    disturbDistance = rootViewRect.left - _topViewBeginRect.left
                case UIInterfaceOrientation.LandscapeRight:
                    disturbDistance = _topViewBeginRect.left - rootViewRect.left
                case UIInterfaceOrientation.Portrait:
                    disturbDistance = rootViewRect.top - _topViewBeginRect.top
                case UIInterfaceOrientation.PortraitUpsideDown:
                    disturbDistance = _topViewBeginRect.top - rootViewRect.top
                default :
                    break
                }
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<0) {

                    switch (interfaceOrientation) {
                    case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= max(move, disturbDistance)
                    case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += max(move, disturbDistance)
                    case UIInterfaceOrientation.Portrait:            rootViewRect.y -= max(move, disturbDistance)
                    case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += max(move, disturbDistance)
                    default :
                        break
                    }

                    //  Setting adjusted rootViewRect
                    self.setRootViewFrame(rootViewRect)
                }
            }
        }
    }
    
    /*  UIKeyboardWillShowNotification. */
    func keyboardWillShow(notification:NSNotification) -> Void {
        
        _kbShowNotification = notification

        var info : NSDictionary = notification.userInfo!
        
        if (enable == false) {
            return
        }
        
        //Due to orientation callback we need to resave it's original frame.    //  (Bug ID: #46)
        //Added _isTextFieldViewFrameChanged check. Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed. (Bug ID: #92)
        if (_isTextFieldViewFrameChanged == false && _textFieldView != nil)
        {
            _textFieldViewIntialFrame = _textFieldView.frame
        }

        if (CGRectEqualToRect(_topViewBeginRect, CGRectZero))    //  (Bug ID: #5)
        {
            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            var rootController = keyWindow().topMostController()
            _topViewBeginRect = rootController.view.frame
        }

        if (shouldAdoptDefaultKeyboardAnimation)
        {
            //  Getting keyboard animation.
            var curve = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.unsignedLongValue
            
            /* If you are running below Xcode6.1 then please remove IQ_IS_XCODE_6_1_OR_GREATER flag from 'other swift flag' to fix compiler errors.
            http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
            #if IQ_IS_XCODE_6_1_OR_GREATER
            _animationCurve = UIViewAnimationOptions(rawValue: curve!)
            #else
            _animationCurve = UIViewAnimationOptions.fromRaw(curve!)!
            #endif
        }
        else
        {
            _animationCurve = UIViewAnimationOptions.CurveEaseOut
        }
        
        //  Getting keyboard animation duration
        var duration =  info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        //Saving animation duration
        if (duration != 0.0) {
            _animationDuration = duration!
        }

        var oldKBSize = _kbSize
        
        //  Getting UIKeyboardSize.
        _kbSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue().size
        
        //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
        var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : self.keyWindow().topMostController().interfaceOrientation

        // Adding Keyboard distance from textField.
        switch (interfaceOrientation)
            {
        case UIInterfaceOrientation.LandscapeLeft:
            _kbSize.width += keyboardDistanceFromTextField
        case UIInterfaceOrientation.LandscapeRight:
            _kbSize.width += keyboardDistanceFromTextField
        case UIInterfaceOrientation.Portrait:
            _kbSize.height += keyboardDistanceFromTextField
        case UIInterfaceOrientation.PortraitUpsideDown:
            _kbSize.height += keyboardDistanceFromTextField
        default :
            break
        }
        
        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if (!CGSizeEqualToSize(_kbSize, oldKBSize))
        {
            //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            if _textFieldView != nil && _textFieldView.viewController()?.isKindOfClass(UITableViewController) == false && _textFieldView.isAlertViewTextField() == false {
                adjustFrame()
            }
        }
    }
    
    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    func keyboardWillHide(notification:NSNotification?) -> Void {
        
        //If it's not a fake notification generated by [self setEnable:NO].
        if (notification != nil) {
            _kbShowNotification = nil
        }
        
        //If not enabled then do nothing.
        if (enable == false) {
            return
        }
        
        //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        //    if (_textFieldView == nil)   return

        //  Boolean to know keyboard is showing/hiding
        _isKeyboardShowing = false
        
        var info :NSDictionary? = notification?.userInfo!
        
        //  Getting keyboard animation duration
        var duration =  info?.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        if (duration != 0) {
            //  Setitng keyboard animation duration
            _animationDuration = duration!
        }
        
        //Restoring the contentOffset of the lastScrollView
        if (_lastScrollView != nil)
        {
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                
                self._lastScrollView?.contentOffset = self._startingContentOffset
                
                // TODO: This is temporary solution. Have to implement the save and restore scrollView state
                var superscrollView : UIScrollView? = self._lastScrollView
                
                superscrollView = superscrollView?.superScrollView()
                
                while (superscrollView != nil) {
                    var superScrollView : UIScrollView! = superscrollView
                    
                    var contentSize = CGSizeMake(max(superScrollView.contentSize.width, superScrollView.width), max(superScrollView.contentSize.height, superScrollView.height))
                    
                    var minimumY = contentSize.height-superScrollView.height
                    
                    if (minimumY < superScrollView.contentOffset.y) {
                        superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, minimumY)
                    }
                    
                    superscrollView = superScrollView.superScrollView()
                }
                }) { (finished) -> Void in }
        }
        
        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        if (!CGRectEqualToRect(_topViewBeginRect, CGRectZero))
        {
            setRootViewFrame(_topViewBeginRect)
        }
        
        //Reset all values
        _lastScrollView = nil
        _kbSize = CGSizeZero
        _startingContentOffset = CGPointZero
    }
    
    func keyboardDidHide(notification:NSNotification) {
        _topViewBeginRect = CGRectZero
    }
    
    /*!  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    func textFieldViewDidBeginEditing(notification:NSNotification) {
        //  Getting object
        _textFieldView = notification.object as UIView
        
        if (overrideKeyboardAppearance == true) {
            
            if (_textFieldView.isKindOfClass(UITextField) == true)
            {
                (_textFieldView as UITextField).keyboardAppearance = keyboardAppearance
            }
            else if (_textFieldView.isKindOfClass(UITextView) == true)
            {
                (_textFieldView as UITextView).keyboardAppearance = keyboardAppearance
            }
        }
        
        // Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed.
        //Added _isTextFieldViewFrameChanged check. (Bug ID: #92)
        if (_isTextFieldViewFrameChanged == false)
        {
            _textFieldViewIntialFrame = _textFieldView.frame
        }
        
        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if (enableAutoToolbar) {
            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if ((_textFieldView.isKindOfClass(UITextView) == true) && _textFieldView.inputAccessoryView == nil) {
                
                UIView.animateWithDuration(0.00001, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (finished) -> Void in

                        var textFieldRetain = self._textFieldView
                        textFieldRetain.resignFirstResponder()
                        textFieldRetain.becomeFirstResponder()
                })
            }
            else {
                addToolbarIfRequired()
            }
        }
        
        if (enable == false) {
            return
        }
        
        _textFieldView.window?.addGestureRecognizer(_tapGesture)    //   (Enhancement ID: #14)

        if _isKeyboardShowing == false {    //  (Bug ID: #5)

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            var rootController = self.keyWindow().topMostController()
            _topViewBeginRect = rootController.view.frame
        }
        
        //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if _textFieldView != nil && _textFieldView.viewController()?.isKindOfClass(UITableViewController) == false && _textFieldView.isAlertViewTextField() == false {
            adjustFrame()
        }
    }
    
    /*!  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    func textFieldViewDidEndEditing(notification:NSNotification) {
        
        _textFieldView.window?.removeGestureRecognizer(_tapGesture) //  (Enhancement ID: #14)
        
        // We check if there's a change in original frame or not.
        if(_isTextFieldViewFrameChanged == true)
        {
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                self._isTextFieldViewFrameChanged = false
                self._textFieldView.frame = self._textFieldViewIntialFrame
                }, completion: { (finished) -> Void in
                    
            })
        }
        
        //Setting object to nil
        _textFieldView = nil
    }
    
    /* UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
    func textFieldViewDidChange(notification:NSNotification) {  //  (Bug ID: #18)
        
        var textView : UITextView = notification.object as UITextView
        
        var line = textView .caretRectForPosition(textView.selectedTextRange?.start)
        
        var overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top)
        
        //Added overflow conditions (Bug ID: 95)
        if ( overflow > 0.0 && overflow < CGFloat(FLT_MAX)) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            var offset = textView.contentOffset
            offset.y += overflow + 7 // leave 7 pixels margin
            
            // Cannot animate with setContentOffset:animated: or caret will not appear
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                textView.contentOffset = offset
            }, completion: { (finished) -> Void in

            })
        }
    }
    
    /*!  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    func willChangeStatusBarOrientation(notification:NSNotification) {
        
        //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
        if (_isTextFieldViewFrameChanged == true)
        {
            //Due to orientation callback we need to set it's original position.
            UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                self._textFieldView.frame = self._textFieldViewIntialFrame
                self._isTextFieldViewFrameChanged = false
            }, completion: { (finished) -> Void in

            })
        }
    }
    
    /*! Resigning on tap gesture. */
    func tapRecognized(gesture: UITapGestureRecognizer) {

        if (gesture.state == UIGestureRecognizerState.Ended) {
            gesture.view?.endEditing(true)
        }
    }
    
    /*! Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /*! Resigning textField. */
    func resignFirstResponder() {
        
        if (_textFieldView != nil)
        {
            //  Retaining textFieldView
            var textFieldRetain = _textFieldView
            
            //Resigning first responder
            var isResignFirstResponder = _textFieldView.resignFirstResponder()
            
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            if (isResignFirstResponder == false)
            {
                //If it refuses to resign then becoming it first responder again for getting notifications callback.
                textFieldRetain.becomeFirstResponder()

                println("IQKeyboardManager: Refuses to Resign first responder: \(_textFieldView) ")
            }
        }
    }
    
    /*!	Get all UITextField/UITextView siblings of textFieldView. */
    
    func responderViews()-> NSArray {
        
        var tableView : UIView? = _textFieldView.superTableView()
        if(tableView == nil) {
            tableView = tableView?.superCollectionView()
        }
        
        var textFields : NSArray!
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if (tableView != nil) {     //   (Enhancement ID: #22)
            textFields = tableView?.deepResponderViews()
        }
            //Otherwise fetching all the siblings
        else {
            textFields = _textFieldView.responderSiblings()
        }
        
        //Sorting textFields according to behaviour
        switch (toolbarManageBehaviour) {
            //If autoToolbar behaviour is bySubviews, then returning it.
        case IQAutoToolbarManageBehaviour.BySubviews:   return textFields
            
            //If autoToolbar behaviour is by tag, then sorting it according to tag property.
        case IQAutoToolbarManageBehaviour.ByTag:    return textFields.sortedArrayByTag()
            
            //If autoToolbar behaviour is by tag, then sorting it according to tag property.
        case IQAutoToolbarManageBehaviour.ByPosition:    return textFields.sortedArrayByPosition()
        }
    }
    
    /*!	previousAction. */
    func previousAction (segmentedControl : AnyObject!) {

        if (shouldPlayInputClicks == true) {
            UIDevice.currentDevice().playInputClick()
        }
        
        //Getting all responder view's.
        var textFields = responderViews()
        
        if (textFields.containsObject(_textFieldView) == true) {
            //Getting index of current textField.
            var index = textFields.indexOfObject(_textFieldView)
            
            //If it is not first textField. then it's previous object becomeFirstResponder.
            if index > 0 {
                
                var nextTextField = textFields[index-1] as UIView
                
                //  Retaining textFieldView
                var  textFieldRetain = _textFieldView
                
                var isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                
                //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                if (isAcceptAsFirstResponder == false)
                {
                    //If next field refuses to become first responder then restoring old textField as first responder.
                    textFieldRetain.becomeFirstResponder()
                    println("IQKeyboardManager: Refuses to become first responder: \(nextTextField)")
                }
            }
        }
    }

    /*!	nextAction. */
    func nextAction (segmentedControl : AnyObject!) {
        
        if (shouldPlayInputClicks == true) {
            UIDevice.currentDevice().playInputClick()
        }
        
        //Getting all responder view's.
        
        var textFields = responderViews()
        
        if (textFields.containsObject(_textFieldView) == true)
        {
            //Getting index of current textField.
            var index = textFields.indexOfObject(_textFieldView)
            
            //If it is not last textField. then it's next object becomeFirstResponder.
            if index < textFields.count-1 {
                
                var nextTextField = textFields[index+1] as UIView

                //  Retaining textFieldView
                var  textFieldRetain = _textFieldView
                
                var isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                
                //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                if (isAcceptAsFirstResponder == false)
                {
                    //If next field refuses to become first responder then restoring old textField as first responder.
                    textFieldRetain.becomeFirstResponder()
                    println("IQKeyboardManager: Refuses to become first responder: \(nextTextField)")
                }
            }
        }
    }
    
    /*!	doneAction. Resigning current textField. */
    func doneAction (barButton : IQBarButtonItem!) {
        
        if (shouldPlayInputClicks == true) {
            UIDevice.currentDevice().playInputClick()
        }
        
        resignFirstResponder()
    }
    
    /*! Add toolbar if it is required to add on textFields and it's siblings. */
    private func addToolbarIfRequired() {
        
        //	Getting all the sibling textFields.
        var siblings : NSArray? = responderViews()
        
        //	If only one object is found, then adding only Done button.
        if (siblings?.count == 1) {
            var textField : UIView = siblings?.firstObject as UIView
            
            //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
            if (textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag) {
                textField.addDoneOnKeyboardWithTarget(self, action: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                textField.inputAccessoryView?.tag = kIQDoneButtonToolbarTag //  (Bug ID: #78)

                //Setting toolbar tintColor.    //  (Enhancement ID: #30)
                if shouldToolbarUsesTextFieldTintColor == true {

                    textField.inputAccessoryView?.tintColor = textField.tintColor
                }
                
                //Setting toolbar title font.   //  (Enhancement ID: #30)
                if (shouldShowTextFieldPlaceholder == true && placeholderFont != nil) {
                    
                    (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont!
                }
            }
        }
        else if siblings?.count != 0 {
            
            //	If more than 1 textField is found. then adding previous/next/done buttons on it.
            for textField in siblings as Array<UIView> {
                
                if (textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag)  {
                    
                    textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: "previousAction:", nextAction: "nextAction:", doneAction: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                    textField.inputAccessoryView?.tag = kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)

                    //Setting toolbar tintColor //  (Enhancement ID: #30)
                    if shouldToolbarUsesTextFieldTintColor == true {
                        textField.inputAccessoryView?.tintColor = textField.tintColor
                    }
                    
                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if (shouldShowTextFieldPlaceholder == true && placeholderFont != nil) {
                        (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont!
                    }
                }

                //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
                if (textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag)
                {
                    //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                    //	If firstTextField, then previous should not be enabled.
                    if (siblings?.objectAtIndex(0) as UIView == textField) {
                        textField.setEnablePrevious(false, isNextEnabled: true)
                    }
                        //	If lastTextField then next should not be enaled.
                    else if (siblings?.lastObject as UIView  == textField) {
                        textField.setEnablePrevious(true, isNextEnabled: false)
                    }
                    else {
                        textField.setEnablePrevious(true, isNextEnabled: true)
                    }
                }
            }
        }
    }

    /*! Remove any toolbar if it is IQToolbar. */
    private func removeToolbarIfRequired() {    //  (Bug ID: #18)
        
        //	Getting all the sibling textFields.
        var siblings : NSArray? = responderViews()
        
        for view in siblings as Array<UIView> {

            var toolbar = view.inputAccessoryView?

            if view.inputAccessoryView is IQToolbar  && ( toolbar != nil && (toolbar?.tag == kIQDoneButtonToolbarTag || toolbar?.tag == kIQPreviousNextButtonToolbarTag)) {
                
                
                if (view.isKindOfClass(UITextField) == true)
                {
                    var textField : UITextField = view as UITextField
                    textField.inputAccessoryView = nil
                }
                else if (view.isKindOfClass(UITextView) == true)
                {
                    var textView : UITextView = view as UITextView
                    textView.inputAccessoryView = nil
                }
            }
        }
    }
}

