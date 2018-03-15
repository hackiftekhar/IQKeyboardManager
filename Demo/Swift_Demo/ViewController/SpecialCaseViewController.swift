//
//  SpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SpecialCaseViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet fileprivate var customWorkTextField : UITextField!
    
    @IBOutlet fileprivate var textField6 : UITextField!
    @IBOutlet fileprivate var textField7 : UITextField!
    @IBOutlet fileprivate var textField8 : UITextField!
    
    @IBOutlet fileprivate var switchInteraction1 : UISwitch!
    @IBOutlet fileprivate var switchInteraction2 : UISwitch!
    @IBOutlet fileprivate var switchInteraction3 : UISwitch!
    @IBOutlet fileprivate var switchEnabled1 : UISwitch!
    @IBOutlet fileprivate var switchEnabled2 : UISwitch!
    @IBOutlet fileprivate var switchEnabled3 : UISwitch!
    
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
    
    @IBAction func showAlertClicked (_ barButton : UIBarButtonItem!) {
        let alertController = UIAlertController(title: "IQKeyboardManager", message: "It doesn't affect UIAlertController (Doesn't add IQToolbar on it's textField", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: { (textField : UITextField) in
            textField.placeholder = "Username"
        })
        
        alertController.addTextField(configurationHandler: { (textField : UITextField) in
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
        textField6.placeholder = (textField6.isEnabled ? "enabled" : "" ) + "," + (textField6.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
        textField7.placeholder = (textField7.isEnabled ? "enabled" : "" ) + "," + (textField7.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
        textField8.placeholder = (textField8.isEnabled ? "enabled" : "" ) + "," + (textField8.isUserInteractionEnabled ? "userInteractionEnabled" : "" )
    }
    
    @IBAction func switch1UserInteractionAction(_ sender: UISwitch) {
        textField6.isUserInteractionEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    @IBAction func switch2UserInteractionAction(_ sender: UISwitch) {
        textField7.isUserInteractionEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    @IBAction func switch3UserInteractionAction(_ sender: UISwitch) {
        textField8.isUserInteractionEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    @IBAction func switch1Action(_ sender: UISwitch) {
        textField6.isEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    @IBAction func switch2Action(_ sender: UISwitch) {
        textField7.isEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    @IBAction func switch3Action(_ sender: UISwitch) {
        textField8.isEnabled = sender.isOn
        IQKeyboardManager.shared.reloadInputViews()
        updateUI()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == customWorkTextField) {
            let alertController = UIAlertController(title: "IQKeyboardManager", message: "Do your custom work here", preferredStyle: .alert)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destination
                
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                
                let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height);
                controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
}


