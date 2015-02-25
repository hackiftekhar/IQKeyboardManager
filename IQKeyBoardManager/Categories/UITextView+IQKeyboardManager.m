//
//  UITextView+SIQKeyboardManager.m
//
//  Created by Tj on 2/25/15.
//

#import "UITextView+IQKeyboardManager.h"
#import <objc/runtime.h>

static char kIQTextViewKeyboardDistanceKey;

@implementation UITextView (Skillz)

- (void)setKeyboardDistance:(NSInteger)keyboardDistance
{
    objc_setAssociatedObject(self, &kIQTextViewKeyboardDistanceKey, @(keyboardDistance), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)keyboardDistance
{
    NSNumber *distance = objc_getAssociatedObject(self, &kIQTextViewKeyboardDistanceKey);
    return [distance integerValue];
}

@end
