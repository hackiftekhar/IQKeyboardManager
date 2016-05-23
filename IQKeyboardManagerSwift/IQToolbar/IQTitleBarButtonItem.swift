//
//  IQTitleBarButtonItem.swift
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

private var kIQBarTitleInvocationTarget     = "kIQBarTitleInvocationTarget"
private var kIQBarTitleInvocationSelector   = "kIQBarTitleInvocationSelector"

public class IQTitleBarButtonItem: IQBarButtonItem {
   
    public var font : UIFont? {
    
        didSet {
            if let unwrappedFont = font {
                _titleButton?.titleLabel?.font = unwrappedFont
            } else {
                _titleButton?.titleLabel?.font = UIFont.systemFontOfSize(13)
            }
        }
    }

    override public var title: String? {
        didSet {
                _titleButton?.setTitle(title, forState: .Normal)
        }
    }
    
    /**
     selectableTextColor to be used for displaying button text when button is enabled.
     */
    public var selectableTextColor : UIColor? {
        
        didSet {
            if let color = selectableTextColor {
                _titleButton?.setTitleColor(color, forState:.Normal)
            } else {
                _titleButton?.setTitleColor(UIColor.init(colorLiteralRed: 0.0, green: 0.5, blue: 1.0, alpha: 1), forState:.Normal)
            }
        }
    }

    /**
     Optional target & action to behave toolbar title button as clickable button
     
     @param target Target object.
     @param action Target Selector.
     */
    public func setTitleTarget(target: AnyObject?, action: Selector?) {
        titleInvocation = (target, action)
    }
    
    /**
     Customized Invocation to be called on title button action. titleInvocation is internally created using setTitleTarget:action: method.
     */
    public var titleInvocation : (target: AnyObject?, action: Selector?) {
        get {
            let target: AnyObject? = objc_getAssociatedObject(self, &kIQBarTitleInvocationTarget)
            var action : Selector?
            
            if let selectorString = objc_getAssociatedObject(self, &kIQBarTitleInvocationSelector) as? String {
                action = NSSelectorFromString(selectorString)
            }
            
            return (target: target, action: action)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kIQBarTitleInvocationTarget, newValue.target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let unwrappedSelector = newValue.action {
                objc_setAssociatedObject(self, &kIQBarTitleInvocationSelector, NSStringFromSelector(unwrappedSelector), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &kIQBarTitleInvocationSelector, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            if (newValue.target == nil || newValue.action == nil)
            {
                self.enabled = false
                _titleButton?.enabled = false
                _titleButton?.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
            }
            else
            {
                self.enabled = true
                _titleButton?.enabled = true
                _titleButton?.addTarget(newValue.target, action: newValue.action!, forControlEvents: .TouchUpInside)
            }
        }
    }

    private var _titleButton : UIButton?
    private var _titleView : UIView?

    override init() {
        super.init()
    }
    
    init(title : String?) {

        self.init(title: nil, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        _titleView = UIView()
        _titleView?.backgroundColor = UIColor.clearColor()
        _titleView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        
        _titleButton = UIButton(type: .System)
        _titleButton?.enabled = false
        _titleButton?.titleLabel?.numberOfLines = 3
        _titleButton?.setTitleColor(UIColor.lightGrayColor(), forState:.Disabled)
        _titleButton?.setTitleColor(UIColor.init(colorLiteralRed: 0.0, green: 0.5, blue: 1.0, alpha: 1), forState:.Normal)
        _titleButton?.backgroundColor = UIColor.clearColor()
        _titleButton?.titleLabel?.textAlignment = .Center
        _titleButton?.setTitle(title, forState: .Normal)
        _titleButton?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        font = UIFont.systemFontOfSize(13.0)
        _titleButton?.titleLabel?.font = self.font
        _titleView?.addSubview(_titleButton!)
        customView = _titleView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
