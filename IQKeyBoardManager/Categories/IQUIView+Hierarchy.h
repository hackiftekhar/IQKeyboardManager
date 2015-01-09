//
//  UIView+Hierarchy.h
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

#import <UIKit/UIView.h>
#import "IQKeyboardManagerConstants.h"

@class UICollectionView, UIScrollView, UITableView, NSArray;

/*!
    @category UIView (IQ_UIView_Hierarchy)
 
	@abstract UIView hierarchy category.
 */
@interface UIView (IQ_UIView_Hierarchy)

/*!
    @property isAskingCanBecomeFirstResponder
 
    @abstract Returns YES if IQKeyboardManager asking for `canBecomeFirstResponder. Useful when doing custom work in `textFieldShouldBeginEditing:` delegate.
 */
@property (nonatomic, readonly) BOOL isAskingCanBecomeFirstResponder;

/*!
    @property viewController
 
    @abstract Returns the UIViewController object that manages the receiver.
 */
@property (nonatomic, readonly, strong) UIViewController *viewController;

/*!
    @property topMostController
 
    @abstract Returns the topMost UIViewController object in hierarchy.
 */
@property (nonatomic, readonly, strong) UIViewController *topMostController;

/*!
    @property superScrollView
 
    @abstract Returns the UIScrollView object if any found in view's upper hierarchy.
 */
@property (nonatomic, readonly, strong) UIScrollView *superScrollView;

/*!
    @property superTableView
 
    @abstract Returns the UITableView object if any found in view's upper hierarchy.
 */
@property (nonatomic, readonly, strong) UITableView *superTableView;

/*!
    @property superCollectionView
 
    @abstract Returns the UICollectionView object if any found in view's upper hierarchy.
 */
@property (nonatomic, readonly, strong) UICollectionView *superCollectionView   NS_AVAILABLE_IOS(6_0);

/*!
    @property responderSiblings
 
    @abstract returns all siblings of the receiver which canBecomeFirstResponder.
 */
@property (nonatomic, readonly, copy) NSArray *responderSiblings;

/*!
    @property deepResponderViews
 
    @abstract returns all deep subViews of the receiver which canBecomeFirstResponder.
 */
@property (nonatomic, readonly, copy) NSArray *deepResponderViews;

/*!
    @property isSearchBarTextField
 
    @abstract returns YES if the receiver object is UISearchBarTextField, otherwise return NO.
 */
@property (nonatomic, getter=isSearchBarTextField, readonly) BOOL searchBarTextField;

/*!
    @property isAlertViewTextField
 
    @abstract returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
 */
@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;

/*!
    @method convertTransformToView
 
    @return returns current view transform with respect to the 'toView'.
 */
-(CGAffineTransform)convertTransformToView:(UIView*)toView;

/*!
    @property subHierarchy
 
    @abstract Returns a string that represent the information about it's subview's hierarchy. You can use this method to debug the subview's positions.
 */
@property (nonatomic, readonly, copy) NSString *subHierarchy;

/*!
    @property superHierarchy
 
    @abstract Returns an string that represent the information about it's upper hierarchy. You can use this method to debug the superview's positions.
 */
@property (nonatomic, readonly, copy) NSString *superHierarchy;

/*!
    @property debugHierarchy
 
    @abstract Returns an string that represent the information about it's frame positions. You can use this method to debug self positions.
 */
@property (nonatomic, readonly, copy) NSString *debugHierarchy;

@end


/*!
    @category UIView (IQ_UIView_Frame)
 
	@abstract UIView frame category.
 */
@interface UIView (IQ_UIView_Frame)

@property (nonatomic, assign) CGPoint IQ_origin;
@property (nonatomic, assign) CGSize IQ_size;
@property (nonatomic, assign) CGFloat IQ_x, IQ_y, IQ_width, IQ_height;
@property (nonatomic, assign) CGFloat IQ_left, IQ_right, IQ_top, IQ_bottom;
@property (nonatomic, assign) CGFloat IQ_centerX;
@property (nonatomic, assign) CGFloat IQ_centerY;
@property (nonatomic, readonly) CGPoint IQ_boundsCenter;

@end


@interface NSObject (IQ_Logging)

/*!
    @property _IQDescription
 
    @abstract Short description for logging purpose.
 */
@property (nonatomic, readonly, copy) NSString *_IQDescription;

@end
