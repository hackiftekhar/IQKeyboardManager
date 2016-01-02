//
//  IQBarButtonItem.m
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

#import "IQBarButtonItem.h"
#import "IQToolbar.h"
#import "IQKeyboardManagerConstantsInternal.h"

@implementation IQBarButtonItem

+(void)load
{
    //Tint color
    [[self appearance] setTintColor:nil];

    //Title
    [[self appearance] setTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateHighlighted];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateSelected];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateApplication];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateReserved];
    
    //Background Image
    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       barMetrics:UIBarMetricsDefault];

    
#ifdef __IPHONE_8_0
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    
    if (IQ_IS_IOS8_OR_GREATER)
    {
        [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
        [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
        [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
        [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
        [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
        [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    }

    #endif

#else
    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
#endif

    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    
    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];

    [[self appearance] setBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    
    //Back Button
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateNormal       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted  barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateDisabled     barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateSelected     barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateApplication  barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateReserved     barMetrics:UIBarMetricsDefault];
    
    [[self appearance] setBackButtonTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

@end
