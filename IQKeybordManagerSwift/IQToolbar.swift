//
//  IQToolbar.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class IQToolbar: UIToolbar , UIInputViewAudioFeedback{

    var titleFont : UIFont? {
        
        didSet {
            
            for item in items as Array<IQTitleBarButtonItem> {
                
                if item.isKindOfClass(IQTitleBarButtonItem) {
                    (item as IQTitleBarButtonItem).font = titleFont
                }
            }
        }
    }

    override init() {
        super.init()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sizeToFit()
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            tintColor = UIColor .blackColor()
        }
        else
        {
            barStyle = UIBarStyle.BlackTranslucent
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        sizeToFit()
        autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            tintColor = UIColor .blackColor()
        }
        else
        {
            barStyle = UIBarStyle.BlackTranslucent
        }
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        var sizeThatFit = super.sizeThatFits(size)
        sizeThatFit.height = 44
        return sizeThatFit
    }

    
//    -(void)setTintColor:(UIColor *)tintColor
//    {
//    [super setTintColor:tintColor];
//    
//    for (UIBarButtonItem *item in self.items)
//    {
//    [item setTintColor:tintColor];
//    }
//    }
    
    var enableInputClicksWhenVisible: Bool {

        get {
            return true
        }
    }
}
