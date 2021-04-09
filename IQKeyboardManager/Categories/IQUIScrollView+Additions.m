//
// IQUIScrollView+Additions.m
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

#import "IQUIScrollView+Additions.h"
#import <objc/runtime.h>

@implementation UIScrollView (Additions)

-(void)setShouldIgnoreScrollingAdjustment:(BOOL)shouldIgnoreScrollingAdjustment
{
    objc_setAssociatedObject(self, @selector(shouldIgnoreScrollingAdjustment), @(shouldIgnoreScrollingAdjustment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)shouldIgnoreScrollingAdjustment
{
    NSNumber *shouldIgnoreScrollingAdjustment = objc_getAssociatedObject(self, @selector(shouldIgnoreScrollingAdjustment));
    
    return [shouldIgnoreScrollingAdjustment boolValue];
}

-(void)setShouldIgnoreContentInsetAdjustment:(BOOL)shouldIgnoreContentInsetAdjustment
{
    objc_setAssociatedObject(self, @selector(shouldIgnoreContentInsetAdjustment), @(shouldIgnoreContentInsetAdjustment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)shouldIgnoreContentInsetAdjustment
{
    NSNumber *shouldIgnoreContentInsetAdjustment = objc_getAssociatedObject(self, @selector(shouldIgnoreContentInsetAdjustment));
    
    return [shouldIgnoreContentInsetAdjustment boolValue];
}

-(void)setShouldRestoreScrollViewContentOffset:(BOOL)shouldRestoreScrollViewContentOffset
{
    objc_setAssociatedObject(self, @selector(shouldRestoreScrollViewContentOffset), @(shouldRestoreScrollViewContentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)shouldRestoreScrollViewContentOffset
{
    NSNumber *shouldRestoreScrollViewContentOffset = objc_getAssociatedObject(self, @selector(shouldRestoreScrollViewContentOffset));
    
    return [shouldRestoreScrollViewContentOffset boolValue];
}

@end

@implementation UITableView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
{
    NSInteger previousRow = indexPath.row - 1;
    NSInteger previousSection = indexPath.section;
    
    //Fixing indexPath
    if (previousRow < 0)
    {
        previousSection -= 1;
        
        if (previousSection >= 0)
        {
            previousRow = [self numberOfRowsInSection:previousSection]-1;
        }
    }
    
    if (previousRow >= 0 && previousSection >= 0)
    {
        return [NSIndexPath indexPathForRow:previousRow inSection:previousSection];
    }
    
    return nil;
}

//-(nullable NSIndexPath*)nextIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
//{
//    NSInteger nextRow = indexPath.row + 1;
//    NSInteger nextSection = indexPath.section;
//
//    //Fixing indexPath
//    if (nextRow >= [self numberOfRowsInSection:nextSection])
//    {
//        nextRow = 0;
//        nextSection += 1;
//    }
//
//    if (self.numberOfSections > nextSection && [self numberOfRowsInSection:nextSection] > nextRow)
//    {
//        return [NSIndexPath indexPathForItem:nextRow inSection:nextSection];
//    }
//
//    return nil;
//}
//
@end

@implementation UICollectionView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
{
    NSInteger previousRow = indexPath.row - 1;
    NSInteger previousSection = indexPath.section;
    
    //Fixing indexPath
    if (previousRow < 0)
    {
        previousSection -= 1;
        
        if (previousSection >= 0)
        {
            previousRow = [self numberOfItemsInSection:previousSection]-1;
        }
    }
    
    if (previousRow >= 0 && previousSection >= 0)
    {
        return [NSIndexPath indexPathForItem:previousRow inSection:previousSection];
    }
    
    return nil;
}

//-(nullable NSIndexPath*)nextIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
//{
//    NSInteger nextRow = indexPath.row + 1;
//    NSInteger nextSection = indexPath.section;
//    
//    //Fixing indexPath
//    if (nextRow >= [self numberOfItemsInSection:nextSection])
//    {
//        nextRow = 0;
//        nextSection += 1;
//    }
//    
//    if (self.numberOfSections > nextSection && [self numberOfItemsInSection:nextSection] > nextRow)
//    {
//        return [NSIndexPath indexPathForItem:nextRow inSection:nextSection];
//    }
//    
//    return nil;
//}

@end
