//
//  IQUIView+IQKeyboardToolbar.swift
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


import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

private var kIQShouldHideToolbarPlaceholder = "kIQShouldHideToolbarPlaceholder"
private var kIQToolbarPlaceholder           = "kIQToolbarPlaceholder"

private var kIQKeyboardToolbar              = "kIQKeyboardToolbar"

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
public extension UIView {
    
    /**
     IQToolbar references for better customization control.
     */
    public var keyboardToolbar: IQToolbar {
        get {
            var toolbar = inputAccessoryView as? IQToolbar
            
            if (toolbar == nil)
            {
                toolbar = objc_getAssociatedObject(self, &kIQKeyboardToolbar) as? IQToolbar
            }
            
            if let unwrappedToolbar = toolbar {
                
                return unwrappedToolbar

            } else {
                
                let newToolbar = IQToolbar()
                
                objc_setAssociatedObject(self, &kIQKeyboardToolbar, newToolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return newToolbar
            }
        }
    }
    
    ///-------------------------
    /// MARK: Title
    ///-------------------------
    
    /**
    If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
    */
    public var shouldHideToolbarPlaceholder: Bool {
        get {
            let aValue: AnyObject? = objc_getAssociatedObject(self, &kIQShouldHideToolbarPlaceholder) as AnyObject?
            
            if let unwrapedValue = aValue as? Bool {
                return unwrapedValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldHideToolbarPlaceholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
        }
    }

    @available(*,deprecated, message: "This is renamed to `shouldHideToolbarPlaceholder` for more clear naming.")
    public var shouldHidePlaceholderText: Bool {
        get {
            return shouldHideToolbarPlaceholder
        }
        set(newValue) {
            shouldHideToolbarPlaceholder = newValue
        }
    }
    
    /**
     `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
     */
    public var toolbarPlaceholder: String? {
        get {
            let aValue = objc_getAssociatedObject(self, &kIQToolbarPlaceholder) as? String
            
            return aValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQToolbarPlaceholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
        }
    }

    @available(*,deprecated, message: "This is renamed to `toolbarPlaceholder` for more clear naming.")
    public var placeholderText: String? {
        get {
            return toolbarPlaceholder
        }
        set(newValue) {
            toolbarPlaceholder = newValue
        }
    }
    
    /**
     `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. This would either `placeholder` or `toolbarPlaceholder`.
     */
    public var drawingToolbarPlaceholder: String? {

        if (self.shouldHideToolbarPlaceholder)
        {
            return nil
        }
        else if (self.toolbarPlaceholder?.isEmpty == false) {
            return self.toolbarPlaceholder
        }
        else if self.responds(to: #selector(getter: UITextField.placeholder)) {
            
            if let textField = self as? UITextField {
                return textField.placeholder
            } else if let textView = self as? IQTextView {
                return textView.placeholder
            } else {
                return nil
            }
        }
        else {
            return nil
        }
    }

    @available(*,deprecated, message: "This is renamed to `drawingToolbarPlaceholder` for more clear naming.")
    public var drawingPlaceholderText: String? {
        
        return drawingToolbarPlaceholder
    }
    
    ///---------------------
    /// MARK: Private helper
    ///---------------------
    
    fileprivate static func flexibleBarButtonItem () -> IQBarButtonItem {
        
        struct Static {
            static let nilButton = IQBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        }
        
        Static.nilButton.isSystemItem = true
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
    public func addDoneOnKeyboardWithTarget(_ target : AnyObject?, action : Selector) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: nil)
    }

    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addDoneOnKeyboardWithTarget (_ target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {

            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: target, action: action)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar

                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar

                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addDoneOnKeyboardWithTarget (_ target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addRightButtonOnKeyboardWithImage (_ image : UIImage, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText

            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton.title = nil
                doneButton.image = image
                doneButton.target = target
                doneButton.action = action
            }
            else
            {
                doneButton = IQBarButtonItem(image: image, style: UIBarButtonItemStyle.done, target: target, action: action)
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addRightButtonOnKeyboardWithImage (_ image : UIImage, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
        }
        
        addRightButtonOnKeyboardWithImage(image, target: target, action: action, titleText: title)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: nil)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {

            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton.title = text
                doneButton.image = nil
                doneButton.target = target
                doneButton.action = action
            }
            else
            {
                doneButton = IQBarButtonItem(title: text, style: UIBarButtonItemStyle.done, target: target, action: action)
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?

        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: nil)
    }

    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Cancel button
            var cancelButton = toolbar.previousBarButton
            if cancelButton.isSystemItem == false {
                cancelButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: target, action: cancelAction)
                cancelButton.isSystemItem = true
                cancelButton.invocation = toolbar.previousBarButton.invocation
                cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = cancelButton
            }

            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: target, action: doneAction)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector) {
        
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
    public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Left button
            var cancelButton = toolbar.previousBarButton
            if cancelButton.isSystemItem == false {
                cancelButton.title = rightButtonTitle
                cancelButton.image = nil
                cancelButton.target = target
                cancelButton.action = rightButtonAction
            }
            else
            {
                cancelButton = IQBarButtonItem(title: leftButtonTitle, style: UIBarButtonItemStyle.plain, target: target, action: leftButtonAction)
                cancelButton.invocation = toolbar.previousBarButton.invocation
                cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = cancelButton
            }

            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton.title = rightButtonTitle
                doneButton.image = nil
                doneButton.target = target
                doneButton.action = rightButtonAction
            }
            else
            {
                doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.done, target: target, action: rightButtonAction)
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector) {
        
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
    public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector,  titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            var imageLeftArrow : UIImage!
            var imageRightArrow : UIImage!
            
            if #available(iOS 10, *) {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowUp", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowDown", in: bundle, compatibleWith: nil)
            } else {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowLeft", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowRight", in: bundle, compatibleWith: nil)
            }

            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                imageLeftArrow = imageLeftArrow?.imageFlippedForRightToLeftLayoutDirection()
                imageRightArrow = imageRightArrow?.imageFlippedForRightToLeftLayoutDirection()
            }

            var prev = toolbar.previousBarButton
            if prev.isSystemItem == false {
                prev.title = nil
                prev.image = imageLeftArrow
                prev.target = target
                prev.action = previousAction
            }
            else
            {
                prev = IQBarButtonItem(image: imageLeftArrow, style: UIBarButtonItemStyle.plain, target: target, action: previousAction)
                prev.invocation = toolbar.previousBarButton.invocation
                prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = prev
            }
            
            
            var next = toolbar.nextBarButton
            if next.isSystemItem == false {
                next.title = nil
                next.image = imageRightArrow
                next.target = target
                next.action = nextAction
            }
            else
            {
                next = IQBarButtonItem(image: imageRightArrow, style: UIBarButtonItemStyle.plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }

            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            fixed.isSystemItem = true
            if #available(iOS 10, *) {
                fixed.width = 6
            } else {
                fixed.width = 20
            }
            items.append(fixed)

            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: target, action: doneAction)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            var imageLeftArrow : UIImage!
            var imageRightArrow : UIImage!
            
            if #available(iOS 10, *) {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowUp", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowDown", in: bundle, compatibleWith: nil)
            } else {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowLeft", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowRight", in: bundle, compatibleWith: nil)
            }
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                imageLeftArrow = imageLeftArrow?.imageFlippedForRightToLeftLayoutDirection()
                imageRightArrow = imageRightArrow?.imageFlippedForRightToLeftLayoutDirection()
            }
            
            
            var prev = toolbar.previousBarButton
            if prev.isSystemItem == false {
                prev.title = nil
                prev.image = imageLeftArrow
                prev.target = target
                prev.action = previousAction
            }
            else
            {
                prev = IQBarButtonItem(image: imageLeftArrow, style: UIBarButtonItemStyle.plain, target: target, action: previousAction)
                prev.invocation = toolbar.previousBarButton.invocation
                prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = prev
            }
            
            
            var next = toolbar.nextBarButton
            if next.isSystemItem == false {
                next.title = nil
                next.image = imageRightArrow
                next.target = target
                next.action = nextAction
            }
            else
            {
                next = IQBarButtonItem(image: imageRightArrow, style: UIBarButtonItemStyle.plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }
            
            //Previous button
            items.append(prev)
            
            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            fixed.isSystemItem = true
            if #available(iOS 10, *) {
                fixed.width = 6
            } else {
                fixed.width = 20
            }
            items.append(fixed)
            
            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton.title = nil
                doneButton.image = rightButtonImage
                doneButton.target = target
                doneButton.action = rightButtonAction
            }
            else
            {
                doneButton = IQBarButtonItem(image: rightButtonImage, style: UIBarButtonItemStyle.done, target: target, action: rightButtonAction)
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector) {
        
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
    public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            var imageLeftArrow : UIImage!
            var imageRightArrow : UIImage!
            
            if #available(iOS 10, *) {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowUp", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowDown", in: bundle, compatibleWith: nil)
            } else {
                imageLeftArrow = UIImage(named: "IQButtonBarArrowLeft", in: bundle, compatibleWith: nil)
                imageRightArrow = UIImage(named: "IQButtonBarArrowRight", in: bundle, compatibleWith: nil)
            }
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                imageLeftArrow = imageLeftArrow?.imageFlippedForRightToLeftLayoutDirection()
                imageRightArrow = imageRightArrow?.imageFlippedForRightToLeftLayoutDirection()
            }
            
            var prev = toolbar.previousBarButton
            if prev.isSystemItem == false {
                prev.title = nil
                prev.image = imageLeftArrow
                prev.target = target
                prev.action = previousAction
            }
            else
            {
                prev = IQBarButtonItem(image: imageLeftArrow, style: UIBarButtonItemStyle.plain, target: target, action: previousAction)
                prev.invocation = toolbar.previousBarButton.invocation
                prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = prev
            }
            
            
            var next = toolbar.nextBarButton
            if next.isSystemItem == false {
                next.title = nil
                next.image = imageRightArrow
                next.target = target
                next.action = nextAction
            }
            else
            {
                next = IQBarButtonItem(image: imageRightArrow, style: UIBarButtonItemStyle.plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }
            
            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = IQBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            fixed.isSystemItem = true
            if #available(iOS 10, *) {
                fixed.width = 6
            } else {
                fixed.width = 20
            }
            items.append(fixed)

            //Next button
            items.append(next)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            if #available(iOS 11, *) {
                
            } else {
                toolbar.titleBarButton.customView?.frame = CGRect.zero;
            }
            
            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Right button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton.title = rightButtonTitle
                doneButton.image = nil
                doneButton.target = target
                doneButton.action = rightButtonAction
            }
            else
            {
                doneButton = IQBarButtonItem(title: rightButtonTitle, style: UIBarButtonItemStyle.done, target: target, action: rightButtonAction)
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            }

            items.append(doneButton)
            
            //  Adding button to toolBar.
            toolbar.items = items

            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar
                
                switch textField.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar
                
                switch textView.keyboardAppearance {
                case UIKeyboardAppearance.dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
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
    public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
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
    public func setEnablePrevious ( _ isPreviousEnabled : Bool, isNextEnabled : Bool) {
        
        //  Getting inputAccessoryView.
        if let inputAccessoryView = self.inputAccessoryView as? IQToolbar {
            //  If it is IQToolbar and it's items are greater than zero.
            if inputAccessoryView.items?.count > 3 {
                if let items = inputAccessoryView.items {
                    if let prevButton = items[0] as? IQBarButtonItem {
                        if let nextButton = items[2] as? IQBarButtonItem {
                            
                            if prevButton.isEnabled != isPreviousEnabled {
                                prevButton.isEnabled = isPreviousEnabled
                            }
                            
                            if nextButton.isEnabled != isNextEnabled {
                                nextButton.isEnabled = isNextEnabled
                            }
                        }
                    }
                }
            }
        }
    }
}

