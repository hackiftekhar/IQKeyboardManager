//
//  YYTextLayout.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/3/3.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextLayout.h"
#import "YYTextUtilities.h"
#import "YYTextAttribute.h"
#import "YYTextArchiver.h"
#import "NSAttributedString+YYText.h"

const CGSize YYTextContainerMaxSize = (CGSize){0x100000, 0x100000};

typedef struct {
    CGFloat head;
    CGFloat foot;
} YYRowEdge;

static inline CGSize YYTextClipCGSize(CGSize size) {
    if (size.width > YYTextContainerMaxSize.width) size.width = YYTextContainerMaxSize.width;
    if (size.height > YYTextContainerMaxSize.height) size.height = YYTextContainerMaxSize.height;
    return size;
}

static inline UIEdgeInsets UIEdgeInsetRotateVertical(UIEdgeInsets insets) {
    UIEdgeInsets one;
    one.top = insets.left;
    one.left = insets.bottom;
    one.bottom = insets.right;
    one.right = insets.top;
    return one;
}

/**
 Sometimes CoreText may convert CGColor to UIColor for `kCTForegroundColorAttributeName`
 attribute in iOS7. This should be a bug of CoreText, and may cause crash. Here's a workaround.
 */
static CGColorRef YYTextGetCGColor(CGColorRef color) {
    static UIColor *defaultColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultColor = [UIColor blackColor];
    });
    if (!color) return defaultColor.CGColor;
    if ([((__bridge NSObject *)color) respondsToSelector:@selector(CGColor)]) {
        return ((__bridge UIColor *)color).CGColor;
    }
    return color;
}

@implementation YYTextLinePositionSimpleModifier
- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container {
    if (container.verticalForm) {
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            YYTextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.x = container.size.width - container.insets.right - line.row * _fixedLineHeight - _fixedLineHeight * 0.9;
            line.position = pos;
        }
    } else {
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            YYTextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.y = line.row * _fixedLineHeight + _fixedLineHeight * 0.9 + container.insets.top;
            line.position = pos;
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    YYTextLinePositionSimpleModifier *one = [self.class new];
    one.fixedLineHeight = _fixedLineHeight;
    return one;
}
@end


@implementation YYTextContainer {
    @package
    BOOL _readonly; ///< used only in YYTextLayout.implementation
    dispatch_semaphore_t _lock;
    
    CGSize _size;
    UIEdgeInsets _insets;
    UIBezierPath *_path;
    NSArray *_exclusionPaths;
    BOOL _pathFillEvenOdd;
    CGFloat _pathLineWidth;
    BOOL _verticalForm;
    NSUInteger _maximumNumberOfRows;
    YYTextTruncationType _truncationType;
    NSAttributedString *_truncationToken;
    id<YYTextLinePositionModifier> _linePositionModifier;
}

+ (instancetype)containerWithSize:(CGSize)size {
    return [self containerWithSize:size insets:UIEdgeInsetsZero];
}

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets {
    YYTextContainer *one = [self new];
    one.size = YYTextClipCGSize(size);
    one.insets = insets;
    return one;
}

+ (instancetype)containerWithPath:(UIBezierPath *)path {
    if (!path) return nil;
    YYTextContainer *one = [self new];
    one.path = path;
    return one;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _lock = dispatch_semaphore_create(1);
    _pathFillEvenOdd = YES;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YYTextContainer *one = [self.class new];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    one->_size = _size;
    one->_insets = _insets;
    one->_path = _path;
    one->_exclusionPaths = _exclusionPaths.copy;
    one->_pathFillEvenOdd = _pathFillEvenOdd;
    one->_pathLineWidth = _pathLineWidth;
    one->_verticalForm = _verticalForm;
    one->_maximumNumberOfRows = _maximumNumberOfRows;
    one->_truncationType = _truncationType;
    one->_truncationToken = _truncationToken.copy;
    one->_linePositionModifier = [(NSObject *)_linePositionModifier copy];
    dispatch_semaphore_signal(_lock);
    return one;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithCGSize:_size] forKey:@"size"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:_insets] forKey:@"insets"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_exclusionPaths forKey:@"exclusionPaths"];
    [aCoder encodeBool:_pathFillEvenOdd forKey:@"pathFillEvenOdd"];
    [aCoder encodeDouble:_pathLineWidth forKey:@"pathLineWidth"];
    [aCoder encodeBool:_verticalForm forKey:@"verticalForm"];
    [aCoder encodeInteger:_maximumNumberOfRows forKey:@"maximumNumberOfRows"];
    [aCoder encodeInteger:_truncationType forKey:@"truncationType"];
    [aCoder encodeObject:_truncationToken forKey:@"truncationToken"];
    if ([_linePositionModifier respondsToSelector:@selector(encodeWithCoder:)] &&
        [_linePositionModifier respondsToSelector:@selector(initWithCoder:)]) {
        [aCoder encodeObject:_linePositionModifier forKey:@"linePositionModifier"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    _size = ((NSValue *)[aDecoder decodeObjectForKey:@"size"]).CGSizeValue;
    _insets = ((NSValue *)[aDecoder decodeObjectForKey:@"insets"]).UIEdgeInsetsValue;
    _path = [aDecoder decodeObjectForKey:@"path"];
    _exclusionPaths = [aDecoder decodeObjectForKey:@"exclusionPaths"];
    _pathFillEvenOdd = [aDecoder decodeBoolForKey:@"pathFillEvenOdd"];
    _pathLineWidth = [aDecoder decodeDoubleForKey:@"pathLineWidth"];
    _verticalForm = [aDecoder decodeBoolForKey:@"verticalForm"];
    _maximumNumberOfRows = [aDecoder decodeIntegerForKey:@"maximumNumberOfRows"];
    _truncationType = [aDecoder decodeIntegerForKey:@"truncationType"];
    _truncationToken = [aDecoder decodeObjectForKey:@"truncationToken"];
    _linePositionModifier = [aDecoder decodeObjectForKey:@"linePositionModifier"];
    return self;
}

#define Getter(...) \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

#define Setter(...) \
if (_readonly) { \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:@"Cannot change the property of the 'container' in 'YYTextLayout'." userInfo:nil]; \
return; \
} \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

- (CGSize)size {
    Getter(CGSize size = _size) return size;
}

- (void)setSize:(CGSize)size {
    Setter(if(!_path) _size = YYTextClipCGSize(size));
}

- (UIEdgeInsets)insets {
    Getter(UIEdgeInsets insets = _insets) return insets;
}

- (void)setInsets:(UIEdgeInsets)insets {
    Setter(if(!_path){
        if (insets.top < 0) insets.top = 0;
        if (insets.left < 0) insets.left = 0;
        if (insets.bottom < 0) insets.bottom = 0;
        if (insets.right < 0) insets.right = 0;
        _insets = insets;
    });
}

- (UIBezierPath *)path {
    Getter(UIBezierPath *path = _path) return path;
}

- (void)setPath:(UIBezierPath *)path {
    Setter(
           _path = path.copy;
           if (_path) {
               CGRect bounds = _path.bounds;
               CGSize size = bounds.size;
               UIEdgeInsets insets = UIEdgeInsetsZero;
               if (bounds.origin.x < 0) size.width += bounds.origin.x;
               if (bounds.origin.x > 0) insets.left = bounds.origin.x;
               if (bounds.origin.y < 0) size.height += bounds.origin.y;
               if (bounds.origin.y > 0) insets.top = bounds.origin.y;
               _size = size;
               _insets = insets;
           }
    );
}

- (NSArray *)exclusionPaths {
    Getter(NSArray *paths = _exclusionPaths) return paths;
}

- (void)setExclusionPaths:(NSArray *)exclusionPaths {
    Setter(_exclusionPaths = exclusionPaths.copy);
}

- (BOOL)isPathFillEvenOdd {
    Getter(BOOL is = _pathFillEvenOdd) return is;
}

- (void)setPathFillEvenOdd:(BOOL)pathFillEvenOdd {
    Setter(_pathFillEvenOdd = pathFillEvenOdd);
}

- (CGFloat)pathLineWidth {
    Getter(CGFloat width = _pathLineWidth) return width;
}

- (void)setPathLineWidth:(CGFloat)pathLineWidth {
    Setter(_pathLineWidth = pathLineWidth);
}

- (BOOL)isVerticalForm {
    Getter(BOOL v = _verticalForm) return v;
}

- (void)setVerticalForm:(BOOL)verticalForm {
    Setter(_verticalForm = verticalForm);
}

- (NSUInteger)maximumNumberOfRows {
    Getter(NSUInteger num = _maximumNumberOfRows) return num;
}

- (void)setMaximumNumberOfRows:(NSUInteger)maximumNumberOfRows {
    Setter(_maximumNumberOfRows = maximumNumberOfRows);
}

- (YYTextTruncationType)truncationType {
    Getter(YYTextTruncationType type = _truncationType) return type;
}

- (void)setTruncationType:(YYTextTruncationType)truncationType {
    Setter(_truncationType = truncationType);
}

- (NSAttributedString *)truncationToken {
    Getter(NSAttributedString *token = _truncationToken) return token;
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    Setter(_truncationToken = truncationToken.copy);
}

- (void)setLinePositionModifier:(id<YYTextLinePositionModifier>)linePositionModifier {
    Setter(_linePositionModifier = [(NSObject *)linePositionModifier copy]);
}

- (id<YYTextLinePositionModifier>)linePositionModifier {
    Getter(id<YYTextLinePositionModifier> m = _linePositionModifier) return m;
}

#undef Getter
#undef Setter
@end




@interface YYTextLayout ()

@property (nonatomic, readwrite) YYTextContainer *container;
@property (nonatomic, readwrite) NSAttributedString *text;
@property (nonatomic, readwrite) NSRange range;

@property (nonatomic, readwrite) CTFramesetterRef frameSetter;
@property (nonatomic, readwrite) CTFrameRef frame;
@property (nonatomic, readwrite) NSArray *lines;
@property (nonatomic, readwrite) YYTextLine *truncatedLine;
@property (nonatomic, readwrite) NSArray *attachments;
@property (nonatomic, readwrite) NSArray *attachmentRanges;
@property (nonatomic, readwrite) NSArray *attachmentRects;
@property (nonatomic, readwrite) NSSet *attachmentContentsSet;
@property (nonatomic, readwrite) NSUInteger rowCount;
@property (nonatomic, readwrite) NSRange visibleRange;
@property (nonatomic, readwrite) CGRect textBoundingRect;
@property (nonatomic, readwrite) CGSize textBoundingSize;

@property (nonatomic, readwrite) BOOL containsHighlight;
@property (nonatomic, readwrite) BOOL needDrawBlockBorder;
@property (nonatomic, readwrite) BOOL needDrawBackgroundBorder;
@property (nonatomic, readwrite) BOOL needDrawShadow;
@property (nonatomic, readwrite) BOOL needDrawUnderline;
@property (nonatomic, readwrite) BOOL needDrawText;
@property (nonatomic, readwrite) BOOL needDrawAttachment;
@property (nonatomic, readwrite) BOOL needDrawInnerShadow;
@property (nonatomic, readwrite) BOOL needDrawStrikethrough;
@property (nonatomic, readwrite) BOOL needDrawBorder;

@property (nonatomic, assign) NSUInteger *lineRowsIndex;
@property (nonatomic, assign) YYRowEdge *lineRowsEdge; ///< top-left origin

@end



@implementation YYTextLayout

#pragma mark - Layout

- (instancetype)_init {
    self = [super init];
    return self;
}

