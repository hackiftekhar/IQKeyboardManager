//
//  TextSelectionViewController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class TextSelectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    private let data = ["Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text.",
    "Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text.",
    "Hello", "This is a demo code", "Issue #56", "With mutiple cells", "And some useless text."]

    func tableView(_ tableView: UITableView, heightForRowAt heightForRowAtIndexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = "\(indexPath.section) \(indexPath.row)"

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {

            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear

            let textView = UITextView(frame: CGRect(x: 5, y: 7, width: 135, height: 30))
            textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            textView.backgroundColor = UIColor.clear
            textView.text = data[indexPath.row]
            textView.dataDetectorTypes = UIDataDetectorTypes.all
            textView.isScrollEnabled = false
            textView.isEditable = false
            cell?.contentView.addSubview(textView)
        }

        return cell!
    }
}
