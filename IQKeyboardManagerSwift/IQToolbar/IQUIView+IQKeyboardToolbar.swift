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

private var kIQShouldHideTitle      = "kIQShouldHideTitle"

private var kIQPreviousInvocationTarget     = "kIQPreviousInvocationTarget"
private var kIQPreviousInvocationSelector   = "kIQPreviousInvocationSelector"
private var kIQNextInvocationTarget         = "kIQNextInvocationTarget"
private var kIQNextInvocationSelector       = "kIQNextInvocationSelector"
private var kIQDoneInvocationTarget         = "kIQDoneInvocationTarget"
private var kIQDoneInvocationSelector       = "kIQDoneInvocationSelector"

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
public extension UIView {
    
    ///-------------------------
    /// MARK: Title and Distance
    ///-------------------------
    
    /**
    If shouldHideTitle is YES, then title will not be added to the toolbar. Default to NO.
    */
    public var shouldHideTitle: Bool? {
        get {
            let aValue: AnyObject? = objc_getAssociatedObject(self, &kIQShouldHideTitle)
            
            if aValue == nil {
                return false
            } else {
                return aValue as? Bool
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldHideTitle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let toolbar = self.inputAccessoryView as? IQToolbar {
                if let textField = self as? UITextField {
                    toolbar.title = textField.placeholder
                } else if let textView = self as? IQTextView {
                    toolbar.title = textView.placeholder
                }
            }
        }
    }
    
    ///-----------------------------------------
    /// TODO: Customised Invocation Registration
    ///-----------------------------------------
    
    /**
    Additional target & action to do get callback action. Note that setting custom `previous` selector doesn't affect native `previous` functionality, this is just used to notifiy user to do additional work according to need.
    
    @param target Target object.
    @param action Target Selector.
    */
    public func setCustomPreviousTarget(target: AnyObject?, selector: Selector?) {
        previousInvocation = (target, selector)
    }
    
    /**
    Additional target & action to do get callback action. Note that setting custom `next` selector doesn't affect native `next` functionality, this is just used to notifiy user to do additional work according to need.
    
    @param target Target object.
    @param action Target Selector.
    */
    public func setCustomNextTarget(target: AnyObject?, selector: Selector?) {
        nextInvocation = (target, selector)
    }
    
    /**
    Additional target & action to do get callback action. Note that setting custom `done` selector doesn't affect native `done` functionality, this is just used to notifiy user to do additional work according to need.
    
    @param target Target object.
    @param action Target Selector.
    */
    public func setCustomDoneTarget(target: AnyObject?, selector: Selector?) {
        doneInvocation = (target, selector)
    }
    
    /**
    Customized Invocation to be called on previous arrow action. previousInvocation is internally created using setCustomPreviousTarget: method.
    */
    public var previousInvocation : (target: AnyObject?, selector: Selector?) {
        get {
            let target: AnyObject? = objc_getAssociatedObject(self, &kIQPreviousInvocationTarget)
            var selector : Selector?

            if let selectorString = objc_getAssociatedObject(self, &kIQPreviousInvocationSelector) as? String {
                selector = NSSelectorFromString(selectorString)
            }
            
            return (target: target, selector: selector)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQPreviousInvocationTarget, newValue.target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let unwrappedSelector = newValue.selector {
                objc_setAssociatedObject(self, &kIQPreviousInvocationSelector, NSStringFromSelector(unwrappedSelector), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &kIQPreviousInvocationSelector, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    /**
    Customized Invocation to be called on next arrow action. nextInvocation is internally created using setCustomNextTarget: method.
    */
    public var nextInvocation : (target: AnyObject?, selector: Selector?) {
        get {
            let target: AnyObject? = objc_getAssociatedObject(self, &kIQNextInvocationTarget)
            var selector : Selector?
            
            if let selectorString = objc_getAssociatedObject(self, &kIQNextInvocationSelector) as? String {
                selector = NSSelectorFromString(selectorString)
            }
            
            return (target: target, selector: selector)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQNextInvocationTarget, newValue.target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let unwrappedSelector = newValue.selector {
                objc_setAssociatedObject(self, &kIQNextInvocationSelector, NSStringFromSelector(unwrappedSelector), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &kIQNextInvocationSelector, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /**
    Customized Invocation to be called on done action. doneInvocation is internally created using setCustomDoneTarget: method.
    */
    public var doneInvocation : (target: AnyObject?, selector: Selector?) {
        get {
            let target: AnyObject? = objc_getAssociatedObject(self, &kIQDoneInvocationTarget)
            var selector : Selector?
            
            if let selectorString = objc_getAssociatedObject(self, &kIQDoneInvocationSelector) as? String {
                selector = NSSelectorFromString(selectorString)
            }
            
            return (target: target, selector: selector)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQDoneInvocationTarget, newValue.target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let unwrappedSelector = newValue.selector {
                objc_setAssociatedObject(self, &kIQDoneInvocationSelector, NSStringFromSelector(unwrappedSelector), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &kIQDoneInvocationSelector, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    ///---------------------
    /// MARK: Private helper
    ///---------------------
    
    public static func flexibleBarButtonItem () -> IQBarButtonItem {
        
        struct Static {
            static let nilButton = IQBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        }
        
        return Static.nilButton
    }

    ///------------
    /// MARK: Done
    ///------------
    
    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    public func addDoneOnKeyboardWithTarget(target : AnyObject?, action : Selector) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: nil)
    }

    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addDoneOnKeyboardWithTarget (target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Done button
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
    public func addDoneOnKeyboardWithTarget (target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
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
     
     @param image Image icon to use as right button.
     @param target Target object for selector.
     @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
     @param titleText text to show as title in IQToolbar'.
     */
    public func addRightButtonOnKeyboardWithImage (image : UIImage, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            let doneButton = IQBarButtonItem(image: image, style: UIBarButtonItemStyle.Done, target: target, action: action)
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
     
     @param image Image icon to use as right button.
     @param target Target object for selector.
     @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
     @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
     */
    public func addRightButtonOnKeyboardWithImage (image : UIImage, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addRightButtonOnKeyboardWithImage(image, target: target, action: action, titleText: title)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    public func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: nil)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {

            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
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
    public func addRightButtonOnKeyboardWithText (text : String, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
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
    public func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: nil)
    }

    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //Cancel button
            let cancelButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: target, action: cancelAction)
            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
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
    public func addCancelDoneOnKeyboardWithTarget (target : AnyObject?, cancelAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
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
    public func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector) {
        
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
    public func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            //Left button
            let cancelButton = IQBarButtonItem(title: leftButtonTitle, style: UIBarButtonItemStyle.Plain, target: target, action: leftButtonAction)
            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            let doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.Done, target: target, action: rightButtonAction)
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
    public func addRightLeftOnKeyboardWithTarget( target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, shouldShowPlaceholder: Bool) {
        
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
    public func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector) {
        
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
    public func addPreviousNextDoneOnKeyboardWithTarget ( target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector,  titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            let prev : IQBarButtonItem
            let next : IQBarButtonItem
            
            if #available(iOS 8.0, *) {
                
                // Get the top level "bundle" which may actually be the framework
                var bundle = NSBundle(forClass: IQKeyboardManager.self)
                
                if let resourcePath = bundle.pathForResource("IQKeyboardManager", ofType: "bundle") {
                    if let resourcesBundle = NSBundle(path: resourcePath) {
                        bundle = resourcesBundle
                    }
                }
                
                prev = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowLeft", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowRight", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            } else {
                prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            }
            
            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            items.append(fixed)

            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
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
    Helper function to add ArrowNextPrevious and Right button on keyboard.
    
    @param target Target object for selector.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            let prev : IQBarButtonItem
            let next : IQBarButtonItem
            
            if #available(iOS 8.0, *) {
                
                // Get the top level "bundle" which may actually be the framework
                var bundle = NSBundle(forClass: IQKeyboardManager.self)
                
                if let resourcePath = bundle.pathForResource("IQKeyboardManager", ofType: "bundle") {
                    if let resourcesBundle = NSBundle(path: resourcePath) {
                        bundle = resourcesBundle
                    }
                }
                
                prev = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowLeft", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowRight", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
            } else {
                prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            }
            
            //Previous button
            items.append(prev)
            
            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            items.append(fixed)
            
            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            let doneButton = IQBarButtonItem(image: rightButtonImage, style: UIBarButtonItemStyle.Done, target: target, action: rightButtonAction)
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
    //    Helper function to add ArrowNextPrevious and Right button on keyboard.
    //
    //    @param target Target object for selector.
    //    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    //    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    //    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    //    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    //    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
    //    */
    public func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            if let textField = self as? UITextField {
                title = textField.placeholder
            } else if let textView = self as? IQTextView {
                title = textView.placeholder
            }
        }
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonImage: rightButtonImage, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: title)
    }
    
    
    /**
    Helper function to add ArrowNextPrevious and Right button on keyboard.
    
    @param target Target object for selector.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    public func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector) {
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: nil)
    }
    
    /**
    Helper function to add ArrowNextPrevious and Right button on keyboard.
    
    @param target Target object for selector.
    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
        //If can't set InputAccessoryView. Then return
        if self is UITextField || self is UITextView {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = IQToolbar()
            
            var items : [UIBarButtonItem] = []
            
            let prev : IQBarButtonItem
            let next : IQBarButtonItem
            
            if #available(iOS 8.0, *) {
                
                // Get the top level "bundle" which may actually be the framework
                var bundle = NSBundle(forClass: IQKeyboardManager.self)
                
                if let resourcePath = bundle.pathForResource("IQKeyboardManager", ofType: "bundle") {
                    if let resourcesBundle = NSBundle(path: resourcePath) {
                        bundle = resourcesBundle
                    }
                }
                
                prev = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowLeft", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQButtonBarArrowRight", inBundle: bundle, compatibleWithTraitCollection: nil), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
            } else {
                prev = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowLeft"), style: UIBarButtonItemStyle.Plain, target: target, action: previousAction)
                
                next = IQBarButtonItem(image: UIImage(named: "IQKeyboardManager.bundle/IQButtonBarArrowRight"), style: UIBarButtonItemStyle.Plain, target: target, action: nextAction)
            }
            
            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixed.width = 23
            items.append(fixed)

            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            let title = IQTitleBarButtonItem(title: shouldHideTitle == true ? nil : titleText)
            items.append(title)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            let doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.Done, target: target, action: rightButtonAction)
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
//    Helper function to add ArrowNextPrevious and Right button on keyboard.
//    
//    @param target Target object for selector.
//    @param rightButtonTitle Title for rightBarButtonItem, usually 'Done'.
//    @param previousAction Previous button action name. Usually 'previousAction:(id)item'.
//    @param nextAction Next button action name. Usually 'nextAction:(id)item'.
//    @param rightButtonAction RightBarButton action name. Usually 'doneAction:(IQBarButtonItem*)item'.
//    @param shouldShowPlaceholder A boolean to indicate whether to show textField placeholder on IQToolbar'.
//    */
    public func addPreviousNextRightOnKeyboardWithTarget( target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
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
    public func setEnablePrevious ( isPreviousEnabled : Bool, isNextEnabled : Bool) {
        
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

