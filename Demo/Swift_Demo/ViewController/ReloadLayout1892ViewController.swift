//
//  ReloadLayout1892ViewController.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/2/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ReloadLayout1892ViewController: BaseViewController {
    @IBOutlet weak var textView: UITextView!
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
}
