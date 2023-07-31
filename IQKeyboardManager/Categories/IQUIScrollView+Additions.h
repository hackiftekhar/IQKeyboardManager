//
// IQUIScrollView+Additions.h
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


@interface UIScrollView (Additions)

/**
 If YES, then scrollview will ignore scrolling (simply not scroll it) for adjusting textfield position. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldIgnoreScrollingAdjustment;

/**
 If YES, then scrollview will ignore content inset adjustment (simply not updating it) when keyboard is shown. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldIgnoreContentInsetAdjustment;

/**
 Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldRestoreScrollViewContentOffset;


@end

@interface UITableView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;
//-(nullable NSIndexPath*)nextIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;

@end

@interface UICollectionView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;
//-(nullable NSIndexPath*)nextIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;

@end
