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
 IQBarButtonItemConfiguration for creating toolbar with bar button items
 */
@objc public class IQBarButtonItemConfiguration: NSObject {
    
    #if swift(>=4.2)
    @objc public init(barButtonSystemItem: UIBarButtonItem.SystemItem, action: Selector) {
        self.barButtonSystemItem = barButtonSystemItem
        self.image = nil
        self.title = nil
        self.action = action
        super.init()
    }
    #else
    @objc public init(barButtonSystemItem: UIBarButtonSystemItem, action: Selector) {
        self.barButtonSystemItem = barButtonSystemItem
        self.image = nil
        self.title = nil
        self.action = action
    super.init()
    }
    #endif

    @objc public init(image: UIImage, action: Selector) {
        self.barButtonSystemItem = nil
        self.image = image
        self.title = nil
        self.action = action
        super.init()
    }
    
    @objc public init(title: String, action: Selector) {
        self.barButtonSystemItem = nil
        self.image = nil
        self.title = title
        self.action = action
        super.init()
    }
    
    #if swift(>=4.2)
    public let barButtonSystemItem: UIBarButtonItem.SystemItem?    //System Item to be used to instantiate bar button.
    #else
    public let barButtonSystemItem: UIBarButtonSystemItem?    //System Item to be used to instantiate bar button.
    #endif
    
    @objc public let image: UIImage?    //Image to show on bar button item if it's not a system item.
    
    @objc public let title: String?     //Title to show on bar button item if it's not a system item.
    
    @objc public let action: Selector?  //action for bar button item. Usually 'doneAction:(IQBarButtonItem*)item'.
}

/**
 UIImage category methods to get next/prev images
 */
@objc public extension UIImage {
    
    @objc static func keyboardPreviousiOS9Image() -> UIImage? {
        
        struct Static {
            static var keyboardPreviousiOS9Image: UIImage?
        }

        if Static.keyboardPreviousiOS9Image == nil {
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            Static.keyboardPreviousiOS9Image = UIImage(named: "IQButtonBarArrowLeft", in: bundle, compatibleWith: nil)
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                Static.keyboardPreviousiOS9Image = Static.keyboardPreviousiOS9Image?.imageFlippedForRightToLeftLayoutDirection()
            }
        }
        
        return Static.keyboardPreviousiOS9Image
    }
    
    @objc static func keyboardNextiOS9Image() -> UIImage? {
        
        struct Static {
            static var keyboardNextiOS9Image: UIImage?
        }
        
        if Static.keyboardNextiOS9Image == nil {
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            Static.keyboardNextiOS9Image = UIImage(named: "IQButtonBarArrowRight", in: bundle, compatibleWith: nil)
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                Static.keyboardNextiOS9Image = Static.keyboardNextiOS9Image?.imageFlippedForRightToLeftLayoutDirection()
            }
        }
        
        return Static.keyboardNextiOS9Image
    }
    
    @objc static func keyboardPreviousiOS10Image() -> UIImage? {
        
        struct Static {
            static var keyboardPreviousiOS10Image: UIImage?
        }
        
        if Static.keyboardPreviousiOS10Image == nil {
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            Static.keyboardPreviousiOS10Image = UIImage(named: "IQButtonBarArrowUp", in: bundle, compatibleWith: nil)
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                Static.keyboardPreviousiOS10Image = Static.keyboardPreviousiOS10Image?.imageFlippedForRightToLeftLayoutDirection()
            }
        }
        
        return Static.keyboardPreviousiOS10Image
    }
    
    @objc static func keyboardNextiOS10Image() -> UIImage? {
        
        struct Static {
            static var keyboardNextiOS10Image: UIImage?
        }
        
        if Static.keyboardNextiOS10Image == nil {
            // Get the top level "bundle" which may actually be the framework
            var bundle = Bundle(for: IQKeyboardManager.self)
            
            if let resourcePath = bundle.path(forResource: "IQKeyboardManager", ofType: "bundle") {
                if let resourcesBundle = Bundle(path: resourcePath) {
                    bundle = resourcesBundle
                }
            }
            
            Static.keyboardNextiOS10Image = UIImage(named: "IQButtonBarArrowDown", in: bundle, compatibleWith: nil)
            
            //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
            if #available(iOS 9, *) {
                Static.keyboardNextiOS10Image = Static.keyboardNextiOS10Image?.imageFlippedForRightToLeftLayoutDirection()
            }
        }
        
        return Static.keyboardNextiOS10Image
    }
    
    @objc static func keyboardPreviousImage() -> UIImage? {
        
        if #available(iOS 10, *) {
            return keyboardPreviousiOS10Image()
        } else {
            return keyboardPreviousiOS9Image()
        }
    }
    
    @objc static func keyboardNextImage() -> UIImage? {
        
        if #available(iOS 10, *) {
            return keyboardNextiOS10Image()
        } else {
            return keyboardNextiOS9Image()
        }
    }
}

