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

/*  @abstract   Manages the return key to work like next/done in a view hierarchy.    */
class IQKeyboardReturnKeyHandler: NSObject , UITextFieldDelegate, UITextViewDelegate {
   
    /** @abstract textField/textView delegate.    */
    var delegate: protocol<UITextFieldDelegate, UITextViewDelegate>?
    
    /** @abstract It help to choose the lastTextField instance from sibling responderViews. Default is IQAutoToolbarBySubviews. */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.BySubviews

    /** @abstract Set the last textfield return key type. Default is UIReturnKeyDefault.    */
    var lastTextFieldReturnKeyType : UIReturnKeyType = UIReturnKeyType.Default {
        
        didSet {
            
            for infoDict in textFieldInfoCache {
                
                if let view = infoDict[kIQTextField] as? UIView {
                    updateReturnKeyTypeOnTextField(view)
                }
            }
        }
    }
    
    private var textFieldInfoCache  = NSMutableSet()

    private let kIQTextField                =   "kIQTextField"
    private let kIQTextFieldDelegate        =   "kIQTextFieldDelegate"
    private let kIQTextFieldReturnKeyType   =   "kIQTextFieldReturnKeyType"

    override init() {
        super.init()
    }
    
    /** @method Add all the textFields available in UIViewController's view.  */
    init(controller : UIViewController) {
        super.init()

        addResponderFromView(controller.view)
    }

    private func textFieldCachedInfo(textField : UIView) -> [String : AnyObject]? {

        for infoDict in textFieldInfoCache {

            if infoDict[kIQTextField] as NSObject == textField {
                return infoDict as? [String : AnyObject]
            }
        }
        
        return nil
    }
    
    /** @abstract Should pass UITextField/UITextView intance. Assign textFieldView delegate to self, change it's returnKeyType. */
    func addTextFieldView(view : UIView) {
        
        var dictInfo : [String : AnyObject] = [String : AnyObject]()
        
        dictInfo[kIQTextField] = view
        
        if let textField = view as? UITextField {

            /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
            http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
            #if IQ_IS_XCODE_BELOW_6_1
                dictInfo[kIQTextFieldReturnKeyType] = textField.returnKeyType.toRaw()
                #else
                dictInfo[kIQTextFieldReturnKeyType] = textField.returnKeyType.rawValue;
            #endif
            
            if let textFieldDelegate = textField.delegate {
                dictInfo[kIQTextFieldDelegate] = textFieldDelegate
            }
            textField.delegate = self

        } else if let textView = view as? UITextView {

            /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
            http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
            #if IQ_IS_XCODE_BELOW_6_1
                dictInfo[kIQTextFieldReturnKeyType] = textView.returnKeyType.toRaw()
                #else
                dictInfo[kIQTextFieldReturnKeyType] = textView.returnKeyType.rawValue;
            #endif

            if let textViewDelegate = textView.delegate {
                dictInfo[kIQTextFieldDelegate] = textViewDelegate
            }

            textView.delegate = self
        }

        textFieldInfoCache.addObject(dictInfo)
    }

    /** @abstract Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType. */
    func removeTextFieldView(view : UIView) {
        
        if let dict : [String : AnyObject] = textFieldCachedInfo(view) {
            
            if let textField = view as? UITextField {
                
                /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_BELOW_6_1
                    textField.returnKeyType = UIReturnKeyType.fromRaw((dict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                    #else
                    let returnKeyTypeValue = dict[kIQTextFieldReturnKeyType] as NSNumber
                    textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                #endif
                
                textField.delegate = dict[kIQTextFieldDelegate] as UITextFieldDelegate?
            } else if let textView = view as? UITextView {
                
                /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_BELOW_6_1
                    textView.returnKeyType = UIReturnKeyType.fromRaw((dict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                    #else
                    let returnKeyTypeValue = dict[kIQTextFieldReturnKeyType] as NSNumber
                    textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                #endif

                textView.delegate = dict[kIQTextFieldDelegate] as UITextViewDelegate?
            }
            
            textFieldInfoCache.removeObject(view)
        }
    }
    
    /** @abstract Add all the UITextField/UITextView responderView's. */
    func addResponderFromView(view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields as [UIView] {

            addTextFieldView(textField)
        }
    }
    
    /** @abstract Remove all the UITextField/UITextView responderView's. */
    func removeResponderFromView(view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields as [UIView] {
            
            removeTextFieldView(textField)
        }
    }
    
    func updateReturnKeyTypeOnTextField(view : UIView)
    {
        var tableView : UIView? = view.superTableView()
        if tableView == nil {
            tableView = tableView?.superCollectionView()
        }
        
        var textFields : NSArray?
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = tableView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch toolbarManageBehaviour {
                //If needs to sort it by tag
            case .ByTag:        textFields = textFields?.sortedArrayByTag()
                //If needs to sort it by Position
            case .ByPosition:   textFields = textFields?.sortedArrayByPosition()
            default:
                break
            }
        }
    
        if let lastView = textFields?.lastObject as? UIView {
            
            if let textField = view as? UITextField {
                
                //If it's the last textField in responder view, else next
                textField.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
            } else if let textView = view as? UITextView {
                
                //If it's the last textField in responder view, else next
                textView.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.Next
            }
        }
    }
    
    func goToNextResponderOrResign(view : UIView) {
        
        var tableView : UIView? = view.superTableView()
        if tableView == nil {
            tableView = tableView?.superCollectionView()
        }
        
        var textFields : NSArray?
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = tableView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch toolbarManageBehaviour {
                //If needs to sort it by tag
            case .ByTag:        textFields = textFields?.sortedArrayByTag()
                //If needs to sort it by Position
            case .ByPosition:   textFields = textFields?.sortedArrayByPosition()
            default:
                break
            }
        }

        if let unwrappedTextFields = textFields {
            
            if unwrappedTextFields.containsObject(view) == true {
                //Getting index of current textField.
                let index = unwrappedTextFields.indexOfObject(view)
                
                //If it is not last textField. then it's next object becomeFirstResponder.
                if index < (unwrappedTextFields.count - 1) {
                    
                    let nextTextField = unwrappedTextFields[index+1] as UIView
                    
                    //  Retaining textFieldView
                    let  textFieldRetain = view
                    
                    let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                    
                    //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                    if isAcceptAsFirstResponder == false {
                        //If next field refuses to become first responder then restoring old textField as first responder.
                        textFieldRetain.becomeFirstResponder()
                        println("IQKeyboardManager: Refuses to become first responder: \(nextTextField)")
                    }
                } else {
                    //  Retaining textFieldView
                    let  textFieldRetain = view
                    
                    let isResignAsFirstResponder = view.resignFirstResponder()
                    //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                    if isResignAsFirstResponder == false {
                        //If next field refuses to become first responder then restoring old textField as first responder.
                        textFieldRetain.becomeFirstResponder()
                        println("IQKeyboardManager: Refuses to become first responder: \(textFieldRetain)")
                    }
                }
            }
        }
    }
    
