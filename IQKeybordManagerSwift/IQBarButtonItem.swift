//
//  IQBarButtonItem.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class IQBarButtonItem: UIBarButtonItem {
   
    override init() {
        super.init()

        //Removing tint
        tintColor = nil
    }
    
    override init(barButtonSystemItem systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
        super.init(barButtonSystemItem: systemItem, target: target, action: action)
    }
    
    override init(image: UIImage?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
        super.init(image: image, style: style, target: target, action: action)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
