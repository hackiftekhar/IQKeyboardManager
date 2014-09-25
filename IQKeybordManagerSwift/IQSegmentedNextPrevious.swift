//
//  IQSegmentedNextPrevious.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

class IQSegmentedNextPrevious: UISegmentedControl {
    
    private var buttonTarget : AnyObject?
    private var previousSelector : Selector?
    private var nextSelector : Selector?
    
    /*!
    @method initWithTarget:previousAction:nextAction:
    
    @abstract initialization function for IQSegmentedNextPrevious.
    
    @param target: Target object for selector. Usually 'self'.
    
    @param previousAction: Previous button action name. Usually 'previousAction:(IQSegmentedNextPrevious*)segmentedControl'.
    
    @param nextAction: Next button action name. Usually 'nextAction:(IQSegmentedNextPrevious*)segmentedControl'.
    */
    
    init(target: AnyObject? ,previousAction: Selector? ,nextAction: Selector?)
    {
        var bundle : NSBundle = NSBundle(path: NSBundle.mainBundle().pathForResource("IQKeyboardManager", ofType: "bundle")!)
        
        var next = bundle.localizedStringForKey("Next", value: "", table: "IQKeyboardManager")
        var previous = bundle.localizedStringForKey("Previous", value: "", table: "IQKeyboardManager")
        
        super.init(items: [previous,next])

        momentary = false
        tintColor = UIColor.blackColor()
        addTarget(self, action: "segmentedControlHandler:", forControlEvents: UIControlEvents.ValueChanged)

        //  Setting target and selectors.
        buttonTarget = target;
        previousSelector = previousAction;
        nextSelector = nextAction;
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func segmentedControlHandler(sender: IQSegmentedNextPrevious) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            var invocation : NSInvocationOperation = NSInvocationOperation(target: buttonTarget!, selector: previousSelector!, object: nil)
            invocation.invocation.target = buttonTarget
            invocation.invocation.selector = previousSelector!
            invocation.invocation.invoke()
        case 1:
            var invocation : NSInvocationOperation = NSInvocationOperation(target: buttonTarget!, selector: nextSelector!, object: nil)
            invocation.invocation.target = buttonTarget
            invocation.invocation.selector = nextSelector!
            invocation.invocation.invoke()
        default:    break;
        }
    }
}
