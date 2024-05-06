//
//  TextSelectionViewController.swift
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
