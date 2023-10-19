//
//  TableViewInContainerViewController.swift
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

final class HeaderFooterView: UITableViewHeaderFooterView {
    let textField: UITextField

    override init(reuseIdentifier: String?) {
        textField = UITextField(frame: CGRect(x: 15.0, y: 10.0, width: UIScreen.main.bounds.width - 30, height: 30.0))
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(textField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableViewInContainerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private var tableView: UITableView!

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: HeaderFooterView = tableView.dequeueHeaderFooter(HeaderFooterView.self)
        view.textField.placeholder = "\(section) Section Header"

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view: HeaderFooterView = tableView.dequeueHeaderFooter(HeaderFooterView.self)

        view.textField.placeholder = "\(section) Section Footer"

        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
        textField?.placeholder = "Cell \(indexPath.section), \(indexPath.row)"

        return cell!
    }
}
