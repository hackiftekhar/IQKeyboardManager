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

#import "IQUIView+Hierarchy.h"

#import <UIKit/UITableView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UISearchBar.h>
#import <UIKit/UIViewController.h>

#import "IQKeyboardManagerConstantsInternal.h"
IQ_LoadCategory(IQUIViewHierarchy)


@implementation UIView (IQ_UIView_Hierarchy)

//Special textFields,textViews,scrollViews
Class UISearchBarTextFieldClass;
Class UIAlertSheetTextFieldClass;
Class UITableViewCellScrollViewClass;


+(void)initialize
{
    [super initialize];

    UISearchBarTextFieldClass       = NSClassFromString(@"UISearchBarTextField");
    UIAlertSheetTextFieldClass      = NSClassFromString(@"UIAlertSheetTextField");
    UITableViewCellScrollViewClass  = NSClassFromString(@"UITableViewCellScrollView");
}

-(UIViewController*)viewController
{
    UIResponder *nextResponder =  self;
    
    do
    {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;

    } while (nextResponder != nil);

    return nil;
}

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
        if ([superview isKindOfClass:[UIScrollView class]] && ([superview isKindOfClass:UITableViewCellScrollViewClass] == NO))
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
        if ([textField canBecomeFirstResponder] && ![textField isAlertViewTextField]  && ![textField isSearchBarTextField])
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
        if ([textField canBecomeFirstResponder] && ![textField isAlertViewTextField]  && ![textField isSearchBarTextField])
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

-(BOOL)isSearchBarTextField
{
    return ([self isKindOfClass:UISearchBarTextFieldClass] || [self isKindOfClass:[UISearchBar class]]);
}

-(BOOL)isAlertViewTextField
{
    return [self isKindOfClass:UIAlertSheetTextFieldClass];
}

@end

@implementation UIView (IQ_UIView_Frame)

-(CGFloat)x         {   return self.frame.origin.x;         }
-(CGFloat)y         {   return self.frame.origin.y;         }
-(CGFloat)width     {   return self.frame.size.width;       }
-(CGFloat)height    {   return self.frame.size.height;      }
-(CGPoint)origin    {   return self.frame.origin;           }
-(CGSize)size       {   return self.frame.size;             }
-(CGFloat)left      {   return CGRectGetMinX(self.frame);   }
-(CGFloat)right     {   return CGRectGetMaxX(self.frame);   }
-(CGFloat)top       {   return CGRectGetMinY(self.frame);   }
-(CGFloat)bottom    {   return CGRectGetMaxY(self.frame);   }
-(CGFloat)centerX   {   return self.center.x;               }
-(CGFloat)centerY   {   return self.center.y;               }
-(CGPoint)boundsCenter  {   return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));   };

-(void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

-(void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    frame.size.width = MAX(self.right-left, 0);
    self.frame = frame;
}

-(void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.size.width = MAX(right-self.left, 0);
    self.frame = frame;
}

-(void)setTop:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    frame.size.height = MAX(self.bottom-top, 0);
    self.frame = frame;
}

-(void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.size.height = MAX(bottom-self.top, 0);
    self.frame = frame;
}

-(void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

-(void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

@end


