//
//  UITextField+IQKeyboardManager.m
//
//  Created by Tj on 2/25/15.
//

#import "UITextField+IQKeyboardManager.h"
#import <objc/runtime.h>

static char kIQTextFieldKeyboardDistanceKey;

@implementation UITextField (IQKeyboardManager)

@dynamic keyboardDistance;

- (void)setKeyboardDistance:(NSInteger)keyboardDistance
{
    objc_setAssociatedObject(self, &kIQTextFieldKeyboardDistanceKey, @(keyboardDistance), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)keyboardDistance
{
    NSNumber *distance = objc_getAssociatedObject(self, &kIQTextFieldKeyboardDistanceKey);
    return [distance integerValue];
}

@end