+ (YYTextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text {
    YYTextContainer *container = [YYTextContainer containerWithSize:size];
    return [self layoutWithContainer:container text:text];
}

+ (YYTextLayout *)layoutWithContainer:(YYTextContainer *)container text:(NSAttributedString *)text {
    return [self layoutWithContainer:container text:text range:NSMakeRange(0, text.length)];
}

+ (YYTextLayout *)layoutWithContainer:(YYTextContainer *)container text:(NSAttributedString *)text range:(NSRange)range {
    YYTextLayout *layout = NULL;
    CGPathRef cgPath = nil;
    CGRect cgPathBox = {0};
    BOOL isVerticalForm = NO;
    BOOL rowMaySeparated = NO;
    NSMutableDictionary *frameAttrs = nil;
    CTFramesetterRef ctSetter = NULL;
    CTFrameRef ctFrame = NULL;
    CFArrayRef ctLines = nil;
    CGPoint *lineOrigins = NULL;
    NSUInteger lineCount = 0;
    NSMutableArray *lines = nil;
    NSMutableArray *attachments = nil;
    NSMutableArray *attachmentRanges = nil;
    NSMutableArray *attachmentRects = nil;
    NSMutableSet *attachmentContentsSet = nil;
    BOOL needTruncation = NO;
    NSAttributedString *truncationToken = nil;
    YYTextLine *truncatedLine = nil;
    YYRowEdge *lineRowsEdge = NULL;
    NSUInteger *lineRowsIndex = NULL;
    NSRange visibleRange;
    NSUInteger maximumNumberOfRows = 0;
    
    text = text.mutableCopy;
    container = container.copy;
    if (!text || !container) return nil;
    if (range.location + range.length > text.length) return nil;
    container->_readonly = YES;
    maximumNumberOfRows = container.maximumNumberOfRows;
    
    // CoreText bug when draw joined emoji since iOS 8.3.
    // See -[NSMutableAttributedString setClearColorToJoinedEmoji] for more information.
    static BOOL needFixJoinedEmojiBug = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double systemVersionDouble = [UIDevice currentDevice].systemVersion.doubleValue;
        if (8.3 <= systemVersionDouble && systemVersionDouble < 9) {
            needFixJoinedEmojiBug = YES;
        }
    });
    if (needFixJoinedEmojiBug) {
        [((NSMutableAttributedString *)text) yy_setClearColorToJoinedEmoji];
    }
    
    layout = [[YYTextLayout alloc] _init];
    layout.text = text;
    layout.container = container;
    layout.range = range;
    isVerticalForm = container.verticalForm;
    
    // set cgPath and cgPathBox
    if (container.path == nil && container.exclusionPaths.count == 0) {
        CGRect rect = (CGRect) {CGPointZero, container.size };
        rect = UIEdgeInsetsInsetRect(rect, container.insets);
        rect = CGRectStandardize(rect);
        cgPathBox = rect;
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL); // let CGPathIsRect() returns true
    } else if (container.path && CGPathIsRect(container.path.CGPath, &cgPathBox) && container.exclusionPaths.count == 0) {
        CGRect rect = CGRectApplyAffineTransform(cgPathBox, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL); // let CGPathIsRect() returns true
    } else {
        rowMaySeparated = YES;
        CGMutablePathRef path = NULL;
        if (container.path) {
            path = CGPathCreateMutableCopy(container.path.CGPath);
        } else {
            CGRect rect = (CGRect) {CGPointZero, container.size };
            rect = UIEdgeInsetsInsetRect(rect, container.insets);
            CGPathRef rectPath = CGPathCreateWithRect(rect, NULL);
            if (rectPath) {
                path = CGPathCreateMutableCopy(rectPath);
                CGPathRelease(rectPath);
            }
        }
        if (path) {
            [layout.container.exclusionPaths enumerateObjectsUsingBlock: ^(UIBezierPath *onePath, NSUInteger idx, BOOL *stop) {
                CGPathAddPath(path, NULL, onePath.CGPath);
            }];
            
            cgPathBox = CGPathGetPathBoundingBox(path);
            CGAffineTransform trans = CGAffineTransformMakeScale(1, -1);
            CGMutablePathRef transPath = CGPathCreateMutableCopyByTransformingPath(path, &trans);
            CGPathRelease(path);
            path = transPath;
        }
        cgPath = path;
    }
    if (!cgPath) goto fail;
    
    // frame setter config
    frameAttrs = [NSMutableDictionary dictionary];
    if (container.isPathFillEvenOdd == NO) {
        frameAttrs[(id)kCTFramePathFillRuleAttributeName] = @(kCTFramePathFillWindingNumber);
    }
    if (container.pathLineWidth > 0) {
        frameAttrs[(id)kCTFramePathWidthAttributeName] = @(container.pathLineWidth);
    }
    if (container.isVerticalForm == YES) {
        frameAttrs[(id)kCTFrameProgressionAttributeName] = @(kCTFrameProgressionRightToLeft);
    }
    
    // create CoreText objects
    ctSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    if (!ctSetter) goto fail;
    ctFrame = CTFramesetterCreateFrame(ctSetter, YYTextCFRangeFromNSRange(range), cgPath, (CFTypeRef)frameAttrs);
    if (!ctFrame) goto fail;
    lines = [NSMutableArray new];
    ctLines = CTFrameGetLines(ctFrame);
    lineCount = CFArrayGetCount(ctLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins == NULL) goto fail;
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    if (isVerticalForm) {
        lastRect = CGRectMake(FLT_MAX, 0, 0, 0);
        lastPosition = CGPointMake(FLT_MAX, 0);
    }
    
    // calculate line frame
    NSUInteger lineCurrentIdx = 0;
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        // CoreText coordinate system
        CGPoint ctLineOrigin = lineOrigins[i];
        
        // UIKit coordinate system
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        YYTextLine *line = [YYTextLine lineWithCTLine:ctLine position:position vertical:isVerticalForm];
        CGRect rect = line.bounds;
        BOOL newRow = YES;
        if (rowMaySeparated && position.x != lastPosition.x) {
            if (isVerticalForm) {
                if (rect.size.width > lastRect.size.width) {
                    if (rect.origin.x > lastPosition.x && lastPosition.x > rect.origin.x - rect.size.width) newRow = NO;
                } else {
                    if (lastRect.origin.x > position.x && position.x > lastRect.origin.x - lastRect.size.width) newRow = NO;
                }
            } else {
                if (rect.size.height > lastRect.size.height) {
                    if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) newRow = NO;
                } else {
                    if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) newRow = NO;
                }
            }
        }
        
        if (newRow) rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        line.index = lineCurrentIdx;
        line.row = rowIdx;
        [lines addObject:line];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        
        if (i == 0) textBoundingRect = rect;
        else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    
    if (rowCount > 0) {
        if (maximumNumberOfRows > 0) {
            if (rowCount > maximumNumberOfRows) {
                needTruncation = YES;
                rowCount = maximumNumberOfRows;
                do {
                    YYTextLine *line = lines.lastObject;
                    if (!line) break;
                    if (line.row < rowCount) break;
                    [lines removeLastObject];
                } while (1);
            }
        }
        YYTextLine *lastLine = lines.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
        
        // Give user a chance to modify the line's position.
        if (container.linePositionModifier) {
            [container.linePositionModifier modifyLines:lines fromText:text inContainer:container];
            textBoundingRect = CGRectZero;
            for (NSUInteger i = 0, max = lines.count; i < max; i++) {
                YYTextLine *line = lines[i];
                if (i == 0) textBoundingRect = line.bounds;
                else textBoundingRect = CGRectUnion(textBoundingRect, line.bounds);
            }
        }
        
        lineRowsEdge = calloc(rowCount, sizeof(YYRowEdge));
        if (lineRowsEdge == NULL) goto fail;
        lineRowsIndex = calloc(rowCount, sizeof(NSUInteger));
        if (lineRowsIndex == NULL) goto fail;
        NSInteger lastRowIdx = -1;
        CGFloat lastHead = 0;
        CGFloat lastFoot = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            YYTextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lineRowsEdge[lastRowIdx] = (YYRowEdge) {.head = lastHead, .foot = lastFoot };
                }
                lastRowIdx = line.row;
                lineRowsIndex[lastRowIdx] = i;
                if (isVerticalForm) {
                    lastHead = rect.origin.x + rect.size.width;
                    lastFoot = lastHead - rect.size.width;
                } else {
                    lastHead = rect.origin.y;
                    lastFoot = lastHead + rect.size.height;
                }
            } else {
                if (isVerticalForm) {
                    lastHead = MAX(lastHead, rect.origin.x + rect.size.width);
                    lastFoot = MIN(lastFoot, rect.origin.x);
                } else {
                    lastHead = MIN(lastHead, rect.origin.y);
                    lastFoot = MAX(lastFoot, rect.origin.y + rect.size.height);
                }
            }
        }
        lineRowsEdge[lastRowIdx] = (YYRowEdge) {.head = lastHead, .foot = lastFoot };
        
        for (NSUInteger i = 1; i < rowCount; i++) {
            YYRowEdge v0 = lineRowsEdge[i - 1];
            YYRowEdge v1 = lineRowsEdge[i];
            lineRowsEdge[i - 1].foot = lineRowsEdge[i].head = (v0.foot + v1.head) * 0.5;
        }
    }
    
    { // calculate bounding size
        CGRect rect = textBoundingRect;
        if (container.path) {
            if (container.pathLineWidth > 0) {
                CGFloat inset = container.pathLineWidth / 2;
                rect = CGRectInset(rect, -inset, -inset);
            }
        } else {
            rect = UIEdgeInsetsInsetRect(rect,YYTextUIEdgeInsetsInvert(container.insets));
        }
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        if (container.verticalForm) {
            size.width += container.size.width - (rect.origin.x + rect.size.width);
        } else {
            size.width += rect.origin.x;
        }
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = YYTextCGFloatPixelCeil(size.width);
        size.height = YYTextCGFloatPixelCeil(size.height);
        textBoundingSize = size;
    }
    
    visibleRange = YYTextNSRangeFromCFRange(CTFrameGetVisibleStringRange(ctFrame));
    if (needTruncation) {
        YYTextLine *lastLine = lines.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        
        // create truncated line
        if (container.truncationType != YYTextTruncationTypeNone) {
            CTLineRef truncationTokenLine = NULL;
            if (container.truncationToken) {
                truncationToken = container.truncationToken;
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            } else {
                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
                NSUInteger runCount = CFArrayGetCount(runs);
                NSMutableDictionary *attrs = nil;
                if (runCount > 0) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                    attrs = (id)CTRunGetAttributes(run);
                    attrs = attrs.mutableCopy;
                    [attrs removeObjectForKey:YYTextAttachmentAttributeName];
                    CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                    UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                    if (uiFont) {
                        font = CTFontCreateWithName((__bridge CFStringRef)uiFont.fontName, uiFont.pointSize, NULL);
                    } else {
                        font = NULL;
                    }
                    if (font) {
                        attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                        uiFont = nil;
                        CFRelease(font);
                    }
                    if (!attrs) attrs = [NSMutableDictionary new];
                }
                truncationToken = [[NSAttributedString alloc] initWithString:YYTextTruncationToken attributes:attrs];
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            }
            if (truncationTokenLine) {
                CTLineTruncationType type = kCTLineTruncationEnd;
                if (container.truncationType == YYTextTruncationTypeStart) {
                    type = kCTLineTruncationStart;
                } else if (container.truncationType == YYTextTruncationTypeMiddle) {
                    type = kCTLineTruncationMiddle;
                }
                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
                [lastLineText appendAttributedString:truncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    CGFloat truncatedWidth = lastLine.width;
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(cgPath, &cgPathRect)) {
                        if (isVerticalForm) {
                            truncatedWidth = cgPathRect.size.height;
                        } else {
                            truncatedWidth = cgPathRect.size.width;
                        }
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    CFRelease(ctLastLineExtend);
                    if (ctTruncatedLine) {
                        truncatedLine = [YYTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position vertical:isVerticalForm];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.row = lastLine.row;
                        CFRelease(ctTruncatedLine);
                    }
                }
                CFRelease(truncationTokenLine);
            }
        }
    }
    
    if (isVerticalForm) {
        NSCharacterSet *rotateCharset = YYTextVerticalFormRotateCharacterSet();
        NSCharacterSet *rotateMoveCharset = YYTextVerticalFormRotateAndMoveCharacterSet();
        
        void (^lineBlock)(YYTextLine *) = ^(YYTextLine *line){
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            if (!runs) return;
            NSUInteger runCount = CFArrayGetCount(runs);
            if (runCount == 0) return;
            NSMutableArray *lineRunRanges = [NSMutableArray new];
            line.verticalRotateRange = lineRunRanges;
            for (NSUInteger r = 0; r < runCount; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                NSMutableArray *runRanges = [NSMutableArray new];
                [lineRunRanges addObject:runRanges];
                NSUInteger glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) continue;
                
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                CTFontRef font = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
                BOOL isColorGlyph = YYTextCTFontContainsColorBitmapGlyphs(font);
                
                NSUInteger prevIdx = 0;
                YYTextRunGlyphDrawMode prevMode = YYTextRunGlyphDrawModeHorizontal;
                NSString *layoutStr = layout.text.string;
                for (NSUInteger g = 0; g < glyphCount; g++) {
                    BOOL glyphRotate = 0, glyphRotateMove = NO;
                    CFIndex runStrLen = runStrIdx[g + 1] - runStrIdx[g];
                    if (isColorGlyph) {
                        glyphRotate = YES;
                    } else if (runStrLen == 1) {
                        unichar c = [layoutStr characterAtIndex:runStrIdx[g]];
                        glyphRotate = [rotateCharset characterIsMember:c];
                        if (glyphRotate) glyphRotateMove = [rotateMoveCharset characterIsMember:c];
                    } else if (runStrLen > 1){
                        NSString *glyphStr = [layoutStr substringWithRange:NSMakeRange(runStrIdx[g], runStrLen)];
                        BOOL glyphRotate = [glyphStr rangeOfCharacterFromSet:rotateCharset].location != NSNotFound;
                        if (glyphRotate) glyphRotateMove = [glyphStr rangeOfCharacterFromSet:rotateMoveCharset].location != NSNotFound;
                    }
                    
                    YYTextRunGlyphDrawMode mode = glyphRotateMove ? YYTextRunGlyphDrawModeVerticalRotateMove : (glyphRotate ? YYTextRunGlyphDrawModeVerticalRotate : YYTextRunGlyphDrawModeHorizontal);
                    if (g == 0) {
                        prevMode = mode;
                    } else if (mode != prevMode) {
                        YYTextRunGlyphRange *aRange = [YYTextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, g - prevIdx) drawMode:prevMode];
                        [runRanges addObject:aRange];
                        prevIdx = g;
                        prevMode = mode;
                    }
                }
                if (prevIdx < glyphCount) {
                    YYTextRunGlyphRange *aRange = [YYTextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, glyphCount - prevIdx) drawMode:prevMode];
                    [runRanges addObject:aRange];
                }
                
            }
        };
        for (YYTextLine *line in lines) {
            lineBlock(line);
        }
        if (truncatedLine) lineBlock(truncatedLine);
    }
    
    if (visibleRange.length > 0) {
        layout.needDrawText = YES;
        
        void (^block)(NSDictionary *attrs, NSRange range, BOOL *stop) = ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            if (attrs[YYTextHighlightAttributeName]) layout.containsHighlight = YES;
            if (attrs[YYTextBlockBorderAttributeName]) layout.needDrawBlockBorder = YES;
            if (attrs[YYTextBackgroundBorderAttributeName]) layout.needDrawBackgroundBorder = YES;
            if (attrs[YYTextShadowAttributeName] || attrs[NSShadowAttributeName]) layout.needDrawShadow = YES;
            if (attrs[YYTextUnderlineAttributeName]) layout.needDrawUnderline = YES;
            if (attrs[YYTextAttachmentAttributeName]) layout.needDrawAttachment = YES;
            if (attrs[YYTextInnerShadowAttributeName]) layout.needDrawInnerShadow = YES;
            if (attrs[YYTextStrikethroughAttributeName]) layout.needDrawStrikethrough = YES;
            if (attrs[YYTextBorderAttributeName]) layout.needDrawBorder = YES;
        };
        
        [layout.text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        if (truncatedLine) {
            [truncationToken enumerateAttributesInRange:NSMakeRange(0, truncationToken.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        }
    }
    
    attachments = [NSMutableArray new];
    attachmentRanges = [NSMutableArray new];
    attachmentRects = [NSMutableArray new];
    attachmentContentsSet = [NSMutableSet new];
    for (NSUInteger i = 0, max = lines.count; i < max; i++) {
        YYTextLine *line = lines[i];
        if (truncatedLine && line.index == truncatedLine.index) line = truncatedLine;
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            for (YYTextAttachment *attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContentsSet addObject:attachment.content];
                }
            }
        }
    }
    if (attachments.count == 0) {
        attachments = attachmentRanges = attachmentRects = nil;
    }
    
    layout.frameSetter = ctSetter;
    layout.frame = ctFrame;
    layout.lines = lines;
    layout.truncatedLine = truncatedLine;
    layout.attachments = attachments;
    layout.attachmentRanges = attachmentRanges;
    layout.attachmentRects = attachmentRects;
    layout.attachmentContentsSet = attachmentContentsSet;
    layout.rowCount = rowCount;
    layout.visibleRange = visibleRange;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    layout.lineRowsEdge = lineRowsEdge;
    layout.lineRowsIndex = lineRowsIndex;
    CFRelease(cgPath);
    CFRelease(ctSetter);
    CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    return layout;
    
