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

public class IQBarButtonItem: UIBarButtonItem {
   
    override public class func initialize() {

        superclass()?.initialize()
        
        //Tint color
        self.appearance().tintColor = nil

        //Title
        self.appearance().setTitlePositionAdjustment(UIOffset.zero, for: UIBarMetrics.default)
        self.appearance().setTitleTextAttributes(nil, for: UIControlState())
        self.appearance().setTitleTextAttributes(nil, for: UIControlState.highlighted)
        self.appearance().setTitleTextAttributes(nil, for: UIControlState.disabled)
        self.appearance().setTitleTextAttributes(nil, for: UIControlState.selected)
        self.appearance().setTitleTextAttributes(nil, for: UIControlState.application)
        self.appearance().setTitleTextAttributes(nil, for: UIControlState.reserved)

        //Background Image
        self.appearance().setBackgroundImage(nil, for: UIControlState(),      barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.highlighted, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.disabled,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.selected,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.application, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.reserved,    barMetrics: UIBarMetrics.default)
        
        self.appearance().setBackgroundImage(nil, for: UIControlState(),      style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.highlighted, style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.disabled,    style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.selected,    style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.application, style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.reserved,    style: UIBarButtonItemStyle.done, barMetrics: UIBarMetrics.default)
        
        self.appearance().setBackgroundImage(nil, for: UIControlState(),      style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.highlighted, style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.disabled,    style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.selected,    style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.application, style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundImage(nil, for: UIControlState.reserved,    style: UIBarButtonItemStyle.plain, barMetrics: UIBarMetrics.default)
        self.appearance().setBackgroundVerticalPositionAdjustment(0, for: UIBarMetrics.default)

        //Back Button
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState(),      barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState.highlighted, barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState.disabled,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState.selected,    barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState.application, barMetrics: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundImage(nil, for: UIControlState.reserved,    barMetrics: UIBarMetrics.default)

        self.appearance().setBackButtonTitlePositionAdjustment(UIOffset.zero, for: UIBarMetrics.default)
        self.appearance().setBackButtonBackgroundVerticalPositionAdjustment(0, for: UIBarMetrics.default)
    }
}
