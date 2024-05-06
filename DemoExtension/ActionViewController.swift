//
//  ActionViewController.swift
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
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the item[s] we're handling from the extension context.
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem]
        for item in inputItems ?? [] {
            let attachements = item.attachments ?? []
            for provider in attachements where provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                // This is an image. We'll load it, then place it in our image view.
                weak var weakImageView = self.imageView
                let identifier = kUTTypeImage as String
                provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (imageURL, _) in
                    OperationQueue.main.addOperation {
                        if let strongImageView = weakImageView {
                            if let imageURL = imageURL as? URL, let data =  try? Data(contentsOf: imageURL) {
                                strongImageView.image = UIImage(data: data)
                            }
                        }
                    }
                })
                imageFound = true
                break
            }
            if imageFound {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems,
                                               completionHandler: nil)
    }

}
