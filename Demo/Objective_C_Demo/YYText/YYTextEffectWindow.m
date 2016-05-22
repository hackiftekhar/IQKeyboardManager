//
//  YYTextEffectWindow.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/2/25.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextEffectWindow.h"
#import "YYTextKeyboardManager.h"
#import "YYTextUtilities.h"
#import "UIView+YYText.h"


@implementation YYTextEffectWindow

+ (instancetype)sharedWindow {
    static YYTextEffectWindow *one = nil;
    if (one == nil) {
        // iOS 9 compatible
        NSString *mode = [NSRunLoop currentRunLoop].currentMode;
        if (mode.length == 27 &&
            [mode hasPrefix:@"UI"] &&
            [mode hasSuffix:@"InitializationRunLoopMode"]) {
            return nil;
        }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!YYTextIsAppExtension()) {
            one = [self new];
            one.frame = (CGRect){.size = YYTextScreenSize()};
            one.userInteractionEnabled = NO;
            one.windowLevel = UIWindowLevelStatusBar + 1;
            one.hidden = NO;
            
            // for iOS 9:
            one.opaque = NO;
            one.backgroundColor = [UIColor clearColor];
            one.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    });
    return one;
}

- (UIViewController *)rootViewController {
    for (UIWindow *window in [YYTextSharedApplication() windows]) {
        if (self == window) continue;
        if (window.hidden) continue;
        UIViewController *topViewController = window.rootViewController;
        if (topViewController) return topViewController;
    }
    UIViewController *viewController = [super rootViewController];
    if (!viewController) {
        viewController = [UIViewController new];
        [super setRootViewController:viewController];
    }
    return viewController;
}

// Bring self to front
- (void)_updateWindowLevel {
    UIApplication *app = YYTextSharedApplication();
    if (!app) return;
    
    UIWindow *top = app.windows.lastObject;
    UIWindow *key = app.keyWindow;
    if (key && key.windowLevel > top.windowLevel) top = key;
    if (top == self) return;
    self.windowLevel = top.windowLevel + 1;
}

- (YYTextDirection)_keyboardDirection {
    CGRect keyboardFrame = [YYTextKeyboardManager defaultManager].keyboardFrame;
    keyboardFrame = [[YYTextKeyboardManager defaultManager] convertRect:keyboardFrame toView:self];
    if (CGRectIsNull(keyboardFrame) || CGRectIsEmpty(keyboardFrame)) return YYTextDirectionNone;
    
    if (CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame))
        return YYTextDirectionTop;
    
    if (CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame) &&
        CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame))
        return YYTextDirectionRight;
    
    if (CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame) &&
        CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame))
        return YYTextDirectionBottom;
    
    if (CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame))
        return YYTextDirectionLeft;
    
    return YYTextDirectionNone;
}

- (CGPoint)_correctedCaptureCenter:(CGPoint)center{
    CGRect keyboardFrame = [YYTextKeyboardManager defaultManager].keyboardFrame;
    keyboardFrame = [[YYTextKeyboardManager defaultManager] convertRect:keyboardFrame toView:self];
    if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
        YYTextDirection direction = [self _keyboardDirection];
        switch (direction) {
            case YYTextDirectionTop: {
                if (center.y < CGRectGetMaxY(keyboardFrame)) center.y = CGRectGetMaxY(keyboardFrame);
            } break;
            case YYTextDirectionRight: {
                if (center.x > CGRectGetMinX(keyboardFrame)) center.x = CGRectGetMinX(keyboardFrame);
            } break;
            case YYTextDirectionBottom: {
                if (center.y > CGRectGetMinY(keyboardFrame)) center.y = CGRectGetMinY(keyboardFrame);
            } break;
            case YYTextDirectionLeft: {
                if (center.x < CGRectGetMaxX(keyboardFrame)) center.x = CGRectGetMaxX(keyboardFrame);
            } break;
            default: break;
        }
    }
    return center;
}

