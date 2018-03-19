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


import Foundation
import UIKit

open class IQTitleBarButtonItem: IQBarButtonItem {
   
    open var titleFont : UIFont? {
    
        didSet {
            if let unwrappedFont = titleFont {
                titleButton?.titleLabel?.font = unwrappedFont
            } else {
                titleButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }

    override open var title: String? {
        didSet {
                titleButton?.setTitle(title, for: .normal)
        }
    }
    
    /**
     titleColor to be used for displaying button text when displaying title (disabled state).
     */
    open var titleColor : UIColor? {

        didSet {
            
            if let color = titleColor {
                titleButton?.setTitleColor(color, for:.disabled)
            } else {
                titleButton?.setTitleColor(UIColor.lightGray, for:.disabled)
            }
        }
    }
    
    /**
     selectableTitleColor to be used for displaying button text when button is enabled.
     */
    open var selectableTitleColor : UIColor? {
        
        didSet {
            
            if let color = selectableTitleColor {
                titleButton?.setTitleColor(color, for:.normal)
            } else {
                titleButton?.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:.normal)
            }
        }
    }

    /**
     Customized Invocation to be called on title button action. titleInvocation is internally created using setTitleTarget:action: method.
     */
    override open var invocation : IQInvocation? {

        didSet {
            
            if let target = invocation?.target, let action = invocation?.action {
                self.isEnabled = true
                titleButton?.isEnabled = true
                titleButton?.addTarget(target, action: action, for: .touchUpInside)
            } else {
                self.isEnabled = false
                titleButton?.isEnabled = false
                titleButton?.removeTarget(nil, action: nil, for: .touchUpInside)
            }
        }
    }

    internal var titleButton : UIButton?
    private var _titleView : UIView?

    override init() {
        super.init()
    }
    
    convenience init(title : String?) {

        self.init(title: nil, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        _titleView = UIView()
        _titleView?.backgroundColor = UIColor.clear
        
        titleButton = UIButton(type: .system)
        titleButton?.isEnabled = false
        titleButton?.titleLabel?.numberOfLines = 3
        titleButton?.setTitleColor(UIColor.lightGray, for:.disabled)
        titleButton?.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:.normal)
        titleButton?.backgroundColor = UIColor.clear
        titleButton?.titleLabel?.textAlignment = .center
        titleButton?.setTitle(title, for: .normal)
        titleFont = UIFont.systemFont(ofSize: 13.0)
        titleButton?.titleLabel?.font = self.titleFont
        _titleView?.addSubview(titleButton!)
        
#if swift(>=3.2)
        if #available(iOS 11, *) {
            
            var layoutDefaultLowPriority : UILayoutPriority
            var layoutDefaultHighPriority : UILayoutPriority

            #if swift(>=4.0)
                let layoutPriorityLowValue = UILayoutPriority.defaultLow.rawValue-1
                let layoutPriorityHighValue = UILayoutPriority.defaultHigh.rawValue-1
                layoutDefaultLowPriority = UILayoutPriority(rawValue: layoutPriorityLowValue)
                layoutDefaultHighPriority = UILayoutPriority(rawValue: layoutPriorityHighValue)
            #else
                layoutDefaultLowPriority = UILayoutPriorityDefaultLow-1
                layoutDefaultHighPriority = UILayoutPriorityDefaultHigh-1
            #endif
            
            _titleView?.translatesAutoresizingMaskIntoConstraints = false
            _titleView?.setContentHuggingPriority(layoutDefaultLowPriority, for: .vertical)
            _titleView?.setContentHuggingPriority(layoutDefaultLowPriority, for: .horizontal)
            _titleView?.setContentCompressionResistancePriority(layoutDefaultHighPriority, for: .vertical)
            _titleView?.setContentCompressionResistancePriority(layoutDefaultHighPriority, for: .horizontal)
            
            titleButton?.translatesAutoresizingMaskIntoConstraints = false
            titleButton?.setContentHuggingPriority(layoutDefaultLowPriority, for: .vertical)
            titleButton?.setContentHuggingPriority(layoutDefaultLowPriority, for: .horizontal)
            titleButton?.setContentCompressionResistancePriority(layoutDefaultHighPriority, for: .vertical)
            titleButton?.setContentCompressionResistancePriority(layoutDefaultHighPriority, for: .horizontal)

            let top = NSLayoutConstraint.init(item: titleButton!, attribute: .top, relatedBy: .equal, toItem: _titleView, attribute: .top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint.init(item: titleButton!, attribute: .bottom, relatedBy: .equal, toItem: _titleView, attribute: .bottom, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint.init(item: titleButton!, attribute: .leading, relatedBy: .equal, toItem: _titleView, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint.init(item: titleButton!, attribute: .trailing, relatedBy: .equal, toItem: _titleView, attribute: .trailing, multiplier: 1, constant: 0)
            
            _titleView?.addConstraints([top,bottom,leading,trailing])
        } else {
            _titleView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            titleButton?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }
#else
    _titleView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    titleButton?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
#endif

        customView = _titleView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        customView = nil
        titleButton?.removeTarget(nil, action: nil, for: .touchUpInside)
        _titleView = nil
        titleButton = nil
    }
}
