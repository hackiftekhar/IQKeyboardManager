//
//  TableViewInContainerViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class TableViewInContainerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = "TestCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {

            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clear

            let contentView: UIView! = cell?.contentView

            let textField = UITextField(frame: CGRect(x: 10, y: 0, width: contentView.frame.size.width-20, height: 33))
            textField.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleWidth]
            textField.center = contentView.center
            textField.backgroundColor = UIColor.clear
            textField.borderStyle = .roundedRect
            textField.tag = 123
            cell?.contentView.addSubview(textField)
        }

        let textField = cell?.viewWithTag(123) as? UITextField
        textField?.placeholder = "Cell \(indexPath.row)"

        return cell!
    }
}
