//
//  IQUIView+Hierarchy.swift
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


import Foundation
import UIKit

//Special textFields,textViews,scrollViews
//var UIAlertSheetTextFieldClass: AnyClass!       = NSClassFromString("UIAlertSheetTextField")
//var UIAlertSheetTextFieldClass_iOS8: AnyClass!  = NSClassFromString("_UIAlertControllerTextField")
//
//var UITableViewCellScrollViewClass: AnyClass!   = NSClassFromString("UITableViewCellScrollView")
//var UITableViewWrapperViewClass: AnyClass!      = NSClassFromString("UITableViewWrapperView")
//
//var UISearchBarTextFieldClass: AnyClass!        = NSClassFromString("UISearchBarTextField")
//var EKPlaceholderTextViewClass: AnyClass!       = NSClassFromString("EKPlaceholderTextView")

class FakeClass :NSObject {
    
    override class func load () {
        
        super.load()
        
//        UIAlertSheetTextFieldClass          = NSClassFromString("UIAlertSheetTextField")
//        UIAlertSheetTextFieldClass_iOS8     = NSClassFromString("_UIAlertControllerTextField")
//        
//        UITableViewCellScrollViewClass      = NSClassFromString("UITableViewCellScrollView")
//        UITableViewWrapperViewClass         = NSClassFromString("UITableViewWrapperView")
//        
//        UISearchBarTextFieldClass           = NSClassFromString("UISearchBarTextField")
//        EKPlaceholderTextViewClass          = NSClassFromString("EKPlaceholderTextView")
    }
}


extension UIView {
    
    /*! @return Returns the UIViewController object that manages the receiver.  */
    func viewController()->UIViewController? {
        
        var nextResponder: UIResponder! = self

        do
        {
            nextResponder = nextResponder.nextResponder()!
            
            if (nextResponder is UIViewController) {
                return nextResponder as? UIViewController
            }
            
        } while (nextResponder != nil)
        
        return nil
    }

    /*! @return Returns the UIScrollView object if any found in view's upper hierarchy. */
    func superScrollView()->UIScrollView? {
        
        var superview: UIView! = self.superview!
        
        while (superview != nil)
        {
            //UITableViewWrapperView
            if (superview is UIScrollView /* && (superview .isKindOfClass(UITableViewCellScrollViewClass) == false) && (superview .isKindOfClass(UITableViewWrapperViewClass) == false) */)
            {
                return superview as? UIScrollView
            }
            else
            {
                superview = superview.superview
            }
        }
        
        return nil
    }

    /*! @return Returns the UITableView object if any found in view's upper hierarchy.  */
    func superTableView()->UITableView? {
    
        var superview: UIView! = self.superview!
        
        while (superview != nil)
        {
            if (superview is UITableView)
            {
                return superview as? UITableView
            }
            else
            {
                superview = superview.superview
            }
        }
        
        return nil
    }
    
    /*! @return returns all siblings of the receiver which canBecomeFirstResponder. */
    func responderSiblings()->NSArray {
        
        //	Getting all siblings
        let siblings : NSArray? = self.superview?.subviews
        
        //Array of (UITextField/UITextView's).
        var tempTextFields = NSMutableArray()
        
        for textField in siblings as Array<UIView> {
            
            if(textField.canBecomeFirstResponder() && textField.userInteractionEnabled && textField.isAlertViewTextField() == false && textField.isSearchBarTextField() == false){
                tempTextFields.addObject(textField)
            }
        }
        
        return tempTextFields

    }
    
    /*! @return returns all deep subViews of the receiver which canBecomeFirstResponder.    */
    func deepResponderViews()->NSArray {
        
        //subviews are returning in opposite order. So I sorted it according the frames 'y'.
        var subViews: NSArray? = self.subviews.sorted { (let view1: AnyObject, let view2: AnyObject) -> Bool in
        
            if (CGFloat(view1.y) < CGFloat(view2.y)) {
                return true
            } else {
                return false
            }
        }
        
        //Array of (UITextField/UITextView's).
        var textfields = NSMutableArray()
        
        for textField in subViews as Array<UIView> {

            if (textField.canBecomeFirstResponder() && textField.userInteractionEnabled && textField.isAlertViewTextField() == false && textField.isSearchBarTextField() == false)
            {
                textfields.addObject(textField)
            }
            else if (textField.subviews.count != 0)
            {
                textfields.addObjectsFromArray(textField.deepResponderViews())
            }
        }
        
        return textfields as NSArray

    }
    
    /*! @return returns YES if the receiver object is UISearchBarTextField, otherwise return NO.    */
    func isSearchBarTextField()-> Bool {
        return false
//        return (self.isKindOfClass(UISearchBarTextFieldClass) || self.isKindOfClass(UISearchBar));
    }
    
