//
//  UIView+Hierarchy.m
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

#import "UIView+Hierarchy.h"

#import <UIKit/UITableView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UISearchBar.h>

#import "IQKeyboardManagerConstantsInternal.h"
IQ_LoadCategory(IQUIViewHierarchy)


@implementation UIView (Hierarchy)


- (UITableView*)superTableView
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UITableView class]])
        {
            return (UITableView*)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

- (UIScrollView*)superScrollView
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UIScrollView class]])
        {
            return (UIScrollView*)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

- (NSArray*)responderSiblings
{
    //	Getting all siblings
    NSArray *siblings = self.superview.subviews;
    
    //Array of (UITextField/UITextView's).
    NSMutableArray *tempTextFields = [[NSMutableArray alloc] init];
    
    for (UITextField *textField in siblings)
        if ([textField canBecomeFirstResponder] /*&& ![textField isInsideAlertView]*/  && ![textField isInsideSearchBar])
            [tempTextFields addObject:textField];
    
    return tempTextFields;
}

- (NSArray*)deepResponderViews
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    
    //subviews are returning in opposite order. So I sorted it according the frames 'y'.
    NSArray *subViews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
        
        if (obj1.frame.origin.y < obj2.frame.origin.y)	return NSOrderedAscending;
        
        else if (obj1.frame.origin.y > obj2.frame.origin.y)	return NSOrderedDescending;
        
        else	return NSOrderedSame;
    }];

    
    for (UITextField *textField in subViews)
    {
        if ([textField canBecomeFirstResponder])
        {
            [textFields addObject:textField];
        }
        else if (textField.subviews.count)
        {
            [textFields addObjectsFromArray:[textField deepResponderViews]];
        }
    }

    return textFields;
}

-(BOOL)isInsideSearchBar
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UISearchBar class]])
        {
            return YES;
        }
        else    superview = superview.superview;
    }
    
    return NO;
}

//-(BOOL)isInsideAlertView
//{
//    UIView *superview = self.superview;
//    
//    while (superview)
//    {
//        if ([superview isKindOfClass:[UIAlertView class]])
//        {
//            return YES;
//        }
//        else    superview = superview.superview;
//    }
//    
//    return NO;
//}

@end
