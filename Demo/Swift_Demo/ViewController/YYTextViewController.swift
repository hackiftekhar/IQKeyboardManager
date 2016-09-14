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
        
        IQKeyboardManager.sharedManager().registerTextFieldViewClass(YYTextView.self, didBeginEditingNotificationName: NSNotification.Name.YYTextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: NSNotification.Name.YYTextViewTextDidEndEditing.rawValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.placeholderText = "This is placeholder text of YYTextView"
    }
    
    func textViewDidBeginEditing(_ tv: YYTextView) {
        tv.reloadInputViews()
    }
}
