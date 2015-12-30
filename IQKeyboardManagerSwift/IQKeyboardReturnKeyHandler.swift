//
//  IQKeyboardReturnKeyHandler.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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

/**
Manages the return key to work like next/done in a view hierarchy.
*/
public class IQKeyboardReturnKeyHandler: NSObject , UITextFieldDelegate, UITextViewDelegate {
    
    
    ///---------------
    /// MARK: Settings
    ///---------------
    
    /**
    Delegate of textField/textView.
    */
    public var delegate: protocol<UITextFieldDelegate, UITextViewDelegate>?
    
    /**
    Set the last textfield return key type. Default is UIReturnKeyDefault.
    */
    public var lastTextFieldReturnKeyType : UIReturnKeyType = UIReturnKeyType.Default {
        
        didSet {
            
            for infoDict in textFieldInfoCache {
                
                if let view = infoDict[kIQTextField] as? UIView {
                    updateReturnKeyTypeOnTextField(view)
                }
            }
        }
    }
    
    ///--------------------------------------
    /// MARK: Initialization/Deinitialization
    ///--------------------------------------

    public override init() {
        super.init()
    }
    
    /**
    Add all the textFields available in UIViewController's view.
    */
    public init(controller : UIViewController) {
        super.init()
        
        addResponderFromView(controller.view)
    }

