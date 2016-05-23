//
//  TextSelectionViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class TextSelectionViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    let _data = ["Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text.",
"Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text.",
"Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text."]
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "\(indexPath.section) \(indexPath.row)"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            cell?.backgroundColor = UIColor.clearColor()
            
            let textView = UITextView(frame: CGRectMake(5,7,135,30))
            textView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
            textView.backgroundColor = UIColor.clearColor()
            textView.text = _data[indexPath.row]
            textView.dataDetectorTypes = UIDataDetectorTypes.All
            textView.scrollEnabled = false
            textView.editable = false
            cell?.contentView.addSubview(textView)
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
