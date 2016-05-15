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
public class IQToolbar: UIToolbar , UIInputViewAudioFeedback {

    override public class func initialize() {
        
        superclass()?.initialize()
                
        self.appearance().barTintColor = nil
        
        //Background image
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.Any,            barMetrics: UIBarMetrics.Default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.Bottom,         barMetrics: UIBarMetrics.Default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.Top,            barMetrics: UIBarMetrics.Default)
        self.appearance().setBackgroundImage(nil, forToolbarPosition: UIBarPosition.TopAttached,    barMetrics: UIBarMetrics.Default)

        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.Any)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.Bottom)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.Top)
        self.appearance().setShadowImage(nil, forToolbarPosition: UIBarPosition.TopAttached)
        
        //Background color
        self.appearance().backgroundColor = nil
    }
    
    public var titleFont : UIFont? {
        
        didSet {
            
            if let newItems = items {
                for item in newItems {
                    
                    if let newItem = item as? IQTitleBarButtonItem {
                        newItem.font = titleFont
                    }
                }
            }
        }
    }
    
    public var title : String? {
        
        didSet {
            
            if let newItems = items {
                for item in newItems {
                    
                    if let newItem = item as? IQTitleBarButtonItem {
                        newItem.font = titleFont
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sizeToFit()
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        tintColor = UIColor .blackColor()
        self.translucent = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        sizeToFit()
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        tintColor = UIColor .blackColor()
        self.translucent = true
    }

    override public func sizeThatFits(size: CGSize) -> CGSize {
        var sizeThatFit = super.sizeThatFits(size)
        sizeThatFit.height = 44
        return sizeThatFit
    }

    override public var tintColor: UIColor! {
        
        didSet {
            if let unwrappedItems = items {
                for item in unwrappedItems {
                    
                    if let newItem = item as? IQTitleBarButtonItem {
                        newItem.tintColor = tintColor
                    }
                }
            }
        }
    }
    
    override public func layoutSubviews() {

        super.layoutSubviews()
        
        struct InternalClass {
            
            static var IQUIToolbarTextButtonClass: AnyClass?   =   NSClassFromString("UIToolbarTextButton")
            static var IQUIToolbarButtonClass: AnyClass?      =   NSClassFromString("UIToolbarButton")
        }


        var leftRect = CGRectNull
        var rightRect = CGRectNull
        var isTitleBarButtonFound = false
        
        let sortedSubviews = self.subviews.sort({ (view1 : UIView, view2 : UIView) -> Bool in
            
            let x1 = CGRectGetMinX(view1.frame)
            let y1 = CGRectGetMinY(view1.frame)
            let x2 = CGRectGetMinX(view2.frame)
            let y2 = CGRectGetMinY(view2.frame)
            
            if x1 != x2 {
                return x1 < x2
            } else {
                return y1 < y2
            }
        })
        
        for barButtonItemView in sortedSubviews {

            if (isTitleBarButtonFound == true)
            {
                rightRect = barButtonItemView.frame
                break
            }
            else if (barButtonItemView.dynamicType === UIView.self)
            {
                isTitleBarButtonFound = true
            }
            else if ((InternalClass.IQUIToolbarTextButtonClass != nil && barButtonItemView.isKindOfClass(InternalClass.IQUIToolbarTextButtonClass!) == true) || (InternalClass.IQUIToolbarButtonClass != nil && barButtonItemView.isKindOfClass(InternalClass.IQUIToolbarButtonClass!) == true))
            {
                leftRect = barButtonItemView.frame
            }
        }
        
        var x : CGFloat = 16
        
        if (CGRectIsNull(leftRect) == false)
        {
            x = CGRectGetMaxX(leftRect) + 16
        }
        
        let width : CGFloat = CGRectGetWidth(self.frame) - 32 - (CGRectIsNull(leftRect) ? 0 : CGRectGetMaxX(leftRect)) - (CGRectIsNull(rightRect) ? 0 : CGRectGetWidth(self.frame) - CGRectGetMinX(rightRect))
        
        
        if let unwrappedItems = items {
            for item in unwrappedItems {
                
                if let newItem = item as? IQTitleBarButtonItem {

                    let titleRect = CGRectMake(x, 0, width, self.frame.size.height)
                    newItem.customView?.frame = titleRect
                    break
                }
            }
        }
    }
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
}
