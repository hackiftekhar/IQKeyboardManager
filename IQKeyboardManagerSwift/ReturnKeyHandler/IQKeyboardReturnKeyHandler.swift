//
//  IQKeyboardReturnKeyHandler.swift
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public final class IQKeyboardReturnKeyHandler: NSObject {

    // MARK: Settings

    /**
    Delegate of textField/textView.
    */
    @objc public weak var delegate: (UITextFieldDelegate & UITextViewDelegate)?

    /**
    Set the last textfield return key type. Default is UIReturnKeyDefault.
    */
    @objc public var lastTextFieldReturnKeyType: UIReturnKeyType = UIReturnKeyType.default {

        didSet {
            for model in textFieldInfoCache {
                if let view: UIView = model.textFieldView {
                    updateReturnKeyTypeOnTextField(view)
                }
            }
        }
    }

    // MARK: Initialization/De-initialization

    @objc public override init() {
        super.init()
    }

    /**
    Add all the textFields available in UIViewController's view.
    */
    @objc public init(controller: UIViewController) {
        super.init()

        addResponderFromView(controller.view)
    }

    deinit {

//        for model in textFieldInfoCache {
//            model.restore()
//        }

        textFieldInfoCache.removeAll()
    }

    // MARK: Private variables
    private var textFieldInfoCache: [IQTextFieldViewInfoModel] = []

    // MARK: Private Functions
    internal func textFieldViewCachedInfo(_ textField: UIView) -> IQTextFieldViewInfoModel? {

        for model in textFieldInfoCache {

            if let view: UIView = model.textFieldView {
                if view == textField {
                    return model
                }
            }
        }

        return nil
    }

    internal func updateReturnKeyTypeOnTextField(_ view: UIView) {
        var superConsideredView: UIView?

        // If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for allowedClasse in IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses {

            superConsideredView = view.iq.superviewOf(type: allowedClasse)

            if superConsideredView != nil {
                break
            }
        }

        var textFields: [UIView] = []

        // If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView: UIView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.iq.deepResponderViews()
        } else {  // Otherwise fetching all the siblings

            textFields = view.iq.responderSiblings()

            // Sorting textFields according to behavior
            switch IQKeyboardManager.shared.toolbarConfiguration.manageBehavior {
                // If needs to sort it by tag
            case .byTag:        textFields = textFields.sortedByTag()
                // If needs to sort it by Position
            case .byPosition:   textFields = textFields.sortedByPosition()
            default:    break
            }
        }

        if let lastView: UIView = textFields.last {

            if let textField: UITextField = view as? UITextField {

                // If it's the last textField in responder view, else next
                textField.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType: UIReturnKeyType.next
            } else if let textView: UITextView = view as? UITextView {

                // If it's the last textField in responder view, else next
                textView.returnKeyType = (view == lastView)    ?   lastTextFieldReturnKeyType: UIReturnKeyType.next
            }
        }
    }

    // MARK: Registering/Unregistering textFieldView

    /**
    Should pass UITextField/UITextView instance. Assign textFieldView delegate to self, change it's returnKeyType.

    @param view UITextField/UITextView object to register.
    */
    @objc public func addTextFieldView(_ view: UIView) {

        if let textField: UITextField = view as? UITextField {
            let model = IQTextFieldViewInfoModel(textField: textField)
            textFieldInfoCache.append(model)
            textField.delegate = self

        } else if let textView: UITextView = view as? UITextView {
            let model = IQTextFieldViewInfoModel(textView: textView)
            textFieldInfoCache.append(model)
            textView.delegate = self
        }
    }

    /**
    Should pass UITextField/UITextView instance. Restore it's textFieldView delegate and it's returnKeyType.
    
    @param view UITextField/UITextView object to unregister.
    */
    @objc public func removeTextFieldView(_ view: UIView) {

        if let model: IQTextFieldViewInfoModel = textFieldViewCachedInfo(view) {
            model.restore()

            if let index: Int = textFieldInfoCache.firstIndex(where: { $0.textFieldView == view}) {
                textFieldInfoCache.remove(at: index)
            }
        }
    }

    /**
    Add all the UITextField/UITextView responderView's.
    
    @param view UIView object to register all it's responder subviews.
    */
    @objc public func addResponderFromView(_ view: UIView) {

        let textFields: [UIView] = view.iq.deepResponderViews()

        for textField in textFields {

            addTextFieldView(textField)
        }
    }

    /**
    Remove all the UITextField/UITextView responderView's.
    
    @param view UIView object to unregister all it's responder subviews.
    */
    @objc public func removeResponderFromView(_ view: UIView) {

        let textFields: [UIView] = view.iq.deepResponderViews()

        for textField in textFields {

            removeTextFieldView(textField)
        }
    }

    @discardableResult
    internal func goToNextResponderOrResign(_ view: UIView) -> Bool {

        var superConsideredView: UIView?

        // If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
        for allowedClass in IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses {

            superConsideredView = view.iq.superviewOf(type: allowedClass)

            if superConsideredView != nil {
                break
            }
        }

        var textFields: [UIView] = []

        // If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
        if let unwrappedTableView: UIView = superConsideredView {     //   (Enhancement ID: #22)
            textFields = unwrappedTableView.iq.deepResponderViews()
        } else {  // Otherwise fetching all the siblings

            textFields = view.iq.responderSiblings()

            // Sorting textFields according to behavior
            switch IQKeyboardManager.shared.toolbarConfiguration.manageBehavior {
                // If needs to sort it by tag
            case .byTag:        textFields = textFields.sortedByTag()
                // If needs to sort it by Position
            case .byPosition:   textFields = textFields.sortedByPosition()
            default:
                break
            }
        }

        //  Getting index of current textField.
        if let index: Int = textFields.firstIndex(of: view) {
            //  If it is not last textField. then it's next object becomeFirstResponder.
            if index < (textFields.count - 1) {

                let nextTextField: UIView = textFields[index+1]
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
}
