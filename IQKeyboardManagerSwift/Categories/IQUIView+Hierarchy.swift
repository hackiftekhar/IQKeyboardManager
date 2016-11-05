//
//  IQUIView+Hierarchy.swift
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

private var kIQIsAskingCanBecomeFirstResponder = "kIQIsAskingCanBecomeFirstResponder"

/**
UIView hierarchy category.
*/
public extension UIView {
    
    ///------------------------------
    /// MARK: canBecomeFirstResponder
    ///------------------------------
    
    /**
    Returns YES if IQKeyboardManager asking for `canBecomeFirstResponder. Useful when doing custom work in `textFieldShouldBeginEditing:` delegate.
    */
    public var isAskingCanBecomeFirstResponder: Bool {
        
        if let aValue = objc_getAssociatedObject(self, &kIQIsAskingCanBecomeFirstResponder) as? Bool {
            return aValue
        } else {
            return false
        }
    }

    ///----------------------
    /// MARK: viewControllers
    ///----------------------

    /**
    Returns the UIViewController object that manages the receiver.
    */
    public func viewController()->UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
    
    /**
    Returns the topMost UIViewController object in hierarchy.
    */
    public func topMostController()->UIViewController? {
        
        var controllersHierarchy = [UIViewController]()

        if var topController = window?.rootViewController {
            controllersHierarchy.append(topController)

            while topController.presentedViewController != nil {
                
                topController = topController.presentedViewController!

                controllersHierarchy.append(topController)
            }
            
            var matchController :UIResponder? = viewController()

            while matchController != nil && controllersHierarchy.contains(matchController as! UIViewController) == false {
                
                repeat {
                    matchController = matchController?.next

                } while matchController != nil && matchController is UIViewController == false
            }
            
            return matchController as? UIViewController
            
        } else {
            return viewController()
        }
    }
    
    
    ///-----------------------------------
    /// MARK: Superviews/Subviews/Siglings
    ///-----------------------------------
    
    /**
    Returns the superView of provided class type.
    */
    public func superviewOfClassType(_ classType:UIView.Type)->UIView? {

        struct InternalClass {
            
            static var UITableViewCellScrollViewClass: UIScrollView.Type?   =   NSClassFromString("UITableViewCellScrollView") as? UIScrollView.Type //UITableViewCell
            static var UITableViewWrapperViewClass: UIView.Type?      =   NSClassFromString("UITableViewWrapperView") as? UIView.Type //UITableViewCell
            static var UIQueuingScrollViewClass: UIScrollView.Type?         =   NSClassFromString("_UIQueuingScrollView") as? UIScrollView.Type //UIPageViewController
        }

        var superView = superview
        
        while let unwrappedSuperView = superView {
            
            if unwrappedSuperView.isKind(of: classType) &&
                ((InternalClass.UITableViewCellScrollViewClass == nil || unwrappedSuperView.isKind(of: InternalClass.UITableViewCellScrollViewClass!) == false) &&
                    (InternalClass.UITableViewWrapperViewClass == nil || unwrappedSuperView.isKind(of: InternalClass.UITableViewWrapperViewClass!) == false) &&
                    (InternalClass.UIQueuingScrollViewClass == nil || unwrappedSuperView.isKind(of: InternalClass.UIQueuingScrollViewClass!) == false)) {
                        return superView
            } else {
                
                superView = unwrappedSuperView.superview
            }
        }
        
        return nil
    }

    /**
    Returns all siblings of the receiver which canBecomeFirstResponder.
    */
    public func responderSiblings()->[UIView] {

        //Array of (UITextField/UITextView's).
        var tempTextFields = [UIView]()

        //	Getting all siblings
        if let siblings = superview?.subviews {
            
            for textField in siblings {
                
                if textField._IQcanBecomeFirstResponder() == true {
                    tempTextFields.append(textField)
                }
            }
        }

        return tempTextFields
    }
    
    /**
    Returns all deep subViews of the receiver which canBecomeFirstResponder.
    */
    public func deepResponderViews()->[UIView] {
        
        //Array of (UITextField/UITextView's).
        var textfields = [UIView]()
        
        for textField in subviews {
            
            if textField._IQcanBecomeFirstResponder() == true {
                textfields.append(textField)
            }

            //Sometimes there are hidden or disabled views and textField inside them still recorded, so we added some more validations here (Bug ID: #458)
            //Uncommented else (Bug ID: #625)
            if textField.subviews.count != 0  && isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 {
                for deepView in textField.deepResponderViews() {
                    textfields.append(deepView)
                }
            }
        }
        
        //subviews are returning in opposite order. Sorting according the frames 'y'.
        return textfields.sorted(by: { (view1 : UIView, view2 : UIView) -> Bool in
            
            let frame1 = view1.convert(view1.bounds, to: self)
            let frame2 = view2.convert(view2.bounds, to: self)

            let x1 = frame1.minX
            let y1 = frame1.minY
            let x2 = frame2.minX
            let y2 = frame2.minY
            
            if y1 != y2 {
                return y1 < y2
            } else {
                return x1 < x2
            }
        })
    }
    
