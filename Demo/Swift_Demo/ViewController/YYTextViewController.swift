//
//  YYTextViewController.swift
//  Demo
//
//  Created by IEMacBook01 on 23/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

import IQKeyboardManagerSwift
import YYText

class YYTextViewController: UIViewController, YYTextViewDelegate {

    @IBOutlet var textView : YYTextView!

    deinit {
        textView = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.registerTextFieldViewClass(YYTextView.self, didBeginEditingNotificationName: Notification.Name.YYTextViewTextDidBeginEditing.rawValue, didEndEditingNotificationName: Notification.Name.YYTextViewTextDidEndEditing.rawValue)

        textView.placeholderText = "This is placeholder text of YYTextView"
    }
    
    func textViewDidBeginEditing(_ tv: YYTextView) {
        tv.reloadInputViews()
    }
}
