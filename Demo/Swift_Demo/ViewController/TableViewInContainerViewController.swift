//
//  TableViewInContainerViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class TableViewInContainerViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "TestCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clearColor()
            
            let contentView : UIView! = cell?.contentView
            
            let textField = UITextField(frame: CGRectMake(10,0,contentView.frame.size.width-20,33))
            textField.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
            textField.center = contentView.center
            textField.backgroundColor = UIColor.clearColor()
            textField.borderStyle = UITextBorderStyle.RoundedRect
            textField.tag = 123
            cell?.contentView.addSubview(textField)
        }

        let textField : UITextField = cell!.viewWithTag(123) as! UITextField
        textField.placeholder = "Cell \(indexPath.row)"
        
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
