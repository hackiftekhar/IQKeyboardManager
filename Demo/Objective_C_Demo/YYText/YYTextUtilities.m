//
//  YYTextUtilities.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/6.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextUtilities.h"
#import <Accelerate/Accelerate.h>
#import "UIView+YYText.h"

NSCharacterSet *YYTextVerticalFormRotateCharacterSet() {
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet new];
        [set addCharactersInRange:NSMakeRange(0x1100, 256)]; // Hangul Jamo
        [set addCharactersInRange:NSMakeRange(0x2460, 160)]; // Enclosed Alphanumerics
        [set addCharactersInRange:NSMakeRange(0x2600, 256)]; // Miscellaneous Symbols
        [set addCharactersInRange:NSMakeRange(0x2700, 192)]; // Dingbats
        [set addCharactersInRange:NSMakeRange(0x2E80, 128)]; // CJK Radicals Supplement
        [set addCharactersInRange:NSMakeRange(0x2F00, 224)]; // Kangxi Radicals
        [set addCharactersInRange:NSMakeRange(0x2FF0, 16)]; // Ideographic Description Characters
        [set addCharactersInRange:NSMakeRange(0x3000, 64)]; // CJK Symbols and Punctuation
        [set removeCharactersInRange:NSMakeRange(0x3008, 10)];
        [set removeCharactersInRange:NSMakeRange(0x3014, 12)];
        [set addCharactersInRange:NSMakeRange(0x3040, 96)]; // Hiragana
        [set addCharactersInRange:NSMakeRange(0x30A0, 96)]; // Katakana
        [set addCharactersInRange:NSMakeRange(0x3100, 48)]; // Bopomofo
        [set addCharactersInRange:NSMakeRange(0x3130, 96)]; // Hangul Compatibility Jamo
        [set addCharactersInRange:NSMakeRange(0x3190, 16)]; // Kanbun
        [set addCharactersInRange:NSMakeRange(0x31A0, 32)]; // Bopomofo Extended
        [set addCharactersInRange:NSMakeRange(0x31C0, 48)]; // CJK Strokes
        [set addCharactersInRange:NSMakeRange(0x31F0, 16)]; // Katakana Phonetic Extensions
        [set addCharactersInRange:NSMakeRange(0x3200, 256)]; // Enclosed CJK Letters and Months
        [set addCharactersInRange:NSMakeRange(0x3300, 256)]; // CJK Compatibility
        [set addCharactersInRange:NSMakeRange(0x3400, 2582)]; // CJK Unified Ideographs Extension A
        [set addCharactersInRange:NSMakeRange(0x4E00, 20941)]; // CJK Unified Ideographs
        [set addCharactersInRange:NSMakeRange(0xAC00, 11172)]; // Hangul Syllables
        [set addCharactersInRange:NSMakeRange(0xD7B0, 80)]; // Hangul Jamo Extended-B
        [set addCharactersInString:@""]; // U+F8FF (Private Use Area)
        [set addCharactersInRange:NSMakeRange(0xF900, 512)]; // CJK Compatibility Ideographs
        [set addCharactersInRange:NSMakeRange(0xFE10, 16)]; // Vertical Forms
        [set addCharactersInRange:NSMakeRange(0xFF00, 240)]; // Halfwidth and Fullwidth Forms
        [set addCharactersInRange:NSMakeRange(0x1F200, 256)]; // Enclosed Ideographic Supplement
        [set addCharactersInRange:NSMakeRange(0x1F300, 768)]; // Enclosed Ideographic Supplement
        [set addCharactersInRange:NSMakeRange(0x1F600, 80)]; // Emoticons (Emoji)
        [set addCharactersInRange:NSMakeRange(0x1F680, 128)]; // Transport and Map Symbols
        
        // See http://unicode-table.com/ for more information.
    });
    return set;
}

NSCharacterSet *YYTextVerticalFormRotateAndMoveCharacterSet() {
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet new];
        [set addCharactersInString:@"，。、．"];
    });
    return set;
}

// return 0 when succeed
static int matrix_invert(__CLPK_integer N, double *matrix) {
    __CLPK_integer error = 0;
    __CLPK_integer pivot_tmp[6 * 6];
    __CLPK_integer *pivot = pivot_tmp;
    double workspace_tmp[6 * 6];
    double *workspace = workspace_tmp;
    bool need_free = false;
    
    if (N > 6) {
        need_free = true;
        pivot = malloc(N * N * sizeof(__CLPK_integer));
        if (!pivot) return -1;
        workspace = malloc(N * sizeof(double));
        if (!workspace) {
            free(pivot);
            return -1;
        }
    }
    
    dgetrf_(&N, &N, matrix, &N, pivot, &error);
    
    if (error == 0) {
        dgetri_(&N, matrix, &N, pivot, workspace, &N, &error);
    }
    
    if (need_free) {
        free(pivot);
        free(workspace);
    }
    return error;
}

