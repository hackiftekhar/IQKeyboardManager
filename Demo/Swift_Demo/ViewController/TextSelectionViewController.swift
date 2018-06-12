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
    
    func tableView(_ tableView: UITableView, heightForRowAt heightForRowAtIndexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "\((indexPath as NSIndexPath).section) \((indexPath as NSIndexPath).row)"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            
            let textView = UITextView(frame: CGRect(x: 5,y: 7,width: 135,height: 30))
            textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            textView.backgroundColor = UIColor.clear
            textView.text = _data[(indexPath as NSIndexPath).row]
            textView.dataDetectorTypes = UIDataDetectorTypes.all
            textView.isScrollEnabled = false
            textView.isEditable = false
            cell?.contentView.addSubview(textView)
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
