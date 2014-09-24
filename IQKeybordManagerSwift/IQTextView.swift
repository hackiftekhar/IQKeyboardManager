//
//  IQTextView.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class IQTextView: UITextView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var placeholderLabel: UILabel?
    

    var placeholder : NSString! {

        get {
            return self.placeholder?
        }
 
        set {
            
            if placeholderLabel == nil {
                
                placeholderLabel = UILabel(frame: CGRectInset(self.bounds, 8, 8))
                placeholderLabel?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
                placeholderLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                placeholderLabel?.numberOfLines = 0
                placeholderLabel?.font = self.font;
                placeholderLabel?.backgroundColor = UIColor.clearColor()
                placeholderLabel?.textColor = UIColor(white: 0.7, alpha: 1.0)
                placeholderLabel?.alpha = 0
                self.addSubview(placeholderLabel!)
            }
            
            placeholderLabel?.text = placeholder
            refreshPlaceholder()
        }
    }
    
    private func refreshPlaceholder() {
        
        if countElements(self.text) != 0 {
            placeholderLabel?.alpha = 0
        }
        else {
            placeholderLabel?.alpha = 1
        }
    }
    
    override var text: String! {
        
        get {
            return self.text?
        }
        
        set {
            refreshPlaceholder()
        }
    }
    
    override var font : UIFont! {
        get {
            return self.font?
        }
        
        set {
            placeholderLabel?.font = font
        }
    }
    
    override var delegate : UITextViewDelegate? {
        
        get {
            refreshPlaceholder()
            return self.delegate?
        }
        
        set {
            
        }
    }
}


