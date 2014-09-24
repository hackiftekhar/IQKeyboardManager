//
//  IQUIView+IQKeyboardToolbar.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

/*  @const kIQRightButtonToolbarTag        Default tag for toolbar with Right button           -1001.   */
let kIQRightButtonToolbarTag : NSInteger            =   -1001
/*  @const kIQDoneButtonToolbarTag         Default tag for toolbar with Done button            -1002.   */
let  kIQDoneButtonToolbarTag : NSInteger            =   -1002
/*  @const kIQRightLeftButtonToolbarTag    Default tag for toolbar with Right/Left buttons     -1003.   */
let  kIQRightLeftButtonToolbarTag : NSInteger       =   -1003
/*  @const kIQCancelDoneButtonToolbarTag   Default tag for toolbar with Cancel/Done buttons    -1004.   */
let  kIQCancelDoneButtonToolbarTag : NSInteger      =   -1004
/*  @const kIQPreviousNextButtonToolbarTag Default tag for toolbar with Previous/Next buttons  -1005.   */
let  kIQPreviousNextButtonToolbarTag : NSInteger    =   -1005

extension UIView {
    
    /*!
    @method addDoneOnKeyboardWithTarget:action:
    
    @abstract Helper functions to add Done button on keyboard.
    
    @param target: Target object for selector. Usually 'self'.
    
    @param action: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
    
    @param titleText: text to show as title in IQToolbar'.
    */
    func addRightButtonOnKeyboardWithText (text : NSString, target : AnyObject, action : Selector, titleText: NSString!) {
        
        
    }
    
