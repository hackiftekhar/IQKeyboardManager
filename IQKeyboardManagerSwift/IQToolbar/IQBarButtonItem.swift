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

        //Tint color
        self.appearance().tintColor = nil

        //Title
        self.appearance().setTitlePositionAdjustment(UIOffset.zero, for: UIBarMetrics.default)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.normal)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.highlighted)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.disabled)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.selected)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.application)
        self.appearance().setTitleTextAttributes(nil, for: UIControl.State.reserved)

        //Background Image
        self.appearance().setBackgroundImage(nil, for: UIControl.State.normal,      barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.highlighted, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.disabled,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.selected,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.application, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.reserved,    barMetrics: UIBarMetrics.default)
        
        self.appearance().setBackgroundImage(nil, for: UIControl.State.normal,      style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.highlighted, style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.disabled,    style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.selected,    style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.application, style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.reserved,    style: UIBarButtonItem.Style.done, barMetrics: UIBarMetrics.default)
        
        self.appearance().setBackgroundImage(nil, for: UIControl.State.normal,      style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.highlighted, style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.disabled,    style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.selected,    style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.application, style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControl.State.reserved,    style: UIBarButtonItem.Style.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundVerticalPositionAdjustment(0, for: UIBarMetrics.default)

        //Back Button
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.normal,      barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.highlighted, barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.disabled,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.selected,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.application, barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControl.State.reserved,    barMetrics: UIBarMetrics.default)

        self.appearance().setBackButtonTitlePositionAdjustment(UIOffset.zero, for: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundVerticalPositionAdjustment(0, for: UIBarMetrics.default)
    }

    /**
     Boolean to know if it's a system item or custom item, we are having a limitation that we cannot override a designated initializer, so we are manually setting this property once in initialization
     */
    var isSystemItem = false
    
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
    open var invocation : (target: AnyObject?, action: Selector?)
    
}