- (CGPoint)_correctedCenter:(CGPoint)center forMagnifier:(YYTextMagnifier *)mag rotation:(CGFloat)rotation {
    CGFloat degree = YYTextRadiansToDegrees(rotation);
    
    degree /= 45.0;
    if (degree < 0) degree += (int)(-degree/8.0 + 1) * 8;
    if (degree > 8) degree -= (int)(degree/8.0) * 8;
    
    CGFloat caretExt = 10;
    if (degree <= 1 || degree >= 7) { //top
        if (mag.type == YYTextMagnifierTypeCaret) {
            if (center.y < caretExt)
                center.y = caretExt;
        } else if (mag.type == YYTextMagnifierTypeRanged) {
            if (center.y < mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (1 < degree && degree < 3) { // right
        if (mag.type == YYTextMagnifierTypeCaret) {
            if (center.x > self.bounds.size.width - caretExt)
                center.x = self.bounds.size.width - caretExt;
        } else if (mag.type == YYTextMagnifierTypeRanged) {
            if (center.x > self.bounds.size.width - mag.bounds.size.height)
                center.x = self.bounds.size.width - mag.bounds.size.height;
        }
    } else if (3 <= degree && degree <= 5) { // bottom
        if (mag.type == YYTextMagnifierTypeCaret) {
            if (center.y > self.bounds.size.height - caretExt)
                center.y = self.bounds.size.height - caretExt;
        } else if (mag.type == YYTextMagnifierTypeRanged) {
            if (center.y > mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (5 < degree && degree < 7) { // left
        if (mag.type == YYTextMagnifierTypeCaret) {
            if (center.x < caretExt)
                center.x = caretExt;
        } else if (mag.type == YYTextMagnifierTypeRanged) {
            if (center.x < mag.bounds.size.height)
                center.x = mag.bounds.size.height;
        }
    }

    
    CGRect keyboardFrame = [YYTextKeyboardManager defaultManager].keyboardFrame;
    keyboardFrame = [[YYTextKeyboardManager defaultManager] convertRect:keyboardFrame toView:self];
    if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
        YYTextDirection direction = [self _keyboardDirection];
        switch (direction) {
            case YYTextDirectionTop: {
                if (mag.type == YYTextMagnifierTypeCaret) {
                    if (center.y - mag.bounds.size.height / 2 < CGRectGetMaxY(keyboardFrame))
                        center.y = CGRectGetMaxY(keyboardFrame) + mag.bounds.size.height / 2;
                } else if (mag.type == YYTextMagnifierTypeRanged) {
                    if (center.y < CGRectGetMaxY(keyboardFrame)) center.y = CGRectGetMaxY(keyboardFrame);
                }
            } break;
            case YYTextDirectionRight: {
                if (mag.type == YYTextMagnifierTypeCaret) {
                    if (center.x + mag.bounds.size.height / 2 > CGRectGetMinX(keyboardFrame))
                        center.x = CGRectGetMinX(keyboardFrame) - mag.bounds.size.width / 2;
                } else if (mag.type == YYTextMagnifierTypeRanged) {
                    if (center.x > CGRectGetMinX(keyboardFrame)) center.x = CGRectGetMinX(keyboardFrame);
                }
            } break;
            case YYTextDirectionBottom: {
                if (mag.type == YYTextMagnifierTypeCaret) {
                    if (center.y + mag.bounds.size.height / 2 > CGRectGetMinY(keyboardFrame))
                        center.y = CGRectGetMinY(keyboardFrame) - mag.bounds.size.height / 2;
                } else if (mag.type == YYTextMagnifierTypeRanged) {
                    if (center.y > CGRectGetMinY(keyboardFrame)) center.y = CGRectGetMinY(keyboardFrame);
                }
            } break;
            case YYTextDirectionLeft: {
                if (mag.type == YYTextMagnifierTypeCaret) {
                    if (center.x - mag.bounds.size.height / 2 < CGRectGetMaxX(keyboardFrame))
                        center.x = CGRectGetMaxX(keyboardFrame) + mag.bounds.size.width / 2;
                } else if (mag.type == YYTextMagnifierTypeRanged) {
                    if (center.x < CGRectGetMaxX(keyboardFrame)) center.x = CGRectGetMaxX(keyboardFrame);
                }
            } break;
            default: break;
        }
    }
    
    return center;
}

/**
 Capture screen snapshot and set it to magnifier.
 @return Magnifier rotation radius.
 */
- (CGFloat)_updateMagnifier:(YYTextMagnifier *)mag {
    UIApplication *app = YYTextSharedApplication();
    if (!app) return 0;
    
    UIView *hostView = mag.hostView;
    UIWindow *hostWindow = [hostView isKindOfClass:[UIWindow class]] ? (id)hostView : hostView.window;
    if (!hostView || !hostWindow) return 0;
    CGPoint captureCenter = [self yy_convertPoint:mag.hostCaptureCenter fromViewOrWindow:hostView];
    captureCenter = [self _correctedCaptureCenter:captureCenter];
    CGRect captureRect = {.size = mag.snapshotSize};
    captureRect.origin.x = captureCenter.x - captureRect.size.width / 2;
    captureRect.origin.y = captureCenter.y - captureRect.size.height / 2;
    
    CGAffineTransform trans = YYTextCGAffineTransformGetFromViews(hostView, self);
    CGFloat rotation = YYTextCGAffineTransformGetRotation(trans);
    
    if (mag.captureDisabled) {
        if (!mag.snapshot || mag.snapshot.size.width > 1) {
            static UIImage *placeholder;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect rect = mag.bounds;
                rect.origin = CGPointZero;
                UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [[UIColor colorWithWhite:1 alpha:0.8] set];
                CGContextFillRect(context, rect);
                placeholder = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            mag.captureFadeAnimation = YES;
            mag.snapshot = placeholder;
            mag.captureFadeAnimation = NO;
        }
        return rotation;
    }
    
    UIGraphicsBeginImageContextWithOptions(captureRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return rotation;
    
    CGPoint tp = CGPointMake(captureRect.size.width / 2, captureRect.size.height / 2);
    tp = CGPointApplyAffineTransform(tp, CGAffineTransformMakeRotation(rotation));
    CGContextRotateCTM(context, -rotation);
    CGContextTranslateCTM(context, tp.x - captureCenter.x, tp.y - captureCenter.y);
    
    NSMutableArray *windows = app.windows.mutableCopy;
    UIWindow *keyWindow = app.keyWindow;
    if (![windows containsObject:keyWindow]) [windows addObject:keyWindow];
    [windows sortUsingComparator:^NSComparisonResult(UIWindow *w1, UIWindow *w2) {
        if (w1.windowLevel < w2.windowLevel) return NSOrderedAscending;
        else if (w1.windowLevel > w2.windowLevel) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    UIScreen *mainScreen = [UIScreen mainScreen];
    for (UIWindow *window in windows) {
        if (window.hidden || window.alpha <= 0.01) continue;
        if (window.screen != mainScreen) continue;
        if ([window isKindOfClass:self.class]) break; //don't capture window above self
        CGContextSaveGState(context);
        CGContextConcatCTM(context, YYTextCGAffineTransformGetFromViews(window, self));
        [window.layer renderInContext:context]; //render
        //[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]; //slower when capture whole window
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (mag.snapshot.size.width == 1) {
        mag.captureFadeAnimation = YES;
    }
    mag.snapshot = image;
    mag.captureFadeAnimation = NO;
    return rotation;
}

- (void)showMagnifier:(YYTextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) [self addSubview:mag];
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self yy_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
    trans = CGAffineTransformScale(trans, 0.3, 0.3);
    mag.transform = trans;
    mag.center = center;
    if (mag.type == YYTextMagnifierTypeRanged) {
        mag.alpha = 0;
    }
    NSTimeInterval time = mag.type == YYTextMagnifierTypeCaret ? 0.08 : 0.1;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (mag.type == YYTextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
        }
        mag.transform = CGAffineTransformMakeRotation(rotation);
        mag.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveMagnifier:(YYTextMagnifier *)mag {
    if (!mag) return;
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self yy_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    if (mag.type == YYTextMagnifierTypeCaret) {
        CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
        newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
        newCenter.x += center.x;
        newCenter.y += center.y;
        mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
    } else {
        mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
    }
    mag.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)hideMagnifier:(YYTextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) return;
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self yy_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    NSTimeInterval time = mag.type == YYTextMagnifierTypeCaret ? 0.20 : 0.15;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
        trans = CGAffineTransformScale(trans, 0.01, 0.01);
        mag.transform = trans;
        
        if (mag.type == YYTextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
            mag.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [mag removeFromSuperview];
            mag.transform = CGAffineTransformIdentity;
            mag.alpha = 1;
        }
    }];
}

- (void)_updateSelectionGrabberDot:(YYSelectionGrabberDot *)dot selection:(YYTextSelectionView *)selection{
    dot.mirror.hidden = YES;
    if (selection.hostView.clipsToBounds == YES && dot.yy_visibleAlpha > 0.1) {
        CGRect dotRect = [dot yy_convertRect:dot.bounds toViewOrWindow:self];
        BOOL dotInKeyboard = NO;
        
        CGRect keyboardFrame = [YYTextKeyboardManager defaultManager].keyboardFrame;
        keyboardFrame = [[YYTextKeyboardManager defaultManager] convertRect:keyboardFrame toView:self];
        if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
            CGRect inter = CGRectIntersection(dotRect, keyboardFrame);
            if (!CGRectIsNull(inter) && (inter.size.width > 1 || inter.size.height > 1)) {
                dotInKeyboard = YES;
            }
        }
        if (!dotInKeyboard) {
            CGRect hostRect = [selection.hostView convertRect:selection.hostView.bounds toView:self];
            CGRect intersection = CGRectIntersection(dotRect, hostRect);
            if (YYTextCGRectGetArea(intersection) < YYTextCGRectGetArea(dotRect)) {
                CGFloat dist = YYTextCGPointGetDistanceToRect(YYTextCGRectGetCenter(dotRect), hostRect);
                if (dist < CGRectGetWidth(dot.frame) * 0.55) {
                    dot.mirror.hidden = NO;
                }
            }
        }
    }
    CGPoint center = [dot yy_convertPoint:CGPointMake(CGRectGetWidth(dot.frame) / 2, CGRectGetHeight(dot.frame) / 2) toViewOrWindow:self];
    dot.mirror.center = center;
}

- (void)showSelectionDot:(YYTextSelectionView *)selection {
    if (!selection) return;
    [self _updateWindowLevel];
    [self insertSubview:selection.startGrabber.dot.mirror atIndex:0];
    [self insertSubview:selection.endGrabber.dot.mirror atIndex:0];
    [self _updateSelectionGrabberDot:selection.startGrabber.dot selection:selection];
    [self _updateSelectionGrabberDot:selection.endGrabber.dot selection:selection];
}

- (void)hideSelectionDot:(YYTextSelectionView *)selection {
    if (!selection) return;
    [selection.startGrabber.dot.mirror removeFromSuperview];
    [selection.endGrabber.dot.mirror removeFromSuperview];
}

@end
