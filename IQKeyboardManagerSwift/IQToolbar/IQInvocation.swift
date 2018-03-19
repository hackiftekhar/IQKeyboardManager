//
//  Invocation.swift
//  IQKeyboardManagerSwift
//
//  Created by Metin Güler on 19.03.2018.
//  Copyright © 2018 IQKeyboardManager. All rights reserved.
//

import Foundation

open class IQInvocation {
    var target: AnyObject?
    var action: Selector?
    
    init(_ target: AnyObject?, _ action: Selector?) {
        self.target = target
        self.action = action
    }
}
