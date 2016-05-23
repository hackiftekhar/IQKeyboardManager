//
//  ExampleTableViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class ExampleTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if ((indexPath.row % 2) == 0) {
            return 40
        } else {
            return 160
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "\(indexPath.section) \(indexPath.row)"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clearColor()
            cell?.selectionStyle = UITableViewCellSelectionStyle.None

            let contentView : UIView! = cell?.contentView

            if ((indexPath.row % 2) == 0) {
                
                let textField = UITextField(frame: CGRectMake(5,5,contentView.frame.size.width-10,30))
                textField.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
                textField.placeholder = identifier
                textField.backgroundColor = UIColor.clearColor()
                textField.borderStyle = UITextBorderStyle.RoundedRect
                cell?.contentView.addSubview(textField)

            } else {

                let textView = UITextView(frame: CGRectInset(contentView.bounds, 5, 5))
                textView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
                textView.text = "Sample Text"
                cell?.contentView.addSubview(textView)
            }
        }
        
        return cell!
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "SettingsNavigationController" {
                
                let controller = segue.destinationViewController
                
                controller.modalPresentationStyle = .Popover
                controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                
                let heightWidth = max(CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds));
                controller.preferredContentSize = CGSizeMake(heightWidth, heightWidth)
                controller.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        self.view.endEditing(true)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