    deinit {
        
        for infoDict in textFieldInfoCache {
            
            let view : AnyObject = infoDict[kIQTextField]!!
            
            if let textField = view as? UITextField {
                
                /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_BELOW_6_1
                    textField.returnKeyType = UIReturnKeyType.fromRaw((infoDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                    #else
                    let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as NSNumber
                    textField.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                #endif
                
                textField.delegate = infoDict[kIQTextFieldDelegate] as UITextFieldDelegate?
            } else if let textView = view as? UITextView {
                
                /* If you are running below Xcode 6.1 then please add `-DIQ_IS_XCODE_BELOW_6_1` flag in 'other swift flag' to fix compiler errors.
                http://stackoverflow.com/questions/24369272/swift-ios-deployment-target-command-line-flag   */
                #if IQ_IS_XCODE_BELOW_6_1
                    textView.returnKeyType = UIReturnKeyType.fromRaw((infoDict[kIQTextFieldReturnKeyType] as NSNumber).integerValue)!
                    #else
                    let returnKeyTypeValue = infoDict[kIQTextFieldReturnKeyType] as NSNumber
                    textView.returnKeyType = UIReturnKeyType(rawValue: returnKeyTypeValue.unsignedIntegerValue)!
                #endif

                textView.delegate = infoDict[kIQTextFieldDelegate] as UITextViewDelegate?
            }
        }
        
        textFieldInfoCache.removeAllObjects()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldBeginEditing:") != nil {
            return (delegate?.textFieldShouldBeginEditing?(textField) == true)
        } else {
            return true
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldEndEditing:") != nil {
            return (delegate?.textFieldShouldEndEditing?(textField) == true)
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        updateReturnKeyTypeOnTextField(textField)
        
        delegate?.textFieldShouldBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if delegate?.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:") != nil {
            return (delegate?.textField?(textField, shouldChangeCharactersInRange: range, replacementString: string) == true)
        } else {
            return true
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if delegate?.respondsToSelector("textFieldShouldClear:") != nil {
            return (delegate?.textFieldShouldClear?(textField) == true)
        } else {
            return true
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        var shouldReturn = true
        
        if delegate?.respondsToSelector("textFieldShouldReturn:") != nil {
            shouldReturn = (delegate?.textFieldShouldReturn?(textField) == true)
        }
        
        if shouldReturn == true {
            goToNextResponderOrResign(textField)
        }
        
        return shouldReturn
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if delegate?.respondsToSelector("textViewShouldBeginEditing:") != nil {
            return (delegate?.textViewShouldBeginEditing?(textView) == true)
        } else {
            return true
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if delegate?.respondsToSelector("textViewShouldEndEditing:") != nil {
            return (delegate?.textViewShouldEndEditing?(textView) == true)
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        updateReturnKeyTypeOnTextField(textView)
        
        delegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        delegate?.textViewDidEndEditing?(textView)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        var shouldReturn = true
        
        if delegate?.respondsToSelector("textView:shouldChangeCharactersInRange:replacementString:") != nil {
            shouldReturn = ((delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text)) == true)
        }
        
        if shouldReturn == true && text == "\n" {
            goToNextResponderOrResign(textView)
        }

        
        return shouldReturn
    }

    func textViewDidChange(textView: UITextView) {
        
        delegate?.textViewDidChange?(textView)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        delegate?.textViewDidChangeSelection?(textView)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        if delegate?.respondsToSelector("textView:shouldInteractWithURL:inRange:") != nil {
            return ((delegate?.textView?(textView, shouldInteractWithURL: URL, inRange: characterRange)) == true)
        } else {
            return true
        }

    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        
        if delegate?.respondsToSelector("textView:shouldInteractWithTextAttachment:inRange:") != nil {
            return ((delegate?.textView?(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange)) == true)
        } else {
            return true
        }
    }
}
