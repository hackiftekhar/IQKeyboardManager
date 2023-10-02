//
//  TextFieldViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import IQDropDownTextFieldSwift

class TextFieldViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet var textField3: UITextField!
    @IBOutlet var textView1: IQTextView!
    @IBOutlet var textView2: UITextView!
    @IBOutlet var textView3: UITextView!

    @IBOutlet var dropDownTextField: IQDropDownTextField!

    @objc func previousAction(_ sender: UITextField) {
        print("PreviousAction")
    }

    @objc func nextAction(_ sender: UITextField) {
        print("nextAction")
    }

    @objc func doneAction(_ sender: UITextField) {
        print("doneAction")
    }

    deinit {
        textField3 = nil
        textView1 = nil
        dropDownTextField = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView2.enableMode = .disabled
        textView1.delegate = self

#if swift(>=5.7)
        if #available(iOS 16.0, *) {
            textView3.isFindInteractionEnabled = true
        }
#endif

//        textView1.attributedPlaceholder = NSAttributedString(string: "Attributed string from code is supported too", attributes: [.foregroundColor: UIColor.red])

        textField3.keyboardToolbar.previousBarButton.setTarget(self, action: #selector(self.previousAction(_:)))
        textField3.keyboardToolbar.nextBarButton.setTarget(self, action: #selector(self.nextAction(_:)))
        textField3.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.doneAction(_:)))
        dropDownTextField.keyboardDistanceFromTextField = 150

        var itemLists = [String]()
        itemLists.append("Zero Line Of Code")
        itemLists.append("No More UIScrollView")
        itemLists.append("No More Subclasses")
        itemLists.append("No More Manual Work")
        itemLists.append("No More #imports")
        itemLists.append("Device Orientation support")
        itemLists.append("UITextField Category for Keyboard")
        itemLists.append("Enable/Desable Keyboard Manager")
        itemLists.append("Customize InputView support")
        itemLists.append("IQTextView for placeholder support")
        itemLists.append("Automanage keyboard toolbar")
        itemLists.append("Can set keyboard and textFiled distance")
        itemLists.append("Can resign on touching outside")
        itemLists.append("Auto adjust textView's height")
        itemLists.append("Adopt tintColor from textField")
        itemLists.append("Customize keyboardAppearance")
        itemLists.append("Play sound on next/prev/done")

        dropDownTextField.itemList = itemLists
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        IQKeyboardManager.shared.registerKeyboardSizeChange(identifier: "TextFieldViewController", sizeHandler: { size in
            print(size)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.unregisterKeyboardSizeChange(identifier: "TextFieldViewController")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        print("textViewDidBeginEditing")
    }
}
