//
//  ScrollViewController.swift
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
import IQKeyboardManagerSwift

class ScrollViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var scrollViewDemo: UIScrollView!
    @IBOutlet var simpleTableView: UITableView!
    @IBOutlet var scrollViewOfTableViews: UIScrollView!
    @IBOutlet var tableViewInsideScrollView: UITableView!
    @IBOutlet var scrollViewInsideScrollView: UIScrollView!

    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!

    @IBOutlet var topTextView: UITextView!
    @IBOutlet var bottomTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewInsideScrollView.iq.ignoreScrollingAdjustment = true
    }

    deinit {
        topTextField = nil
        bottomTextField = nil
        topTextView = nil
        bottomTextView = nil
    }
}

extension ScrollViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = "\(indexPath.section) \(indexPath.row)"

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {

            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear

            let textField = UITextField(frame: cell!.contentView.bounds.insetBy(dx: 5, dy: 5))
            textField.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleWidth]
            textField.placeholder = identifier
            textField.borderStyle = .roundedRect
            cell?.contentView.addSubview(textField)
        }

        return cell!
    }
}