fail:
    if (cgPath) CFRelease(cgPath);
    if (ctSetter) CFRelease(ctSetter);
    if (ctFrame) CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    if (lineRowsEdge) free(lineRowsEdge);
    if (lineRowsIndex) free(lineRowsIndex);
    return nil;
}

+ (NSArray *)layoutWithContainers:(NSArray *)containers text:(NSAttributedString *)text {
    return [self layoutWithContainers:containers text:text range:NSMakeRange(0, text.length)];
}

+ (NSArray *)layoutWithContainers:(NSArray *)containers text:(NSAttributedString *)text range:(NSRange)range {
    if (!containers || !text) return nil;
    if (range.location + range.length > text.length) return nil;
    NSMutableArray *layouts = [NSMutableArray array];
    for (NSUInteger i = 0, max = containers.count; i < max; i++) {
        YYTextContainer *container = containers[i];
        YYTextLayout *layout = [self layoutWithContainer:container text:text range:range];
        if (!layout) return nil;
        NSInteger length = (NSInteger)range.length - (NSInteger)layout.visibleRange.length;
        if (length <= 0) {
            range.length = 0;
            range.location = text.length;
        } else {
            range.length = length;
            range.location += layout.visibleRange.length;
        }
    }
    return layouts;
}

- (void)setFrameSetter:(CTFramesetterRef)frameSetter {
    if (_frameSetter != frameSetter) {
        if (frameSetter) CFRetain(frameSetter);
        if (_frameSetter) CFRelease(_frameSetter);
        _frameSetter = frameSetter;
    }
}

- (void)setFrame:(CTFrameRef)frame {
    if (_frame != frame) {
        if (frame) CFRetain(frame);
        if (_frame) CFRelease(_frame);
        _frame = frame;
    }
}

- (void)dealloc {
    if (_frameSetter) CFRelease(_frameSetter);
    if (_frame) CFRelease(_frame);
    if (_lineRowsIndex) free(_lineRowsIndex);
    if (_lineRowsEdge) free(_lineRowsEdge);
}

#pragma mark - Coding


- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSData *textData = [YYTextArchiver archivedDataWithRootObject:_text];
    [aCoder encodeObject:textData forKey:@"text"];
    [aCoder encodeObject:_container forKey:@"container"];
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:@"range"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSData *textData = [aDecoder decodeObjectForKey:@"text"];
    NSAttributedString *text = [YYTextUnarchiver unarchiveObjectWithData:textData];
    YYTextContainer *container = [aDecoder decodeObjectForKey:@"container"];
    NSRange range = ((NSValue *)[aDecoder decodeObjectForKey:@"range"]).rangeValue;
    self = [self.class layoutWithContainer:container text:text range:range];
    return self;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    return self; // readonly object
}


#pragma mark - Query

/**
 Get the row index with 'edge' distance.
 
 @param edge  The distance from edge to the point.
 If vertical form, the edge is left edge, otherwise the edge is top edge.
 
 @return Returns NSNotFound if there's no row at the point.
 */
- (NSUInteger)_rowIndexForEdge:(CGFloat)edge {
    if (_rowCount == 0) return NSNotFound;
    BOOL isVertical = _container.verticalForm;
    NSUInteger lo = 0, hi = _rowCount - 1, mid = 0;
    NSUInteger rowIdx = NSNotFound;
    while (lo <= hi) {
        mid = (lo + hi) / 2;
        YYRowEdge oneEdge = _lineRowsEdge[mid];
        if (isVertical ?
            (oneEdge.foot <= edge && edge <= oneEdge.head) :
            (oneEdge.head <= edge && edge <= oneEdge.foot)) {
          rowIdx = mid;
          break;
        }
        if ((isVertical ? (edge > oneEdge.head) : (edge < oneEdge.head))) {
            if (mid == 0) break;
            hi = mid - 1;
        } else {
            lo = mid + 1;
        }
    }
    return rowIdx;
}

/**
 Get the closest row index with 'edge' distance.
 
 @param edge  The distance from edge to the point.
 If vertical form, the edge is left edge, otherwise the edge is top edge.
 
 @return Returns NSNotFound if there's no line.
 */
- (NSUInteger)_closestRowIndexForEdge:(CGFloat)edge {
    if (_rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:edge];
    if (rowIdx == NSNotFound) {
        if (_container.verticalForm) {
            if (edge > _lineRowsEdge[0].head) {
                rowIdx = 0;
            } else if (edge < _lineRowsEdge[_rowCount - 1].foot) {
                rowIdx = _rowCount - 1;
            }
        } else {
            if (edge < _lineRowsEdge[0].head) {
                rowIdx = 0;
            } else if (edge > _lineRowsEdge[_rowCount - 1].foot) {
                rowIdx = _rowCount - 1;
            }
        }
    }
    return rowIdx;
}

/**
 Get a CTRun from a line position.
 
 @param line     The text line.
 @param position The position in the whole text.
 
 @return Returns NULL if not found (no CTRun at the position).
 */
- (CTRunRef)_runForLine:(YYTextLine *)line position:(YYTextPosition *)position {
    if (!line || !position) return NULL;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger i = 0, max = CFArrayGetCount(runs); i < max; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFRange range = CTRunGetStringRange(run);
        if (position.affinity == YYTextAffinityBackward) {
            if (range.location < position.offset && position.offset <= range.location + range.length) {
                return run;
            }
        } else {
            if (range.location <= position.offset && position.offset < range.location + range.length) {
                return run;
            }
        }
    }
    return NULL;
}

/**
 Whether the position is inside a composed character sequence.
 
 @param line     The text line.
 @param position Text text position in whole text.
 @param block    The block to be executed before returns YES.
            left:  left X offset
            right: right X offset
            prev:  left position
            next:  right position
 */
- (BOOL)_insideComposedCharacterSequences:(YYTextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block {
    NSRange range = line.range;
    if (range.length == 0) return NO;
    __block BOOL inside = NO;
    __block NSUInteger _prev, _next;
    [_text.string enumerateSubstringsInRange:range options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSUInteger prev = substringRange.location;
        NSUInteger next = substringRange.location + substringRange.length;
        if (prev == position || next == position) {
            *stop = YES;
        }
        if (prev < position && position < next) {
            inside = YES;
            _prev = prev;
            _next = next;
            *stop = YES;
        }
    }];
    if (inside && block) {
        CGFloat left = [self offsetForTextPosition:_prev lineIndex:line.index];
        CGFloat right = [self offsetForTextPosition:_next lineIndex:line.index];
        block(left, right, _prev, _next);
    }
    return inside;
}

/**
 Whether the position is inside an emoji (such as National Flag Emoji).
 
 @param line     The text line.
 @param position Text text position in whole text.
 @param block    Yhe block to be executed before returns YES.
           left:  emoji's left X offset
           right: emoji's right X offset
           prev:  emoji's left position
           next:  emoji's right position
 */
- (BOOL)_insideEmoji:(YYTextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block {
    if (!line) return NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        CFRange range = CTRunGetStringRange(run);
        if (range.length <= 1) continue;
        if (position <= range.location || position >= range.location + range.length) continue;
        CFDictionaryRef attrs = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
        if (!YYTextCTFontContainsColorBitmapGlyphs(font)) continue;
        
        // Here's Emoji runs (larger than 1 unichar), and position is inside the range.
        CFIndex indices[glyphCount];
        CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
        for (NSUInteger g = 0; g < glyphCount; g++) {
            CFIndex prev = indices[g];
            CFIndex next = g + 1 < glyphCount ? indices[g + 1] : range.location + range.length;
            if (position == prev) break; // Emoji edge
            if (prev < position && position < next) { // inside an emoji (such as National Flag Emoji)
                CGPoint pos = CGPointZero;
                CGSize adv = CGSizeZero;
                CTRunGetPositions(run, CFRangeMake(g, 1), &pos);
                CTRunGetAdvances(run, CFRangeMake(g, 1), &adv);
                if (block) {
                    block(line.position.x + pos.x,
                          line.position.x + pos.x + adv.width,
                          prev, next);
                }
                return YES;
            }
        }
    }
    return NO;
}
/**
 Whether the write direction is RTL at the specified point
 
 @param line  The text line
 @param point The point in layout.
 
 @return YES if RTL.
 */
- (BOOL)_isRightToLeftInLine:(YYTextLine *)line atPoint:(CGPoint)point {
    if (!line) return NO;
    // get write direction
    BOOL RTL = NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CGPoint glyphPosition;
        CTRunGetPositions(run, CFRangeMake(0, 1), &glyphPosition);
        if (_container.verticalForm) {
            CGFloat runX = glyphPosition.x;
            runX += line.position.y;
            CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            if (runX <= point.y && point.y <= runX + runWidth) {
                if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
                break;
            }
        } else {
            CGFloat runX = glyphPosition.x;
            runX += line.position.x;
            CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            if (runX <= point.x && point.x <= runX + runWidth) {
                if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
                break;
            }
        }
    }
    return RTL;
}

/**
 Correct the range's edge.
 */
- (YYTextRange *)_correctedRangeWithEdge:(YYTextRange *)range {
    NSRange visibleRange = self.visibleRange;
    YYTextPosition *start = range.start;
    YYTextPosition *end = range.end;
    
    if (start.offset == visibleRange.location && start.affinity == YYTextAffinityBackward) {
        start = [YYTextPosition positionWithOffset:start.offset affinity:YYTextAffinityForward];
    }
    
    if (end.offset == visibleRange.location + visibleRange.length && start.affinity == YYTextAffinityForward) {
        end = [YYTextPosition positionWithOffset:end.offset affinity:YYTextAffinityBackward];
    }
    
    if (start != range.start || end != range.end) {
        range = [YYTextRange rangeWithStart:start end:end];
    }
    return range;
}

- (NSUInteger)lineIndexForRow:(NSUInteger)row {
    if (row >= _rowCount) return NSNotFound;
    return _lineRowsIndex[row];
}

- (NSUInteger)lineCountForRow:(NSUInteger)row {
    if (row >= _rowCount) return NSNotFound;
    if (row == _rowCount - 1) {
        return _lines.count - _lineRowsIndex[row];
    } else {
        return _lineRowsIndex[row + 1] - _lineRowsIndex[row];
    }
}

- (NSUInteger)rowIndexForLine:(NSUInteger)line {
    if (line >= _lines.count) return NSNotFound;
    return ((YYTextLine *)_lines[line]).row;
}

- (NSUInteger)lineIndexForPoint:(CGPoint)point {
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:_container.verticalForm ? point.x : point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((YYTextLine *)_lines[i]).bounds;
        if (CGRectContainsPoint(bounds, point)) return i;
    }
    
    return NSNotFound;
}

- (NSUInteger)closestLineIndexForPoint:(CGPoint)point {
    BOOL isVertical = _container.verticalForm;
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _closestRowIndexForEdge:isVertical ? point.x : point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    if (lineIdx0 == lineIdx1) return lineIdx0;
    
    CGFloat minDistance = CGFLOAT_MAX;
    NSUInteger minIndex = lineIdx0;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((YYTextLine *)_lines[i]).bounds;
        if (isVertical) {
            if (bounds.origin.y <= point.y && point.y <= bounds.origin.y + bounds.size.height) return i;
            CGFloat distance;
            if (point.y < bounds.origin.y) {
                distance = bounds.origin.y - point.y;
            } else {
                distance = point.y - (bounds.origin.y + bounds.size.height);
            }
            if (distance < minDistance) {
                minDistance = distance;
                minIndex = i;
            }
        } else {
            if (bounds.origin.x <= point.x && point.x <= bounds.origin.x + bounds.size.width) return i;
            CGFloat distance;
            if (point.x < bounds.origin.x) {
                distance = bounds.origin.x - point.x;
            } else {
                distance = point.x - (bounds.origin.x + bounds.size.width);
            }
            if (distance < minDistance) {
                minDistance = distance;
                minIndex = i;
            }
        }
    }
    return minIndex;
}

- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return CGFLOAT_MAX;
    YYTextLine *line = _lines[lineIndex];
    CFRange range = CTLineGetStringRange(line.CTLine);
    if (position < range.location || position > range.location + range.length) return CGFLOAT_MAX;
    
    CGFloat offset = CTLineGetOffsetForStringIndex(line.CTLine, position, NULL);
    return _container.verticalForm ? (offset + line.position.y) : (offset + line.position.x);
}

- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return NSNotFound;
    YYTextLine *line = _lines[lineIndex];
    if (_container.verticalForm) {
        point.x = point.y - line.position.y;
        point.y = 0;
    } else {
        point.x -= line.position.x;
        point.y = 0;
    }
    CFIndex idx = CTLineGetStringIndexForPosition(line.CTLine, point);
    if (idx == kCFNotFound) return NSNotFound;
    
    /*
     If the emoji contains one or more variant form (such as ☔️ "\u2614\uFE0F")
     and the font size is smaller than 379/15, then each variant form ("\uFE0F")
     will rendered as a single blank glyph behind the emoji glyph. Maybe it's a
     bug in CoreText? Seems iOS8.3 fixes this problem.
     
     If the point hit the blank glyph, the CTLineGetStringIndexForPosition()
     returns the position before the emoji glyph, but it should returns the
     position after the emoji and variant form.
     
     Here's a workaround.
     */
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFRange range = CTRunGetStringRange(run);
        if (range.location <= idx && idx < range.location + range.length) {
            NSUInteger glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) break;
            CFDictionaryRef attrs = CTRunGetAttributes(run);
            CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
            if (!YYTextCTFontContainsColorBitmapGlyphs(font)) break;
            
            CFIndex indices[glyphCount];
            CGPoint positions[glyphCount];
            CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions);
            for (NSUInteger g = 0; g < glyphCount; g++) {
                NSUInteger gIdx = indices[g];
                if (gIdx == idx && g + 1 < glyphCount) {
                    CGFloat right = positions[g + 1].x;
                    if (point.x < right) break;
                    NSUInteger next = indices[g + 1];
                    do {
                        if (next == range.location + range.length) break;
                        unichar c = [_text.string characterAtIndex:next];
                        if ((c == 0xFE0E || c == 0xFE0F)) { // unicode variant form for emoji style
                            next++;
                        } else break;
                    }
                    while (1);
                    if (next != indices[g + 1]) idx = next;
                    break;
                }
            }
            break;
        }
    }
    return idx;
}

- (YYTextPosition *)closestPositionToPoint:(CGPoint)point {
    BOOL isVertical = _container.verticalForm;
    // When call CTLineGetStringIndexForPosition() on ligature such as 'fi',
    // and the point `hit` the glyph's left edge, it may get the ligature inside offset.
    // I don't know why, maybe it's a bug of CoreText. Try to avoid it.
    if (isVertical) point.y += 0.00001234;
    else point.x += 0.00001234;
    
    NSUInteger lineIndex = [self closestLineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    YYTextLine *line = _lines[lineIndex];
    __block NSUInteger position = [self textPositionForPoint:point lineIndex:lineIndex];
    if (position == NSNotFound) position = line.range.location;
    if (position <= _visibleRange.location) {
        return [YYTextPosition positionWithOffset:_visibleRange.location affinity:YYTextAffinityForward];
    } else if (position >= _visibleRange.location + _visibleRange.length) {
        return [YYTextPosition positionWithOffset:_visibleRange.location + _visibleRange.length affinity:YYTextAffinityBackward];
    }
    
    YYTextAffinity finalAffinity = YYTextAffinityForward;
    BOOL finalAffinityDetected = NO;
    
    // binding range
    NSRange bindingRange;
    YYTextBinding *binding = [_text attribute:YYTextBindingAttributeName atIndex:position longestEffectiveRange:&bindingRange inRange:NSMakeRange(0, _text.length)];
    if (binding && bindingRange.length > 0) {
        NSUInteger headLineIdx = [self lineIndexForPosition:[YYTextPosition positionWithOffset:bindingRange.location]];
        NSUInteger tailLineIdx = [self lineIndexForPosition:[YYTextPosition positionWithOffset:bindingRange.location + bindingRange.length affinity:YYTextAffinityBackward]];
        if (headLineIdx == lineIndex && lineIndex == tailLineIdx) { // all in same line
            CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:lineIndex];
            CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:lineIndex];
            if (left != CGFLOAT_MAX && right != CGFLOAT_MAX) {
                if (_container.isVerticalForm) {
                    if (fabs(point.y - left) < fabs(point.y - right)) {
                        position = bindingRange.location;
                        finalAffinity = YYTextAffinityForward;
                    } else {
                        position = bindingRange.location + bindingRange.length;
                        finalAffinity = YYTextAffinityBackward;
                    }
                } else {
                    if (fabs(point.x - left) < fabs(point.x - right)) {
                        position = bindingRange.location;
                        finalAffinity = YYTextAffinityForward;
                    } else {
                        position = bindingRange.location + bindingRange.length;
                        finalAffinity = YYTextAffinityBackward;
                    }
                }
            } else if (left != CGFLOAT_MAX) {
                position = left;
                finalAffinity = YYTextAffinityForward;
            } else if (right != CGFLOAT_MAX) {
                position = right;
                finalAffinity = YYTextAffinityBackward;
            }
            finalAffinityDetected = YES;
        } else if (headLineIdx == lineIndex) {
            CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:lineIndex];
            if (left != CGFLOAT_MAX) {
                position = bindingRange.location;
                finalAffinity = YYTextAffinityForward;
                finalAffinityDetected = YES;
            }
        } else if (tailLineIdx == lineIndex) {
            CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:lineIndex];
            if (right != CGFLOAT_MAX) {
                position = bindingRange.location + bindingRange.length;
                finalAffinity = YYTextAffinityBackward;
                finalAffinityDetected = YES;
            }
        } else {
            BOOL onLeft = NO, onRight = NO;
            if (headLineIdx != NSNotFound && tailLineIdx != NSNotFound) {
                if (abs((int)headLineIdx - (int)lineIndex) < abs((int)tailLineIdx - (int)lineIndex)) onLeft = YES;
                else onRight = YES;
            } else if (headLineIdx != NSNotFound) {
                onLeft = YES;
            } else if (tailLineIdx != NSNotFound) {
                onRight = YES;
            }
            
            if (onLeft) {
                CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:headLineIdx];
                if (left != CGFLOAT_MAX) {
                    lineIndex = headLineIdx;
                    line = _lines[headLineIdx];
                    position = bindingRange.location;
                    finalAffinity = YYTextAffinityForward;
                    finalAffinityDetected = YES;
                }
            } else if (onRight) {
                CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:tailLineIdx];
                if (right != CGFLOAT_MAX) {
                    lineIndex = tailLineIdx;
                    line = _lines[tailLineIdx];
                    position = bindingRange.location + bindingRange.length;
                    finalAffinity = YYTextAffinityBackward;
                    finalAffinityDetected = YES;
                }
            }
        }
    }
    
    // empty line
    if (line.range.length == 0) {
        BOOL behind = (_lines.count > 1 && lineIndex == _lines.count - 1);  //end line
        return [YYTextPosition positionWithOffset:line.range.location affinity:behind ? YYTextAffinityBackward:YYTextAffinityForward];
    }
    
    // detect weather the line is a linebreak token
    if (line.range.length <= 2) {
        NSString *str = [_text.string substringWithRange:line.range];
        if (YYTextIsLinebreakString(str)) { // an empty line ("\r", "\n", "\r\n")
            return [YYTextPosition positionWithOffset:line.range.location];
        }
    }
    
    // above whole text frame
    if (lineIndex == 0 && (isVertical ? (point.x > line.right) : (point.y < line.top))) {
        position = 0;
        finalAffinity = YYTextAffinityForward;
        finalAffinityDetected = YES;
    }
    // below whole text frame
    if (lineIndex == _lines.count - 1 && (isVertical ? (point.x < line.left) : (point.y > line.bottom))) {
        position = line.range.location + line.range.length;
        finalAffinity = YYTextAffinityBackward;
        finalAffinityDetected = YES;
    }
    
    // There must be at least one non-linebreak char,
    // ignore the linebreak characters at line end if exists.
    if (position >= line.range.location + line.range.length - 1) {
        if (position > line.range.location) {
            unichar c1 = [_text.string characterAtIndex:position - 1];
            if (YYTextIsLinebreakChar(c1)) {
                position--;
                if (position > line.range.location) {
                    unichar c0 = [_text.string characterAtIndex:position - 1];
                    if (YYTextIsLinebreakChar(c0)) {
                        position--;
                    }
                }
            }
        }
    }
    if (position == line.range.location) {
        return [YYTextPosition positionWithOffset:position];
    }
    if (position == line.range.location + line.range.length) {
        return [YYTextPosition positionWithOffset:position affinity:YYTextAffinityBackward];
    }
    
    [self _insideComposedCharacterSequences:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        if (isVertical) {
            position = fabs(left - point.y) < fabs(right - point.y) < (right ? prev : next);
        } else {
            position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
        }
    }];
    
    [self _insideEmoji:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        if (isVertical) {
            position = fabs(left - point.y) < fabs(right - point.y) < (right ? prev : next);
        } else {
            position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
        }
    }];
    
    if (position < _visibleRange.location) position = _visibleRange.location;
    else if (position > _visibleRange.location + _visibleRange.length) position = _visibleRange.location + _visibleRange.length;
    
    if (!finalAffinityDetected) {
        CGFloat ofs = [self offsetForTextPosition:position lineIndex:lineIndex];
        if (ofs != CGFLOAT_MAX) {
            BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
            if (position >= line.range.location + line.range.length) {
                finalAffinity = RTL ? YYTextAffinityForward : YYTextAffinityBackward;
            } else if (position <= line.range.location) {
                finalAffinity = RTL ? YYTextAffinityBackward : YYTextAffinityForward;
            } else {
                finalAffinity = (ofs < (isVertical ? point.y : point.x) && !RTL) ? YYTextAffinityForward : YYTextAffinityBackward;
            }
        }
    }
    
    return [YYTextPosition positionWithOffset:position affinity:finalAffinity];
}

- (YYTextPosition *)positionForPoint:(CGPoint)point
                         oldPosition:(YYTextPosition *)oldPosition
                       otherPosition:(YYTextPosition *)otherPosition {
    if (!oldPosition || !otherPosition) {
        return oldPosition;
    }
    YYTextPosition *newPos = [self closestPositionToPoint:point];
    if (!newPos) return oldPosition;
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    NSUInteger lineIndex = [self lineIndexForPosition:otherPosition];
    if (lineIndex == NSNotFound) return oldPosition;
    YYTextLine *line = _lines[lineIndex];
    YYRowEdge vertical = _lineRowsEdge[line.row];
    if (_container.verticalForm) {
        point.x = (vertical.head + vertical.foot) * 0.5;
    } else {
        point.y = (vertical.head + vertical.foot) * 0.5;
    }
    newPos = [self closestPositionToPoint:point];
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    
    if (_container.isVerticalForm) {
        if ([oldPosition compare:otherPosition] == NSOrderedAscending) { // search backward
            YYTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionUp offset:1];
            if (range) return range.start;
        } else { // search forward
            YYTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionDown offset:1];
            if (range) return range.end;
        }
    } else {
        if ([oldPosition compare:otherPosition] == NSOrderedAscending) { // search backward
            YYTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionLeft offset:1];
            if (range) return range.start;
        } else { // search forward
            YYTextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionRight offset:1];
            if (range) return range.end;
        }
    }
    
    return oldPosition;
}

