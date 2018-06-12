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

private var kIQShouldHideToolbarPlaceholder = "kIQShouldHideToolbarPlaceholder"
private var kIQToolbarPlaceholder           = "kIQToolbarPlaceholder"

private var kIQKeyboardToolbar              = "kIQKeyboardToolbar"

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
public extension UIView {
    
    ///--------------
    /// MARK: Toolbar
    ///--------------
    
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
    
    ///--------------------
    /// MARK: Toolbar title
    ///--------------------
    
    /**
    If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
    */
    @objc public var shouldHideToolbarPlaceholder: Bool {
        get {
            let aValue = objc_getAssociatedObject(self, &kIQShouldHideToolbarPlaceholder) as Any?
            
            if let unwrapedValue = aValue as? Bool {
                return unwrapedValue
            } else {
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQShouldHideToolbarPlaceholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder
        }
    }

    @available(*,deprecated, message: "This is renamed to `shouldHideToolbarPlaceholder` for more clear naming.")
    @objc public var shouldHidePlaceholderText: Bool {
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
    @objc public var toolbarPlaceholder: String? {
        get {
            let aValue = objc_getAssociatedObject(self, &kIQToolbarPlaceholder) as? String
            
            return aValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQToolbarPlaceholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder
        }
    }

    @available(*,deprecated, message: "This is renamed to `toolbarPlaceholder` for more clear naming.")
    @objc public var placeholderText: String? {
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
    @objc public var drawingToolbarPlaceholder: String? {

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
    @objc public var drawingPlaceholderText: String? {
        
        return drawingToolbarPlaceholder
    }
    
    ///---------------------
    /// MARK: Private helper
    ///---------------------
    
    private static func flexibleBarButtonItem () -> IQBarButtonItem {
        
        struct Static {
            
            static let nilButton = IQBarButtonItem(barButtonSystemItem:.flexibleSpace, target: nil, action: nil)
        }
        
        Static.nilButton.isSystemItem = true
        return Static.nilButton
    }

    ///-----------
    /// MARK: Done
    ///-----------
    
    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    */
    @objc public func addDoneOnKeyboardWithTarget(_ target : AnyObject?, action : Selector) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: nil)
    }

    /**
    Helper function to add Done button on keyboard.
    
    @param target Target object for selector.
    @param action Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    @objc public func addDoneOnKeyboardWithTarget (_ target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: .done, target: target, action: action)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            } else {
                doneButton.target = target
                doneButton.action = action
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
    @objc public func addDoneOnKeyboardWithTarget (_ target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addRightButtonOnKeyboardWithImage (_ image : UIImage, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText

            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

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
                doneButton = IQBarButtonItem(image: image, style: .done, target: target, action: action)
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
    @objc public func addRightButtonOnKeyboardWithImage (_ image : UIImage, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: nil)
    }
    
    /**
    Helper function to add Right button on keyboard.
    
    @param text Title for rightBarButtonItem, usually 'Done'.
    @param target Target object for selector.
    @param action Right button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    @objc public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {

            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())

            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

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
                doneButton = IQBarButtonItem(title: text, style: .done, target: target, action: action)
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
    @objc public func addRightButtonOnKeyboardWithText (_ text : String, target : AnyObject?, action : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: nil)
    }

    /**
    Helper function to add Cancel and Done button on keyboard.
    
    @param target Target object for selector.
    @param cancelAction Cancel button action name. Usually 'cancelAction:(IQBarButtonItem*)item'.
    @param doneAction Done button action name. Usually 'doneAction:(IQBarButtonItem*)item'.
    @param titleText text to show as title in IQToolbar'.
    */
    @objc public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Cancel button
            var cancelButton = toolbar.previousBarButton
            if cancelButton.isSystemItem == false {
                cancelButton = IQBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancelAction)
                cancelButton.isSystemItem = true
                cancelButton.invocation = toolbar.previousBarButton.invocation
                cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = cancelButton
            } else {
                cancelButton.target = target
                cancelButton.action = cancelAction
            }

            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: .done, target: target, action: doneAction)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            } else {
                doneButton.target = target
                doneButton.action = doneAction
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
    @objc public func addCancelDoneOnKeyboardWithTarget (_ target : AnyObject?, cancelAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector) {
        
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
    @objc public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, titleText: String?) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items : [IQBarButtonItem] = []
            
            //Left button
            var cancelButton = toolbar.previousBarButton
            if cancelButton.isSystemItem == false {
                cancelButton.title = leftButtonTitle
                cancelButton.image = nil
                cancelButton.target = target
                cancelButton.action = leftButtonAction
            }
            else
            {
                cancelButton = IQBarButtonItem(title: leftButtonTitle, style: .plain, target: target, action: leftButtonAction)
                cancelButton.invocation = toolbar.previousBarButton.invocation
                cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                toolbar.previousBarButton = cancelButton
            }

            items.append(cancelButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Title button
            toolbar.titleBarButton.title = shouldHideToolbarPlaceholder == true ? nil : titleText
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

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
                doneButton = IQBarButtonItem(title: rightButtonTitle, style: .done, target: target, action: rightButtonAction)
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
    @objc public func addRightLeftOnKeyboardWithTarget( _ target : AnyObject?, leftButtonTitle : String, rightButtonTitle : String, rightButtonAction : Selector, leftButtonAction : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector) {
        
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
    @objc public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector,  titleText: String?) {
        
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
                prev = IQBarButtonItem(image: imageLeftArrow, style: .plain, target: target, action: previousAction)
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
                next = IQBarButtonItem(image: imageRightArrow, style: .plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }

            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = toolbar.fixedSpaceBarButton
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
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

            items.append(toolbar.titleBarButton)
            
            //Flexible space
            items.append(UIView.flexibleBarButtonItem())
            
            //Done button
            var doneButton = toolbar.doneBarButton
            if doneButton.isSystemItem == false {
                doneButton = IQBarButtonItem(barButtonSystemItem: .done, target: target, action: doneAction)
                doneButton.isSystemItem = true
                doneButton.invocation = toolbar.doneBarButton.invocation
                doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                toolbar.doneBarButton = doneButton
            } else {
                doneButton.target = target
                doneButton.action = doneAction
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
    @objc public func addPreviousNextDoneOnKeyboardWithTarget ( _ target : AnyObject?, previousAction : Selector, nextAction : Selector, doneAction : Selector, shouldShowPlaceholder: Bool) {
        
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
    @objc public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
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
                prev = IQBarButtonItem(image: imageLeftArrow, style: .plain, target: target, action: previousAction)
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
                next = IQBarButtonItem(image: imageRightArrow, style: .plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }
            
            //Previous button
            items.append(prev)
            
            //Fixed space
            let fixed = toolbar.fixedSpaceBarButton
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
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

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
                doneButton = IQBarButtonItem(image: rightButtonImage, style: .done, target: target, action: rightButtonAction)
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
    @objc public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonImage : UIImage, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
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
    @objc public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector) {
        
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
    @objc public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, titleText : String?) {
        
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
                prev = IQBarButtonItem(image: imageLeftArrow, style: .plain, target: target, action: previousAction)
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
                next = IQBarButtonItem(image: imageRightArrow, style: .plain, target: target, action: nextAction)
                next.invocation = toolbar.nextBarButton.invocation
                next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                toolbar.nextBarButton = next
            }
            
            //Previous button
            items.append(prev)

            //Fixed space
            let fixed = toolbar.fixedSpaceBarButton
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
            
            #if swift(>=3.2)
                if #available(iOS 11, *) {}
                else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
            #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
            #endif

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
                doneButton = IQBarButtonItem(title: rightButtonTitle, style: .done, target: target, action: rightButtonAction)
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
    @objc public func addPreviousNextRightOnKeyboardWithTarget( _ target : AnyObject?, rightButtonTitle : String, previousAction : Selector, nextAction : Selector, rightButtonAction : Selector, shouldShowPlaceholder : Bool) {
        
        var title : String?
        
        if shouldShowPlaceholder == true {
            title = self.drawingToolbarPlaceholder
        }
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: title)
    }
}

