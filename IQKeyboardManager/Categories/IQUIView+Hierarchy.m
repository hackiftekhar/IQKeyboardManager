//
// IQUIView+Hierarchy.m
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

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "IQUIView+Hierarchy.h"
#import "IQUITextFieldView+Additions.h"
#import "IQUIViewController+Additions.h"
#import "IQNSArray+Sort.h"

@implementation UIView (IQ_UIView_Hierarchy)

-(UIViewController*)viewContainingController
{
    UIResponder *nextResponder =  self;
    
    do
    {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;

    } while (nextResponder);

    return nil;
}

-(UIViewController *)topMostController
{
    NSMutableArray<UIViewController*> *controllersHierarchy = [[NSMutableArray alloc] init];
    
    UIViewController *topController = self.window.rootViewController;
    
    if (topController)
    {
        [controllersHierarchy addObject:topController];
    }
    
    while ([topController presentedViewController]) {
        
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }
    
    UIViewController *matchController = [self viewContainingController];
    
    while (matchController && [controllersHierarchy containsObject:matchController] == NO)
    {
        do
        {
            matchController = (UIViewController*)[matchController nextResponder];
            
        } while (matchController && [matchController isKindOfClass:[UIViewController class]] == NO);
    }
    
    return matchController;
}

-(UIViewController *)parentContainerViewController
{
    UIViewController *matchController = [self viewContainingController];
    
    UIViewController *parentContainerViewController = nil;
    
    if (matchController.navigationController)
    {
        UINavigationController *navController = matchController.navigationController;
        
        while (navController.navigationController) {
            navController = navController.navigationController;
        }
        
        UIViewController *parentController = navController;
        
        UIViewController *parentParentController = parentController.parentViewController;
        
        while (parentParentController &&
               ([parentParentController isKindOfClass:[UINavigationController class]] == NO &&
                [parentParentController isKindOfClass:[UITabBarController class]] == NO &&
                [parentParentController isKindOfClass:[UISplitViewController class]] == NO))
        {
            parentController = parentParentController;
            parentParentController = parentController.parentViewController;
        }

        if (navController == parentController)
        {
            parentContainerViewController = navController.topViewController;
        }
        else
        {
            parentContainerViewController = parentController;
        }
    }
    else if (matchController.tabBarController)
    {
        if ([matchController.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            parentContainerViewController = [(UINavigationController*)matchController.tabBarController.selectedViewController topViewController];
        }
        else
        {
            parentContainerViewController = matchController.tabBarController.selectedViewController;
        }
    }
    else
    {
        UIViewController *matchParentController = matchController.parentViewController;

        while (matchParentController &&
               ([matchParentController isKindOfClass:[UINavigationController class]] == NO &&
                [matchParentController isKindOfClass:[UITabBarController class]] == NO &&
                [matchParentController isKindOfClass:[UISplitViewController class]] == NO))
        {
            matchController = matchParentController;
            matchParentController = matchController.parentViewController;
        }
        
        parentContainerViewController = matchController;
    }
    
    UIViewController *finalController = [parentContainerViewController parentIQContainerViewController] ?: parentContainerViewController;
    
    return finalController;
}

-(UIView*)superviewOfClassType:(nonnull Class)classType
{
    return [self superviewOfClassType:classType belowView:nil];
}

-(nullable __kindof UIView*)superviewOfClassType:(nonnull Class)classType belowView:(nullable UIView*)belowView
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:classType])
        {
            //If it's UIScrollView, then validating for special cases
            if ([superview isKindOfClass:[UIScrollView class]])
            {
                NSString *classNameString = NSStringFromClass([superview class]);

                //  If it's not UITableViewWrapperView class, this is internal class which is actually manage in UITableview. The speciality of this class is that it's superview is UITableView.
                //  If it's not UITableViewCellScrollView class, this is internal class which is actually manage in UITableviewCell. The speciality of this class is that it's superview is UITableViewCell.
                //If it's not _UIQueuingScrollView class, actually we validate for _ prefix which usually used by Apple internal classes
                if ([superview.superview isKindOfClass:[UITableView class]] == NO &&
                    [superview.superview isKindOfClass:[UITableViewCell class]] == NO &&
                    [classNameString hasPrefix:@"_"] == NO)
                {
                    return superview;
                }
            }
            else
            {
                return superview;
            }
        }
        else if (belowView == superview)
        {
            return nil;
        }
        
        superview = superview.superview;
    }
    
    return nil;
}

-(BOOL)_IQcanBecomeFirstResponder
{
    BOOL _IQcanBecomeFirstResponder = NO;
    
    if ([self conformsToProtocol:@protocol(UITextInput)]) {
        if ([self respondsToSelector:@selector(isEditable)] && [self isKindOfClass:[UIScrollView class]])
        {
            _IQcanBecomeFirstResponder = [(UITextView*)self isEditable];
        }
        else if ([self respondsToSelector:@selector(isEnabled)])
        {
            _IQcanBecomeFirstResponder = [(UITextField*)self isEnabled];
        }
    }
    
    if (_IQcanBecomeFirstResponder == YES)
    {
        _IQcanBecomeFirstResponder = ([self isUserInteractionEnabled] && ![self isHidden] && [self alpha]!=0.0 && ![self isAlertViewTextField]  && !self.textFieldSearchBar);
    }
    
    return _IQcanBecomeFirstResponder;
}

- (NSArray<UIView*>*)responderSiblings
{
    //	Getting all siblings
    NSArray<UIView*> *siblings = self.superview.subviews;
    
    //Array of (UITextField/UITextView's).
    NSMutableArray<UIView*> *tempTextFields = [[NSMutableArray alloc] init];
    
    for (UIView *textField in siblings)
        if ((textField == self || textField.ignoreSwitchingByNextPrevious == NO) && [textField _IQcanBecomeFirstResponder])
            [tempTextFields addObject:textField];
    
    return tempTextFields;
}

