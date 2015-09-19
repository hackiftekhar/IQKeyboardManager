//
//  CollectionViewDemoController.swift
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 20/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

import UIKit

class CollectionViewDemoController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("TextFieldCollectionViewCell", forIndexPath: indexPath) 
     
        let textField : UITextField = cell.viewWithTag(10) as! UITextField
        textField.placeholder = "\(indexPath.section) \(indexPath.row)"

        return cell
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
