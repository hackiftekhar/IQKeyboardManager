//
//  TextFieldViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import IQDropDownTextField

class TextFieldViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet fileprivate var textField3 : UITextField!
    @IBOutlet var textView1: IQTextView!

    @IBOutlet fileprivate var dropDownTextField : IQDropDownTextField!

    @IBOutlet fileprivate var buttonPush : UIButton!
    @IBOutlet fileprivate var buttonPresent : UIButton!

    @objc func previousAction(_ sender : UITextField) {
        print("PreviousAction")
    }
    
    @objc func nextAction(_ sender : UITextField) {
        print("nextAction")
    }
    
    @objc func doneAction(_ sender : UITextField) {
        print("doneAction")
    }

    deinit {
        textField3 = nil
        textView1 = nil
        dropDownTextField = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView1.delegate = self

        textView1.attributedPlaceholder = NSAttributedString(string: "Attributed string from code is supported too", attributes: [.foregroundColor: UIColor.red])
        
        textField3.keyboardToolbar.previousBarButton.setTarget(self, action: #selector(self.previousAction(_:)))
        textField3.keyboardToolbar.nextBarButton.setTarget(self, action: #selector(self.nextAction(_:)))
        textField3.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.doneAction(_:)))
        dropDownTextField.keyboardDistanceFromTextField = 150;
        
        var itemLists = [String]()
        itemLists.append("Zero Line Of Code")
        itemLists.append("No More UIScrollView")
        itemLists.append("No More Subclasses")
        itemLists.append("No More Manual Work")
        itemLists.append("No More #imports")
        itemLists.append("Device Orientation support")
        itemLists.append("UITextField Category for Keyboard")
        itemLists.append("Enable/Desable Keyboard Manager")
        itemLists.append("Customize InputView support")
        itemLists.append("IQTextView for placeholder support")
        itemLists.append("Automanage keyboard toolbar")
        itemLists.append("Can set keyboard and textFiled distance")
        itemLists.append("Can resign on touching outside")
        itemLists.append("Auto adjust textView's height")
        itemLists.append("Adopt tintColor from textField")
        itemLists.append("Customize keyboardAppearance")
        itemLists.append("Play sound on next/prev/done")

        dropDownTextField.itemList = itemLists
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        if (self.presentingViewController != nil)
        {
            buttonPush.isHidden = true
            buttonPresent.setTitle("Dismiss", for:.normal)
        }
    }
    
    @IBAction func presentClicked (_ sender: AnyObject!) {
        
        if self.presentingViewController == nil {
            
            let controller: UIViewController = (storyboard?.instantiateViewController(withIdentifier: "TextFieldViewController"))!
            let navController : UINavigationController = UINavigationController(rootViewController: controller)
            navController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            navController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            navController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
            navController.modalTransitionStyle = UIModalTransitionStyle(rawValue: Int(arc4random()%4))!

            // TransitionStylePartialCurl can only be presented by FullScreen style.
            if (navController.modalTransitionStyle == UIModalTransitionStyle.partialCurl) {
                navController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            } else {
                navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            }

            present(navController, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        print("textViewDidBeginEditing");
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
}
