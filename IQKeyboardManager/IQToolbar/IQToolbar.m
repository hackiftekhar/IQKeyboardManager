//
//  IQToolbar.m
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

#import "IQToolbar.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQTitleBarButtonItem.h"
#import "IQUIView+Hierarchy.h"

#import <UIKit/UIViewController.h>

@implementation IQToolbar
@synthesize titleFont = _titleFont;
@synthesize title = _title;

+(void)initialize
{
    [super initialize];

    //Tint Color
    [[self appearance] setTintColor:nil];

    [[self appearance] setBarTintColor:nil];
    
    //Background image
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionAny           barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionBottom        barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionTop           barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forToolbarPosition:UIBarPositionTopAttached   barMetrics:UIBarMetricsDefault];
    
    //Shadow image
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionAny];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionBottom];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionTop];
    [[self appearance] setShadowImage:nil forToolbarPosition:UIBarPositionTopAttached];
    
    //Background color
    [[self appearance] setBackgroundColor:nil];
}

-(void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight;
    self.translucent = YES;
    [self setTintColor:[UIColor blackColor]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFit = [super sizeThatFits:size];

    sizeThatFit.height = 44;
    
    return sizeThatFit;
}

-(void)setBarStyle:(UIBarStyle)barStyle
{
    [super setBarStyle:barStyle];
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            if (barStyle == UIBarStyleDefault)
            {
                [(IQTitleBarButtonItem*)item setSelectableTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]];
            }
            else
            {
                [(IQTitleBarButtonItem*)item setSelectableTextColor:[UIColor yellowColor]];
            }
            
            break;
        }
    }
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    for (UIBarButtonItem *item in self.items)
    {
        [item setTintColor:tintColor];
    }
}

-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            [(IQTitleBarButtonItem*)item setFont:titleFont];
            break;
        }
    }
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            [(IQTitleBarButtonItem*)item setTitle:title];
            break;
        }
    }
}

-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }
    
    self.titleInvocation = invocation;
}

-(void)setTitleInvocation:(NSInvocation*)invocation
{
    _titleInvocation = invocation;

    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            [(IQTitleBarButtonItem*)item setTitleInvocation:_titleInvocation];
            break;
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect leftRect = CGRectNull;
    CGRect rightRect = CGRectNull;
    
    BOOL isTitleBarButtonFound = NO;
    
    NSArray *subviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        CGFloat x1 = CGRectGetMinX(view1.frame);
        CGFloat y1 = CGRectGetMinY(view1.frame);
        CGFloat x2 = CGRectGetMinX(view2.frame);
        CGFloat y2 = CGRectGetMinY(view2.frame);
        
        if (x1 < x2)  return NSOrderedAscending;
        
        else if (x1 > x2) return NSOrderedDescending;
        
        //Else both y are same so checking for x positions
        else if (y1 < y2)  return NSOrderedAscending;
        
        else if (y1 > y2) return NSOrderedDescending;
        
        else    return NSOrderedSame;
    }];
    
    for (UIView *barButtonItemView in subviews)
    {
        if (isTitleBarButtonFound == YES)
        {
            rightRect = barButtonItemView.frame;
            break;
        }
        else if ([barButtonItemView isMemberOfClass:[UIView class]])
        {
            isTitleBarButtonFound = YES;
        }
        else
        {
            NSString *classNameString = NSStringFromClass([barButtonItemView class]);
            
            //If it's UIToolbarButton or UIToolbarTextButton
            if (([classNameString hasPrefix:@"UIToolbar"] && [classNameString hasSuffix:@"Button"]))
            {
                leftRect = barButtonItemView.frame;
            }
        }
    }
    
    CGFloat x = 16;
    
    if (CGRectIsNull(leftRect) == false)
    {
        x = CGRectGetMaxX(leftRect) + 16;
    }
    
    CGFloat width = CGRectGetWidth(self.frame) - 32 - (CGRectIsNull(leftRect)?0:CGRectGetMaxX(leftRect)) - (CGRectIsNull(rightRect)?0:CGRectGetWidth(self.frame)-CGRectGetMinX(rightRect));
    
    for (UIBarButtonItem *item in self.items)
    {
        if ([item isKindOfClass:[IQTitleBarButtonItem class]])
        {
            CGRect titleRect = CGRectMake(x, 0, width, self.frame.size.height);
            item.customView.frame = titleRect;
            break;
        }
    }
}

#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL) enableInputClicksWhenVisible
{
	return YES;
}

@end
