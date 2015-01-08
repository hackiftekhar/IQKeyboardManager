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
#import "IQKeyboardManagerConstantsInternal.h"

#import <UIKit/UICollectionView.h>
#import <UIKit/UITableView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UISearchBar.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWindow.h>

#import <objc/runtime.h>


IQ_LoadCategory(IQUIViewHierarchy)


@implementation UIView (IQ_UIView_Hierarchy)

//Special textFields,textViews,scrollViews
Class UIAlertSheetTextFieldClass;       //UIAlertView
Class UIAlertSheetTextFieldClass_iOS8;  //UIAlertView

Class UITableViewCellScrollViewClass;   //UITableViewCell
Class UITableViewWrapperViewClass;      //UITableViewCell
Class UIQueuingScrollViewClass;         //UIPageViewController

Class UISearchBarTextFieldClass;        //UISearchBar

+(void)initialize
{
    [super initialize];
    
    UIAlertSheetTextFieldClass          = NSClassFromString(@"UIAlertSheetTextField");
    UIAlertSheetTextFieldClass_iOS8     = NSClassFromString(@"_UIAlertControllerTextField");
    
    UITableViewCellScrollViewClass      = NSClassFromString(@"UITableViewCellScrollView");
    UITableViewWrapperViewClass         = NSClassFromString(@"UITableViewWrapperView");
    UIQueuingScrollViewClass            = NSClassFromString(@"_UIQueuingScrollView");

    UISearchBarTextFieldClass           = NSClassFromString(@"UISearchBarTextField");
}

-(void)_setIsAskingCanBecomeFirstResponder:(BOOL)isAskingCanBecomeFirstResponder
{
    objc_setAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder), @(isAskingCanBecomeFirstResponder), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isAskingCanBecomeFirstResponder
{
    NSNumber *shouldHideTitle = objc_getAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder));
    return [shouldHideTitle boolValue];
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

-(UIViewController *)topMostController
{
    NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];
    
    UIViewController *topController = self.window.rootViewController;
    
    [controllersHierarchy addObject:topController];
    
    while ([topController presentedViewController]) {
        
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }
    
    UIResponder *matchController = [self viewController];
    
    while (matchController != nil && [controllersHierarchy containsObject:matchController] == NO)
    {
        do
        {
            matchController = [matchController nextResponder];
            
        } while (matchController != nil && [matchController isKindOfClass:[UIViewController class]] == NO);
    }
    
    return (UIViewController*)matchController;
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

-(UICollectionView *)superCollectionView
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UICollectionView class]])
        {
            return (UICollectionView*)superview;
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
        if ([superview isKindOfClass:[UIScrollView class]] && ([superview isKindOfClass:UITableViewCellScrollViewClass] == NO) && ([superview isKindOfClass:UITableViewWrapperViewClass] == NO) && ([superview isKindOfClass:UIQueuingScrollViewClass] == NO))
        {
            return (UIScrollView*)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

-(BOOL)_IQcanBecomeFirstResponder
{
    [self _setIsAskingCanBecomeFirstResponder:YES];
    BOOL _IQcanBecomeFirstResponder = ([self canBecomeFirstResponder] && [self isUserInteractionEnabled] && ![self isAlertViewTextField]  && ![self isSearchBarTextField]);
    [self _setIsAskingCanBecomeFirstResponder:NO];
    
    return _IQcanBecomeFirstResponder;
}

- (NSArray*)responderSiblings
{
    //	Getting all siblings
    NSArray *siblings = self.superview.subviews;
    
    //Array of (UITextField/UITextView's).
    NSMutableArray *tempTextFields = [[NSMutableArray alloc] init];
    
    for (UITextField *textField in siblings)
        if ([textField _IQcanBecomeFirstResponder])
            [tempTextFields addObject:textField];
    
    return tempTextFields;
}

- (NSArray*)deepResponderViews
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    
    //subviews are returning in opposite order. So I sorted it according the frames 'y'.
    NSArray *subViews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        if (view1.IQ_y < view2.IQ_y)	return NSOrderedAscending;
        
        else if (view1.IQ_y > view2.IQ_y)	return NSOrderedDescending;
        
        else	return NSOrderedSame;
    }];

    for (UITextField *textField in subViews)
    {
        if ([textField _IQcanBecomeFirstResponder])
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

    [debugInfo appendFormat:@"%@: ( %.0f, %.0f, %.0f, %.0f )",NSStringFromClass([self class]),self.IQ_x,self.IQ_y,self.IQ_width,self.IQ_height];
    
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

-(BOOL)isSearchBarTextField
{
    return ([self isKindOfClass:UISearchBarTextFieldClass] || [self isKindOfClass:[UISearchBar class]]);
}

-(BOOL)isAlertViewTextField
{
    return ([self isKindOfClass:UIAlertSheetTextFieldClass] || [self isKindOfClass:UIAlertSheetTextFieldClass_iOS8]);
}

@end

@implementation UIView (IQ_UIView_Frame)

-(CGFloat)IQ_x         {   return CGRectGetMinX(self.frame);   }
-(CGFloat)IQ_y         {   return CGRectGetMinY(self.frame);   }
-(CGFloat)IQ_width     {   return CGRectGetWidth(self.frame);  }
-(CGFloat)IQ_height    {   return CGRectGetHeight(self.frame); }
-(CGPoint)IQ_origin    {   return self.frame.origin;           }
-(CGSize)IQ_size       {   return self.frame.size;             }
-(CGFloat)IQ_left      {   return CGRectGetMinX(self.frame);   }
-(CGFloat)IQ_right     {   return CGRectGetMaxX(self.frame);   }
-(CGFloat)IQ_top       {   return CGRectGetMinY(self.frame);   }
-(CGFloat)IQ_bottom    {   return CGRectGetMaxY(self.frame);   }
-(CGFloat)IQ_centerX   {   return self.center.x;               }
-(CGFloat)IQ_centerY   {   return self.center.y;               }
-(CGPoint)IQ_boundsCenter  {   return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));   };

