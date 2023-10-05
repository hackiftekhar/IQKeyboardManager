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

#import <UIKit/UIKit.h>

#import "IQToolbar.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQUIView+Hierarchy.h"


NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@implementation IQToolbar
@synthesize previousBarButton = _previousBarButton;
@synthesize nextBarButton = _nextBarButton;
@synthesize titleBarButton = _titleBarButton;
@synthesize doneBarButton = _doneBarButton;
@synthesize fixedSpaceBarButton = _fixedSpaceBarButton;

-(void)initialize
{
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight;
    self.translucent = YES;
    self.barTintColor = nil;

    NSArray <NSNumber*> *positions = @[@(UIBarPositionAny),@(UIBarPositionBottom),@(UIBarPositionTop),@(UIBarPositionTopAttached)];

    for (NSNumber *position in positions)
    {
        UIToolbarPosition toolbarPosition = [position unsignedIntegerValue];

        [self setBackgroundImage:nil forToolbarPosition:toolbarPosition barMetrics:UIBarMetricsDefault];
        [self setShadowImage:nil forToolbarPosition:toolbarPosition];
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

-(void)dealloc
{
    self.items = nil;
}

-(IQBarButtonItem *)previousBarButton
{
    if (_previousBarButton == nil)
    {
        _previousBarButton = [[IQBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _previousBarButton;
}

-(IQBarButtonItem *)nextBarButton
{
    if (_nextBarButton == nil)
    {
        _nextBarButton = [[IQBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _nextBarButton;
}

-(IQTitleBarButtonItem *)titleBarButton
{
    if (_titleBarButton == nil)
    {
        _titleBarButton = [[IQTitleBarButtonItem alloc] initWithTitle:nil];
        _titleBarButton.accessibilityLabel = @"Title";
        _titleBarButton.accessibilityIdentifier = _titleBarButton.accessibilityLabel;
    }
    
    return _titleBarButton;
}

-(IQBarButtonItem *)doneBarButton
{
    if (_doneBarButton == nil)
    {
        _doneBarButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
    }
    
    return _doneBarButton;
}

-(IQBarButtonItem *)fixedSpaceBarButton
{
    if (_fixedSpaceBarButton == nil)
    {
        _fixedSpaceBarButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [_fixedSpaceBarButton setWidth:6];
    }
    
    return _fixedSpaceBarButton;
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

#pragma mark - UIInputViewAudioFeedback delegate
- (BOOL) enableInputClicksWhenVisible
{
	return YES;
}

@end
