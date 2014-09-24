//
//  IQTitleBarButtonItem.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class IQTitleBarButtonItem: UIBarButtonItem {
   
    var font : UIFont? {
    
        didSet {
            titleLabel?.font = font!
        }
    }
    
    private var titleLabel : UILabel?
    
    override init() {
        super.init()
    }
    
    init(frame : CGRect, title : NSString?) {

        super.init(title: nil, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        titleLabel = UILabel(frame: frame)
        titleLabel?.backgroundColor = UIColor.clearColor()
        titleLabel?.textAlignment = NSTextAlignment.Center
        titleLabel?.text = title
        titleLabel?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.font = UIFont.boldSystemFontOfSize(12.0)

        self.customView = titleLabel
        self.enabled = false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
