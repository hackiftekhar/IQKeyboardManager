//
//  IQTextView.swift
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

/** @abstract UITextView with placeholder support   */
open class IQTextView : UITextView {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    override open func awakeFromNib() {
         super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var placeholderLabel: UILabel?
    
    /** @abstract To set textView's placeholder text. Default is ni.    */
    @IBInspectable open var placeholder : String? {

        get {
            return placeholderLabel?.text
        }
 
        set {
            
            if placeholderLabel == nil {
                
                placeholderLabel = UILabel()
                
                if let unwrappedPlaceholderLabel = placeholderLabel {
                    
                    unwrappedPlaceholderLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    unwrappedPlaceholderLabel.lineBreakMode = .byWordWrapping
                    unwrappedPlaceholderLabel.numberOfLines = 0
                    unwrappedPlaceholderLabel.font = self.font
                    unwrappedPlaceholderLabel.backgroundColor = UIColor.clear
                    unwrappedPlaceholderLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
                    unwrappedPlaceholderLabel.alpha = 0
                    addSubview(unwrappedPlaceholderLabel)
                }
            }
            
            placeholderLabel?.text = newValue
            refreshPlaceholder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let unwrappedPlaceholderLabel = placeholderLabel {
            unwrappedPlaceholderLabel.sizeToFit()
            unwrappedPlaceholderLabel.frame = CGRect(x: 8, y: 8, width: self.frame.width-16, height: unwrappedPlaceholderLabel.frame.height)
        }
    }

    open func refreshPlaceholder() {
        
        if text.characters.count != 0 {
            placeholderLabel?.alpha = 0
        } else {
            placeholderLabel?.alpha = 1
        }
    }
    
    override open var text: String! {
        
        didSet {
            
            refreshPlaceholder()

        }
    }
    
    override open var font : UIFont? {
       
        didSet {
            
            if let unwrappedFont = font {
                placeholderLabel?.font = unwrappedFont
            } else {
                placeholderLabel?.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
    
    override open var delegate : UITextViewDelegate? {
        
        get {
            refreshPlaceholder()
            return super.delegate
        }
        
        set {
            super.delegate = newValue
        }
    }
}


