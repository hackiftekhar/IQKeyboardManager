//
//  ExampleTableViewController.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class ExampleTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row % 2) == 0 {
            return 40
        } else {
            return 160
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = "\(indexPath.section) \(indexPath.row)"

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {

            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.backgroundColor = UIColor.clear
            cell?.selectionStyle = .none

            let contentView: UIView! = cell?.contentView

            if (indexPath.row % 2) == 0 {

                let textField = UITextField(frame: CGRect(x: 5, y: 5,
                                                          width: contentView.frame.size.width-10,
                                                          height: 30))
                textField.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleWidth]
                textField.placeholder = identifier
                textField.backgroundColor = UIColor.clear
                textField.borderStyle = .roundedRect
                cell?.contentView.addSubview(textField)

            } else {

                let textView = UITextView(frame: contentView.bounds.insetBy(dx: 5, dy: 5))
                textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                textView.text = "Sample Text"
                cell?.contentView.addSubview(textView)
            }
        }

        return cell!
    }
}
