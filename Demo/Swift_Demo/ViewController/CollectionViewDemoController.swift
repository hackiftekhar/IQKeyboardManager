//
//  CollectionViewDemoController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class CollectionViewDemoController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCollectionViewCell", for: indexPath)

        let textField = cell.viewWithTag(10) as? UITextField
        textField?.placeholder = "\(indexPath.section) \(indexPath.row)"

        return cell
    }
}
