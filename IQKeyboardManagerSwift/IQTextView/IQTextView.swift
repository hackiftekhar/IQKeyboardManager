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
    
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        #if swift(>=4.2)
        let UITextViewTextDidChange = UITextView.textDidChangeNotification
        #else
        let UITextViewTextDidChange = Notification.Name.UITextViewTextDidChange
        #endif

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name:UITextViewTextDidChange, object: self)
    }
    
    @objc override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        #if swift(>=4.2)
        let notificationName = UITextView.textDidChangeNotification
        #else
        let notificationName = Notification.Name.UITextViewTextDidChange
        #endif

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: notificationName, object: self)
    }
    
    @objc override open func awakeFromNib() {
        super.awakeFromNib()
        
        #if swift(>=4.2)
        let UITextViewTextDidChange = UITextView.textDidChangeNotification
        #else
        let UITextViewTextDidChange = Notification.Name.UITextViewTextDidChange
        #endif

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: UITextViewTextDidChange, object: self)
    }
    
    deinit {
        placeholderLabel.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }

    private var placeholderInsets : UIEdgeInsets {
        return UIEdgeInsets(top: self.textContainerInset.top, left: self.textContainerInset.left + self.textContainer.lineFragmentPadding, bottom: self.textContainerInset.bottom, right: self.textContainerInset.right + self.textContainer.lineFragmentPadding)
    }
    
    private var placeholderExpectedFrame : CGRect {
        let placeholderInsets = self.placeholderInsets
        let maxWidth = self.frame.width-placeholderInsets.left-placeholderInsets.right
        let expectedSize = placeholderLabel.sizeThatFits(CGSize(width: maxWidth, height: self.frame.height-placeholderInsets.top-placeholderInsets.bottom))
        
        return CGRect(x: placeholderInsets.left, y: placeholderInsets.top, width: maxWidth, height: expectedSize.height)
    }

    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor(white: 0.7, alpha: 1.0)
        label.alpha = 0
        self.addSubview(label)
        
        return label
    }()
    
    /** @abstract To set textView's placeholder text color. */
    @IBInspectable open var placeholderTextColor : UIColor? {
        
        get {
            return placeholderLabel.textColor
        }
        
        set {
            placeholderLabel.textColor = newValue
        }
    }
    
    /** @abstract To set textView's placeholder text. Default is nil.    */
    @IBInspectable open var placeholder : String? {
        
        get {
            return placeholderLabel.text
        }
        
        set {
            placeholderLabel.text = newValue
            refreshPlaceholder()
        }
    }

    /** @abstract To set textView's placeholder attributed text. Default is nil.    */
    open var attributedPlaceholder: NSAttributedString? {
        get {
            return placeholderLabel.attributedText
        }

        set {
            placeholderLabel.attributedText = newValue
            refreshPlaceholder()
        }
    }
    
    @objc override open func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.frame = placeholderExpectedFrame
    }
    
    @objc internal func refreshPlaceholder() {
        
        if !text.isEmpty || !attributedText.string.isEmpty {
            placeholderLabel.alpha = 0
        } else {
            placeholderLabel.alpha = 1
        }
    }
    
    @objc override open var text: String! {
        
        didSet {
            refreshPlaceholder()
        }
    }
    
    open override var attributedText: NSAttributedString! {
        
        didSet {
            refreshPlaceholder()
        }
    }
    
    @objc override open var font : UIFont? {
        
        didSet {
            
            if let unwrappedFont = font {
                placeholderLabel.font = unwrappedFont
            } else {
                placeholderLabel.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
    
    @objc override open var textAlignment: NSTextAlignment
        {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    @objc override open var delegate : UITextViewDelegate? {
        
        get {
            refreshPlaceholder()
            return super.delegate
        }
        
        set {
            super.delegate = newValue
        }
    }
    
    @objc override open var intrinsicContentSize: CGSize {
        guard !hasText else {
            return super.intrinsicContentSize
        }
        
        var newSize = super.intrinsicContentSize
        let placeholderInsets = self.placeholderInsets
        newSize.height = placeholderExpectedFrame.height + placeholderInsets.top + placeholderInsets.bottom
        
        return newSize
    }
}


