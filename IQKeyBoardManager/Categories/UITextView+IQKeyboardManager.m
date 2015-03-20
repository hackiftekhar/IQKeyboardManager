//
//  UITextView+SIQKeyboardManager.m
//
//  Created by Tj on 2/25/15.
//

#import "UITextView+IQKeyboardManager.h"
#import <objc/runtime.h>

@implementation UITextView (Skillz)

- (void)setKeyboardDistance:(NSInteger)keyboardDistance
{
    objc_setAssociatedObject(self, @selector(keyboardDistance), @(keyboardDistance), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)keyboardDistance
{
    NSNumber *distance = objc_getAssociatedObject(self, @selector(keyboardDistance));
    return [distance integerValue];
}

@end
