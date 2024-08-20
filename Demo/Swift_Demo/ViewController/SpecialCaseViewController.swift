//
//  SpecialCaseViewController.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class SpecialCaseViewController: BaseViewController, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var customWorkTextField: UITextField!

    @IBOutlet var textField6: UITextField!
    @IBOutlet var textField7: UITextField!
    @IBOutlet var textField8: UITextField!

    @IBOutlet var switchInteraction1: UISwitch!
    @IBOutlet var switchInteraction2: UISwitch!
    @IBOutlet var switchInteraction3: UISwitch!
    @IBOutlet var switchEnabled1: UISwitch!
    @IBOutlet var switchEnabled2: UISwitch!
    @IBOutlet var switchEnabled3: UISwitch!

    deinit {
        customWorkTextField = nil
        textField6 = nil
        textField7 = nil
        textField8 = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField6.isUserInteractionEnabled = switchInteraction1.isOn
        textField7.isUserInteractionEnabled = switchInteraction2.isOn
        textField8.isUserInteractionEnabled = switchInteraction3.isOn

        textField6.isEnabled = switchEnabled1.isOn
        textField7.isEnabled = switchEnabled2.isOn
        textField8.isEnabled = switchEnabled3.isOn

        updateUI()
    }

    @IBAction func showAlertClicked (_ barButton: UIBarButtonItem!) {
        let message = "It doesn't affect UIAlertController (Doesn't add IQToolbar on it's textField"
        let alertController = UIAlertController(title: "IQKeyboardManager",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        alertController.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "Username"
        })

        alertController.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })

        self.present(alertController, animated: true, completion: nil)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func updateUI() {
        textField6.placeholder = (textField6.isEnabled ? "enabled" : "" ) + "," +
        (textField6.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
        textField7.placeholder = (textField7.isEnabled ? "enabled" : "" ) + "," +
        (textField7.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
        textField8.placeholder = (textField8.isEnabled ? "enabled" : "" ) + "," +
        (textField8.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
    }

    @IBAction func switch1UserInteractionAction(_ sender: UISwitch) {
        textField6.isUserInteractionEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    @IBAction func switch2UserInteractionAction(_ sender: UISwitch) {
        textField7.isUserInteractionEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    @IBAction func switch3UserInteractionAction(_ sender: UISwitch) {
        textField8.isUserInteractionEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    @IBAction func switch1Action(_ sender: UISwitch) {
        textField6.isEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    @IBAction func switch2Action(_ sender: UISwitch) {
        textField7.isEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    @IBAction func switch3Action(_ sender: UISwitch) {
        textField8.isEnabled = sender.isOn
        IQKeyboardToolbarManager.shared.reloadInputViews()
        updateUI()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == customWorkTextField {
            let alertController = UIAlertController(title: "IQKeyboardManager",
                                                    message: "Do your custom work here",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

            self.present(alertController, animated: true, completion: nil)

            return false
        } else {
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}
