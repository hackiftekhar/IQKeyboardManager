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

open class IQTitleBarButtonItem: IQBarButtonItem {
   
    open var font : UIFont? {
    
        didSet {
            if let unwrappedFont = font {
                _titleButton?.titleLabel?.font = unwrappedFont
            } else {
                _titleButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }

    override open var title: String? {
        didSet {
                _titleButton?.setTitle(title, for: UIControlState())
        }
    }
    
    /**
     selectableTextColor to be used for displaying button text when button is enabled.
     */
    open var selectableTextColor : UIColor? {
        
        didSet {
            if let color = selectableTextColor {
                _titleButton?.setTitleColor(color, for:UIControlState())
            } else {
                _titleButton?.setTitleColor(UIColor.init(colorLiteralRed: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:UIControlState())
            }
        }
    }

    /**
     Optional target & action to behave toolbar title button as clickable button
     
     @param target Target object.
     @param action Target Selector.
     */
    open func setTitleTarget(_ target: AnyObject?, action: Selector?) {
        titleInvocation = (target, action)
    }
    
    /**
     Customized Invocation to be called on title button action. titleInvocation is internally created using setTitleTarget:action: method.
     */
    open var titleInvocation : (target: AnyObject?, action: Selector?) {
        get {
            let target: AnyObject? = objc_getAssociatedObject(self, &kIQBarTitleInvocationTarget) as AnyObject?
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
                self.isEnabled = false
                _titleButton?.isEnabled = false
                _titleButton?.removeTarget(nil, action: nil, for: .touchUpInside)
            }
            else
            {
                self.isEnabled = true
                _titleButton?.isEnabled = true
                _titleButton?.addTarget(newValue.target, action: newValue.action!, for: .touchUpInside)
            }
        }
    }

    fileprivate var _titleButton : UIButton?
    fileprivate var _titleView : UIView?

    override init() {
        super.init()
    }
    
    init(title : String?) {

        self.init(title: nil, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        _titleView = UIView()
        _titleView?.backgroundColor = UIColor.clear
        _titleView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        _titleButton = UIButton(type: .system)
        _titleButton?.isEnabled = false
        _titleButton?.titleLabel?.numberOfLines = 3
        _titleButton?.setTitleColor(UIColor.lightGray, for:.disabled)
        _titleButton?.setTitleColor(UIColor.init(colorLiteralRed: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:UIControlState())
        _titleButton?.backgroundColor = UIColor.clear
        _titleButton?.titleLabel?.textAlignment = .center
        _titleButton?.setTitle(title, for: UIControlState())
        _titleButton?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        font = UIFont.systemFont(ofSize: 13.0)
        _titleButton?.titleLabel?.font = self.font
        _titleView?.addSubview(_titleButton!)
        customView = _titleView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
