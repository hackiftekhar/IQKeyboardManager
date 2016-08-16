//
//  ScrollViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet private var scrollViewDemo : UIScrollView!
    @IBOutlet private var simpleTableView : UITableView!
    @IBOutlet private var scrollViewOfTableViews : UIScrollView!
    @IBOutlet private var tableViewInsideScrollView : UITableView!
    @IBOutlet private var scrollViewInsideScrollView : UIScrollView!
    
    @IBOutlet private var topTextField : UITextField!
    @IBOutlet private var bottomTextField : UITextField!
    
    @IBOutlet private var topTextView : UITextView!
    @IBOutlet private var bottomTextView : UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = "\((indexPath as NSIndexPath).section) \((indexPath as NSIndexPath).row)"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.backgroundColor = UIColor.clear
            
            let textField = UITextField(frame: cell!.contentView.bounds.insetBy(dx: 5, dy: 5))
            textField.autoresizingMask = [UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleWidth]
            textField.placeholder = identifier
            textField.borderStyle = UITextBorderStyle.roundedRect
            cell?.contentView.addSubview(textField)
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
    
	override var shouldAutorotate: Bool {
        return true
    }
}
