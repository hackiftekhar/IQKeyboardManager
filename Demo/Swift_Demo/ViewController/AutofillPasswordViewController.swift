//
//  AutofillPasswordViewController.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/2/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit

class AutofillPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func loginActin(_ sender: UIButton) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}
