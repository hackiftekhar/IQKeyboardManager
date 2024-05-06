//
//  IQBarButtonItem.m
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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

#import "IQBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"

NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@implementation IQBarButtonItem

-(void)initialize
{
    NSArray <NSNumber*> *states = @[@(UIControlStateNormal),@(UIControlStateHighlighted),@(UIControlStateDisabled),@(UIControlStateFocused)];

    for (NSNumber *state in states)
    {
        UIControlState controlState = [state unsignedIntegerValue];

        [self setBackgroundImage:[UIImage new] forState:controlState barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:[UIImage new] forState:controlState style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
        [self setBackButtonBackgroundImage:[UIImage new] forState:controlState barMetrics:UIBarMetricsDefault];
    }

    [self setTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [self setBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    [self setBackButtonBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self initialize];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder: coder];

    if (self)
    {
        [self initialize];
    }

    return self;
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    
    //titleTextAttributes tweak is to overcome an issue comes with iOS11 where appearanceProxy set for NSForegroundColorAttributeName and bar button texts start appearing in appearance proxy color
    NSMutableDictionary *textAttributes = [[self titleTextAttributesForState:UIControlStateNormal] mutableCopy]?:[NSMutableDictionary new];
    
    textAttributes[NSForegroundColorAttributeName] = tintColor;
    
    [self setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(nullable id)target action:(nullable SEL)action
{
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    
    if (self)
    {
        _isSystemItem = YES;
    }
    
    return self;
}


-(void)setTarget:(nullable id)target action:(nullable SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }
    
    self.invocation = invocation;
}

-(void)dealloc
{
    self.target = nil;
    self.invocation = nil;
}

@end
