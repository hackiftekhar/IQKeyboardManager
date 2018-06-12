//
//  ExampleTableViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class ExampleTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (((indexPath as NSIndexPath).row % 2) == 0) {
            return 40
        } else {
            return 160
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "\((indexPath as NSIndexPath).section) \((indexPath as NSIndexPath).row)"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clear
            cell?.selectionStyle = .none

            let contentView : UIView! = cell?.contentView

            if (((indexPath as NSIndexPath).row % 2) == 0) {
                
                let textField = UITextField(frame: CGRect(x: 5,y: 5,width: contentView.frame.size.width-10,height: 30))
                textField.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleWidth]
                textField.placeholder = identifier
                textField.backgroundColor = UIColor.clear
                textField.borderStyle = .roundedRect
                cell?.contentView.addSubview(textField)

            } else {

                let textView = UITextView(frame: contentView.bounds.insetBy(dx: 5, dy: 5))
                textView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
                textView.text = "Sample Text"
                cell?.contentView.addSubview(textView)
            }
        }
        
        return cell!
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
