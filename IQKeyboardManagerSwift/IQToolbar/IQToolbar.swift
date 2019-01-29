//
//  IQToolbar.swift
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

/** @abstract   IQToolbar for IQKeyboardManager.    */
open class IQToolbar: UIToolbar , UIInputViewAudioFeedback {

    private static var _classInitialize: Void = classInitialize()
    
    private class func classInitialize() {
                
        self.appearance().barTintColor = nil
        
        //Background image
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.any,            barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.bottom,         barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.top,            barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.topAttached,    barMetrics: UIBarMetrics.default)

        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.any)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.bottom)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.top)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.topAttached)
        
        //Background color
        self.appearance().backgroundColor = nil
    }
    
    /**
     Previous bar button of toolbar.
     */
    private var privatePreviousBarButton: IQBarButtonItem?
    open var previousBarButton : IQBarButtonItem {
        get {
            if privatePreviousBarButton == nil {
                privatePreviousBarButton = IQBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                privatePreviousBarButton?.accessibilityLabel = "Toolbar Previous Button"
            }
            return privatePreviousBarButton!
        }
        
        set (newValue) {
            privatePreviousBarButton = newValue
        }
    }
    
    /**
     Next bar button of toolbar.
     */
    private var privateNextBarButton: IQBarButtonItem?
    open var nextBarButton : IQBarButtonItem {
        get {
            if privateNextBarButton == nil {
                privateNextBarButton = IQBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
                privateNextBarButton?.accessibilityLabel = "Toolbar Next Button"
            }
            return privateNextBarButton!
        }
        
        set (newValue) {
            privateNextBarButton = newValue
        }
    }
    
    /**
     Title bar button of toolbar.
     */
    private var privateTitleBarButton: IQTitleBarButtonItem?
    open var titleBarButton : IQTitleBarButtonItem {
        get {
            if privateTitleBarButton == nil {
                privateTitleBarButton = IQTitleBarButtonItem(title: nil)
                privateTitleBarButton?.accessibilityLabel = "Toolbar Title Button"
            }
            return privateTitleBarButton!
        }
        
        set (newValue) {
            privateTitleBarButton = newValue
        }
    }
    
    /**
     Done bar button of toolbar.
     */
    private var privateDoneBarButton: IQBarButtonItem?
    open var doneBarButton : IQBarButtonItem {
        get {
            if privateDoneBarButton == nil {
                privateDoneBarButton = IQBarButtonItem(title: nil, style: .done, target: nil, action: nil)
                privateDoneBarButton?.accessibilityLabel = "Toolbar Done Button"
            }
            return privateDoneBarButton!
        }
        
        set (newValue) {
            privateDoneBarButton = newValue
        }
    }

    override init(frame: CGRect) {
        _ = IQToolbar._classInitialize
        super.init(frame: frame)
        
        sizeToFit()
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        tintColor = UIColor.black
        self.isTranslucent = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        _ = IQToolbar._classInitialize
        super.init(coder: aDecoder)

        sizeToFit()
        autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        tintColor = UIColor.black
        self.isTranslucent = true
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFit = super.sizeThatFits(size)
        sizeThatFit.height = 44
        return sizeThatFit
    }

    override open var tintColor: UIColor! {
        
        didSet {
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    item.tintColor = tintColor
                }
            }
        }
    }
    
    override open var barStyle: UIBarStyle {
        didSet {
            
            if barStyle == .default {
                titleBarButton.selectableTextColor = UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1)
            } else {
                titleBarButton.selectableTextColor = UIColor.yellow
            }
        }
    }
    
    override open func layoutSubviews() {

        super.layoutSubviews()
        
        if #available(iOS 11, *) {
            return
        } else {
            var leftRect = CGRect.null
            var rightRect = CGRect.null
            var isTitleBarButtonFound = false
            
            let sortedSubviews = self.subviews.sorted(by: { (view1 : UIView, view2 : UIView) -> Bool in
                
                let x1 = view1.frame.minX
                let y1 = view1.frame.minY
                let x2 = view2.frame.minX
                let y2 = view2.frame.minY
                
                if x1 != x2 {
                    return x1 < x2
                } else {
                    return y1 < y2
                }
            })
            
            for barButtonItemView in sortedSubviews {
                
                if isTitleBarButtonFound == true {
                    rightRect = barButtonItemView.frame
                    break
                } else if type(of: barButtonItemView) === UIView.self {
                    isTitleBarButtonFound = true
                    //If it's UIToolbarButton or UIToolbarTextButton (which actually UIBarButtonItem)
                } else if barButtonItemView.isKind(of: UIControl.self) == true {
                    leftRect = barButtonItemView.frame
                }
            }
            
            var x : CGFloat = 16
            
            if (leftRect.isNull == false)
            {
                x = leftRect.maxX + 16
            }
            
            let width : CGFloat = self.frame.width - 32 - (leftRect.isNull ? 0 : leftRect.maxX) - (rightRect.isNull ? 0 : self.frame.width - rightRect.minX)
            
            
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    
                    if let newItem = item as? IQTitleBarButtonItem {
                        
                        let titleRect = CGRect(x: x, y: 0, width: width, height: self.frame.size.height)
                        newItem.customView?.frame = titleRect
                        break
                    }
                }
            }
        }
    }
    
    open var enableInputClicksWhenVisible: Bool {
        return true
    }
}