    deinit {
        
        for infoDict in textFieldInfoCache {
            
            let view : AnyObject = infoDict[kIQTextField]!!
            
            if let textField = view as? UITextField {
                
                let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as! NSNumber
                textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.integerValue)!
                
                textField.delegate = infoDict[kIQTextFieldDelegate] as! UITextFieldDelegate?
            } else if let textView = view as? UITextView {
                
                textView.returnKeyType = UIReturnKeyType(rawValue: (infoDict[kIQTextFieldReturnKeyType] as! NSNumber).integerValue)!
                
                let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as! NSNumber
                textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.integerValue)!
                
                textView.delegate = infoDict[kIQTextFieldDelegate] as! UITextViewDelegate?
            }
        }
        
        textFieldInfoCache.removeAllObjects()
    }
    

    ///------------------------
    /// MARK: Private variables
    ///------------------------
    private var textFieldInfoCache          =   NSMutableSet()
    private let kIQTextField                =   "kIQTextField"
    private let kIQTextFieldDelegate        =   "kIQTextFieldDelegate"
    private let kIQTextFieldReturnKeyType   =   "kIQTextFieldReturnKeyType"

    
    ///------------------------
    /// MARK: Private Functions
    ///------------------------
    private func textFieldCachedInfo(textField : UIView) -> [String : AnyObject]? {
        
        for infoDict in textFieldInfoCache {
            
            if infoDict[kIQTextField] as! NSObject == textField {
                return infoDict as? [String : AnyObject]
            }
        }
        
        return nil
    }

    private func updateReturnKeyTypeOnTextField(view : UIView)
    {
        var superConsideredView : UIView?
        
        //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for disabledClassString in IQKeyboardManager.sharedManager().consideredToolbarPreviousNextViewClassesString() {
            
            if let disabledClass = NSClassFromString(disabledClassString) {
                
                superConsideredView = view.superviewOfClassType(disabledClass)
                
                if superConsideredView != nil {
                    break
                }
            }
        }

        var textFields : [UIView]?
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch IQKeyboardManager.sharedManager().toolbarManageBehaviour {
                //If needs to sort it by tag
            case .ByTag:        textFields = textFields?.sortedArrayByTag()
                //If needs to sort it by Position
            case .ByPosition:   textFields = textFields?.sortedArrayByPosition()
            default:    break
            }
        }
        
        if let lastView = textFields?.last {
            
            if let textField = view as? UITextField {
                
                //If it's the last textField in responder view, else next
                textField.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
            } else if let textView = view as? UITextView {
                
                //If it's the last textField in responder view, else next
                textView.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
            }
        }
    }
    

    ///----------------------------------------------
    /// MARK: Registering/Unregistering textFieldView
    ///----------------------------------------------

    /**
    Should pass UITextField/UITextView intance. Assign textFieldView delegate to self, change it's returnKeyType.
    
    @param textFieldView UITextField/UITextView object to register.
    */
    public func addTextFieldView(view : UIView) {
        
        var dictInfo : [String : AnyObject] = [String : AnyObject]()
        
        dictInfo[kIQTextField] = view
        
        if let textField = view as? UITextField {
            
            dictInfo[kIQTextFieldReturnKeyType] = textField.returnKeyType.rawValue
            
            if let textFieldDelegate = textField.delegate {
                dictInfo[kIQTextFieldDelegate] = textFieldDelegate
            }
            textField.delegate = self
            
        } else if let textView = view as? UITextView {
            
            dictInfo[kIQTextFieldReturnKeyType] = textView.returnKeyType.rawValue
            
            if let textViewDelegate = textView.delegate {
                dictInfo[kIQTextFieldDelegate] = textViewDelegate
            }
            
            textView.delegate = self
        }
        
        textFieldInfoCache.addObject(dictInfo)
    }
    
    /**
    Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType.
    
    @param textFieldView UITextField/UITextView object to unregister.
    */
    public func removeTextFieldView(view : UIView) {
        
        if let dict : [String : AnyObject] = textFieldCachedInfo(view) {
            
            if let textField = view as? UITextField {
                
                let returnKeyTypeValue = dict[kIQTextFieldReturnKeyType] as! NSNumber
                textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.integerValue)!
                
                textField.delegate = dict[kIQTextFieldDelegate] as! UITextFieldDelegate?
            } else if let textView = view as? UITextView {
                
                let returnKeyTypeValue = dict[kIQTextFieldReturnKeyType] as! NSNumber
                textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.integerValue)!
                
                textView.delegate = dict[kIQTextFieldDelegate] as! UITextViewDelegate?
            }
            
            textFieldInfoCache.removeObject(dict)
        }
    }
    
    /**
    Add all the UITextField/UITextView responderView's.
    
    @param UIView object to register all it's responder subviews.
    */
    public func addResponderFromView(view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields {
            
            addTextFieldView(textField)
        }
    }
    
    /**
    Remove all the UITextField/UITextView responderView's.
    
    @param UIView object to unregister all it's responder subviews.
    */
    public func removeResponderFromView(view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields {
            
            removeTextFieldView(textField)
        }
    }
    
    private func goToNextResponderOrResign(view : UIView) {
        
        var superConsideredView : UIView?
        
        //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for disabledClassString in IQKeyboardManager.sharedManager().consideredToolbarPreviousNextViewClassesString() {
            
            if let disabledClass = NSClassFromString(disabledClassString) {
                
                superConsideredView = view.superviewOfClassType(disabledClass)
                
                if superConsideredView != nil {
                    break
                }
            }
        }
        
        var textFields : [UIView]?
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch IQKeyboardManager.sharedManager().toolbarManageBehaviour {
                //If needs to sort it by tag
            case .ByTag:        textFields = textFields?.sortedArrayByTag()
                //If needs to sort it by Position
            case .ByPosition:   textFields = textFields?.sortedArrayByPosition()
            default:
                break
            }
        }

        if let unwrappedTextFields = textFields {
            
            //Getting index of current textField.
            if let index = unwrappedTextFields.indexOf(view) {
                //If it is not last textField. then it's next object becomeFirstResponder.
                if index < (unwrappedTextFields.count - 1) {
                    
                    let nextTextField = unwrappedTextFields[index+1]
                    nextTextField.becomeFirstResponder()
                } else {
                    
                    view.resignFirstResponder()
                }
            }
        }
    }
    

    ///----------------------------------------------
    /// MARK: UITextField/UITextView delegates
    ///----------------------------------------------
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldBeginEditing:") != nil {
            return (delegate?.textFieldShouldBeginEditing?(textField) == true)
        } else {
            return true
        }
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldEndEditing:") != nil {
            return (delegate?.textFieldShouldEndEditing?(textField) == true)
        } else {
            return true
        }
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        updateReturnKeyTypeOnTextField(textField)
        
        delegate?.textFieldShouldBeginEditing?(textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if delegate?.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:") != nil {
            return (delegate?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) == true)
        } else {
            return true
        }
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldClear:") != nil {
            return (delegate?.textFieldShouldClear?(textField) == true)
        } else {
            return true
        }
    }
    
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        var shouldReturn = true
        
        if delegate?.respondsToSelector("textFieldShouldReturn:") != nil {
            shouldReturn = (delegate?.textFieldShouldReturn?(textField) == true)
        }
        
        if shouldReturn == true {
            goToNextResponderOrResign(textField)
        }
        
        return shouldReturn
    }
    
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if delegate?.respondsToSelector("textViewShouldBeginEditing:") != nil {
            return (delegate?.textViewShouldBeginEditing?(textView) == true)
        } else {
            return true
        }
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if delegate?.respondsToSelector("textViewShouldEndEditing:") != nil {
            return (delegate?.textViewShouldEndEditing?(textView) == true)
        } else {
            return true
        }
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        updateReturnKeyTypeOnTextField(textView)
        
        delegate?.textViewDidBeginEditing?(textView)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        
        delegate?.textViewDidEndEditing?(textView)
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var shouldReturn = true
        
        if delegate?.respondsToSelector("textView:shouldChangeCharactersInRange:replacementString:") != nil {
            shouldReturn = ((delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text)) == true)
        }
        
        if shouldReturn == true && text == "\n" {
            goToNextResponderOrResign(textView)
        }
        
        
        return shouldReturn
    }
    
    public func textViewDidChange(textView: UITextView) {
        
        delegate?.textViewDidChange?(textView)
    }
    
    public func textViewDidChangeSelection(textView: UITextView) {
        
        delegate?.textViewDidChangeSelection?(textView)
    }
    
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        if delegate?.respondsToSelector("textView:shouldInteractWithURL:inRange:") != nil {
            return ((delegate?.textView?(textView, shouldInteractWithURL: URL, inRange: characterRange)) == true)
        } else {
            return true
        }
        
    }
    
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        
        if delegate?.respondsToSelector("textView:shouldInteractWithTextAttachment:inRange:") != nil {
            return ((delegate?.textView?(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange)) == true)
        } else {
            return true
        }
    }
}