    fileprivate func _IQcanBecomeFirstResponder() -> Bool {
        
        objc_setAssociatedObject(self, &kIQIsAskingCanBecomeFirstResponder, true, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        var _IQcanBecomeFirstResponder = (canBecomeFirstResponder == true && isUserInteractionEnabled == true && isHidden == false && alpha != 0.0 && isAlertViewTextField() == false && isSearchBarTextField() == false) as Bool

        if _IQcanBecomeFirstResponder == true {
            //  Setting toolbar to keyboard.
            if let textField = self as? UITextField {
                _IQcanBecomeFirstResponder = textField.isEnabled
            } else if let textView = self as? UITextView {
                _IQcanBecomeFirstResponder = textView.isEditable
            }
        }

        objc_setAssociatedObject(self, &kIQIsAskingCanBecomeFirstResponder, false, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return _IQcanBecomeFirstResponder
    }

    ///-------------------------
    /// MARK: Special TextFields
    ///-------------------------
    
    /**
    Returns YES if the receiver object is UISearchBarTextField, otherwise return NO.
    */
    public func isSearchBarTextField()-> Bool {
        
        struct InternalClass {
            
            static var UISearchBarTextFieldClass: UITextField.Type?        =   NSClassFromString("UISearchBarTextField") as? UITextField.Type//UISearchBar
        }

        return  (InternalClass.UISearchBarTextFieldClass != nil && isKind(of: InternalClass.UISearchBarTextFieldClass!)) || self is UISearchBar
    }
    
    /**
    Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
    */
    public func isAlertViewTextField()->Bool {
        
        struct InternalClass {
            
            static var UIAlertSheetTextFieldClass: UITextField.Type?       =   NSClassFromString("UIAlertSheetTextField") as? UITextField.Type //UIAlertView
            static var UIAlertSheetTextFieldClass_iOS8: UITextField.Type?  =   NSClassFromString("_UIAlertControllerTextField") as? UITextField.Type //UIAlertView
        }
        
        return (InternalClass.UIAlertSheetTextFieldClass != nil && isKind(of: InternalClass.UIAlertSheetTextFieldClass!)) ||
            (InternalClass.UIAlertSheetTextFieldClass_iOS8 != nil && isKind(of: InternalClass.UIAlertSheetTextFieldClass_iOS8!))
    }
    

    ///----------------
    /// MARK: Transform
    ///----------------
    
    /**
    Returns current view transform with respect to the 'toView'.
    */
    public func convertTransformToView(_ toView:UIView?)->CGAffineTransform {
        
        var newView = toView
        
        if newView == nil {
            newView = window
        }
        
        //My Transform
        var myTransform = CGAffineTransform.identity
        
        if let superView = superview {
            myTransform = transform.concatenating(superView.convertTransformToView(nil))
        } else {
            myTransform = transform
        }
    
        var viewTransform = CGAffineTransform.identity
        
        //view Transform
        if let unwrappedToView = newView {
            
            if let unwrappedSuperView = unwrappedToView.superview {
                viewTransform = unwrappedToView.transform.concatenating(unwrappedSuperView.convertTransformToView(nil))
            }
            else {
                viewTransform = unwrappedToView.transform
            }
        }
        
        //Concating MyTransform and ViewTransform
        return myTransform.concatenating(viewTransform.inverted())
    }
    
    ///-----------------
    /// TODO: Hierarchy
    ///-----------------
    
//    /**
//    Returns a string that represent the information about it's subview's hierarchy. You can use this method to debug the subview's positions.
//    */
//    func subHierarchy()->NSString {
//        
//    }
//    
//    /**
//    Returns an string that represent the information about it's upper hierarchy. You can use this method to debug the superview's positions.
//    */
//    func superHierarchy()->NSString {
//        
//    }
//    
//    /**
//    Returns an string that represent the information about it's frame positions. You can use this method to debug self positions.
//    */
//    func debugHierarchy()->NSString {
//        
//    }

    fileprivate func depth()->Int {
        var depth : Int = 0
        
        if let superView = superview {
            depth = superView.depth()+1
        }
        
        return depth
    }
    
}


extension NSObject {
    
    public func _IQDescription() -> String {
        return "<\(self) \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}