- (NSArray<UIView*>*)deepResponderViews
{
    NSMutableArray<UIView*> *textFields = [[NSMutableArray alloc] init];
    
    for (UIView *textField in self.subviews)
    {
        if ((textField == self || textField.ignoreSwitchingByNextPrevious == NO) && [textField _IQcanBecomeFirstResponder])
        {
            [textFields addObject:textField];
        }
        //Sometimes there are hidden or disabled views and textField inside them still recorded, so we added some more validations here (Bug ID: #458)
        //Uncommented else (Bug ID: #625)
        else if (textField.subviews.count && [textField isUserInteractionEnabled] && ![textField isHidden] && [textField alpha]!=0.0)
        {
            [textFields addObjectsFromArray:[textField deepResponderViews]];
        }
    }

    //subviews are returning in incorrect order. Sorting according the frames 'y'.
    return [textFields sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        CGRect frame1 = [view1 convertRect:view1.bounds toView:self];
        CGRect frame2 = [view2 convertRect:view2.bounds toView:self];
        
        CGFloat x1 = CGRectGetMinX(frame1);
        CGFloat y1 = CGRectGetMinY(frame1);
        CGFloat x2 = CGRectGetMinX(frame2);
        CGFloat y2 = CGRectGetMinY(frame2);
        
        if (y1 < y2)  return NSOrderedAscending;
        
        else if (y1 > y2) return NSOrderedDescending;
        
        //Else both y are same so checking for x positions
        else if (x1 < x2)  return NSOrderedAscending;
        
        else if (x1 > x2) return NSOrderedDescending;
        
        else    return NSOrderedSame;
    }];

    return textFields;
}

-(CGAffineTransform)convertTransformToView:(UIView*)toView
{
    if (toView == nil)
    {
        toView = self.window;
    }
    
    CGAffineTransform myTransform = CGAffineTransformIdentity;
    
    //My Transform
    {
        UIView *superView = [self superview];
        
        if (superView)  myTransform = CGAffineTransformConcat(self.transform, [superView convertTransformToView:nil]);
        else            myTransform = self.transform;
    }
    
    CGAffineTransform viewTransform = CGAffineTransformIdentity;
    
    //view Transform
    {
        UIView *superView = [toView superview];
        
        if (superView)  viewTransform = CGAffineTransformConcat(toView.transform, [superView convertTransformToView:nil]);
        else if (toView)  viewTransform = toView.transform;
    }
    
    return CGAffineTransformConcat(myTransform, CGAffineTransformInvert(viewTransform));
}


- (NSInteger)depth
{
    NSInteger depth = 0;
    
    if ([self superview])
    {
        depth = [[self superview] depth] + 1;
    }
    
    return depth;
}

- (NSString *)subHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] initWithString:@"\n"];
    NSInteger depth = [self depth];
    
    for (int counter = 0; counter < depth; counter ++)  [debugInfo appendString:@"|  "];
    
    [debugInfo appendString:[self debugHierarchy]];
    
    for (UIView *subview in self.subviews)
    {
        [debugInfo appendString:[subview subHierarchy]];
    }
    
    return debugInfo;
}

- (NSString *)superHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];

    if (self.superview)
    {
        [debugInfo appendString:[self.superview superHierarchy]];
    }
    else
    {
        [debugInfo appendString:@"\n"];
    }
    
    NSInteger depth = [self depth];
    
    for (int counter = 0; counter < depth; counter ++)  [debugInfo appendString:@"|  "];
    
    [debugInfo appendString:[self debugHierarchy]];

    [debugInfo appendString:@"\n"];
    
    return debugInfo;
}

-(NSString *)debugHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];

    [debugInfo appendFormat:@"%@: ( %.0f, %.0f, %.0f, %.0f )",NSStringFromClass([self class]), CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)];
    
    if ([self isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self;
        [debugInfo appendFormat:@"%@: ( %.0f, %.0f )",NSStringFromSelector(@selector(contentSize)),scrollView.contentSize.width,scrollView.contentSize.height];
    }
    
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) == false)
    {
        [debugInfo appendFormat:@"%@: %@",NSStringFromSelector(@selector(transform)),NSStringFromCGAffineTransform(self.transform)];
    }
    
    return debugInfo;
}

-(UISearchBar *)textFieldSearchBar
{
    UIResponder *searchBar = [self nextResponder];
    
    while (searchBar)
    {
        if ([searchBar isKindOfClass:[UISearchBar class]])
        {
            return (UISearchBar*)searchBar;
        }
        else if ([searchBar isKindOfClass:[UIViewController class]])    //If found viewcontroller but still not found UISearchBar then it's not the search bar textfield
        {
            break;
        }
        
        searchBar = [searchBar nextResponder];
    }
    
    return nil;
}

-(BOOL)isAlertViewTextField
{
    UIResponder *alertViewController = [self viewContainingController];
    
    BOOL isAlertViewTextField = NO;
    while (alertViewController && isAlertViewTextField == NO)
    {
        if ([alertViewController isKindOfClass:[UIAlertController class]])
        {
            isAlertViewTextField = YES;
            break;
        }

        alertViewController = [alertViewController nextResponder];
    }
    
    return isAlertViewTextField;
}

@end

@implementation NSObject (IQ_Logging)

-(NSString *)_IQDescription
{
    return [NSString stringWithFormat:@"<%@ %p>",NSStringFromClass([self class]),self];
}

@end
