//
//  IQNSArray+Sort.swift
//  IQKeyboard
//
//  Created by Iftekhar on 21/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import Foundation

extension NSArray {
    
    
    func sortedArrayByTag() -> NSArray {
        
        return self.sortedArrayUsingComparator({ (let view1: AnyObject?, let view2: AnyObject?) -> NSComparisonResult in

            if view1?.tag < view2?.tag {
                return NSComparisonResult.OrderedAscending
            }
            else if view1?.tag > view2?.tag {
                    return NSComparisonResult.OrderedDescending
            }
            else {
                return NSComparisonResult.OrderedSame
            }
        })
    }
    
}