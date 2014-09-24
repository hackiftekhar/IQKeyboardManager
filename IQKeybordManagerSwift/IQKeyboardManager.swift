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

@abstract Keyboard TextField/TextView Manager
*/

class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
//UIKeyboard handling
    /*! @abstract enable/disable the keyboard manager. Default is YES(Enabled when class loads in `+(void)load` method.    */
    var enable: Bool = false {
        
        didSet{
            
            //If not enable, enable it.
            if (enable == true && oldValue == false) {
                //If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
                if kbShowNotification != nil {
                    keyboardWillShow(kbShowNotification)
                }
            }
            //If not disable, desable it.
            else if (enable == false && oldValue == true) {
                var a : NSNotification? = nil
                keyboardWillHide(a)
            }
        }
    }
    
    /*! @abstract To set keyboard distance from textField. can't be less than zero. Default is 10.0.    */
    var keyboardDistanceFromTextField: CGFloat = 10.0 /*{

        willSet {
            keyboardDistanceFromTextField = max(0, newValue)
        }
    }*/

    //IQToolbar handling
    /*! @abstract Automatic add the IQToolbar functionality. Default is YES.    */
    var enableAutoToolbar: Bool = true {
        
        didSet {
            enableAutoToolbar ?addToolbarIfRequired():removeToolbarIfRequired()
        }
    }
    
    /*! @abstract AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.   */
    var toolbarManageBehaviour: IQAutoToolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /*! @abstract If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO. */
    var shouldToolbarUsesTextFieldTintColor: Bool = false
    
    /*! @abstract If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.    */
    var shouldShowTextFieldPlaceholder: Bool = true
    
    /*! @abstract placeholder Font. Default is nil. */
    var placeholderFont: UIFont?
    
    
//TextView handling
    /*! @abstract Adjust textView's frame when it is too big in height. Default is NO.  */
    var canAdjustTextView: Bool = false

    
//Keyboard appearance overriding
    /*! @abstract override the keyboardAppearance for all textField/textView. Default is NO.    */
    var overrideKeyboardAppearance: Bool = false
    
    /*! @abstract if overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.   */
    var keyboardAppearance: UIKeyboardAppearance = UIKeyboardAppearance.Default

    
//Resign handling
    /*! @abstract Resigns Keyboard on touching outside of UITextField/View. Default is NO.  */
    var shouldResignOnTouchOutside:Bool = false {
        
        didSet {
            tapGesture.enabled = shouldResignOnTouchOutside
        }
    }
    
//Sound handling
    /*! @abstract If YES, then it plays inputClick sound on next/previous/done click.   */
    var shouldPlayInputClicks: Bool = false
    
    
//Animation handling
    /*! @abstract   If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
        @discussion Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.    */
    var shouldAdoptDefaultKeyboardAnimation: Bool = true


    
