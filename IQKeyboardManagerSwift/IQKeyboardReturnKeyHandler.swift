//
//  IQKeyboardReturnKeyHandler.swift
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


import Foundation
import UIKit

fileprivate class IQTextFieldViewInfoModal : NSObject {

    open weak var textFieldDelegate: UITextFieldDelegate?
    open weak var textViewDelegate: UITextViewDelegate?
    open weak var textFieldView: UIView?
    open var originalReturnKeyType = UIReturnKeyType.default
    
    init(textFieldView : UIView?, textFieldDelegate : UITextFieldDelegate?, textViewDelegate : UITextViewDelegate?, originalReturnKeyType : UIReturnKeyType = .default) {
        self.textFieldView = textFieldView
        self.textFieldDelegate = textFieldDelegate
        self.textViewDelegate = textViewDelegate
        self.originalReturnKeyType = originalReturnKeyType
    }
}

/**
Manages the return key to work like next/done in a view hierarchy.
*/
open class IQKeyboardReturnKeyHandler: NSObject , UITextFieldDelegate, UITextViewDelegate {
    
    
    ///---------------
    /// MARK: Settings
    ///---------------
    
    /**
    Delegate of textField/textView.
    */
    open weak var delegate: (UITextFieldDelegate & UITextViewDelegate)?
    
