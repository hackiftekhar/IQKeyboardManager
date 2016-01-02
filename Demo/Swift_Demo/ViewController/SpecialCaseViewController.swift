//
//  SpecialCaseViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class SpecialCaseViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet private var customWorkTextField : UITextField!
    
    @IBOutlet private var textField6 : UITextField!
    @IBOutlet private var textField7 : UITextField!
    @IBOutlet private var textField8 : UITextField!
    
    @IBOutlet private var switchInteraction1 : UISwitch!
    @IBOutlet private var switchInteraction2 : UISwitch!
    @IBOutlet private var switchInteraction3 : UISwitch!
    @IBOutlet private var switchEnabled1 : UISwitch!
    @IBOutlet private var switchEnabled2 : UISwitch!
    @IBOutlet private var switchEnabled3 : UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField6.userInteractionEnabled = switchInteraction1.on
        textField7.userInteractionEnabled = switchInteraction2.on
        textField8.userInteractionEnabled = switchInteraction3.on
        
        textField6.enabled = switchEnabled1.on
        textField7.enabled = switchEnabled2.on
        textField8.enabled = switchEnabled3.on
        
        updateUI()
    }
    
    @IBAction func showAlertClicked (barButton : UIBarButtonItem!) {
        let alertView : UIAlertView = UIAlertView(title: "IQKeyboardManager", message: "It doesn't affect UIAlertView (Doesn't add IQToolbar on it's textField", delegate: nil, cancelButtonTitle: "OK")
        alertView.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
        alertView.show()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateUI() {
        textField6.placeholder = (textField6.enabled ? "enabled" : "" ) + "," + (textField6.userInteractionEnabled ? "userInteractionEnabled" : "" )
        textField7.placeholder = (textField7.enabled ? "enabled" : "" ) + "," + (textField7.userInteractionEnabled ? "userInteractionEnabled" : "" )
        textField8.placeholder = (textField8.enabled ? "enabled" : "" ) + "," + (textField8.userInteractionEnabled ? "userInteractionEnabled" : "" )
    }
    
    func switch1UserInteractionAction(sender: UISwitch) {
        textField6.userInteractionEnabled = sender.on
        updateUI()
    }
    
    func switch2UserInteractionAction(sender: UISwitch) {
        textField7.userInteractionEnabled = sender.on
        updateUI()
    }
    
    func switch3UserInteractionAction(sender: UISwitch) {
        textField8.userInteractionEnabled = sender.on
        updateUI()
    }
    
    func switch1Action(sender: UISwitch) {
        textField6.enabled = sender.on
        updateUI()
    }
    
    func switch2Action(sender: UISwitch) {
        textField7.enabled = sender.on
        updateUI()
    }
    
    func switch3Action(sender: UISwitch) {
        textField8.enabled = sender.on
        updateUI()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField == customWorkTextField) {
            if(textField.isAskingCanBecomeFirstResponder == false) {
                let alertView : UIAlertView = UIAlertView(title: "IQKeyboardManager", message: "Do your custom work here", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
            
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switchEnabled1.enabled = false
        switchEnabled2.enabled = false
        switchEnabled3.enabled = false
        switchInteraction1.enabled = false
        switchInteraction2.enabled = false
        switchInteraction3.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switchEnabled1.enabled = true
        switchEnabled2.enabled = true
        switchEnabled3.enabled = true
        switchInteraction1.enabled = true
        switchInteraction2.enabled = true
        switchInteraction3.enabled = true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

}


