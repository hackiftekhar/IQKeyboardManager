//
//  TextViewSpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class TextViewSpecialCaseViewController: BaseViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear (_ animated: Bool) {

        super.viewWillAppear(animated)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if text == "\n" {
            textView.resignFirstResponder()
        }

        return true
    }
}
