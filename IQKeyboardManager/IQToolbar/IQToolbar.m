//
// IQToolbar.m
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
#import "IQUIView+Hierarchy.h"

#import <UIKit/UIButton.h>
#import <UIKit/UIAccessibility.h>
#import <UIKit/UIViewController.h>

@interface IQTitleBarButtonItem (PrivateAccessor)

@property(nonnull, nonatomic, strong) UIButton *titleButton;

@end

@implementation IQToolbar
@synthesize previousBarButton = _previousBarButton;
@synthesize nextBarButton = _nextBarButton;
@synthesize titleBarButton = _titleBarButton;
@synthesize doneBarButton = _doneBarButton;
@synthesize fixedSpaceBarButton = _fixedSpaceBarButton;

+(void)initialize
{
    [super initialize];

    IQToolbar *appearanceProxy = [self appearance];
    
    NSArray <NSNumber*> *positions = @[@(UIBarPositionAny),@(UIBarPositionBottom),@(UIBarPositionTop),@(UIBarPositionTopAttached)];

    for (NSNumber *position in positions)
    {
        UIToolbarPosition toolbarPosition = [position unsignedIntegerValue];

        [appearanceProxy setBackgroundImage:nil forToolbarPosition:toolbarPosition barMetrics:UIBarMetricsDefault];
        [appearanceProxy setShadowImage:nil forToolbarPosition:toolbarPosition];
    }
}

-(void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight;
    self.translucent = YES;
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

-(void)dealloc
{
    self.items = nil;
}

-(IQBarButtonItem *)previousBarButton
{
    if (_previousBarButton == nil)
    {
        _previousBarButton = [[IQBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        _previousBarButton.accessibilityLabel = @"Previous";
    }
    
    return _previousBarButton;
}

-(IQBarButtonItem *)nextBarButton
{
    if (_nextBarButton == nil)
    {
        _nextBarButton = [[IQBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        _nextBarButton.accessibilityLabel = @"Next";
    }
    
    return _nextBarButton;
}

-(IQTitleBarButtonItem *)titleBarButton
{
    if (_titleBarButton == nil)
    {
        _titleBarButton = [[IQTitleBarButtonItem alloc] initWithTitle:nil];
        _titleBarButton.accessibilityLabel = @"Title";
    }
    
    return _titleBarButton;
}

-(IQBarButtonItem *)doneBarButton
{
    if (_doneBarButton == nil)
    {
        _doneBarButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
        _doneBarButton.accessibilityLabel = @"Done";
    }
    
    return _doneBarButton;
}

-(IQBarButtonItem *)fixedSpaceBarButton
{
    if (_fixedSpaceBarButton == nil)
    {
        _fixedSpaceBarButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if (@available(iOS 10.0, *))
        {
            [_fixedSpaceBarButton setWidth:6];
        }
        else
        {
            [_fixedSpaceBarButton setWidth:20];
        }
    }
    
    return _fixedSpaceBarButton;
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
    
    if (self.titleBarButton.selectableTitleColor == nil)
    {
        if (barStyle == UIBarStyleDefault)
        {
            [self.titleBarButton.titleButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        }
        else
        {
            [self.titleBarButton.titleButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
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

-(void)layoutSubviews
{
    [super layoutSubviews];

    if (@available(iOS 11.0, *)) {}
    else {
        CGRect leftRect = CGRectNull;
        CGRect rightRect = CGRectNull;
        
        BOOL isTitleBarButtonFound = NO;
        
        NSArray<UIView*> *subviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
            
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
            else if (barButtonItemView == self.titleBarButton.customView)
            {
                isTitleBarButtonFound = YES;
            }
            //If it's UIToolbarButton or UIToolbarTextButton (which actually UIBarButtonItem)
            else if ([barButtonItemView isKindOfClass:[UIControl class]])
            {
                leftRect = barButtonItemView.frame;
            }
        }
        
        CGFloat titleMargin = 16;

        CGFloat maxWidth = CGRectGetWidth(self.frame) - titleMargin*2 - (CGRectIsNull(leftRect)?0:CGRectGetMaxX(leftRect)) - (CGRectIsNull(rightRect)?0:CGRectGetWidth(self.frame)-CGRectGetMinX(rightRect));
        CGFloat maxHeight = self.frame.size.height;

        CGSize sizeThatFits = [self.titleBarButton.customView sizeThatFits:CGSizeMake(maxWidth, maxHeight)];

        CGRect titleRect = CGRectZero;

        CGFloat x = titleMargin;

        if (sizeThatFits.width > 0 && sizeThatFits.height > 0)
        {
            CGFloat width = MIN(sizeThatFits.width, maxWidth);
            CGFloat height = MIN(sizeThatFits.height, maxHeight);
            
            if (CGRectIsNull(leftRect) == false)
            {
                x = titleMargin + CGRectGetMaxX(leftRect) + ((maxWidth - width)/2);
            }
            
            CGFloat y = (maxHeight - height)/2;
            
            titleRect = CGRectMake(x, y, width, height);
        }
        else
        {
            if (CGRectIsNull(leftRect) == false)
            {
                x = titleMargin + CGRectGetMaxX(leftRect);
            }
            
            CGFloat width = CGRectGetWidth(self.frame) - titleMargin*2 - (CGRectIsNull(leftRect)?0:CGRectGetMaxX(leftRect)) - (CGRectIsNull(rightRect)?0:CGRectGetWidth(self.frame)-CGRectGetMinX(rightRect));
            
            titleRect = CGRectMake(x, 0, width, maxHeight);
        }
        
        self.titleBarButton.customView.frame = titleRect;
    }
}

#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL) enableInputClicksWhenVisible
{
	return YES;
}

@end
