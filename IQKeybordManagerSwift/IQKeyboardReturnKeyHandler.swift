//
//  IQKeyboardReturnKeyHandler.swift
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

let kIQTextField                =   "kIQTextField"
let kIQTextFieldDelegate        =   "kIQTextFieldDelegate"
let kIQTextFieldReturnKeyType   =   "kIQTextFieldReturnKeyType"

/*  IQKeyboardReturnKeyHandler class in not yet implemented in swift    */
class IQKeyboardReturnKeyHandler {
   
    /*! @abstract textField's delegates.    */
    var delegate: protocol<UITextFieldDelegate, UITextViewDelegate>?
    
    /*! @abstract It help to choose the lastTextField instance from sibling responderViews. Default is IQAutoToolbarBySubviews. */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /*! @abstract Set the last textfield return key type. Default is UIReturnKeyDefault.    */
    var lastTextFieldReturnKeyType = UIReturnKeyType.Default
    
    
    var textFieldInfoCache : NSMutableSet  = NSMutableSet()

    init() {
    }
    
    /*! @method initWithViewController  */
    init(controller : UIViewController) {
        
        addResponderFromView(controller.view)
    }

    private func textFieldCachedInfo(textField : UITextField) -> Dictionary<String, UITextField>? {

        return nil;
    }

    
    /*! @abstract Should pass UITextField/UITextView intance. Assign textFieldView delegate to self, change it's returnKeyType. */
    func addTextFieldView(textFieldView : UIView) {
        
    }

    /*! @abstract Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType. */
    func removeTextFieldView(textFieldView : UIView) {
        
    }
    
    /*! @abstract Add all the UITextField/UITextView responderView's. */
    func addResponderFromView(textFieldView : UIView) {
        
    }
    
    /*! @abstract Remove all the UITextField/UITextView responderView's. */
    func removeResponderFromView(textFieldView : UIView) {
        
    }
}
