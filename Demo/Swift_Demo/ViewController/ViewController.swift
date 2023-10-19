//
//  ViewController.swift
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

class ViewController: BaseTableViewController {

    @IBAction func shareClicked (_ sender: UIBarButtonItem) {

        let shareString: String = "IQKeyboardManager is really great for iOS developer to manage keyboard-textField."
        let shareImage: UIImage = UIImage(named: "IQKeyboardManagerScreenshot")!
        let youtubeUrl: URL = URL(string: "http://youtu.be/6nhLw6hju2A")!

        var activityItems = [Any]()
        activityItems.append(shareString)
        activityItems.append(shareImage)
        activityItems.append(youtubeUrl)

        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
        present(controller, animated: true) { () -> Void in

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.toolbarConfiguration.manageBehaviour = IQAutoToolbarManageBehaviour.byPosition
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else {
            return
        }

        if identifier == "PopoverViewController" {
            let controller = segue.destination

            controller.modalPresentationStyle = .popover

            controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            controller.popoverPresentationController?.sourceView = sender as? UIView

            let heightWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            controller.preferredContentSize = CGSize(width: heightWidth, height: heightWidth)
            controller.popoverPresentationController?.delegate = self
        }
    }
}