//Private variables
    /*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    private var isKeyboardShowing: Bool = false
    
    /*! To save rootViewController.view.frame. */
    private var topViewBeginRect: CGRect = CGRectZero
    
    /*! To save keyboard animation duration. */
    private var animationDuration: NSTimeInterval = 0.25
    
    /*! To mimic the keyboard animation */
    private var animationCurve: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseOut
    
    /*! To save UITextField/UITextView object voa textField/textView notifications. */
    private weak var _textFieldView: UIView!
    
    /*! To save keyboard size. */
    private var kbSize: CGSize! = CGSizeZero
    
    /*! To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    private var kbShowNotification: NSNotification!
    
    /*! Variable to save lastScrollView that was scrolled. */
    private weak var lastScrollView: UIScrollView?
    
    /*! LastScrollView's initial contentOffset. */
    private var startingContentOffset: CGPoint = CGPointZero
    
    /*! TapGesture to resign keyboard on view's touch. */
    private var tapGesture: UITapGestureRecognizer!
    
    /*! used with canAdjustTextView boolean. */
    private var textFieldViewIntialFrame: CGRect = CGRectZero

    /*! @abstract   Save keyWindow object for reuse.
        @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
    private var _keyWindow: UIWindow!

    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",                name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",                name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidBeginEditing:",    name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidEndEditing:",      name: UITextFieldTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidBeginEditing:",    name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidEndEditing:",      name: UITextViewTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldViewDidChange:",          name: UITextViewTextDidChangeNotification, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "tapRecognized:")
        tapGesture.delegate = self
        tapGesture.enabled = shouldResignOnTouchOutside
    }

    override class func load() {
        super.load()
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
//    func dealloc() {
//        enable = false
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
    class func sharedManager() -> IQKeyboardManager {
        
        struct Static {
            static let kbManager : IQKeyboardManager = IQKeyboardManager()
        }
        
        /*! @return Returns the default singleton instance. */
        return Static.kbManager
    }

    /*! Getting keyWindow. */
    private func keyWindow() -> UIWindow {
        
        /*  (Bug ID: #73)   */
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
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in

            //  Setting it's new frame
            controller.view.frame = frame

            }) { (animated:Bool) -> Void in}
    }

    
    /*  Helper function to manipulate RootViewController's frame with animation. */
    private func adjustFrame() {
        
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.
        if (_textFieldView == nil) {
            return
        }
        
        //  Boolean to know keyboard is showing/hiding
        isKeyboardShowing = true
        
        //  Getting KeyWindow object.
        var window = keyWindow()
        //  Getting RootViewController.
        var rootController = keyWindow().topMostController()
        
        //  Converting Rectangle according to window bounds.
        var textFieldViewRect : CGRect? = _textFieldView.superview?.convertRect(_textFieldView.frame, toView: window)
        //  Getting RootViewRect.
        var rootViewRect = rootController.view.frame
        
        var move : CGFloat = 0
        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        
        //  Calculating move position. Common for both normal and special cases.
        switch (rootController.interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            move = (textFieldViewRect?.right)! - (window.width-kbSize.width)
        case UIInterfaceOrientation.LandscapeRight:
            move = kbSize.width - (textFieldViewRect?.left)!
        case UIInterfaceOrientation.Portrait:
            move = (textFieldViewRect?.bottom)! - (window.height-kbSize.height)
        case UIInterfaceOrientation.PortraitUpsideDown:
            move = kbSize.height - (textFieldViewRect?.top)!
        default :   break
        }
        
        //  Getting it's superScrollView.
        var superScrollView : UIScrollView? = _textFieldView.superScrollView()
        
        //If there was a lastScrollView.
        if (lastScrollView != nil) {
            //If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if (superScrollView == nil) {
                lastScrollView?.setContentOffset(startingContentOffset, animated: true)
                lastScrollView = nil
                startingContentOffset = CGPointZero
            }
            //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
            if (superScrollView != lastScrollView) {
                lastScrollView?.setContentOffset(startingContentOffset, animated: true)
                lastScrollView = superScrollView
                startingContentOffset = (superScrollView?.contentOffset)!
            }
        }
            //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
        else if((superScrollView) != nil) {
            lastScrollView = superScrollView
            startingContentOffset = (superScrollView?.contentOffset)!
        }
        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (lastScrollView != nil) {
            //Saving
            var lastView = _textFieldView
            var superScrollView : UIScrollView! = lastScrollView
            
            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView != nil) {
                //Getting lastViewRect.
                var lastViewRect : CGRect! = lastView.superview?.convertRect(lastView.frame, toView: superScrollView)
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                var shouldOffsetY = superScrollView.contentOffset.y - min(superScrollView.contentOffset.y,-move)
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = min(shouldOffsetY, lastViewRect.y/*-5*/)   //-5 is for good UI.//Commenting -5 Bug ID #69
                
                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                move -= (shouldOffsetY-superScrollView.contentOffset.y)
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in
                    
                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY)
                    }) { (animated:Bool) -> Void in }
                
                //  Getting next lastView & superScrollView.
                lastView = superScrollView
                superScrollView = lastView.superScrollView()
            }
        }
        //Going ahead. No else if.
        
        
        //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen).
        var initialMove: CGFloat = move
        
        var adjustment: CGFloat = 0
        
        //If it's iOS8 then we should do calculations according to portrait orientations.
        var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation
        
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            adjustment += UIApplication.sharedApplication().statusBarFrame.width
            move = min((textFieldViewRect?.left)! - adjustment, move)
        case UIInterfaceOrientation.LandscapeRight:
            adjustment += UIApplication.sharedApplication().statusBarFrame.width
            move = min(window.width - (textFieldViewRect?.right)! - adjustment, move)
        case UIInterfaceOrientation.Portrait:
            adjustment += UIApplication.sharedApplication().statusBarFrame.height
            move = min( (textFieldViewRect?.top)! - adjustment, move)
        case UIInterfaceOrientation.PortraitUpsideDown:
            adjustment += UIApplication.sharedApplication().statusBarFrame.height
            move = min(window.height - (textFieldViewRect?.bottom)! - adjustment, move)
        default :   break
        }
        
        //If we have permission to adjust the textView, then let's do it on behalf of user.
        if (canAdjustTextView && (_textFieldView is UITextView) == true) {
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in
                self._textFieldView.height = self._textFieldView.height-(initialMove-move)
                }, completion: { (finished) -> Void in })
        }
        
        //  Special case for iPad modalPresentationStyle.
        if (rootController.modalPresentationStyle == UIModalPresentationStyle.FormSheet || rootController.modalPresentationStyle == UIModalPresentationStyle.PageSheet) {
            //  Positive or zero.
            if (move>=0) {
                // We should only manipulate y.
                rootViewRect.y -= move
                self.setRootViewFrame(rootViewRect)
            }
                //  Negative
            else {
                //  Calculating disturbed distance
                var disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(topViewBeginRect)
                
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
                //If it's iOS8 then we should do calculations according to portrait orientations.
                var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation
                
                switch (interfaceOrientation) {
                case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= move
                case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += move
                case UIInterfaceOrientation.Portrait:            rootViewRect.y -= move
                case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += move
                default :   break
                }
                
                //  Setting adjusted rootViewRect
                self.setRootViewFrame(rootViewRect)
            }
                //  Negative
            else {
                var disturbDistance : CGFloat = 0
                
                //If it's iOS8 then we should do calculations according to portrait orientations.
                var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation
                
                switch (interfaceOrientation) {
                case UIInterfaceOrientation.LandscapeLeft:
                    disturbDistance = rootViewRect.left - topViewBeginRect.left
                case UIInterfaceOrientation.LandscapeRight:
                    disturbDistance = topViewBeginRect.left - rootViewRect.left
                case UIInterfaceOrientation.Portrait:
                    disturbDistance = rootViewRect.top - topViewBeginRect.top
                case UIInterfaceOrientation.PortraitUpsideDown:
                    disturbDistance = topViewBeginRect.top - rootViewRect.top
                default :   break
                }
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<0) {
                    //If it's iOS8 then we should do calculations according to portrait orientations.
                    var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : rootController.interfaceOrientation
                    
                    switch (interfaceOrientation) {
                    case UIInterfaceOrientation.LandscapeLeft:       rootViewRect.x -= max(move, disturbDistance)
                    case UIInterfaceOrientation.LandscapeRight:      rootViewRect.x += max(move, disturbDistance)
                    case UIInterfaceOrientation.Portrait:            rootViewRect.y -= max(move, disturbDistance)
                    case UIInterfaceOrientation.PortraitUpsideDown:  rootViewRect.y += max(move, disturbDistance)
                    default :   break
                    }

                    //  Setting adjusted rootViewRect
                    self.setRootViewFrame(rootViewRect)
                }
            }
        }
    }
    
    /*  UIKeyboardWillShowNotification. */
    func keyboardWillShow(notification:NSNotification) -> Void {
        
        kbShowNotification = notification

        var info : NSDictionary = notification.userInfo!
        
        if (enable == false) {
            return
        }
        
        //Due to orientation callback we need to resave it's original frame.
        textFieldViewIntialFrame = (enable && canAdjustTextView) ? _textFieldView.frame : CGRectZero
        
        if (shouldAdoptDefaultKeyboardAnimation)
        {
            var curve = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.unsignedLongValue
            
            animationCurve = UIViewAnimationOptions.fromRaw(curve!)!
        }
        else
        {
            animationCurve = UIViewAnimationOptions.CurveEaseOut
        }
        
        //  Getting keyboard animation duration
        var duration =  info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        //Saving animation duration
        if (duration != 0.0) {
            animationDuration = duration!
        }

        var oldKBSize = kbSize
        
        //  Getting UIKeyboardSize.
        kbSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue().size
        
        //If it's iOS8 then we should do calculations according to portrait orientations.
        var interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.Portrait : self.keyWindow().topMostController().interfaceOrientation

        // Adding Keyboard distance from textField.
        switch (interfaceOrientation)
            {
        case UIInterfaceOrientation.LandscapeLeft:
            kbSize.width += keyboardDistanceFromTextField
        case UIInterfaceOrientation.LandscapeRight:
            kbSize.width += keyboardDistanceFromTextField
        case UIInterfaceOrientation.Portrait:
            kbSize.height += keyboardDistanceFromTextField
        case UIInterfaceOrientation.PortraitUpsideDown:
            kbSize.height += keyboardDistanceFromTextField
        default :   break
        }
        
        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if (!CGSizeEqualToSize(kbSize, oldKBSize))
        {
            //If it is EventKit textView object then let EventKit to adjust it. (Bug ID: #37)
            if _textFieldView?.isEventKitTextView() == false {
                
                adjustFrame()
            }
        }
    }
    
    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    func keyboardWillHide(notification:NSNotification?) -> Void {
        
        //If it's not a fake notification generated by [self setEnable:NO].
        if (notification != nil) {
            kbShowNotification = nil
        }
        
        var info :NSDictionary? = notification?.userInfo!

        //If not enabled then do nothing.
        if (enable == false) {
            return
        }
        
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.
        if (_textFieldView == nil) {
            return
        }

        //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
        if (!CGRectEqualToRect(textFieldViewIntialFrame, CGRectZero)) {
            //Due to orientation callback we need to set it's original position.
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in
                self._textFieldView.frame = self.textFieldViewIntialFrame
            }, completion: { (finished) -> Void in
            })
        }
        
        //  Boolean to know keyboard is showing/hiding
        isKeyboardShowing = false
        
        //  Getting keyboard animation duration
        var duration =  info?.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue

        if (duration != 0) {
            //  Setitng keyboard animation duration
            animationDuration = duration!
        }
        
        //Restoring the contentOffset of the lastScrollView
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in

            self.lastScrollView?.contentOffset = self.startingContentOffset
            
            // TODO: This is temporary solution. Have to implement the save and restore scrollView state
            var superscrollView : UIScrollView? = self.lastScrollView
            
            superscrollView = superscrollView?.superScrollView()
            
            while (superscrollView != nil) {
                var superScrollView : UIScrollView! = superscrollView

                var contentSize = CGSizeMake(max(superScrollView.contentSize.width, superScrollView.width), max(superScrollView.contentSize.height, superScrollView.height))
                
                var minimumY = contentSize.height-superScrollView.height
                
                if (minimumY<superScrollView.contentOffset.y) {
                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, minimumY)
                }
                
                superscrollView = superScrollView.superScrollView()
            }
            }) { (finished) -> Void in }
        
        //Reset all values
        lastScrollView = nil
        kbSize = CGSizeZero
        startingContentOffset = CGPointZero
        
        //  Setting rootViewController frame to it's original position.
        setRootViewFrame(topViewBeginRect)
    }
    
    /*!  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    func textFieldViewDidBeginEditing(notification:NSNotification) {
        //  Getting object
        _textFieldView = notification.object as UIView
        
        if (overrideKeyboardAppearance == true) {
            (_textFieldView as UITextField).keyboardAppearance = keyboardAppearance
        }
        
        // If the manager is not enabled and it can't adjust the textview set the initial frame to CGRectZero
        textFieldViewIntialFrame = enable && canAdjustTextView ? _textFieldView.frame : CGRectZero
        
        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if (enableAutoToolbar) {
            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if ((_textFieldView is UITextView) == true && _textFieldView.inputAccessoryView == nil) {
                 var view = _textFieldView
                
                UIView.animateWithDuration(0.00001, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (finished) -> Void in

                        view.resignFirstResponder()
                        view.becomeFirstResponder()
                })
            }
            else {
                addToolbarIfRequired()
            }
        }
        
        if (enable == false) {
            return
        }
        
        _textFieldView.window?.addGestureRecognizer(tapGesture)

        if isKeyboardShowing == false {

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            var rootController = self.keyWindow().topMostController()
            topViewBeginRect = rootController.view.frame
        }
        
        //If it is EventKit textView object then let EventKit to adjust it. (Bug ID: #37)
        if (_textFieldView.isEventKitTextView() == false) {
            //  keyboard is already showing. adjust frame.
            adjustFrame()
        }
    }
    
    /*!  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    func textFieldViewDidEndEditing(notification:NSNotification) {
        
        _textFieldView.window?.removeGestureRecognizer(tapGesture)
        
        // We check if there's a valid frame before resetting the textview's frame
        if(!CGRectEqualToRect(textFieldViewIntialFrame, CGRectZero)) {
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in
                self._textFieldView.frame = self.textFieldViewIntialFrame
            }, completion: { (finished) -> Void in

            })
        }
        
        //Setting object to nil
        _textFieldView = nil
    }
    
    /* UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
    func textFieldViewDidChange(notification:NSNotification) {
        
        var textView : UITextView = notification.object as UITextView
        
        var line = textView .caretRectForPosition(textView.selectedTextRange?.start)
        
        var overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top)
        
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            var offset = textView.contentOffset
            offset.y += overflow + 7 // leave 7 pixels margin
            
            // Cannot animate with setContentOffset:animated: or caret will not appear
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|animationCurve, animations: { () -> Void in
                textView.contentOffset = offset
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
        _textFieldView.resignFirstResponder()
    }
    
    /*!	Get all UITextField/UITextView siblings of textFieldView. */
    
    func responderViews()-> NSArray {
        
        var tableView  : UITableView? = _textFieldView.superTableView()
        
        var textFields : NSArray!
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if (tableView != nil) {
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
        }
    }
    
    /*!	previousAction. */
    func previousAction (segmentedControl : AnyObject!) {

        if (shouldPlayInputClicks == true) {
            UIDevice.currentDevice().playInputClick()
        }
        
        //Getting all responder view's.
        
        var textFields = responderViews()
        
        if (textFields.containsObject(_textFieldView)) {
            //Getting index of current textField.
            var index = textFields.indexOfObject(_textFieldView)
            
            //If it is not first textField. then it's previous object becomeFirstResponder.
            if index > 0 {
                textFields.objectAtIndex(index-1).becomeFirstResponder()
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
        
        if (textFields.containsObject(_textFieldView))
        {
            //Getting index of current textField.
            var index = textFields.indexOfObject(_textFieldView)
            
            //If it is not last textField. then it's next object becomeFirstResponder.
            if index < textFields.count-1 {
                textFields.objectAtIndex(index+1).becomeFirstResponder()
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
            
            if (textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag != kIQDoneButtonToolbarTag) {
                textField.addDoneOnKeyboardWithTarget(self, action: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)

                //Setting toolbar tintColor
                if shouldToolbarUsesTextFieldTintColor == true {

                    textField.inputAccessoryView?.tintColor = textField.tintColor
                }
                
                //Setting toolbar title font.
                if (shouldShowTextFieldPlaceholder == true && placeholderFont != nil) {
                    
                    (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont!
                }
            }
        }
        else if siblings?.count != 0 {
            
            //	If more than 1 textField is found. then adding previous/next/done buttons on it.
            
            for textField in siblings as Array<UIView> {
                
                if (textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag != kIQPreviousNextButtonToolbarTag)  {
                    
                    textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: "previousAction:", nextAction: "nextAction:", doneAction: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)

                    //Setting toolbar tintColor
                    if shouldToolbarUsesTextFieldTintColor == true {
                        
                        textField.inputAccessoryView?.tintColor = textField.tintColor
                    }
                    
                    //Setting toolbar title font.
                    if (shouldShowTextFieldPlaceholder == true && placeholderFont != nil) {
                        
                        (textField.inputAccessoryView as IQToolbar).titleFont = placeholderFont!
                    }
                }

                //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.
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

    /*! Remove any toolbar if it is IQToolbar. */
    private func removeToolbarIfRequired() {
        //	Getting all the sibling textFields.
        var siblings : NSArray? = responderViews()
        
        for textField in siblings as Array<UITextField> {

            if textField.inputAccessoryView is IQToolbar {
                
                textField.inputAccessoryView = nil
            }
        }
    }
}