    func addRightButtonOnKeyboardWithText (text : NSString, target : AnyObject, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : NSString!

        if shouldShowPlaceholder {
            var textField : UITextField? = self as? UITextField
            
            title = textField?.placeholder
        }
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: title)
    }
    
    func addRightButtonOnKeyboardWithText (text : NSString, target : AnyObject, action : Selector) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: nil)
    }

    func addDoneOnKeyboardWithTarget (target : AnyObject, action : Selector, titleText: NSString!) {

        
    }
    
    func addDoneOnKeyboardWithTarget (target : AnyObject, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : NSString!
        
        if shouldShowPlaceholder {
            var textField : UITextField? = self as? UITextField
            
            title = textField?.placeholder
        }

        addDoneOnKeyboardWithTarget(target, action: action, titleText: title)
    }
    
    func addDoneOnKeyboardWithTarget (target : AnyObject, action : Selector) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: nil)
    }

    
    /*!
    @method addCancelDoneOnKeyboardWithTarget:cancelAction:doneAction:
    
    @abstract Helper function to add Cancel and Done button on keyboard.
    
    @param target: Target object for selector. Usually 'self'.
    
    @param cancelAction: Crevious button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    
    @param doneAction: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
    
    @param titleText: text to show as title in IQToolbar'.
    */
    
    func addRightLeftOnKeyboardWithTarget( target : AnyObject, leftButtonTitle : NSString, rightButtonTitle : NSString, rightButtonAction : Selector, leftButtonAction : Selector, titleText: NSString!) {
        
    }
    
    func addRightLeftOnKeyboardWithTarget( target : AnyObject, leftButtonTitle : NSString, rightButtonTitle : NSString, rightButtonAction : Selector, leftButtonAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : NSString!
        
        if shouldShowPlaceholder {
            var textField : UITextField? = self as? UITextField
            
            title = textField?.placeholder
        }
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, rightButtonAction: rightButtonAction, leftButtonAction: leftButtonAction, titleText: title)
    }
    
    func addRightLeftOnKeyboardWithTarget( target : AnyObject, leftButtonTitle : NSString, rightButtonTitle : NSString, rightButtonAction : Selector, leftButtonAction : Selector) {
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, rightButtonAction: rightButtonAction, leftButtonAction: leftButtonAction, titleText: nil)
    }
    
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject, cancelAction : Selector, doneAction : Selector, titleText: NSString!) {
        
    }
    
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject, cancelAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : NSString!
        
        if shouldShowPlaceholder {
            var textField : UITextField? = self as? UITextField
            
            title = textField?.placeholder
        }
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: title)
    }
    
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject, cancelAction : Selector, doneAction : Selector) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: nil)
    }
    
    
    /*!
    @method addPreviousNextDoneOnKeyboardWithTarget:previousAction:nextAction:doneAction
    
    @abstract Helper function to add SegmentedNextPrevious and Done button on keyboard.
    
    @param target: Target object for selector. Usually 'self'.
    
    @param previousAction: Previous button action name. Usually 'previousAction:(IQSegmentedNextPrevious*)segmentedControl'.
    
    @param nextAction: Next button action name. Usually 'nextAction:(IQSegmentedNextPrevious*)segmentedControl'.
    
    @param doneAction: Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    
    @param shouldShowPlaceholder: A boolean to indicate whether to show textField placeholder on IQToolbar'.
    
    @param titleText: text to show as title in IQToolbar'.
    */
    func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject, previousAction : Selector, nextAction : Selector, doneAction : Selector,  titleText: NSString?) {
        
        //If can't set InputAccessoryView. Then return
        if self.respondsToSelector("setInputAccessoryView:") == false  {
            return
        }
        
        //  Creating a toolBar for phoneNumber keyboard
        var toolbar = IQToolbar()
        toolbar.tag = kIQPreviousNextButtonToolbarTag
        
        var items = NSMutableArray()
        
        //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
        
        var doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: target, action: doneAction)
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            var prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
            
            var fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            
            var next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            
            items.addObject(prev)
            items.addObject(fixed)
            items.addObject(next)
        }
        else
        {
//            #pragma GCC diagnostic push
//            #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//            //  Create a next/previous button to switch between TextFieldViews.
//            IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousAction:previousAction nextAction:nextAction];
//            #pragma GCC diagnostic pop
//            IQBarButtonItem *segButton = [[IQBarButtonItem alloc] initWithCustomView:segControl];
//            [items addObject:segButton];
        }
        
        if (titleText?.length != 0 /* && self.shouldHideTitle == false */)
        {
            var buttonFrame : CGRect
            
            if (IQ_IS_IOS7_OR_GREATER)
            {
                /*
                72.5 next/previous maximum x.
                50 done button frame.
                8+8 distance maintenance
                */
                buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-72.5-50.0-16, 44)
            }
            else
            {
                /*
                135 next/previous maximum x.
                57 done button frame.
                8+8 distance maintenance
                */
                buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-135-57.0-16, 44)
            }
            
            var title = IQTitleBarButtonItem(frame: buttonFrame, title: titleText?)
            items.addObject(title)
        }
        
        var nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        items.addObject(nilButton)
        items.addObject(doneButton)
        
        //  Adding button to toolBar.
        toolbar.items = items

        //  Setting toolbar to keyboard.
        if (self is UITextField) == true {

            var textField : UITextField = self as UITextField
            textField.inputAccessoryView = toolbar
        }
        else if (self is UITextView) == true {

            var textView : UITextView = self as UITextView
            textView.inputAccessoryView = toolbar
        }
    }
    
    public func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject, previousAction : Selector, nextAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : NSString?
        
        if shouldShowPlaceholder {
            
            var textField : UITextField? = self as? UITextField
            
            title = textField?.placeholder
        }
        
        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: title)
    }
    
    func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject, previousAction : Selector, nextAction : Selector, doneAction : Selector) {
        
        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: nil)
    }
    
    /*!
    @method setEnablePrevious:next:
    
    @abstract Helper function to enable and disable previous next buttons.
    
    @param isPreviousEnabled: BOOL to enable/disable previous button on keyboard.
    
    @param isNextEnabled:  BOOL to enable/disable next button on keyboard..
    */
    func setEnablePrevious ( isPreviousEnabled : Bool, isNextEnabled : Bool) {
        
        //  Getting inputAccessoryView.
        var inputAccessoryView : IQToolbar? = self.inputAccessoryView as? IQToolbar
        
        //  If it is IQToolbar and it's items are greater than zero.
        if (inputAccessoryView?.isKindOfClass(IQToolbar) == true && inputAccessoryView?.items?.count>0)
        {
            if (IQ_IS_IOS7_OR_GREATER && inputAccessoryView?.items?.count>3)
            {
                //  Getting first item from inputAccessoryView.
                
                var items : NSArray? = inputAccessoryView?.items
                
                var prevButton : IQBarButtonItem? = items?.objectAtIndex(0) as? IQBarButtonItem
                var nextButton : IQBarButtonItem? = items?.objectAtIndex(2) as? IQBarButtonItem

                //  If it is UIBarButtonItem and it's customView is not nil.
                if (prevButton?.isKindOfClass(IQBarButtonItem) == true && nextButton?.isKindOfClass(IQBarButtonItem) == true)
                {
                    if (prevButton?.enabled != isPreviousEnabled) {
                        prevButton?.enabled = isPreviousEnabled
                    }
                    
                    if (nextButton?.enabled != isNextEnabled) {
                        nextButton?.enabled = isNextEnabled
                    }
                }
            }
            else
            {
//                //  Getting first item from inputAccessoryView.
//                IQBarButtonItem *barButtonItem = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
//                
//                //  If it is IQBarButtonItem and it's customView is not nil.
//                if ([barButtonItem isKindOfClass:[IQBarButtonItem class]] && [barButtonItem customView] != nil)
//                {
//                    //  Getting it's customView.
//                    #pragma GCC diagnostic push
//                    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//                    IQSegmentedNextPrevious *segmentedControl = (IQSegmentedNextPrevious*)[barButtonItem customView];
//                    //  If its customView is IQSegmentedNextPrevious and has 2 segments
//                    if ([segmentedControl isKindOfClass:[IQSegmentedNextPrevious class]] && [segmentedControl numberOfSegments]==2)
//                    #pragma GCC diagnostic pop
//                    {
//                        if ([segmentedControl isEnabledForSegmentAtIndex:0] != isPreviousEnabled)
//                        {
//                            //  Setting it's first segment enable/disable.
//                            [segmentedControl setEnabled:isPreviousEnabled forSegmentAtIndex:0];
//                        }
//                        
//                        if ([segmentedControl isEnabledForSegmentAtIndex:1] != isNextEnabled)
//                        {
//                            //  Setting it's second segment enable/disable.
//                            [segmentedControl setEnabled:isNextEnabled forSegmentAtIndex:1];
//                        }
//                    }
//                }
            }
        }
    }
}