- (YYTextRange *)textRangeAtPoint:(CGPoint)point {
    NSUInteger lineIndex = [self lineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    NSUInteger textPosition = [self textPositionForPoint:point lineIndex:[self lineIndexForPoint:point]];
    if (textPosition == NSNotFound) return nil;
    YYTextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    
    // get write direction
    BOOL RTL = [self _isRightToLeftInLine:_lines[lineIndex] atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    if (_container.verticalForm) {
        YYTextRange *range = [self textRangeByExtendingPosition:pos inDirection:(rect.origin.y >= point.y && !RTL) ? UITextLayoutDirectionUp:UITextLayoutDirectionDown offset:1];
        return range;
    } else {
        YYTextRange *range = [self textRangeByExtendingPosition:pos inDirection:(rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight offset:1];
        return range;
    }
}

- (YYTextRange *)closestTextRangeAtPoint:(CGPoint)point {
    YYTextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    NSUInteger lineIndex = [self lineIndexForPosition:pos];
    if (lineIndex == NSNotFound) return nil;
    YYTextLine *line = _lines[lineIndex];
    BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    UITextLayoutDirection direction = UITextLayoutDirectionRight;
    if (pos.offset >= line.range.location + line.range.length) {
        if (direction != RTL) {
            direction = _container.verticalForm ? UITextLayoutDirectionUp : UITextLayoutDirectionLeft;
        } else {
            direction = _container.verticalForm ? UITextLayoutDirectionDown : UITextLayoutDirectionRight;
        }
    } else if (pos.offset <= line.range.location) {
        if (direction != RTL) {
            direction = _container.verticalForm ? UITextLayoutDirectionDown : UITextLayoutDirectionRight;
        } else {
            direction = _container.verticalForm ? UITextLayoutDirectionUp : UITextLayoutDirectionLeft;
        }
    } else {
        if (_container.verticalForm) {
            direction = (rect.origin.y >= point.y && !RTL) ? UITextLayoutDirectionUp:UITextLayoutDirectionDown;
        } else {
            direction = (rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight;
        }
    }
    
    YYTextRange *range = [self textRangeByExtendingPosition:pos inDirection:direction offset:1];
    return range;
}

- (YYTextRange *)textRangeByExtendingPosition:(YYTextPosition *)position {
    NSUInteger visibleStart = _visibleRange.location;
    NSUInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    
    // head or tail, returns immediately
    if (position.offset == visibleStart) {
        return [YYTextRange rangeWithRange:NSMakeRange(position.offset, 0)];
    } else if (position.offset == visibleEnd) {
        return [YYTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:YYTextAffinityBackward];
    }
    
    // binding range
    NSRange tRange;
    YYTextBinding *binding = [_text attribute:YYTextBindingAttributeName atIndex:position.offset longestEffectiveRange:&tRange inRange:_visibleRange];
    if (binding && tRange.length > 0 && tRange.location < position.offset) {
        return [YYTextRange rangeWithRange:tRange];
    }
    
    // inside emoji or composed character sequences
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex != NSNotFound) {
        __block NSUInteger _prev, _next;
        BOOL emoji = NO, seq = NO;
        
        YYTextLine *line = _lines[lineIndex];
        emoji = [self _insideEmoji:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
            _prev = prev;
            _next = next;
        }];
        if (!emoji) {
            seq = [self _insideComposedCharacterSequences:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
                _prev = prev;
                _next = next;
            }];
        }
        if (emoji || seq) {
            return [YYTextRange rangeWithRange:NSMakeRange(_prev, _next - _prev)];
        }
    }
    
    // inside linebreak '\r\n'
    if (position.offset > visibleStart && position.offset < visibleEnd) {
        unichar c0 = [_text.string characterAtIndex:position.offset - 1];
        if ((c0 == '\r') && position.offset < visibleEnd) {
            unichar c1 = [_text.string characterAtIndex:position.offset];
            if (c1 == '\n') {
                return [YYTextRange rangeWithStart:[YYTextPosition positionWithOffset:position.offset - 1] end:[YYTextPosition positionWithOffset:position.offset + 1]];
            }
        }
        if (YYTextIsLinebreakChar(c0) && position.affinity == YYTextAffinityBackward) {
            NSString *str = [_text.string substringToIndex:position.offset];
            NSUInteger len = YYTextLinebreakTailLength(str);
            return [YYTextRange rangeWithStart:[YYTextPosition positionWithOffset:position.offset - len] end:[YYTextPosition positionWithOffset:position.offset]];
        }
    }
    
    return [YYTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:position.affinity];
}

- (YYTextRange *)textRangeByExtendingPosition:(YYTextPosition *)position
                                  inDirection:(UITextLayoutDirection)direction
                                       offset:(NSInteger)offset {
    NSInteger visibleStart = _visibleRange.location;
    NSInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    if (offset == 0) return [self textRangeByExtendingPosition:position];
    
    BOOL isVerticalForm = _container.verticalForm;
    BOOL verticalMove, forwardMove;
    
    if (isVerticalForm) {
        verticalMove = direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionRight;
        forwardMove = direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionDown;
    } else {
        verticalMove = direction == UITextLayoutDirectionUp || direction == UITextLayoutDirectionDown;
        forwardMove = direction == UITextLayoutDirectionDown || direction == UITextLayoutDirectionRight;
    }
    
    if (offset < 0) {
        forwardMove = !forwardMove;
        offset = -offset;
    }
    
    // head or tail, returns immediately
    if (!forwardMove && position.offset == visibleStart) {
        return [YYTextRange rangeWithRange:NSMakeRange(_visibleRange.location, 0)];
    } else if (forwardMove && position.offset == visibleEnd) {
        return [YYTextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:YYTextAffinityBackward];
    }
    
    // extend from position
    YYTextRange *fromRange = [self textRangeByExtendingPosition:position];
    if (!fromRange) return nil;
    YYTextRange *allForward = [YYTextRange rangeWithStart:fromRange.start end:[YYTextPosition positionWithOffset:visibleEnd]];
    YYTextRange *allBackward = [YYTextRange rangeWithStart:[YYTextPosition positionWithOffset:visibleStart] end:fromRange.end];
    
    if (verticalMove) { // up/down in text layout
        NSInteger lineIndex = [self lineIndexForPosition:position];
        if (lineIndex == NSNotFound) return nil;
        
        YYTextLine *line = _lines[lineIndex];
        NSInteger moveToRowIndex = (NSInteger)line.row + (forwardMove ? offset : -offset);
        if (moveToRowIndex < 0) return allBackward;
        else if (moveToRowIndex >= (NSInteger)_rowCount) return allForward;
        
        CGFloat ofs = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
        if (ofs == CGFLOAT_MAX) return nil;
        
        NSUInteger moveToLineFirstIndex = [self lineIndexForRow:moveToRowIndex];
        NSUInteger moveToLineCount = [self lineCountForRow:moveToRowIndex];
        if (moveToLineFirstIndex == NSNotFound || moveToLineCount == NSNotFound || moveToLineCount == 0) return nil;
        CGFloat mostLeft = CGFLOAT_MAX, mostRight = -CGFLOAT_MAX;
        YYTextLine *mostLeftLine = nil, *mostRightLine = nil;
        NSUInteger insideIndex = NSNotFound;
        for (NSUInteger i = 0; i < moveToLineCount; i++) {
            NSUInteger lineIndex = moveToLineFirstIndex + i;
            YYTextLine *line = _lines[lineIndex];
            if (isVerticalForm) {
                if (line.top <= ofs && ofs <= line.bottom) {
                    insideIndex = line.index;
                    break;
                }
                if (line.top < mostLeft) {
                    mostLeft = line.top;
                    mostLeftLine = line;
                }
                if (line.bottom > mostRight) {
                    mostRight = line.bottom;
                    mostRightLine = line;
                }
            } else {
                if (line.left <= ofs && ofs <= line.right) {
                    insideIndex = line.index;
                    break;
                }
                if (line.left < mostLeft) {
                    mostLeft = line.left;
                    mostLeftLine = line;
                }
                if (line.right > mostRight) {
                    mostRight = line.right;
                    mostRightLine = line;
                }
            }
        }
        BOOL afinityEdge = NO;
        if (insideIndex == NSNotFound) {
            if (ofs <= mostLeft) {
                insideIndex = mostLeftLine.index;
            } else {
                insideIndex = mostRightLine.index;
            }
            afinityEdge = YES;
        }
        YYTextLine *insideLine = _lines[insideIndex];
        NSUInteger pos;
        if (isVerticalForm) {
            pos = [self textPositionForPoint:CGPointMake(insideLine.position.x, ofs) lineIndex:insideIndex];
        } else {
            pos = [self textPositionForPoint:CGPointMake(ofs, insideLine.position.y) lineIndex:insideIndex];
        }
        if (pos == NSNotFound) return nil;
        YYTextPosition *extPos;
        if (afinityEdge) {
            if (pos == insideLine.range.location + insideLine.range.length) {
                NSString *subStr = [_text.string substringWithRange:insideLine.range];
                NSUInteger lineBreakLen = YYTextLinebreakTailLength(subStr);
                extPos = [YYTextPosition positionWithOffset:pos - lineBreakLen];
            } else {
                extPos = [YYTextPosition positionWithOffset:pos];
            }
        } else {
            extPos = [YYTextPosition positionWithOffset:pos];
        }
        YYTextRange *ext = [self textRangeByExtendingPosition:extPos];
        if (!ext) return nil;
        if (forwardMove) {
            return [YYTextRange rangeWithStart:fromRange.start end:ext.end];
        } else {
            return [YYTextRange rangeWithStart:ext.start end:fromRange.end];
        }
        
    } else { // left/right in text layout
        YYTextPosition *toPosition = [YYTextPosition positionWithOffset:position.offset + (forwardMove ? offset : -offset)];
        if (toPosition.offset <= visibleStart) return allBackward;
        else if (toPosition.offset >= visibleEnd) return allForward;
        
        YYTextRange *toRange = [self textRangeByExtendingPosition:toPosition];
        if (!toRange) return nil;
        
        NSInteger start = MIN(fromRange.start.offset, toRange.start.offset);
        NSInteger end = MAX(fromRange.end.offset, toRange.end.offset);
        return [YYTextRange rangeWithRange:NSMakeRange(start, end - start)];
    }
}

- (NSUInteger)lineIndexForPosition:(YYTextPosition *)position {
    if (!position) return NSNotFound;
    if (_lines.count == 0) return NSNotFound;
    NSUInteger location = position.offset;
    NSInteger lo = 0, hi = _lines.count - 1, mid = 0;
    if (position.affinity == YYTextAffinityBackward) {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            YYTextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location < location && location <= range.location + range.length) {
                return mid;
            }
            if (location <= range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    } else {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            YYTextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location <= location && location < range.location + range.length) {
                return mid;
            }
            if (location < range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    }
    return NSNotFound;
}

- (CGPoint)linePositionForPosition:(YYTextPosition *)position {
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGPointZero;
    YYTextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGPointZero;
    if (_container.verticalForm) {
        return CGPointMake(line.position.x, offset);
    } else {
        return CGPointMake(offset, line.position.y);
    }
}

- (CGRect)caretRectForPosition:(YYTextPosition *)position {
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGRectNull;
    YYTextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGRectNull;
    if (_container.verticalForm) {
        return CGRectMake(line.bounds.origin.x, offset, line.bounds.size.width, 0);
    } else {
        return CGRectMake(offset, line.bounds.origin.y, 0, line.bounds.size.height);
    }
}

- (CGRect)firstRectForRange:(YYTextRange *)range {
    range = [self _correctedRangeWithEdge:range];
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return CGRectNull;
    if (startLineIndex > endLineIndex) return CGRectNull;
    YYTextLine *startLine = _lines[startLineIndex];
    YYTextLine *endLine = _lines[endLineIndex];
    NSMutableArray *lines = [NSMutableArray new];
    for (NSUInteger i = startLineIndex; i <= startLineIndex; i++) {
        YYTextLine *line = _lines[i];
        if (line.row != startLine.row) break;
        [lines addObject:line];
    }
    if (_container.verticalForm) {
        if (lines.count == 1) {
            CGFloat top = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat bottom;
            if (startLine == endLine) {
                bottom = [self offsetForTextPosition:range.end.offset lineIndex:startLineIndex];
            } else {
                bottom = startLine.bottom;
            }
            if (top == CGFLOAT_MAX || bottom == CGFLOAT_MAX) return CGRectNull;
            if (top > bottom) YYTEXT_SWAP(top, bottom);
            return CGRectMake(startLine.left, top, startLine.width, bottom - top);
        } else {
            CGFloat top = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat bottom = startLine.bottom;
            if (top == CGFLOAT_MAX || bottom == CGFLOAT_MAX) return CGRectNull;
            if (top > bottom) YYTEXT_SWAP(top, bottom);
            CGRect rect = CGRectMake(startLine.left, top, startLine.width, bottom - top);
            for (NSUInteger i = 1; i < lines.count; i++) {
                YYTextLine *line = lines[i];
                rect = CGRectUnion(rect, line.bounds);
            }
            return rect;
        }
    } else {
        if (lines.count == 1) {
            CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat right;
            if (startLine == endLine) {
                right = [self offsetForTextPosition:range.end.offset lineIndex:startLineIndex];
            } else {
                right = startLine.right;
            }
            if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
            if (left > right) YYTEXT_SWAP(left, right);
            return CGRectMake(left, startLine.top, right - left, startLine.height);
        } else {
            CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat right = startLine.right;
            if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
            if (left > right) YYTEXT_SWAP(left, right);
            CGRect rect = CGRectMake(left, startLine.top, right - left, startLine.height);
            for (NSUInteger i = 1; i < lines.count; i++) {
                YYTextLine *line = lines[i];
                rect = CGRectUnion(rect, line.bounds);
            }
            return rect;
        }
    }
}

- (CGRect)rectForRange:(YYTextRange *)range {
    NSArray *rects = [self selectionRectsForRange:range];
    if (rects.count == 0) return CGRectNull;
    CGRect rectUnion = ((YYTextSelectionRect *)rects.firstObject).rect;
    for (NSUInteger i = 1; i < rects.count; i++) {
        YYTextSelectionRect *rect = rects[i];
        rectUnion = CGRectUnion(rectUnion, rect.rect);
    }
    return rectUnion;
}

- (NSArray *)selectionRectsForRange:(YYTextRange *)range {
    range = [self _correctedRangeWithEdge:range];
    
    BOOL isVertical = _container.verticalForm;
    NSMutableArray *rects = [NSMutableArray array];
    if (!range) return rects;
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return rects;
    if (startLineIndex > endLineIndex) YYTEXT_SWAP(startLineIndex, endLineIndex);
    YYTextLine *startLine = _lines[startLineIndex];
    YYTextLine *endLine = _lines[endLineIndex];
    CGFloat offsetStart = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
    CGFloat offsetEnd = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
    
    YYTextSelectionRect *start = [YYTextSelectionRect new];
    if (isVertical) {
        start.rect = CGRectMake(startLine.left, offsetStart, startLine.width, 0);
    } else {
        start.rect = CGRectMake(offsetStart, startLine.top, 0, startLine.height);
    }
    start.containsStart = YES;
    start.isVertical = isVertical;
    [rects addObject:start];
    
    YYTextSelectionRect *end = [YYTextSelectionRect new];
    if (isVertical) {
        end.rect = CGRectMake(endLine.left, offsetEnd, endLine.width, 0);
    } else {
        end.rect = CGRectMake(offsetEnd, endLine.top, 0, endLine.height);
    }
    end.containsEnd = YES;
    end.isVertical = isVertical;
    [rects addObject:end];
    
    if (startLine.row == endLine.row) { // same row
        if (offsetStart > offsetEnd) YYTEXT_SWAP(offsetStart, offsetEnd);
        YYTextSelectionRect *rect = [YYTextSelectionRect new];
        if (isVertical) {
            rect.rect = CGRectMake(startLine.bounds.origin.x, offsetStart, MAX(startLine.width, endLine.width), offsetEnd - offsetStart);
        } else {
            rect.rect = CGRectMake(offsetStart, startLine.bounds.origin.y, offsetEnd - offsetStart, MAX(startLine.height, endLine.height));
        }
        rect.isVertical = isVertical;
        [rects addObject:rect];
        
    } else { // more than one row
        
        // start line select rect
        YYTextSelectionRect *topRect = [YYTextSelectionRect new];
        topRect.isVertical = isVertical;
        CGFloat topOffset = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
        CTRunRef topRun = [self _runForLine:startLine position:range.start];
        if (topRun && (CTRunGetStatus(topRun) & kCTRunStatusRightToLeft)) {
            if (isVertical) {
                topRect.rect = CGRectMake(startLine.left, _container.path ? startLine.top : _container.insets.top, startLine.width, topOffset - startLine.top);
            } else {
                topRect.rect = CGRectMake(_container.path ? startLine.left : _container.insets.left, startLine.top, topOffset - startLine.left, startLine.height);
            }
            topRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            if (isVertical) {
                topRect.rect = CGRectMake(startLine.left, topOffset, startLine.width, (_container.path ? startLine.bottom : _container.size.height - _container.insets.bottom) - topOffset);
            } else {
                topRect.rect = CGRectMake(topOffset, startLine.top, (_container.path ? startLine.right : _container.size.width - _container.insets.right) - topOffset, startLine.height);
            }
        }
        [rects addObject:topRect];
        
        // end line select rect
        YYTextSelectionRect *bottomRect = [YYTextSelectionRect new];
        bottomRect.isVertical = isVertical;
        CGFloat bottomOffset = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
        CTRunRef bottomRun = [self _runForLine:endLine position:range.end];
        if (bottomRun && (CTRunGetStatus(bottomRun) & kCTRunStatusRightToLeft)) {
            if (isVertical) {
                bottomRect.rect = CGRectMake(endLine.left, bottomOffset, endLine.width, (_container.path ? endLine.bottom : _container.size.height - _container.insets.bottom) - bottomOffset);
            } else {
                bottomRect.rect = CGRectMake(bottomOffset, endLine.top, (_container.path ? endLine.right : _container.size.width - _container.insets.right) - bottomOffset, endLine.height);
            }
            bottomRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            if (isVertical) {
                CGFloat top = _container.path ? endLine.top : _container.insets.top;
                bottomRect.rect = CGRectMake(endLine.left, top, endLine.width, bottomOffset - top);
            } else {
                CGFloat left = _container.path ? endLine.left : _container.insets.left;
                bottomRect.rect = CGRectMake(left, endLine.top, bottomOffset - left, endLine.height);
            }
        }
        [rects addObject:bottomRect];
        
        if (endLineIndex - startLineIndex >= 2) {
            CGRect r = CGRectZero;
            BOOL startLineDetected = NO;
            for (NSUInteger l = startLineIndex + 1; l < endLineIndex; l++) {
                YYTextLine *line = _lines[l];
                if (line.row == startLine.row || line.row == endLine.row) continue;
                if (!startLineDetected) {
                    r = line.bounds;
                    startLineDetected = YES;
                } else {
                    r = CGRectUnion(r, line.bounds);
                }
            }
            if (startLineDetected) {
                if (isVertical) {
                    if (!_container.path) {
                        r.origin.y = _container.insets.top;
                        r.size.height = _container.size.height - _container.insets.bottom - _container.insets.top;
                    }
                    r.size.width =  CGRectGetMinX(topRect.rect) - CGRectGetMaxX(bottomRect.rect);
                    r.origin.x = CGRectGetMaxX(bottomRect.rect);
                } else {
                    if (!_container.path) {
                        r.origin.x = _container.insets.left;
                        r.size.width = _container.size.width - _container.insets.right - _container.insets.left;
                    }
                    r.origin.y = CGRectGetMaxY(topRect.rect);
                    r.size.height = bottomRect.rect.origin.y - r.origin.y;
                }
                
                YYTextSelectionRect *rect = [YYTextSelectionRect new];
                rect.rect = r;
                rect.isVertical = isVertical;
                [rects addObject:rect];
            }
        } else {
            if (isVertical) {
                CGRect r0 = bottomRect.rect;
                CGRect r1 = topRect.rect;
                CGFloat mid = (CGRectGetMaxX(r0) + CGRectGetMinX(r1)) * 0.5;
                r0.size.width = mid - r0.origin.x;
                CGFloat r1ofs = r1.origin.x - mid;
                r1.origin.x -= r1ofs;
                r1.size.width += r1ofs;
                topRect.rect = r1;
                bottomRect.rect = r0;
            } else {
                CGRect r0 = topRect.rect;
                CGRect r1 = bottomRect.rect;
                CGFloat mid = (CGRectGetMaxY(r0) + CGRectGetMinY(r1)) * 0.5;
                r0.size.height = mid - r0.origin.y;
                CGFloat r1ofs = r1.origin.y - mid;
                r1.origin.y -= r1ofs;
                r1.size.height += r1ofs;
                topRect.rect = r0;
                bottomRect.rect = r1;
            }
        }
    }
    return rects;
}

- (NSArray *)selectionRectsWithoutStartAndEndForRange:(YYTextRange *)range {
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        YYTextSelectionRect *rect = rects[i];
        if (rect.containsStart || rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}

- (NSArray *)selectionRectsWithOnlyStartAndEndForRange:(YYTextRange *)range {
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        YYTextSelectionRect *rect = rects[i];
        if (!rect.containsStart && !rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}


#pragma mark - Draw


typedef NS_OPTIONS(NSUInteger, YYTextDecorationType) {
    YYTextDecorationTypeUnderline     = 1 << 0,
    YYTextDecorationTypeStrikethrough = 1 << 1,
};

typedef NS_OPTIONS(NSUInteger, YYTextBorderType) {
    YYTextBorderTypeBackgound = 1 << 0,
    YYTextBorderTypeNormal    = 1 << 1,
};

static CGRect YYTextMergeRectInSameLine(CGRect rect1, CGRect rect2, BOOL isVertical) {
    if (isVertical) {
        CGFloat top = MIN(rect1.origin.y, rect2.origin.y);
        CGFloat bottom = MAX(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height);
        CGFloat width = MAX(rect1.size.width, rect2.size.width);
        return CGRectMake(rect1.origin.x, top, width, bottom - top);
    } else {
        CGFloat left = MIN(rect1.origin.x, rect2.origin.x);
        CGFloat right = MAX(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width);
        CGFloat height = MAX(rect1.size.height, rect2.size.height);
        return CGRectMake(left, rect1.origin.y, right - left, height);
    }
}

static void YYTextGetRunsMaxMetric(CFArrayRef runs, CGFloat *xHeight, CGFloat *underlinePosition, CGFloat *lineThickness) {
    CGFloat maxXHeight = 0;
    CGFloat maxUnderlinePos = 0;
    CGFloat maxLineThickness = 0;
    for (NSUInteger i = 0, max = CFArrayGetCount(runs); i < max; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFDictionaryRef attrs = CTRunGetAttributes(run);
        if (attrs) {
            CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
            if (font) {
                CGFloat xHeight = CTFontGetXHeight(font);
                if (xHeight > maxXHeight) maxXHeight = xHeight;
                CGFloat underlinePos = CTFontGetUnderlinePosition(font);
                if (underlinePos < maxUnderlinePos) maxUnderlinePos = underlinePos;
                CGFloat lineThickness = CTFontGetUnderlineThickness(font);
                if (lineThickness > maxLineThickness) maxLineThickness = lineThickness;
            }
        }
    }
    if (xHeight) *xHeight = maxXHeight;
    if (underlinePosition) *underlinePosition = maxUnderlinePos;
    if (lineThickness) *lineThickness = maxLineThickness;
}

static void YYTextDrawRun(YYTextLine *line, CTRunRef run, CGContextRef context, CGSize size, BOOL isVertical, NSArray *runRanges, CGFloat verticalOffset) {
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
    if (!isVertical && !glyphTransformValue) { // draw run
        if (!runTextMatrixIsID) {
            CGContextSaveGState(context);
            CGAffineTransform trans = CGContextGetTextMatrix(context);
            CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
        }
        CTRunDraw(run, context, CFRangeMake(0, 0));
        if (!runTextMatrixIsID) {
            CGContextRestoreGState(context);
        }
    } else { // draw glyph
        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
        if (!runFont) return;
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount <= 0) return;
        
        CGGlyph glyphs[glyphCount];
        CGPoint glyphPositions[glyphCount];
        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
        
        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
        fillColor = YYTextGetCGColor(fillColor);
        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
        
        CGContextSaveGState(context); {
            CGContextSetFillColorWithColor(context, fillColor);
            if (!strokeWidth || strokeWidth.floatValue == 0) {
                CGContextSetTextDrawingMode(context, kCGTextFill);
            } else {
                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
                if (!strokeColor) strokeColor = fillColor;
                CGContextSetStrokeColorWithColor(context, strokeColor);
                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
                if (strokeWidth.floatValue > 0) {
                    CGContextSetTextDrawingMode(context, kCGTextStroke);
                } else {
                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                }
            }
            
            if (isVertical) {
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
                CGFloat ascent = CTFontGetAscent(runFont);
                CGFloat descent = CTFontGetDescent(runFont);
                CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
                CGPoint zeroPoint = CGPointZero;
                
                for (YYTextRunGlyphRange *oneRange in runRanges) {
                    NSRange range = oneRange.glyphRangeInRun;
                    NSUInteger rangeMax = range.location + range.length;
                    YYTextRunGlyphDrawMode mode = oneRange.drawMode;
                    
                    for (NSUInteger g = range.location; g < rangeMax; g++) {
                        CGContextSaveGState(context); {
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            if (glyphTransformValue) {
                                CGContextSetTextMatrix(context, glyphTransform);
                            }
                            if (mode) { // CJK glyph, need rotated
                                CGFloat ofs = (ascent - descent) * 0.5;
                                CGFloat w = glyphAdvances[g].width * 0.5;
                                CGFloat x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
                                CGFloat y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
                                if (mode == YYTextRunGlyphDrawModeVerticalRotateMove) {
                                    x += w;
                                    y += w;
                                }
                                CGContextSetTextPosition(context, x, y);
                            } else {
                                CGContextRotateCTM(context, YYTextDegreesToRadians(-90));
                                CGContextSetTextPosition(context,
                                                         line.position.y - size.height + glyphPositions[g].x,
                                                         line.position.x + verticalOffset + glyphPositions[g].y);
                            }
                            
                            if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
                            } else {
                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                                CGContextSetFont(context, cgFont);
                                CGContextSetFontSize(context, CTFontGetSize(runFont));
                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                                CGFontRelease(cgFont);
                            }
                        } CGContextRestoreGState(context);
                    }
                }
            } else { // not vertical
                if (glyphTransformValue) {
                    CFIndex runStrIdx[glyphCount + 1];
                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                    CFRange runStrRange = CTRunGetStringRange(run);
                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                    CGSize glyphAdvances[glyphCount];
                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
                    CGPoint zeroPoint = CGPointZero;
                    
                    for (NSUInteger g = 0; g < glyphCount; g++) {
                        CGContextSaveGState(context); {
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            CGContextSetTextMatrix(context, glyphTransform);
                            CGContextSetTextPosition(context,
                                                     line.position.x + glyphPositions[g].x,
                                                     size.height - (line.position.y + glyphPositions[g].y));
                            
                            if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
                            } else {
                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                                CGContextSetFont(context, cgFont);
                                CGContextSetFontSize(context, CTFontGetSize(runFont));
                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                                CGFontRelease(cgFont);
                            }
                        } CGContextRestoreGState(context);
                    }
                } else {
                    if (YYTextCTFontContainsColorBitmapGlyphs(runFont)) {
                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
                    } else {
                        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                        CGContextSetFont(context, cgFont);
                        CGContextSetFontSize(context, CTFontGetSize(runFont));
                        CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
                        CGFontRelease(cgFont);
                    }
                }
            }
            
        } CGContextRestoreGState(context);
    }
}

