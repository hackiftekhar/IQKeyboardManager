//
//  IQTitleBarButtonItem.swift
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


import UIKit

class IQTitleBarButtonItem: UIBarButtonItem {
   
    var font : UIFont? {
    
        didSet {
            if let unwrappedFont = font {
                titleLabel?.font = unwrappedFont
            } else {
                titleLabel?.font = UIFont.boldSystemFontOfSize(12)
            }
        }
    }
    
    private var titleLabel : UILabel?
    
    override init() {
        super.init()
    }
    
    init(frame : CGRect, title : String?) {

        super.init(title: nil, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        titleLabel = UILabel(frame: frame)
        titleLabel?.backgroundColor = UIColor.clearColor()
        titleLabel?.textAlignment = .Center
        titleLabel?.text = title
        titleLabel?.autoresizingMask = .FlexibleWidth
        font = UIFont.boldSystemFontOfSize(12.0)
        titleLabel?.font = self.font
        customView = titleLabel
        enabled = false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
