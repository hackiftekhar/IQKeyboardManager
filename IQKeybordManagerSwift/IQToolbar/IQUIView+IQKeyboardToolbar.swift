//
//  IQUIView+IQKeyboardToolbar.swift
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
import UIKit

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
extension UIView {
    
    ///-------------------------
    /// MARK: Title and Distance
    ///-------------------------
    
    /**
    If shouldHideTitle is YES, then title will not be added to the toolbar. Default to NO.
    */
    var shouldHideTitle: Bool? {
        get {
            let aValue: AnyObject? = objc_getAssociatedObject(self, "shouldHideTitle")
            
            if aValue == nil {
                return false
            } else {
                return aValue as? Bool
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, "shouldHideTitle", newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    ///-----------------------------------------
    /// TODO: Customised Invocation Registration
    ///-----------------------------------------
    
//    /**
//    Additional target & action to do get callback action. Note that setting custom `previous` selector doesn't affect native `previous` functionality, this is just used to notifiy user to do additional work according to need.
//    
//    @param target Target object.
//    @param action Target Selector.
//    */
//    -(void)setCustomPreviousTarget:(id)target action:(SEL)action;
//    
//    /**
//    Additional target & action to do get callback action. Note that setting custom `next` selector doesn't affect native `next` functionality, this is just used to notifiy user to do additional work according to need.
//    
//    @param target Target object.
//    @param action Target Selector.
//    */
//    -(void)setCustomNextTarget:(id)target action:(SEL)action;
//    
//    /**
//    Additional target & action to do get callback action. Note that setting custom `done` selector doesn't affect native `done` functionality, this is just used to notifiy user to do additional work according to need.
//    
//    @param target Target object.
//    @param action Target Selector.
//    */
//    -(void)setCustomDoneTarget:(id)target action:(SEL)action;
//    
//    /**
//    Customized Invocation to be called on previous arrow action. previousInvocation is internally created using setCustomPreviousTarget: method.
//    */
//    @property (strong, nonatomic) NSInvocation *previousInvocation;
//    
//    /**
//    Customized Invocation to be called on next arrow action. nextInvocation is internally created using setCustomNextTarget: method.
//    */
//    @property (strong, nonatomic) NSInvocation *nextInvocation;
//    
//    /**
//    Customized Invocation to be called on done action. doneInvocation is internally created using setCustomDoneTarget: method.
//    */
//    @property (strong, nonatomic) NSInvocation *doneInvocation;
    

    
    ///------------
    /// MARK: Done
    ///------------
    
    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addDoneOnKeyboardWithTarget(target : AnyObject?, action : Selector) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: nil)
    }

    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addDoneOnKeyboardWithTarget (target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    /*
                    50 done button frame.
                    24 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-64.0-12.0, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(nilButton)
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: target, action: action)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar

                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar

                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
           }
        }
    }
    
    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    */
    func addDoneOnKeyboardWithTarget (target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: title)
    }
    

    ///------------
    /// MARK: Right
    ///------------
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: nil)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {

            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    
                    /*
                    50 done button frame.
                    24 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-50.0-24, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(nilButton)
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(title: text, style: UIBarButtonItemStyle.Done, target: target, action: action)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            }
        }
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    */
    func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?

        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: title)
    }
    

    ///------------------
    /// MARK: Cancel/Done
    ///------------------
    
    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: nil)
    }

    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
            let cancelButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: target, action: cancelAction)
            items.append(cancelButton)
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    /*
                    66 Cancel button maximum x.
                    50 done button frame.
                    8+8 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-50.0-16, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(nilButton)
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: target, action: doneAction)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            }
        }
    }
    
    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    */
    func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: title)
    }
    

    ///-----------------
    /// MARK: Right/Left
    ///-----------------
    
    /**
    Helper function to add Left and Right button on keyboard.
    
    @param target Target object for selector.
    @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector) {
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, rightButtonAction: rightButtonAction, leftButtonAction: leftButtonAction, titleText: nil)
    }
    
    /**
    Helper function to add Left and Right button on keyboard.
    
    @param target Target object for selector.
    @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
            let cancelButton = IQBarButtonItem(title: leftButtonTitle, style: UIBarButtonItemStyle.Bordered, target: target, action: leftButtonAction)
            items.append(cancelButton)
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    /*
                    66 Cancel button maximum x.
                    50 done button frame.
                    8+8 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-50.0-16, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(nilButton)
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.Bordered, target: target, action: rightButtonAction)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            }
        }
    }
    
    /**
    Helper function to add Left and Right button on keyboard.
    
    @param target Target object for selector.
    @param leftButtonTitle Title for leftBarButtonItem, usually 'Cancel'.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param leftButtonAction Left button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param rightButtonAction Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    */
    func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, rightButtonAction: rightButtonAction, leftButtonAction: leftButtonAction, titleText: title)
    }
    
    
    ///-------------------------
    /// MARK: Previous/Next/Done
    ///-------------------------
    
    /**
    Helper function to add ArrowNextPrevious and Done button on keyboard.
    
    @param target Target object for selector.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector) {
        
        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: nil)
    }
    
    /**
    Helper function to add ArrowNextPrevious and Done button on keyboard.
    
    @param target Target object for selector.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector,  titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: target, action: doneAction)
            
            let prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
            
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            
            let next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            
            items.append(prev)
            items.append(fixed)
            items.append(next)
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    /*
                    72.5 next/previous maximum x.
                    50 done button frame.
                    8+8 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-72.5-50.0-16, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            
            items.append(nilButton)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            }
        }
    }
    
    /**
    Helper function to add ArrowNextPrevious and Done button on keyboard.
    
    @param target Target object for selector.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    */
    public func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: title)
    }
    
    ///--------------------------
    /// MARK: Previous/Next/Right
    ///--------------------------
    
    /**
    Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
    
    @param target Target object for selector.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector) {
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: nil)
    }
    
    /**
    Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
    
    @param target Target object for selector.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
            let doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.Bordered, target: target, action: rightButtonAction)
            
            let prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
            
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            
            let next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            
            items.append(prev)
            items.append(fixed)
            items.append(next)
            
            if let unwrappedTitleText = titleText {
                if count(unwrappedTitleText) != 0 && shouldHideTitle == false {
                    /*
                    72.5 next/previous maximum x.
                    50 done button frame.
                    8+8 distance maintenance
                    */
                    let buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-72.5-50.0-16, 44)
                    
                    let title = IQTitleBarButtonItem(frame: buttonFrame, title: unwrappedTitleText)
                    items.append(title)
                }
            }
            
            //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
            let nilButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            
            items.append(nilButton)
            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.Dark:
                    toolbar.barStyle = UIBarStyle.Black
                default:
                    toolbar.barStyle = UIBarStyle.Default
                }
            }
        }
    }
    