static void YYTextSetLinePatternInContext(YYTextLineStyle style, CGFloat width, CGFloat phase, CGContextRef context){
    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    
    CGFloat dash = 12, dot = 5, space = 3;
    NSUInteger pattern = style & 0xF00;
    if (pattern == YYTextLineStylePatternSolid) {
        CGContextSetLineDash(context, phase, NULL, 0);
    } else if (pattern == YYTextLineStylePatternDot) {
        CGFloat lengths[2] = {width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == YYTextLineStylePatternDash) {
        CGFloat lengths[2] = {width * dash, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == YYTextLineStylePatternDashDot) {
        CGFloat lengths[4] = {width * dash, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 4);
    } else if (pattern == YYTextLineStylePatternDashDotDot) {
        CGFloat lengths[6] = {width * dash, width * space,width * dot, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 6);
    } else if (pattern == YYTextLineStylePatternCircleDot) {
        CGFloat lengths[2] = {width * 0, width * 3};
        CGContextSetLineDash(context, phase, lengths, 2);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
    }
}


static void YYTextDrawBorderRects(CGContextRef context, CGSize size, YYTextBorder *border, NSArray *rects, BOOL isVertical) {
    if (rects.count == 0) return;
    
    YYTextShadow *shadow = border.shadow;
    if (shadow.color) {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.offset, shadow.radius, shadow.color.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
    }
    
    NSMutableArray *paths = [NSMutableArray new];
    for (NSValue *value in rects) {
        CGRect rect = value.CGRectValue;
        if (isVertical) {
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(border.insets));
        } else {
            rect = UIEdgeInsetsInsetRect(rect, border.insets);
        }
        rect = YYTextCGRectPixelRound(rect);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius];
        [path closePath];
        [paths addObject:path];
    }
    
    if (border.fillColor) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, border.fillColor.CGColor);
        for (UIBezierPath *path in paths) {
            CGContextAddPath(context, path.CGPath);
        }
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    if (border.strokeColor && border.lineStyle > 0 && border.strokeWidth > 0) {
        
        //-------------------------- single line ------------------------------//
        CGContextSaveGState(context);
        for (UIBezierPath *path in paths) {
            CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextAddPath(context, path.CGPath);
            CGContextEOClip(context);
        }
        [border.strokeColor setStroke];
        YYTextSetLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context);
        CGFloat inset = -border.strokeWidth * 0.5;
        if ((border.lineStyle & 0xFF) == YYTextLineStyleThick) {
            inset *= 2;
            CGContextSetLineWidth(context, border.strokeWidth * 2);
        }
        CGFloat radiusDelta = -inset;
        if (border.cornerRadius <= 0) {
            radiusDelta = 0;
        }
        CGContextSetLineJoin(context, border.lineJoin);
        for (NSValue *value in rects) {
            CGRect rect = value.CGRectValue;
            if (isVertical) {
                rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(border.insets));
            } else {
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
            }
            rect = CGRectInset(rect, inset, inset);
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + radiusDelta];
            [path closePath];
            CGContextAddPath(context, path.CGPath);
        }
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        //------------------------- second line ------------------------------//
        if ((border.lineStyle & 0xFF) == YYTextLineStyleDouble) {
            CGContextSaveGState(context);
            CGFloat inset = -border.strokeWidth * 2;
            for (NSValue *value in rects) {
                CGRect rect = value.CGRectValue;
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
                rect = CGRectInset(rect, inset, inset);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + 2 * border.strokeWidth];
                [path closePath];
                CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                CGContextAddPath(context, path.CGPath);
                CGContextEOClip(context);
            }
            CGContextSetStrokeColorWithColor(context, border.strokeColor.CGColor);
            YYTextSetLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context);
            CGContextSetLineJoin(context, border.lineJoin);
            inset = -border.strokeWidth * 2.5;
            radiusDelta = border.strokeWidth * 2;
            if (border.cornerRadius <= 0) {
                radiusDelta = 0;
            }
            for (NSValue *value in rects) {
                CGRect rect = value.CGRectValue;
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
                rect = CGRectInset(rect, inset, inset);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + radiusDelta];
                [path closePath];
                CGContextAddPath(context, path.CGPath);
            }
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
    }
    
    if (shadow.color) {
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
}