-(void)setIQ_x:(CGFloat)IQ_x
{
    CGRect frame = self.frame;
    frame.origin.x = IQ_x;
    self.frame = frame;
}

-(void)setIQ_y:(CGFloat)IQ_y
{
    CGRect frame = self.frame;
    frame.origin.y = IQ_y;
    self.frame = frame;
}

-(void)setIQ_width:(CGFloat)IQ_width
{
    CGRect frame = self.frame;
    frame.size.width = IQ_width;
    self.frame = frame;
}

-(void)setIQ_height:(CGFloat)IQ_height
{
    CGRect frame = self.frame;
    frame.size.height = IQ_height;
    self.frame = frame;
}

-(void)setIQ_origin:(CGPoint)IQ_origin
{
    CGRect frame = self.frame;
    frame.origin = IQ_origin;
    self.frame = frame;
}

-(void)setIQ_size:(CGSize)IQ_size
{
    CGRect frame = self.frame;
    frame.size = IQ_size;
    self.frame = frame;
}

-(void)setIQ_left:(CGFloat)IQ_left
{
    CGRect frame = self.frame;
    frame.origin.x = IQ_left;
    frame.size.width = MAX(self.IQ_right-IQ_left, 0);
    self.frame = frame;
}

-(void)setIQ_right:(CGFloat)IQ_right
{
    CGRect frame = self.frame;
    frame.size.width = MAX(IQ_right-self.IQ_left, 0);
    self.frame = frame;
}

-(void)setIQ_top:(CGFloat)IQ_top
{
    CGRect frame = self.frame;
    frame.origin.y = IQ_top;
    frame.size.height = MAX(self.IQ_bottom-IQ_top, 0);
    self.frame = frame;
}

-(void)setIQ_bottom:(CGFloat)IQ_bottom
{
    CGRect frame = self.frame;
    frame.size.height = MAX(IQ_bottom-self.IQ_top, 0);
    self.frame = frame;
}

-(void)setIQ_centerX:(CGFloat)IQ_centerX
{
    CGPoint center = self.center;
    center.x = IQ_centerX;
    self.center = center;
}

-(void)setIQ_centerY:(CGFloat)IQ_centerY
{
    CGPoint center = self.center;
    center.y = IQ_centerY;
    self.center = center;
}

@end


@implementation NSObject (IQ_Logging)

-(NSString *)_IQDescription
{
    return [NSString stringWithFormat:@"<%@ %p>",NSStringFromClass([self class]),self];
}

@end