/**
UIView category methods to add IQToolbar on UIKeyboard.
*/
@objc public extension UIView {
    
    ///--------------
    /// MARK: Toolbar
    ///--------------
    
    /**
     IQToolbar references for better customization control.
     */
    @objc var keyboardToolbar: IQToolbar {
        var toolbar = inputAccessoryView as? IQToolbar
        
        if toolbar == nil {
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
    
    ///--------------------
    /// MARK: Toolbar title
    ///--------------------
    
    /**
    If `shouldHideToolbarPlaceholder` is YES, then title will not be added to the toolbar. Default to NO.
    */
    @objc var shouldHideToolbarPlaceholder: Bool {
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
    
    /**
     `toolbarPlaceholder` to override default `placeholder` text when drawing text on toolbar.
     */
    @objc var toolbarPlaceholder: String? {
        get {
            let aValue = objc_getAssociatedObject(self, &kIQToolbarPlaceholder) as? String
            
            return aValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQToolbarPlaceholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder
        }
    }

    /**
     `drawingToolbarPlaceholder` will be actual text used to draw on toolbar. This would either `placeholder` or `toolbarPlaceholder`.
     */
    @objc var drawingToolbarPlaceholder: String? {

        if self.shouldHideToolbarPlaceholder {
            return nil
        } else if self.toolbarPlaceholder?.isEmpty == false {
            return self.toolbarPlaceholder
        } else if self.responds(to: #selector(getter: UITextField.placeholder)) {
            
            if let textField = self as? UITextField {
                return textField.placeholder
            } else if let textView = self as? IQTextView {
                return textView.placeholder
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    ///---------------------
    /// MARK: Private helper
    ///---------------------
    
    private static func flexibleBarButtonItem () -> IQBarButtonItem {
        
        struct Static {
            
            static let nilButton = IQBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        
        Static.nilButton.isSystemItem = true
        return Static.nilButton
    }

    ///-------------
    /// MARK: Common
    ///-------------

    @objc func addKeyboardToolbarWithTarget(target: AnyObject?, titleText: String?, rightBarButtonConfiguration: IQBarButtonItemConfiguration?, previousBarButtonConfiguration: IQBarButtonItemConfiguration? = nil, nextBarButtonConfiguration: IQBarButtonItemConfiguration? = nil) {
        
        //If can't set InputAccessoryView. Then return
        if self.responds(to: #selector(setter: UITextField.inputAccessoryView)) {
            
            //  Creating a toolBar for phoneNumber keyboard
            let toolbar = self.keyboardToolbar
            
            var items: [IQBarButtonItem] = []
            
            if let prevConfig = previousBarButtonConfiguration {

                var prev = toolbar.previousBarButton

                if prevConfig.barButtonSystemItem == nil && prev.isSystemItem == false {
                    prev.title = prevConfig.title
                    prev.image = prevConfig.image
                    prev.target = target
                    prev.action = prevConfig.action
                } else {
                    if let systemItem = prevConfig.barButtonSystemItem {
                        prev = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: prevConfig.action)
                        prev.isSystemItem = true
                    } else if let image = prevConfig.image {
                        prev = IQBarButtonItem(image: image, style: .plain, target: target, action: prevConfig.action)
                    } else {
                        prev = IQBarButtonItem(title: prevConfig.title, style: .plain, target: target, action: prevConfig.action)
                    }
                    
                    prev.invocation = toolbar.previousBarButton.invocation
                    prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel
                    prev.isEnabled = toolbar.previousBarButton.isEnabled
                    prev.tag = toolbar.previousBarButton.tag
                    toolbar.previousBarButton = prev
                }

                items.append(prev)
            }
            
            if previousBarButtonConfiguration != nil && nextBarButtonConfiguration != nil {
                
                items.append(toolbar.fixedSpaceBarButton)
            }

            if let nextConfig = nextBarButtonConfiguration {
                
                var next = toolbar.nextBarButton

                if nextConfig.barButtonSystemItem == nil && next.isSystemItem == false {
                    next.title = nextConfig.title
                    next.image = nextConfig.image
                    next.target = target
                    next.action = nextConfig.action
                } else {
                    if let systemItem = nextConfig.barButtonSystemItem {
                        next = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: nextConfig.action)
                        next.isSystemItem = true
                    } else if let image = nextConfig.image {
                        next = IQBarButtonItem(image: image, style: .plain, target: target, action: nextConfig.action)
                    } else {
                        next = IQBarButtonItem(title: nextConfig.title, style: .plain, target: target, action: nextConfig.action)
                    }
                    
                    next.invocation = toolbar.nextBarButton.invocation
                    next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel
                    next.isEnabled = toolbar.nextBarButton.isEnabled
                    next.tag = toolbar.nextBarButton.tag
                    toolbar.nextBarButton = next
                }

                items.append(next)
            }
            
            //Title bar button item
            do {
                //Flexible space
                items.append(UIView.flexibleBarButtonItem())
                
                //Title button
                toolbar.titleBarButton.title = titleText
                
                #if swift(>=3.2)
                if #available(iOS 11, *) {} else {
                    toolbar.titleBarButton.customView?.frame = CGRect.zero
                }
                #else
                toolbar.titleBarButton.customView?.frame = CGRect.zero
                #endif
                
                items.append(toolbar.titleBarButton)
                
                //Flexible space
                items.append(UIView.flexibleBarButtonItem())
            }
            
            if let rightConfig = rightBarButtonConfiguration {
                
                var done = toolbar.doneBarButton

                if rightConfig.barButtonSystemItem == nil && done.isSystemItem == false {
                    done.title = rightConfig.title
                    done.image = rightConfig.image
                    done.target = target
                    done.action = rightConfig.action
                } else {
                    if let systemItem = rightConfig.barButtonSystemItem {
                        done = IQBarButtonItem(barButtonSystemItem: systemItem, target: target, action: rightConfig.action)
                        done.isSystemItem = true
                    } else if let image = rightConfig.image {
                        done = IQBarButtonItem(image: image, style: .plain, target: target, action: rightConfig.action)
                    } else {
                        done = IQBarButtonItem(title: rightConfig.title, style: .plain, target: target, action: rightConfig.action)
                    }
                    
                    done.invocation = toolbar.doneBarButton.invocation
                    done.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel
                    done.isEnabled = toolbar.doneBarButton.isEnabled
                    done.tag = toolbar.doneBarButton.tag
                    toolbar.doneBarButton = done
                }
                
                items.append(done)
            }
            
            //  Adding button to toolBar.
            toolbar.items = items
            
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                textField.inputAccessoryView = toolbar

                switch textField.keyboardAppearance {
                case .dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            } else if let textView = self as? UITextView {
                textView.inputAccessoryView = toolbar

                switch textView.keyboardAppearance {
                case .dark:
                    toolbar.barStyle = UIBarStyle.black
                default:
                    toolbar.barStyle = UIBarStyle.default
                }
            }
        }
    }
    
    ///------------
    /// MARK: Right
    ///------------

    @objc func addDoneOnKeyboardWithTarget(_ target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false) {
        
        addDoneOnKeyboardWithTarget(target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }

    @objc func addDoneOnKeyboardWithTarget(_ target: AnyObject?, action: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .done, action: action)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration)
    }

    @objc func addRightButtonOnKeyboardWithImage(_ image: UIImage, target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false) {
        
        addRightButtonOnKeyboardWithImage(image, target: target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addRightButtonOnKeyboardWithImage(_ image: UIImage, target: AnyObject?, action: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(image: image, action: action)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration)
    }

    @objc func addRightButtonOnKeyboardWithText(_ text: String, target: AnyObject?, action: Selector, shouldShowPlaceholder: Bool = false) {
        
        addRightButtonOnKeyboardWithText(text, target: target, action: action, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addRightButtonOnKeyboardWithText(_ text: String, target: AnyObject?, action: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(title: text, action: action)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration)
    }

    ///-----------------
    /// MARK: Right/Left
    ///-----------------

    @objc func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?, cancelAction: Selector, doneAction: Selector, shouldShowPlaceholder: Bool = false) {
        
        addCancelDoneOnKeyboardWithTarget(target, cancelAction: cancelAction, doneAction: doneAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }

    @objc func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonTitle: String, rightButtonTitle: String, leftButtonAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false) {
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonImage: UIImage, rightButtonImage: UIImage, leftButtonAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false) {
        
        addRightLeftOnKeyboardWithTarget(target, leftButtonImage: leftButtonImage, rightButtonImage: rightButtonImage, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addCancelDoneOnKeyboardWithTarget(_ target: AnyObject?, cancelAction: Selector, doneAction: Selector, titleText: String?) {
        
        let leftConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .cancel, action: cancelAction)
        let rightConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .done, action: doneAction)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }
    
    @objc func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonTitle: String, rightButtonTitle: String, leftButtonAction: Selector, rightButtonAction: Selector, titleText: String?) {
        
        let leftConfiguration = IQBarButtonItemConfiguration(title: leftButtonTitle, action: leftButtonAction)
        let rightConfiguration = IQBarButtonItemConfiguration(title: rightButtonTitle, action: rightButtonAction)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }
    
    @objc func addRightLeftOnKeyboardWithTarget(_ target: AnyObject?, leftButtonImage: UIImage, rightButtonImage: UIImage, leftButtonAction: Selector, rightButtonAction: Selector, titleText: String?) {
        
        let leftConfiguration = IQBarButtonItemConfiguration(image: leftButtonImage, action: leftButtonAction)
        let rightConfiguration = IQBarButtonItemConfiguration(image: rightButtonImage, action: rightButtonAction)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: leftConfiguration)
    }
    
    ///--------------------------
    /// MARK: Previous/Next/Right
    ///--------------------------

    @objc func addPreviousNextDoneOnKeyboardWithTarget (_ target: AnyObject?, previousAction: Selector, nextAction: Selector, doneAction: Selector, shouldShowPlaceholder: Bool = false) {

        addPreviousNextDoneOnKeyboardWithTarget(target, previousAction: previousAction, nextAction: nextAction, doneAction: doneAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }

    @objc func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonImage: UIImage, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false) {
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonImage: rightButtonImage, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonTitle: String, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, shouldShowPlaceholder: Bool = false) {
        
        addPreviousNextRightOnKeyboardWithTarget(target, rightButtonTitle: rightButtonTitle, previousAction: previousAction, nextAction: nextAction, rightButtonAction: rightButtonAction, titleText: (shouldShowPlaceholder ? self.drawingToolbarPlaceholder: nil))
    }
    
    @objc func addPreviousNextDoneOnKeyboardWithTarget (_ target: AnyObject?, previousAction: Selector, nextAction: Selector, doneAction: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(barButtonSystemItem: .done, action: doneAction)
        let nextConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)

        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }
    
    @objc func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonImage: UIImage, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(image: rightButtonImage, action: rightButtonAction)
        let nextConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }
    
    @objc func addPreviousNextRightOnKeyboardWithTarget(_ target: AnyObject?, rightButtonTitle: String, previousAction: Selector, nextAction: Selector, rightButtonAction: Selector, titleText: String?) {
        
        let rightConfiguration = IQBarButtonItemConfiguration(title: rightButtonTitle, action: rightButtonAction)
        let nextConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardNextImage() ?? UIImage(), action: nextAction)
        let prevConfiguration = IQBarButtonItemConfiguration(image: UIImage.keyboardPreviousImage() ?? UIImage(), action: previousAction)
        
        addKeyboardToolbarWithTarget(target: target, titleText: titleText, rightBarButtonConfiguration: rightConfiguration, previousBarButtonConfiguration: prevConfiguration, nextBarButtonConfiguration: nextConfiguration)
    }
}
