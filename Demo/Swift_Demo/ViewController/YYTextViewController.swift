//
//  YYTextViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

import IQKeyboardManagerSwift

class YYTextViewController: UIViewController, YYTextViewDelegate {

    @IBOutlet var textView : YYTextView!

    override internal class func initialize() {
        super.initialize()
        
        IQKeyboardManager.sharedManager().registerTextFieldViewClass(YYTextView.self, didBeginEditingNotificationName: YYTextViewTextDidBeginEditingNotification, didEndEditingNotificationName: YYTextViewTextDidEndEditingNotification)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.placeholderText = "This is placeholder text of YYTextView"
    }
    
    func textViewDidBeginEditing(tv: YYTextView) {
        tv.reloadInputViews()
    }
}