static void YYTextDrawLineStyle(CGContextRef context, CGFloat length, CGFloat lineWidth, YYTextLineStyle style, CGPoint position, CGColorRef color, BOOL isVertical) {
    NSUInteger styleBase = style & 0xFF;
    if (styleBase == 0) return;
    
    CGContextSaveGState(context); {
        if (isVertical) {
            CGFloat x, y1, y2, w;
            y1 = YYTextCGFloatPixelRound(position.y);
            y2 = YYTextCGFloatPixelRound(position.y + length);
            w = (styleBase == YYTextLineStyleThick ? lineWidth * 2 : lineWidth);
            
            CGFloat linePixel = YYTextCGFloatToPixel(w);
            if (fabs(linePixel - floor(linePixel)) < 0.1) {
                int iPixel = linePixel;
                if (iPixel == 0 || (iPixel % 2)) { // odd line pixel
                    x = YYTextCGFloatPixelHalf(position.x);
                } else {
                    x = YYTextCGFloatPixelFloor(position.x);
                }
            } else {
                x = position.x;
            }
            
            CGContextSetStrokeColorWithColor(context, color);
            YYTextSetLinePatternInContext(style, lineWidth, position.y, context);
            CGContextSetLineWidth(context, w);
            if (styleBase == YYTextLineStyleSingle) {
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else if (styleBase == YYTextLineStyleThick) {
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else if (styleBase == YYTextLineStyleDouble) {
                CGContextMoveToPoint(context, x - w, y1);
                CGContextAddLineToPoint(context, x - w, y2);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, x + w, y1);
                CGContextAddLineToPoint(context, x + w, y2);
                CGContextStrokePath(context);
            }
        } else {
            CGFloat x1, x2, y, w;
            x1 = YYTextCGFloatPixelRound(position.x);
            x2 = YYTextCGFloatPixelRound(position.x + length);
            w = (styleBase == YYTextLineStyleThick ? lineWidth * 2 : lineWidth);
            
            CGFloat linePixel = YYTextCGFloatToPixel(w);
            if (fabs(linePixel - floor(linePixel)) < 0.1) {
                int iPixel = linePixel;
                if (iPixel == 0 || (iPixel % 2)) { // odd line pixel
                    y = YYTextCGFloatPixelHalf(position.y);
                } else {
                    y = YYTextCGFloatPixelFloor(position.y);
                }
            } else {
                y = position.y;
            }
            
            CGContextSetStrokeColorWithColor(context, color);
            YYTextSetLinePatternInContext(style, lineWidth, position.x, context);
            CGContextSetLineWidth(context, w);
            if (styleBase == YYTextLineStyleSingle) {
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            } else if (styleBase == YYTextLineStyleThick) {
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            } else if (styleBase == YYTextLineStyleDouble) {
                CGContextMoveToPoint(context, x1, y - w);
                CGContextAddLineToPoint(context, x2, y - w);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, x1, y + w);
                CGContextAddLineToPoint(context, x2, y + w);
                CGContextStrokePath(context);
            }
        }
    } CGContextRestoreGState(context);
}

static void YYTextDrawText(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextSetShadow(context, CGSizeZero, 0);
        
        BOOL isVertical = layout.container.verticalForm;
        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
        
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
            YYTextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            NSArray *lineRunRanges = line.verticalRotateRange;
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, line.position.x + verticalOffset, size.height - line.position.y);
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
            }
            if (cancel && cancel()) break;
        }
        
        // Use this to draw frame for test/debug.
        // CGContextTranslateCTM(context, verticalOffset, size.height);
        // CTFrameDraw(layout.frame, context);
        
    } CGContextRestoreGState(context);
}

static void YYTextDrawBlockBorder(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    for (NSInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        YYTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            YYTextBorder *border = attrs[YYTextBlockBorderAttributeName];
            if (!border) continue;
            
            NSUInteger lineStartIndex = line.index;
            while (lineStartIndex > 0) {
                if (((YYTextLine *)lines[lineStartIndex - 1]).row == line.row) lineStartIndex--;
                else break;
            }
            
            CGRect unionRect = CGRectZero;
            NSUInteger lineStartRow = ((YYTextLine *)lines[lineStartIndex]).row;
            NSUInteger lineContinueIndex = lineStartIndex;
            NSUInteger lineContinueRow = lineStartRow;
            do {
                YYTextLine *one = lines[lineContinueIndex];
                if (lineContinueIndex == lineStartIndex) {
                    unionRect = one.bounds;
                } else {
                    unionRect = CGRectUnion(unionRect, one.bounds);
                }
                if (lineContinueIndex + 1 == lMax) break;
                YYTextLine *next = lines[lineContinueIndex + 1];
                if (next.row != lineContinueRow) {
                    YYTextBorder *nextBorder = [layout.text yy_attribute:YYTextBlockBorderAttributeName atIndex:next.range.location];
                    if ([nextBorder isEqual:border]) {
                        lineContinueRow++;
                    } else {
                        break;
                    }
                }
                lineContinueIndex++;
            } while (true);
            
            if (isVertical) {
                UIEdgeInsets insets = layout.container.insets;
                unionRect.origin.y = insets.top;
                unionRect.size.height = layout.container.size.height -insets.top - insets.bottom;
            } else {
                UIEdgeInsets insets = layout.container.insets;
                unionRect.origin.x = insets.left;
                unionRect.size.width = layout.container.size.width -insets.left - insets.right;
            }
            unionRect.origin.x += verticalOffset;
            YYTextDrawBorderRects(context, size, border, @[[NSValue valueWithCGRect:unionRect]], isVertical);
            
            l = lineContinueIndex;
            break;
        }
    }
    
    
    CGContextRestoreGState(context);
}

static void YYTextDrawBorder(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, YYTextBorderType type, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    NSString *borderKey = (type == YYTextBorderTypeNormal ? YYTextBorderAttributeName : YYTextBackgroundBorderAttributeName);
    
    BOOL needJumpRun = NO;
    NSUInteger jumpRunIndex = 0;
    
    for (NSInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        YYTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            if (needJumpRun) {
                needJumpRun = NO;
                r = jumpRunIndex + 1;
                if (r >= rMax) break;
            }
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            YYTextBorder *border = attrs[borderKey];
            if (!border) continue;
            
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location == kCFNotFound || runRange.length == 0) continue;
            if (runRange.location + runRange.length > layout.text.length) continue;
            
            NSMutableArray *runRects = [NSMutableArray new];
            NSInteger endLineIndex = l;
            NSInteger endRunIndex = r;
            BOOL endFound = NO;
            for (NSInteger ll = l; ll < lMax; ll++) {
                if (endFound) break;
                YYTextLine *iLine = lines[ll];
                CFArrayRef iRuns = CTLineGetGlyphRuns(iLine.CTLine);
                
                CGRect extLineRect = CGRectNull;
                for (NSInteger rr = (ll == l) ? r : 0, rrMax = CFArrayGetCount(iRuns); rr < rrMax; rr++) {
                    CTRunRef iRun = CFArrayGetValueAtIndex(iRuns, rr);
                    NSDictionary *iAttrs = (id)CTRunGetAttributes(iRun);
                    YYTextBorder *iBorder = iAttrs[borderKey];
                    if (![border isEqual:iBorder]) {
                        endFound = YES;
                        break;
                    }
                    endLineIndex = ll;
                    endRunIndex = rr;
                    
                    CGPoint iRunPosition = CGPointZero;
                    CTRunGetPositions(iRun, CFRangeMake(0, 1), &iRunPosition);
                    CGFloat ascent, descent;
                    CGFloat iRunWidth = CTRunGetTypographicBounds(iRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    
                    if (isVertical) {
                        YYTEXT_SWAP(iRunPosition.x, iRunPosition.y);
                        iRunPosition.y += iLine.position.y;
                        CGRect iRect = CGRectMake(verticalOffset + line.position.x - descent, iRunPosition.y, ascent + descent, iRunWidth);
                        if (CGRectIsNull(extLineRect)) {
                            extLineRect = iRect;
                        } else {
                            extLineRect = CGRectUnion(extLineRect, iRect);
                        }
                    } else {
                        iRunPosition.x += iLine.position.x;
                        CGRect iRect = CGRectMake(iRunPosition.x, iLine.position.y - ascent, iRunWidth, ascent + descent);
                        if (CGRectIsNull(extLineRect)) {
                            extLineRect = iRect;
                        } else {
                            extLineRect = CGRectUnion(extLineRect, iRect);
                        }
                    }
                }
                
                if (!CGRectIsNull(extLineRect)) {
                    [runRects addObject:[NSValue valueWithCGRect:extLineRect]];
                }
            }
            
            NSMutableArray *drawRects = [NSMutableArray new];
            CGRect curRect= ((NSValue *)[runRects firstObject]).CGRectValue;
            for (NSInteger re = 0, reMax = runRects.count; re < reMax; re++) {
                CGRect rect = ((NSValue *)runRects[re]).CGRectValue;
                if (isVertical) {
                    if (fabs(rect.origin.x - curRect.origin.x) < 1) {
                        curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical);
                    } else {
                        [drawRects addObject:[NSValue valueWithCGRect:curRect]];
                        curRect = rect;
                    }
                } else {
                    if (fabs(rect.origin.y - curRect.origin.y) < 1) {
                        curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical);
                    } else {
                        [drawRects addObject:[NSValue valueWithCGRect:curRect]];
                        curRect = rect;
                    }
                }
            }
            if (!CGRectEqualToRect(curRect, CGRectZero)) {
                [drawRects addObject:[NSValue valueWithCGRect:curRect]];
            }
            
            YYTextDrawBorderRects(context, size, border, drawRects, isVertical);
            
            if (l == endLineIndex) {
                r = endRunIndex;
            } else {
                l = endLineIndex - 1;
                needJumpRun = YES;
                jumpRunIndex = endRunIndex;
                break;
            }
            
        }
    }
    
    CGContextRestoreGState(context);
}

static void YYTextDrawDecoration(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, YYTextDecorationType type, BOOL (^cancel)(void)) {
    NSArray *lines = layout.lines;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    CGContextTranslateCTM(context, verticalOffset, 0);
    
    for (NSUInteger l = 0, lMax = layout.lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        YYTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            YYTextDecoration *underline = attrs[YYTextUnderlineAttributeName];
            YYTextDecoration *strikethrough = attrs[YYTextStrikethroughAttributeName];
            
            BOOL needDrawUnderline = NO, needDrawStrikethrough = NO;
            if ((type & YYTextDecorationTypeUnderline) && underline.style > 0) {
                needDrawUnderline = YES;
            }
            if ((type & YYTextDecorationTypeStrikethrough) && strikethrough.style > 0) {
                needDrawStrikethrough = YES;
            }
            if (!needDrawUnderline && !needDrawStrikethrough) continue;
            
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location == kCFNotFound || runRange.length == 0) continue;
            if (runRange.location + runRange.length > layout.text.length) continue;
            NSString *runStr = [layout.text attributedSubstringFromRange:NSMakeRange(runRange.location, runRange.length)].string;
            if (YYTextIsLinebreakString(runStr)) continue; // may need more checks...
            
            CGFloat xHeight, underlinePosition, lineThickness;
            YYTextGetRunsMaxMetric(runs, &xHeight, &underlinePosition, &lineThickness);
            
            CGPoint underlineStart, strikethroughStart;
            CGFloat length;
            
            if (isVertical) {
                underlineStart.x = line.position.x + underlinePosition;
                strikethroughStart.x = line.position.x + xHeight / 2;
                
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                underlineStart.y = strikethroughStart.y = runPosition.x + line.position.y;
                length = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
                
            } else {
                underlineStart.y = line.position.y - underlinePosition;
                strikethroughStart.y = line.position.y - xHeight / 2;
                
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                underlineStart.x = strikethroughStart.x = runPosition.x + line.position.x;
                length = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            }
            
            if (needDrawUnderline) {
                CGColorRef color = underline.color.CGColor;
                if (!color) {
                    color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    color = YYTextGetCGColor(color);
                }
                CGFloat thickness = underline.width ? underline.width.floatValue : lineThickness;
                YYTextShadow *shadow = underline.shadow;
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGFloat offsetAlterX = size.width + 0xFFFF;
                    CGContextSaveGState(context); {
                        CGSize offset = shadow.offset;
                        offset.width -= offsetAlterX;
                        CGContextSaveGState(context); {
                            CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                            CGContextSetBlendMode(context, shadow.blendMode);
                            CGContextTranslateCTM(context, offsetAlterX, 0);
                            YYTextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
                        } CGContextRestoreGState(context);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
                YYTextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
            }
            
            if (needDrawStrikethrough) {
                CGColorRef color = strikethrough.color.CGColor;
                if (!color) {
                    color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    color = YYTextGetCGColor(color);
                }
                CGFloat thickness = strikethrough.width ? strikethrough.width.floatValue : lineThickness;
                YYTextShadow *shadow = underline.shadow;
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGFloat offsetAlterX = size.width + 0xFFFF;
                    CGContextSaveGState(context); {
                        CGSize offset = shadow.offset;
                        offset.width -= offsetAlterX;
                        CGContextSaveGState(context); {
                            CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                            CGContextSetBlendMode(context, shadow.blendMode);
                            CGContextTranslateCTM(context, offsetAlterX, 0);
                            YYTextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
                        } CGContextRestoreGState(context);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
                YYTextDrawLineStyle(context, length, thickness, strikethrough.style, strikethroughStart, color, isVertical);
            }
        }
    }
    CGContextRestoreGState(context);
}

