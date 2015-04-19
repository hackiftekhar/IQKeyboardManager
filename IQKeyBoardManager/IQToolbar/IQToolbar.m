//
//  IQToolbar.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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

#if !(__has_feature(objc_instancetype))
    #define instancetype id
#endif


@implementation IQToolbar
@synthesize titleFont = _titleFont;
@synthesize title = _title;

+(void)initialize
{
    [super initialize];
    
    [[self appearance] setTintColor:nil];
    
#ifdef NSFoundationVersionNumber_iOS_6_1
    if ([[self appearance] respondsToSelector:@selector(setBarTintColor:)])
    {
        [[self appearance] setBarTintColor:nil];
    }
#endif
    
    [[self appearance] setBackgroundColor:nil];
}

-(void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight;
    
     if (IQ_IS_IOS7_OR_GREATER)
    {
        [self setTintColor:[UIColor blackColor]];
    }
    else
    {
        [self setBarStyle:UIBarStyleBlackTranslucent];
    }
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
        }
    }
}

#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL) enableInputClicksWhenVisible
{
	return YES;
}

@end