    /*! @return returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.   */
    func isAlertViewTextField()->Bool {
        return false
//        return (self.isKindOfClass(UIAlertSheetTextFieldClass) || self.isKindOfClass(UIAlertSheetTextFieldClass_iOS8));
    }
    
    /*! @return returns YES if the receiver object is EKPlaceholderTextView, otherwise return NO.   */
    func isEventKitTextView()->Bool {
        return false
//        return (self.isKindOfClass(EKPlaceholderTextViewClass));
    }
    
//    /*! @return returns current view transform with respect to the 'toView'.    */
//    func convertTransformToView(toView:UIView)->CGAffineTransform {
//        
//    }
//    
//    /*! @return Returns a string that represent the information about it's subview's hierarchy. You can use this method to debug the subview's positions.   */
//    func subHierarchy()->NSString {
//        
//    }
//    
//    /*! @return Returns an string that represent the information about it's upper hierarchy. You can use this method to debug the superview's positions.    */
//    func superHierarchy()->NSString {
//        
//    }
}


extension UIView {

    var x : CGFloat {
        
        get {   return frame.x    }
        set {
            var frame : CGRect = self.frame
            frame.x = x
            self.frame = frame }
    }
    
    var y : CGFloat {
        
        get {   return frame.y    }
        set {
            var frame : CGRect = self.frame
            frame.y = y
            self.frame = frame }
    }
    
    var width : CGFloat {
        
        get {   return frame.width    }
        set {
            var frame : CGRect = self.frame
            frame.width = width
            self.frame = frame }
    }
    
    var height : CGFloat {
        
        get {   return frame.height    }
        set {
            var frame : CGRect = self.frame
            frame.height = height
            self.frame = frame }
    }
    
    var origin : CGPoint {
        
        get {   return frame.origin    }
        set {
            var frame : CGRect = self.frame
            frame.origin = origin
            self.frame = frame }
    }
    
    var size : CGSize {
        
        get {   return frame.size    }
        set {
            var frame : CGRect = self.frame
            frame.size = size
            self.frame = frame }
    }

    
    public var top: CGFloat {
        get {
            return frame.top
        }
        set(value) {
            var frame = self.frame
            frame.top = value
            self.frame = frame
        }
    }
    
    public var left: CGFloat {
        get {
            return frame.left
        }
        set(value) {
            var frame = self.frame
            frame.left = value
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get {
            return frame.bottom
        }
        set(value) {
            var frame = self.frame
            frame.bottom = value
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return frame.right
        }
        set(value) {
            var frame = self.frame
            frame.right = value
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get {
            return frame.centerX
        }
        set(value) {
            var frame = self.frame
            frame.centerX = value
            self.frame = frame
        }
    }
    
    public var centerY: CGFloat {
        get {
            return frame.centerY
        }
        set(value) {
            var frame = self.frame
            frame.centerY = value
            self.frame = frame
        }
    }
    
    public var center: CGPoint {
        get {
            return frame.center
        }
        set(value) {
            var frame = self.frame
            frame.center = value
            self.frame = frame
        }
    }

    public var boundsCenter : CGPoint {
        return bounds.center
    }
}

extension CGRect {
    
    public var x : CGFloat {
        
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }
    
    public var y : CGFloat {
        
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
     }
    
    public var width : CGFloat {
        
        get {   return size.width    }
        set {   size.width = newValue   }
    }
    
    public var height : CGFloat {

        get {   return size.height    }
        set {   size.height = newValue   }
    }

    // The left-side coordinate of the rect.
    public var left: CGFloat {
        
        get {   return origin.x }
        set {
            
            origin.x = newValue
            size.width = max(self.right - newValue , 0)
        }
    }
    
    public var right: CGFloat {
        get {
            return origin.x + size.width
        }
        set {
            size.width = max(newValue - self.left, 0)
        }
    }
    
    /// The top coordinate of the rect.
    public var top: CGFloat {
        
        get {   return origin.y }
        set {
            size.height = max(self.bottom-newValue, 0)
        }
    }
    
    public var bottom: CGFloat {
        get {
            return origin.y + size.height
        }
        set {
            size.height = max(newValue-self.top, 0)
        }
    }
    
    // The center of the rect.
    public var center: CGPoint {
        get {
            return CGPoint(
                x: CGRectGetMidX(self),
                y: CGRectGetMidY(self)
            )
        }
        set {
            origin.x = newValue.x - size.width / 2
            origin.y = newValue.y - size.height / 2
        }
    }
    
    // The center x coordinate of the rect.
    public var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            origin.x = newValue - size.width / 2
        }
    }
    
    // The center y coordinate of the rect.
    public var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            origin.y = newValue - size.height / 2
        }
    }
}





