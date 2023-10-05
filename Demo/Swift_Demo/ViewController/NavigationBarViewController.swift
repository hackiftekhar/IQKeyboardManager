//
//  NavigationBarViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class NavigationBarViewController: BaseViewController, UITextFieldDelegate {

    fileprivate var returnKeyHandler: IQKeyboardReturnKeyHandler!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var scrollView: UIScrollView!

    deinit {
        returnKeyHandler = nil
        textField2 = nil
        textField3 = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField3.iq.placeholder = "This is the customised placeholder title for displaying as toolbar title"

        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }

    @IBAction func textFieldClicked(_ sender: UITextField!) {

    }

    @IBAction func enableScrollAction(_ sender: UISwitch!) {
        scrollView.isScrollEnabled = sender.isOn
    }

    @IBAction func shouldHideTitle(_ sender: UISwitch!) {
        textField2.iq.hidePlaceholder = !textField2.iq.hidePlaceholder
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
