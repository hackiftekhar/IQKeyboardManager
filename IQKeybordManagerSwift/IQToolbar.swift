//
//  IQToolbar.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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