CGAffineTransform YYTextCGAffineTransformGetFromPoints(CGPoint before[3], CGPoint after[3]) {
    if (before == NULL || after == NULL) return CGAffineTransformIdentity;
    
    CGPoint p1, p2, p3, q1, q2, q3;
    p1 = before[0]; p2 = before[1]; p3 = before[2];
    q1 =  after[0]; q2 =  after[1]; q3 =  after[2];
    
    double A[36];
    A[ 0] = p1.x; A[ 1] = p1.y; A[ 2] = 0; A[ 3] = 0; A[ 4] = 1; A[ 5] = 0;
    A[ 6] = 0; A[ 7] = 0; A[ 8] = p1.x; A[ 9] = p1.y; A[10] = 0; A[11] = 1;
    A[12] = p2.x; A[13] = p2.y; A[14] = 0; A[15] = 0; A[16] = 1; A[17] = 0;
    A[18] = 0; A[19] = 0; A[20] = p2.x; A[21] = p2.y; A[22] = 0; A[23] = 1;
    A[24] = p3.x; A[25] = p3.y; A[26] = 0; A[27] = 0; A[28] = 1; A[29] = 0;
    A[30] = 0; A[31] = 0; A[32] = p3.x; A[33] = p3.y; A[34] = 0; A[35] = 1;
    
    int error = matrix_invert(6, A);
    if (error) return CGAffineTransformIdentity;
    
    double B[6];
    B[0] = q1.x; B[1] = q1.y; B[2] = q2.x; B[3] = q2.y; B[4] = q3.x; B[5] = q3.y;
    
    double M[6];
    M[0] = A[ 0] * B[0] + A[ 1] * B[1] + A[ 2] * B[2] + A[ 3] * B[3] + A[ 4] * B[4] + A[ 5] * B[5];
    M[1] = A[ 6] * B[0] + A[ 7] * B[1] + A[ 8] * B[2] + A[ 9] * B[3] + A[10] * B[4] + A[11] * B[5];
    M[2] = A[12] * B[0] + A[13] * B[1] + A[14] * B[2] + A[15] * B[3] + A[16] * B[4] + A[17] * B[5];
    M[3] = A[18] * B[0] + A[19] * B[1] + A[20] * B[2] + A[21] * B[3] + A[22] * B[4] + A[23] * B[5];
    M[4] = A[24] * B[0] + A[25] * B[1] + A[26] * B[2] + A[27] * B[3] + A[28] * B[4] + A[29] * B[5];
    M[5] = A[30] * B[0] + A[31] * B[1] + A[32] * B[2] + A[33] * B[3] + A[34] * B[4] + A[35] * B[5];
    
    CGAffineTransform transform = CGAffineTransformMake(M[0], M[2], M[1], M[3], M[4], M[5]);
    return transform;
}

CGAffineTransform YYTextCGAffineTransformGetFromViews(UIView *from, UIView *to) {
    if (!from || !to) return CGAffineTransformIdentity;
    
    CGPoint before[3], after[3];
    before[0] = CGPointMake(0, 0);
    before[1] = CGPointMake(0, 1);
    before[2] = CGPointMake(1, 0);
    after[0] = [from yy_convertPoint:before[0] toViewOrWindow:to];
    after[1] = [from yy_convertPoint:before[1] toViewOrWindow:to];
    after[2] = [from yy_convertPoint:before[2] toViewOrWindow:to];
    
    return YYTextCGAffineTransformGetFromPoints(before, after);
}

UIViewContentMode YYTextCAGravityToUIViewContentMode(NSString *gravity) {
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{ kCAGravityCenter:@(UIViewContentModeCenter),
                 kCAGravityTop:@(UIViewContentModeTop),
                 kCAGravityBottom:@(UIViewContentModeBottom),
                 kCAGravityLeft:@(UIViewContentModeLeft),
                 kCAGravityRight:@(UIViewContentModeRight),
                 kCAGravityTopLeft:@(UIViewContentModeTopLeft),
                 kCAGravityTopRight:@(UIViewContentModeTopRight),
                 kCAGravityBottomLeft:@(UIViewContentModeBottomLeft),
                 kCAGravityBottomRight:@(UIViewContentModeBottomRight),
                 kCAGravityResize:@(UIViewContentModeScaleToFill),
                 kCAGravityResizeAspect:@(UIViewContentModeScaleAspectFit),
                 kCAGravityResizeAspectFill:@(UIViewContentModeScaleAspectFill) };
    });
    if (!gravity) return UIViewContentModeScaleToFill;
    return (UIViewContentMode)((NSNumber *)dic[gravity]).integerValue;
}

NSString *YYTextUIViewContentModeToCAGravity(UIViewContentMode contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: return kCAGravityResize;
        case UIViewContentModeScaleAspectFit: return kCAGravityResizeAspect;
        case UIViewContentModeScaleAspectFill: return kCAGravityResizeAspectFill;
        case UIViewContentModeRedraw: return kCAGravityResize;
        case UIViewContentModeCenter: return kCAGravityCenter;
        case UIViewContentModeTop: return kCAGravityTop;
        case UIViewContentModeBottom: return kCAGravityBottom;
        case UIViewContentModeLeft: return kCAGravityLeft;
        case UIViewContentModeRight: return kCAGravityRight;
        case UIViewContentModeTopLeft: return kCAGravityTopLeft;
        case UIViewContentModeTopRight: return kCAGravityTopRight;
        case UIViewContentModeBottomLeft: return kCAGravityBottomLeft;
        case UIViewContentModeBottomRight: return kCAGravityBottomRight;
        default: return kCAGravityResize;
    }
}

CGRect YYTextCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode) {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}

CGFloat YYTextScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

CGSize YYTextScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}


BOOL YYTextIsAppExtension() {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
    return isAppExtension;
}

UIApplication *YYTextSharedApplication() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return YYTextIsAppExtension() ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}
