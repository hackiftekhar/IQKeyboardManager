//
//  ScrollViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
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
        
        scrollViewDemo.contentSize = CGSizeMake(0, 321)
        scrollViewInsideScrollView.contentSize = CGSizeMake(0,321)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let identifier = "\(indexPath.section) \(indexPath.row)"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)

        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            cell?.backgroundColor = UIColor.clearColor()
            
            let textField = UITextField(frame: CGRectInset(cell!.contentView.bounds, 5, 5))
            textField.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
            textField.placeholder = identifier
            textField.borderStyle = UITextBorderStyle.RoundedRect
            cell?.contentView.addSubview(textField)
        }

        return cell!
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

}