    /**
    Set the last textfield return key type. Default is UIReturnKeyDefault.
    */
    open var lastTextFieldReturnKeyType : UIReturnKeyType = UIReturnKeyType.default {
        
        didSet {
            
            for modal in textFieldInfoCache {
                
                if let view = modal.textFieldView {
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
        
        for modal in textFieldInfoCache {
            
            if let textField = modal.textFieldView as? UITextField {
                textField.returnKeyType = modal.originalReturnKeyType
                
                textField.delegate = modal.textFieldDelegate

            } else if let textView = modal.textFieldView as? UITextView {

                textView.returnKeyType = modal.originalReturnKeyType

                textView.delegate = modal.textViewDelegate
            }
        }
        
        textFieldInfoCache.removeAll()
    }
    

    ///------------------------
    /// MARK: Private variables
    ///------------------------
    private var textFieldInfoCache          =   [IQTextFieldViewInfoModal]()
    
    ///------------------------
    /// MARK: Private Functions
    ///------------------------
    private func textFieldViewCachedInfo(_ textField : UIView) -> IQTextFieldViewInfoModal? {
        
        for modal in textFieldInfoCache {
            
            if let view = modal.textFieldView {

                if view == textField {
                    return modal
                }
            }
        }
        
        return nil
    }

    private func updateReturnKeyTypeOnTextField(_ view : UIView)
    {
        var superConsideredView : UIView?
        
        //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for disabledClass in IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses {
            
            superConsideredView = view.superviewOfClassType(disabledClass)
            
            if superConsideredView != nil {
                break
            }
        }

        var textFields = [UIView]()
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch IQKeyboardManager.shared.toolbarManageBehaviour {
                //If needs to sort it by tag
            case .byTag:        textFields = textFields.sortedArrayByTag()
                //If needs to sort it by Position
            case .byPosition:   textFields = textFields.sortedArrayByPosition()
            default:    break
            }
        }
        
        if let lastView = textFields.last {
            
            if let textField = view as? UITextField {
                
                //If it's the last textField in responder view, else next
                textField.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.next
            } else if let textView = view as? UITextView {
                
                //If it's the last textField in responder view, else next
                textView.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType : UIReturnKeyType.next
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
    open func addTextFieldView(_ view : UIView) {
        
        let modal = IQTextFieldViewInfoModal(textFieldView: view, textFieldDelegate: nil, textViewDelegate: nil)
        
        if let textField = view as? UITextField {
            
            modal.originalReturnKeyType = textField.returnKeyType
            modal.textFieldDelegate = textField.delegate
            textField.delegate = self
            
        } else if let textView = view as? UITextView {

            modal.originalReturnKeyType = textView.returnKeyType
            modal.textViewDelegate = textView.delegate
            textView.delegate = self
        }
        
        textFieldInfoCache.append(modal)
    }
    
    /**
    Should pass UITextField/UITextView intance. Restore it's textFieldView delegate and it's returnKeyType.
    
    @param textFieldView UITextField/UITextView object to unregister.
    */
    open func removeTextFieldView(_ view : UIView) {
        
        if let modal = textFieldViewCachedInfo(view) {
            
            if let textField = view as? UITextField {

                textField.returnKeyType = modal.originalReturnKeyType
                textField.delegate = modal.textFieldDelegate
            } else if let textView = view as? UITextView {

                textView.returnKeyType = modal.originalReturnKeyType
                textView.delegate = modal.textViewDelegate
            }
            
            if let index = textFieldInfoCache.index(where: { $0.textFieldView == view}) {

                textFieldInfoCache.remove(at: index)
            }
        }
    }
    
    /**
    Add all the UITextField/UITextView responderView's.
    
    @param UIView object to register all it's responder subviews.
    */
    open func addResponderFromView(_ view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields {
            
            addTextFieldView(textField)
        }
    }
    
    /**
    Remove all the UITextField/UITextView responderView's.
    
    @param UIView object to unregister all it's responder subviews.
    */
    open func removeResponderFromView(_ view : UIView) {
        
        let textFields = view.deepResponderViews()
        
        for textField in textFields {
            
            removeTextFieldView(textField)
        }
    }
    
    @discardableResult private func goToNextResponderOrResign(_ view : UIView) -> Bool {
        
        var superConsideredView : UIView?
        
        //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for disabledClass in IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses {
            
            superConsideredView = view.superviewOfClassType(disabledClass)
            
            if superConsideredView != nil {
                break
            }
        }
        
        var textFields = [UIView]()
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            textFields = view.responderSiblings()
            
            //Sorting textFields according to behaviour
            switch IQKeyboardManager.shared.toolbarManageBehaviour {
                //If needs to sort it by tag
            case .byTag:        textFields = textFields.sortedArrayByTag()
                //If needs to sort it by Position
            case .byPosition:   textFields = textFields.sortedArrayByPosition()
            default:
                break
            }
        }

        //Getting index of current textField.
        if let index = textFields.index(of: view) {
            //If it is not last textField. then it's next object becomeFirstResponder.
            if index < (textFields.count - 1) {
                
                let nextTextField = textFields[index+1]
                nextTextField.becomeFirstResponder()
                return false
            } else {
                
                view.resignFirstResponder()
                return true
            }
        } else {
            return true
        }
    }
    

    ///----------------------------------------------
    /// MARK: UITextField/UITextView delegates
    ///----------------------------------------------
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector(UITextFieldDelegate.textFieldShouldBeginEditing(_:))) {
                    return unwrapDelegate.textFieldShouldBeginEditing?(textField) == true
                }
            }
        }
        
        return true
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:))) {
                    return unwrapDelegate.textFieldShouldEndEditing?(textField) == true
                }
            }
        }
        
        return true
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        updateReturnKeyTypeOnTextField(textField)
        
        var aDelegate : UITextFieldDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textField) {
                aDelegate = modal.textFieldDelegate
            }
        }
        
        aDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
        var aDelegate : UITextFieldDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textField) {
                aDelegate = modal.textFieldDelegate
            }
        }
        
        aDelegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    open func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {

        var aDelegate : UITextFieldDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textField) {
                aDelegate = modal.textFieldDelegate
            }
        }
        
        aDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector(UITextFieldDelegate.textField(_:shouldChangeCharactersIn:replacementString:))) {
                    return unwrapDelegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) == true
                }
            }
        }
        return true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector(UITextFieldDelegate.textFieldShouldClear(_:))) {
                    return unwrapDelegate.textFieldShouldClear?(textField) == true
                }
            }
        }

        return true
    }
    
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        var shouldReturn = true

        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textField)?.textFieldDelegate {
                if unwrapDelegate.responds(to: #selector(UITextFieldDelegate.textFieldShouldReturn(_:))) {
                    shouldReturn = unwrapDelegate.textFieldShouldReturn?(textField) == true
                }
            }
        }

        if shouldReturn == true {
            goToNextResponderOrResign(textField)
            return true
        } else {
            return goToNextResponderOrResign(textField)
        }
    }
    
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(UITextViewDelegate.textViewShouldBeginEditing(_:))) {
                    return unwrapDelegate.textViewShouldBeginEditing?(textView) == true
                }
            }
        }
        
        return true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(UITextViewDelegate.textViewShouldEndEditing(_:))) {
                    return unwrapDelegate.textViewShouldEndEditing?(textView) == true
                }
            }
        }
        
        return true
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        updateReturnKeyTypeOnTextField(textView)
        
        var aDelegate : UITextViewDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textView) {
                aDelegate = modal.textViewDelegate
            }
        }
        
        aDelegate?.textViewDidBeginEditing?(textView)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        
        var aDelegate : UITextViewDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textView) {
                aDelegate = modal.textViewDelegate
            }
        }
        
        aDelegate?.textViewDidEndEditing?(textView)
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var shouldReturn = true
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(textView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(UITextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))) {
                    shouldReturn = (unwrapDelegate.textView?(textView, shouldChangeTextIn: range, replacementText: text)) == true
                }
            }
        }
        
        if shouldReturn == true && text == "\n" {
            shouldReturn = goToNextResponderOrResign(textView)
        }
        
        return shouldReturn
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        
        var aDelegate : UITextViewDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textView) {
                aDelegate = modal.textViewDelegate
            }
        }
        
        aDelegate?.textViewDidChange?(textView)
    }
    
    open func textViewDidChangeSelection(_ textView: UITextView) {
        
        var aDelegate : UITextViewDelegate? = delegate
        
        if aDelegate == nil {
            
            if let modal = textFieldViewCachedInfo(textView) {
                aDelegate = modal.textViewDelegate
            }
        }
        
        aDelegate?.textViewDidChangeSelection?(textView)
    }
    
    @available(iOS 10.0, *)
    open func textView(_ aTextView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, URL, NSRange, UITextItemInteraction) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView, shouldInteractWith: URL, in: characterRange, interaction: interaction) == true
                }
            }
        }
        
        return true
    }
    
    @available(iOS 10.0, *)
    open func textView(_ aTextView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, NSTextAttachment, NSRange, UITextItemInteraction) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) == true
                }
            }
        }
        
        return true
    }
    
    @available(iOS, deprecated: 10.0)
    open func textView(_ aTextView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, URL, NSRange) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView, shouldInteractWith: URL, in: characterRange) == true
                }
            }
        }
        
        return true
    }
    
    @available(iOS, deprecated: 10.0)
    open func textView(_ aTextView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        
        if delegate == nil {
            
            if let unwrapDelegate = textFieldViewCachedInfo(aTextView)?.textViewDelegate {
                if unwrapDelegate.responds(to: #selector(textView as (UITextView, NSTextAttachment, NSRange) -> Bool)) {
                    return unwrapDelegate.textView?(aTextView, shouldInteractWith: textAttachment, in: characterRange) == true
                }
            }
        }
        
        return true
    }
}