static void YYTextDrawAttachment(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, UIView *targetView, CALayer *targetLayer, BOOL (^cancel)(void)) {
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    for (NSUInteger i = 0, max = layout.attachments.count; i < max; i++) {
        YYTextAttachment *a = layout.attachments[i];
        if (!a.content) continue;
        
        UIImage *image = nil;
        UIView *view = nil;
        CALayer *layer = nil;
        if ([a.content isKindOfClass:[UIImage class]]) {
            image = a.content;
        } else if ([a.content isKindOfClass:[UIView class]]) {
            view = a.content;
        } else if ([a.content isKindOfClass:[CALayer class]]) {
            layer = a.content;
        }
        if (!image && !view && !layer) continue;
        if (image && !context) continue;
        if (view && !targetView) continue;
        if (layer && !targetLayer) continue;
        if (cancel && cancel()) break;
        
        CGSize asize = image ? image.size : view ? view.frame.size : layer.frame.size;
        CGRect rect = ((NSValue *)layout.attachmentRects[i]).CGRectValue;
        if (isVertical) {
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(a.contentInsets));
        } else {
            rect = UIEdgeInsetsInsetRect(rect, a.contentInsets);
        }
        rect = YYTextCGRectFitWithContentMode(rect, asize, a.contentMode);
        rect = YYTextCGRectPixelRound(rect);
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x + verticalOffset;
        rect.origin.y += point.y;
        if (image) {
            CGImageRef ref = image.CGImage;
            if (ref) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, rect, ref);
                CGContextRestoreGState(context);
            }
        } else if (view) {
            view.frame = rect;
            [targetView addSubview:view];
        } else if (layer) {
            layer.frame = rect;
            [targetLayer addSublayer:layer];
        }
    }
}

static void YYTextDrawShadow(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    //move out of context. (0xFFFF is just a random large number)
    CGFloat offsetAlterX = size.width + 0xFFFF;
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = layout.lines.count; l < lMax; l++) {
            if (cancel && cancel()) break;
            
            YYTextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            NSArray *lineRunRanges = line.verticalRotateRange;
            CGContextSetTextPosition(context, line.position.x, size.height - line.position.y);
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                NSDictionary *attrs = (id)CTRunGetAttributes(run);
                YYTextShadow *shadow = attrs[YYTextShadowAttributeName];
                YYTextShadow *nsShadow = [YYTextShadow shadowWithNSShadow:attrs[NSShadowAttributeName]]; // NSShadow compatible
                if (nsShadow) {
                    nsShadow.subShadow = shadow;
                    shadow = nsShadow;
                }
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGSize offset = shadow.offset;
                    offset.width -= offsetAlterX;
                    CGContextSaveGState(context); {
                        CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                        CGContextSetBlendMode(context, shadow.blendMode);
                        CGContextTranslateCTM(context, offsetAlterX, 0);
                        YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
            }
        }
    } CGContextRestoreGState(context);
}

static void YYTextDrawInnerShadow(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        YYTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        NSArray *lineRunRanges = line.verticalRotateRange;
        CGContextSetTextPosition(context, line.position.x, size.height - line.position.y);
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            if (CTRunGetGlyphCount(run) == 0) continue;
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            YYTextShadow *shadow = attrs[YYTextInnerShadowAttributeName];
            while (shadow) {
                if (!shadow.color) {
                    shadow = shadow.subShadow;
                    continue;
                }
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                CGRect runImageBounds = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
                runImageBounds.origin.x += runPosition.x;
                if (runImageBounds.size.width < 0.1 || runImageBounds.size.height < 0.1) continue;
                
                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(YYTextGlyphTransformAttributeName));
                if (glyphTransformValue) {
                    runImageBounds = CGRectMake(0, 0, size.width, size.height);
                }
                
                // text inner shadow
                CGContextSaveGState(context); {
                    CGContextSetBlendMode(context, shadow.blendMode);
                    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
                    CGContextSetAlpha(context, CGColorGetAlpha(shadow.color.CGColor));
                    CGContextClipToRect(context, runImageBounds);
                    CGContextBeginTransparencyLayer(context, NULL); {
                        UIColor *opaqueShadowColor = [shadow.color colorWithAlphaComponent:1];
                        CGContextSetShadowWithColor(context, shadow.offset, shadow.radius, opaqueShadowColor.CGColor);
                        CGContextSetFillColorWithColor(context, opaqueShadowColor.CGColor);
                        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                        CGContextBeginTransparencyLayer(context, NULL); {
                            CGContextFillRect(context, runImageBounds);
                            CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
                            CGContextBeginTransparencyLayer(context, NULL); {
                                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
                            } CGContextEndTransparencyLayer(context);
                        } CGContextEndTransparencyLayer(context);
                    } CGContextEndTransparencyLayer(context);
                } CGContextRestoreGState(context);
                shadow = shadow.subShadow;
            }
        }
    }
    
    CGContextRestoreGState(context);
}

static void YYTextDrawDebug(YYTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, YYTextDebugOption *op) {
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextSetLineWidth(context, 1.0 / YYTextScreenScale());
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    CGContextTranslateCTM(context, verticalOffset, 0);
    
    if (op.CTFrameBorderColor || op.CTFrameFillColor) {
        UIBezierPath *path = layout.container.path;
        if (!path) {
            CGRect rect = (CGRect){CGPointZero, layout.container.size};
            rect = UIEdgeInsetsInsetRect(rect, layout.container.insets);
            if (op.CTFrameBorderColor) rect = YYTextCGRectPixelHalf(rect);
            else rect = YYTextCGRectPixelRound(rect);
            path = [UIBezierPath bezierPathWithRect:rect];
        }
        [path closePath];
        
        for (UIBezierPath *ex in layout.container.exclusionPaths) {
            [path appendPath:ex];
        }
        if (op.CTFrameFillColor) {
            [op.CTFrameFillColor setFill];
            if (layout.container.pathLineWidth > 0) {
                CGContextSaveGState(context); {
                    CGContextBeginTransparencyLayer(context, NULL); {
                        CGContextAddPath(context, path.CGPath);
                        if (layout.container.pathFillEvenOdd) {
                            CGContextEOFillPath(context);
                        } else {
                            CGContextFillPath(context);
                        }
                        CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
                        [[UIColor blackColor] setFill];
                        CGPathRef cgPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, layout.container.pathLineWidth, kCGLineCapButt, kCGLineJoinMiter, 0);
                        if (cgPath) {
                            CGContextAddPath(context, cgPath);
                            CGContextFillPath(context);
                        }
                        CGPathRelease(cgPath);
                    } CGContextEndTransparencyLayer(context);
                } CGContextRestoreGState(context);
            } else {
                CGContextAddPath(context, path.CGPath);
                if (layout.container.pathFillEvenOdd) {
                    CGContextEOFillPath(context);
                } else {
                    CGContextFillPath(context);
                }
            }
        }
        if (op.CTFrameBorderColor) {
            CGContextSaveGState(context); {
                if (layout.container.pathLineWidth > 0) {
                    CGContextSetLineWidth(context, layout.container.pathLineWidth);
                }
                [op.CTFrameBorderColor setStroke];
                CGContextAddPath(context, path.CGPath);
                CGContextStrokePath(context);
            } CGContextRestoreGState(context);
        }
    }
    
    NSArray *lines = layout.lines;
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
        YYTextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CGRect lineBounds = line.bounds;
        if (op.CTLineFillColor) {
            [op.CTLineFillColor setFill];
            CGContextAddRect(context, YYTextCGRectPixelRound(lineBounds));
            CGContextFillPath(context);
        }
        if (op.CTLineBorderColor) {
            [op.CTLineBorderColor setStroke];
            CGContextAddRect(context, YYTextCGRectPixelHalf(lineBounds));
            CGContextStrokePath(context);
        }
        if (op.baselineColor) {
            [op.baselineColor setStroke];
            if (isVertical) {
                CGFloat x = YYTextCGFloatPixelHalf(line.position.x);
                CGFloat y1 = YYTextCGFloatPixelHalf(line.top);
                CGFloat y2 = YYTextCGFloatPixelHalf(line.bottom);
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else {
                CGFloat x1 = YYTextCGFloatPixelHalf(lineBounds.origin.x);
                CGFloat x2 = YYTextCGFloatPixelHalf(lineBounds.origin.x + lineBounds.size.width);
                CGFloat y = YYTextCGFloatPixelHalf(line.position.y);
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            }
        }
        if (op.CTLineNumberColor) {
            [op.CTLineNumberColor set];
            NSMutableAttributedString *num = [[NSMutableAttributedString alloc] initWithString:@(l).description];
            num.yy_color = op.CTLineNumberColor;
            num.yy_font = [UIFont systemFontOfSize:6];
            [num drawAtPoint:CGPointMake(line.position.x, line.position.y - (isVertical ? 1 : 6))];
        }
        if (op.CTRunFillColor || op.CTRunBorderColor || op.CTRunNumberColor || op.CGGlyphFillColor || op.CGGlyphBorderColor) {
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CFIndex glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) continue;
                
                CGPoint glyphPositions[glyphCount];
                CTRunGetPositions(run, CFRangeMake(0, glyphCount), glyphPositions);
                
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);
                
                CGPoint runPosition = glyphPositions[0];
                if (isVertical) {
                    YYTEXT_SWAP(runPosition.x, runPosition.y);
                    runPosition.x = line.position.x;
                    runPosition.y += line.position.y;
                } else {
                    runPosition.x += line.position.x;
                    runPosition.y = line.position.y - runPosition.y;
                }
                
                CGFloat ascent, descent, leading;
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                CGRect runTypoBounds;
                if (isVertical) {
                    runTypoBounds = CGRectMake(runPosition.x - descent, runPosition.y, ascent + descent, width);
                } else {
                    runTypoBounds = CGRectMake(runPosition.x, line.position.y - ascent, width, ascent + descent);
                }
                
                if (op.CTRunFillColor) {
                    [op.CTRunFillColor setFill];
                    CGContextAddRect(context, YYTextCGRectPixelRound(runTypoBounds));
                    CGContextFillPath(context);
                }
                if (op.CTRunBorderColor) {
                    [op.CTRunBorderColor setStroke];
                    CGContextAddRect(context, YYTextCGRectPixelHalf(runTypoBounds));
                    CGContextStrokePath(context);
                }
                if (op.CTRunNumberColor) {
                    [op.CTRunNumberColor set];
                    NSMutableAttributedString *num = [[NSMutableAttributedString alloc] initWithString:@(r).description];
                    num.yy_color = op.CTRunNumberColor;
                    num.yy_font = [UIFont systemFontOfSize:6];
                    [num drawAtPoint:CGPointMake(runTypoBounds.origin.x, runTypoBounds.origin.y - 1)];
                }
                if (op.CGGlyphBorderColor || op.CGGlyphFillColor) {
                    for (NSUInteger g = 0; g < glyphCount; g++) {
                        CGPoint pos = glyphPositions[g];
                        CGSize adv = glyphAdvances[g];
                        CGRect rect;
                        if (isVertical) {
                            YYTEXT_SWAP(pos.x, pos.y);
                            pos.x = runPosition.x;
                            pos.y += line.position.y;
                            rect = CGRectMake(pos.x - descent, pos.y, runTypoBounds.size.width, adv.width);
                        } else {
                            pos.x += line.position.x;
                            pos.y = runPosition.y;
                            rect = CGRectMake(pos.x, pos.y - ascent, adv.width, runTypoBounds.size.height);
                        }
                        if (op.CGGlyphFillColor) {
                            [op.CGGlyphFillColor setFill];
                            CGContextAddRect(context, YYTextCGRectPixelRound(rect));
                            CGContextFillPath(context);
                        }
                        if (op.CGGlyphBorderColor) {
                            [op.CGGlyphBorderColor setStroke];
                            CGContextAddRect(context, YYTextCGRectPixelHalf(rect));
                            CGContextStrokePath(context);
                        }
                    }
                }
            }
        }
    }
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}


- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(UIView *)view
                layer:(CALayer *)layer
                debug:(YYTextDebugOption *)debug
                cancel:(BOOL (^)(void))cancel{
    @autoreleasepool {
        if (self.needDrawBlockBorder && context) {
            if (cancel && cancel()) return;
            YYTextDrawBlockBorder(self, context, size, point, cancel);
        }
        if (self.needDrawBackgroundBorder && context) {
            if (cancel && cancel()) return;
            YYTextDrawBorder(self, context, size, point, YYTextBorderTypeBackgound, cancel);
        }
        if (self.needDrawShadow && context) {
            if (cancel && cancel()) return;
            YYTextDrawShadow(self, context, size, point, cancel);
        }
        if (self.needDrawUnderline && context) {
            if (cancel && cancel()) return;
            YYTextDrawDecoration(self, context, size, point, YYTextDecorationTypeUnderline, cancel);
        }
        if (self.needDrawText && context) {
            if (cancel && cancel()) return;
            YYTextDrawText(self, context, size, point, cancel);
        }
        if (self.needDrawAttachment && (context || view || layer)) {
            if (cancel && cancel()) return;
            YYTextDrawAttachment(self, context, size, point, view, layer, cancel);
        }
        if (self.needDrawInnerShadow && context) {
            if (cancel && cancel()) return;
            YYTextDrawInnerShadow(self, context, size, point, cancel);
        }
        if (self.needDrawStrikethrough && context) {
            if (cancel && cancel()) return;
            YYTextDrawDecoration(self, context, size, point, YYTextDecorationTypeStrikethrough, cancel);
        }
        if (self.needDrawBorder && context) {
            if (cancel && cancel()) return;
            YYTextDrawBorder(self, context, size, point, YYTextBorderTypeNormal, cancel);
        }
        if (debug.needDrawDebug && context) {
            if (cancel && cancel()) return;
            YYTextDrawDebug(self, context, size, point, debug);
        }
    }
}

- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                debug:(YYTextDebugOption *)debug {
    [self drawInContext:context size:size point:CGPointZero view:nil layer:nil debug:debug cancel:nil];
}

- (void)addAttachmentToView:(UIView *)view layer:(CALayer *)layer {
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    [self drawInContext:NULL size:CGSizeZero point:CGPointZero view:view layer:layer debug:nil cancel:nil];
}

- (void)removeAttachmentFromViewAndLayer {
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    for (YYTextAttachment *a in self.attachments) {
        if ([a.content isKindOfClass:[UIView class]]) {
            UIView *v = a.content;
            [v removeFromSuperview];
        } else if ([a.content isKindOfClass:[CALayer class]]) {
            CALayer *l = a.content;
            [l removeFromSuperlayer];
        }
    }
}

@end
