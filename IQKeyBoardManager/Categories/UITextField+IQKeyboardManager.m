//
//  UITextField+IQKeyboardManager.m
//
//  Created by Tj on 2/25/15.
//

#import "UITextField+IQKeyboardManager.h"
#import <objc/runtime.h>

@implementation UITextField (IQKeyboardManager)

@dynamic keyboardDistance;

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
