//
//  IQTitleBarButtonItem.m
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

#import "IQTitleBarButtonItem.h"
#import "IQKeyboardManagerConstants.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import <UIKit/UILabel.h>

@implementation IQTitleBarButtonItem
{
    UIView *_titleView;
    UILabel *_titleLabel;
}
@synthesize font = _font;


-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super init];
    if (self)
    {
        _titleView = [[UIView alloc] initWithFrame:frame];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _titleLabel = [[UILabel alloc] initWithFrame:_titleView.bounds];

        [_titleLabel setTextColor:[UIColor lightGrayColor]];
        
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setTitle:title];
        [self setFont:[UIFont boldSystemFontOfSize:12.0]];
        [_titleView addSubview:_titleLabel];
        
        self.customView = _titleView;
        self.enabled = NO;
    }
    return self;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    [_titleLabel setFont:font];
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _titleLabel.text = title;
}

@end
