//
//  IQBarButtonItem.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
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
import Foundation

open class IQBarButtonItem: UIBarButtonItem {

    private static var _classInitialize: Void = classInitialize()
    
    public override init() {
        _ = IQBarButtonItem._classInitialize
          super.init()
      }

    public required init?(coder aDecoder: NSCoder) {
        _ = IQBarButtonItem._classInitialize
           super.init(coder: aDecoder)
       }

   
    private class func classInitialize() {

        let  appearanceProxy = self.appearance()

        let states : [UIControlState] = [.normal,.highlighted,.disabled,.selected,.application,.reserved]

        for state in states {

            appearanceProxy.setBackgroundImage(nil, for: state, barMetrics: .default)
            appearanceProxy.setBackgroundImage(nil, for: state, style: .done, barMetrics: .default)
            appearanceProxy.setBackgroundImage(nil, for: state, style: .plain, barMetrics: .default)
            appearanceProxy.setBackButtonBackgroundImage(nil, for: state, barMetrics: .default)
        }
        
        appearanceProxy.setTitlePositionAdjustment(UIOffset.zero, for: .default)
        appearanceProxy.setBackgroundVerticalPositionAdjustment(0, for: .default)
        appearanceProxy.setBackButtonBackgroundVerticalPositionAdjustment(0, for: .default)
    }
    
    open override var tintColor: UIColor? {
        didSet {

            #if swift(>=4)
                var textAttributes = [NSAttributedStringKey : Any]()
                
                if let attributes = titleTextAttributes(for: .normal) {
                
                    for (key, value) in attributes {
                
                        textAttributes[NSAttributedStringKey.init(key)] = value
                    }
                }
                
                textAttributes[NSAttributedStringKey.foregroundColor] = tintColor
                
                setTitleTextAttributes(textAttributes, for: .normal)

            #else

                var textAttributes = [String:Any]()
                
                if let attributes = titleTextAttributes(for: .normal) {
                    textAttributes = attributes
                }
                
                textAttributes[NSForegroundColorAttributeName] = tintColor
                
                setTitleTextAttributes(textAttributes, for: .normal)

            #endif
        }
    }

    /**
     Boolean to know if it's a system item or custom item, we are having a limitation that we cannot override a designated initializer, so we are manually setting this property once in initialization
     */
    @objc var isSystemItem = false
    
//    public override init(barButtonSystemItem systemItem: UIBarButtonSystemItem, target: Any?, action: Selector?) {
//        return super.init(barButtonSystemItem: systemItem, target: target, action: action)
//    }

    /**
     Additional target & action to do get callback action. Note that setting custom target & selector doesn't affect native functionality, this is just an additional target to get a callback.
     
     @param target Target object.
     @param action Target Selector.
     */
    open func setTarget(_ target: AnyObject?, action: Selector?) {
        invocation = (target, action)
    }
    
    /**
     Customized Invocation to be called when button is pressed. invocation is internally created using setTarget:action: method.
     */
    open var invocation : (target: AnyObject?, action: Selector?)?
    
    deinit {

        target = nil
        invocation?.target = nil
        invocation = nil
    }
}
