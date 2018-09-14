//
// IQUIView+Hierarchy.h
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

#import <UIKit/UIView.h>
#import <UIKit/UIViewController.h>
#import "IQKeyboardManagerConstants.h"

@class UICollectionView, UIScrollView, UITableView, UISearchBar, NSArray;

/**
 UIView hierarchy category.
 */
@interface UIView (IQ_UIView_Hierarchy)

///----------------------
/// @name viewControllers
///----------------------

/**
 Returns the UIViewController object that manages the receiver.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *iq_viewContainingController;

/**
 Returns the topMost UIViewController object in hierarchy.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *iq_topMostController;

/**
 Returns the UIViewController object that is actually the parent of this object. Most of the time it's the viewController object which actually contains it, but result may be different if it's viewController is added as childViewController of another viewController.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *iq_parentContainerViewController;

///-----------------------------------
/// @name Superviews/Subviews/Siglings
///-----------------------------------

/**
 Returns the superView of provided class type.
 */
-(nullable UIView*)iq_superviewOfClassType:(nonnull Class)classType;

/**
 Returns all siblings of the receiver which canBecomeFirstResponder.
 */
@property (nonnull, nonatomic, readonly, copy) NSArray<__kindof UIView*> *iq_responderSiblings;

/**
 Returns all deep subViews of the receiver which canBecomeFirstResponder.
 */
@property (nonnull, nonatomic, readonly, copy) NSArray<__kindof UIView*> *iq_deepResponderViews;

///-------------------------
/// @name Special TextFields
///-------------------------

/**
 Returns searchBar if receiver object is UISearchBarTextField, otherwise return nil.
 */
@property (nullable, nonatomic, readonly) UISearchBar *iq_searchBar;

/**
 Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
 */
@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL iq_alertViewTextField;

///----------------
/// @name Transform
///----------------

/**
 Returns current view transform with respect to the 'toView'.
 */
-(CGAffineTransform)iq_convertTransformToView:(nullable UIView*)toView;

///-----------------
/// @name Hierarchy
///-----------------

/**
 Returns a string that represent the information about it's subview's hierarchy. You can use this method to debug the subview's positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *iq_subHierarchy;

/**
 Returns an string that represent the information about it's upper hierarchy. You can use this method to debug the superview's positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *iq_superHierarchy;

/**
 Returns an string that represent the information about it's frame positions. You can use this method to debug self positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *iq_debugHierarchy;

@end


@interface UIViewController (IQ_UIView_Hierarchy)

-(nullable UIViewController*)parentIQContainerViewController;

@end

/**
 NSObject category to used for logging purposes
 */
@interface NSObject (IQ_Logging)

/**
 Short description for logging purpose.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *_IQDescription;

@end
