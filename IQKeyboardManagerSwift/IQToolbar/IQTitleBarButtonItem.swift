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
                _titleButton?.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:UIControlState())
            }
        }
    }

    /**
     Customized Invocation to be called on title button action. titleInvocation is internally created using setTitleTarget:action: method.
     */
    override open var invocation : (target: AnyObject?, action: Selector?) {

        didSet {
            
            if (invocation.target == nil || invocation.action == nil)
            {
                self.isEnabled = false
                _titleButton?.isEnabled = false
                _titleButton?.removeTarget(nil, action: nil, for: .touchUpInside)
            }
            else
            {
                self.isEnabled = true
                _titleButton?.isEnabled = true
                _titleButton?.addTarget(invocation.target, action: invocation.action!, for: .touchUpInside)
            }
        }
    }

    fileprivate var _titleButton : UIButton?
    fileprivate var _titleView : UIView?

    override init() {
        super.init()
    }
    
    convenience init(title : String?) {

        self.init(title: nil, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        _titleView = UIView()
        _titleView?.backgroundColor = UIColor.clear
        
        _titleButton = UIButton(type: .system)
        _titleButton?.isEnabled = false
        _titleButton?.titleLabel?.numberOfLines = 3
        _titleButton?.setTitleColor(UIColor.lightGray, for:.disabled)
        _titleButton?.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), for:UIControlState())
        _titleButton?.backgroundColor = UIColor.clear
        _titleButton?.titleLabel?.textAlignment = .center
        _titleButton?.setTitle(title, for: UIControlState())
        titleFont = UIFont.systemFont(ofSize: 13.0)
        _titleButton?.titleLabel?.font = self.titleFont
        _titleView?.addSubview(_titleButton!)
        
        if #available(iOS 11, *) {
            _titleView?.translatesAutoresizingMaskIntoConstraints = false;
            _titleView?.setContentHuggingPriority(UILayoutPriorityDefaultLow-1, for: .vertical)
            _titleView?.setContentHuggingPriority(UILayoutPriorityDefaultLow-1, for: .horizontal)
            _titleView?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh-1, for: .vertical)
            _titleView?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh-1, for: .horizontal)
            
            _titleButton?.translatesAutoresizingMaskIntoConstraints = false;
            _titleButton?.setContentHuggingPriority(UILayoutPriorityDefaultLow-1, for: .vertical)
            _titleButton?.setContentHuggingPriority(UILayoutPriorityDefaultLow-1, for: .horizontal)
            _titleButton?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh-1, for: .vertical)
            _titleButton?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh-1, for: .horizontal)

            let top = NSLayoutConstraint.init(item: _titleButton!, attribute: .top, relatedBy: .equal, toItem: _titleView, attribute: .top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint.init(item: _titleButton!, attribute: .bottom, relatedBy: .equal, toItem: _titleView, attribute: .bottom, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint.init(item: _titleButton!, attribute: .leading, relatedBy: .equal, toItem: _titleView, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint.init(item: _titleButton!, attribute: .trailing, relatedBy: .equal, toItem: _titleView, attribute: .trailing, multiplier: 1, constant: 0)
            
            _titleView?.addConstraints([top,bottom,leading,trailing])
        } else {
            _titleView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            _titleButton?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }

        customView = _titleView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