//    /**
//    Helper function to add SegmentedNextPrevious/ArrowNextPrevious and Right button on keyboard.
//    
//    @param target Target object for selector.
//    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
//    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
//    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
//    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
//    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
//    */
    func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: title)
    }

    
    ///-----------------------------------
    /// MARK: Enable/Disable Previous/Next
    ///-----------------------------------
    
    /**
    Helper function to enable and disable previous next buttons.
    
    @param isPreviousEnabled BOOL to enable/disable previous button on keyboard.
    @param isNextEnabled  BOOL to enable/disable next button on keyboard..
    */
    func setEnablePrevious ( isPreviousEnabled : Bool, isNextEnabled : Bool) {
        
        //  Getting inputAccessoryView.
        if let inputAccessoryView = self.inputAccessoryView as? IQToolbar {
            //  If it is IQToolbar and it's items are greater than zero.
            if inputAccessoryView.items?.count > 3 {
                if let items = inputAccessoryView.items {
                    if let prevButton = items[0] as? IQBarButtonItem {
                        if let nextButton = items[2] as? IQBarButtonItem {
                            
                            if prevButton.enabled != isPreviousEnabled {
                                prevButton.enabled = isPreviousEnabled
                            }
                            
                            if nextButton.enabled != isNextEnabled {
                                nextButton.enabled = isNextEnabled
                            }
                        }
                    }
                }
            }
        }
    }
}

