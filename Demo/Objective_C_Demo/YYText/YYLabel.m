//
//  YYLabel.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/2/25.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYLabel.h"
#import "YYTextAsyncLayer.h"
#import "YYTextWeakProxy.h"
#import "YYTextUtilities.h"
#import "NSAttributedString+YYText.h"
#import <libkern/OSAtomic.h>


static dispatch_queue_t YYLabelGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}


#define kLongPressMinimumDuration 0.5 // Time in seconds the fingers must be held down for long press gesture.
#define kLongPressAllowableMovement 9.0 // Maximum movement in points allowed before the long press fails.
#define kHighlightFadeDuration 0.15 // Time in seconds for highlight fadeout animation.
#define kAsyncFadeDuration 0.08 // Time in seconds for async display fadeout animation.


@interface YYLabel() <YYTextDebugTarget, YYTextAsyncLayerDelegate> {
    NSMutableAttributedString *_innerText; ///< nonnull
    YYTextLayout *_innerLayout;
    YYTextContainer *_innerContainer; ///< nonnull
    
    NSMutableArray *_attachmentViews;
    NSMutableArray *_attachmentLayers;
    
    NSRange _highlightRange; ///< current highlight range
    YYTextHighlight *_highlight; ///< highlight attribute in `_highlightRange`
    YYTextLayout *_highlightLayout; ///< when _state.showingHighlight=YES, this layout should be displayed
    
    YYTextLayout *_shrinkInnerLayout;
    YYTextLayout *_shrinkHighlightLayout;
    
    NSTimer *_longPressTimer;
    CGPoint _touchBeganPoint;
    
    struct {
        unsigned int layoutNeedUpdate : 1;
        unsigned int showingHighlight : 1;
        
        unsigned int trackingTouch : 1;
        unsigned int swallowTouch : 1;
        unsigned int touchMoved : 1;
        
        unsigned int hasTapAction : 1;
        unsigned int hasLongPressAction : 1;
        
        unsigned int contentsNeedFade : 1;
    } _state;
}
@end


@implementation YYLabel

#pragma mark - Private

- (void)_updateIfNeeded {
    if (_state.layoutNeedUpdate) {
        _state.layoutNeedUpdate = NO;
        [self _updateLayout];
        [self.layer setNeedsDisplay];
    }
}

- (void)_updateLayout {
    _innerLayout = [YYTextLayout layoutWithContainer:_innerContainer text:_innerText];
    _shrinkInnerLayout = [YYLabel _shrinkLayoutWithLayout:_innerLayout];
}

- (void)_setLayoutNeedUpdate {
    _state.layoutNeedUpdate = YES;
    [self _clearInnerLayout];
    [self _setLayoutNeedRedraw];
}

- (void)_setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)_clearInnerLayout {
    if (!_innerLayout) return;
    YYTextLayout *layout = _innerLayout;
    _innerLayout = nil;
    _shrinkInnerLayout = nil;
    dispatch_async(YYLabelGetReleaseQueue(), ^{
        NSAttributedString *text = [layout text]; // capture to block and release in background
        if (layout.attachments.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [text length]; // capture to block and release in main thread (maybe there's UIView/CALayer attachments).
            });
        }
    });
}

- (YYTextLayout *)_innerLayout {
    return _shrinkInnerLayout ? _shrinkInnerLayout : _innerLayout;
}

- (YYTextLayout *)_highlightLayout {
    return _shrinkHighlightLayout ? _shrinkHighlightLayout : _highlightLayout;
}

+ (YYTextLayout *)_shrinkLayoutWithLayout:(YYTextLayout *)layout {
    if (layout.text.length && layout.lines.count == 0) {
        YYTextContainer *container = layout.container.copy;
        container.maximumNumberOfRows = 1;
        CGSize containerSize = container.size;
        if (!container.verticalForm) {
            containerSize.height = YYTextContainerMaxSize.height;
        } else {
            containerSize.width = YYTextContainerMaxSize.width;
        }
        container.size = containerSize;
        return [YYTextLayout layoutWithContainer:container text:layout.text];
    } else {
        return nil;
    }
}

- (void)_startLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressMinimumDuration
                                              target:[YYTextWeakProxy proxyWithTarget:self]
                                            selector:@selector(_trackDidLongPress)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)_endLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = nil;
}

- (void)_trackDidLongPress {
    [self _endLongPressTimer];
    if (_state.hasLongPressAction && _textLongPressAction) {
        NSRange range = NSMakeRange(NSNotFound, 0);
        CGRect rect = CGRectNull;
        CGPoint point = [self _convertPointToLayout:_touchBeganPoint];
        YYTextRange *textRange = [self._innerLayout textRangeAtPoint:point];
        CGRect textRect = [self._innerLayout rectForRange:textRange];
        textRect = [self _convertRectFromLayout:textRect];
        if (textRange) {
            range = textRange.asRange;
            rect = textRect;
        }
        _textLongPressAction(self, _innerText, range, rect);
    }
    if (_highlight) {
        YYTextAction longPressAction = _highlight.longPressAction ? _highlight.longPressAction : _highlightLongPressAction;
        if (longPressAction) {
            YYTextPosition *start = [YYTextPosition positionWithOffset:_highlightRange.location];
            YYTextPosition *end = [YYTextPosition positionWithOffset:_highlightRange.location + _highlightRange.length affinity:YYTextAffinityBackward];
            YYTextRange *range = [YYTextRange rangeWithStart:start end:end];
            CGRect rect = [self._innerLayout rectForRange:range];
            rect = [self _convertRectFromLayout:rect];
            longPressAction(self, _innerText, _highlightRange, rect);
            [self _removeHighlightAnimated:YES];
            _state.trackingTouch = NO;
        }
    }
}

- (YYTextHighlight *)_getHighlightAtPoint:(CGPoint)point range:(NSRangePointer)range {
    if (!self._innerLayout.containsHighlight) return nil;
    point = [self _convertPointToLayout:point];
    YYTextRange *textRange = [self._innerLayout textRangeAtPoint:point];
    if (!textRange) return nil;
    
    NSUInteger startIndex = textRange.start.offset;
    if (startIndex == _innerText.length) {
        if (startIndex > 0) {
            startIndex--;
        }
    }
    NSRange highlightRange = {0};
    YYTextHighlight *highlight = [_innerText attribute:YYTextHighlightAttributeName
                                               atIndex:startIndex
                                 longestEffectiveRange:&highlightRange
                                               inRange:NSMakeRange(0, _innerText.length)];
    
    if (!highlight) return nil;
    if (range) *range = highlightRange;
    return highlight;
}

- (void)_showHighlightAnimated:(BOOL)animated {
    if (!_highlight) return;
    if (!_highlightLayout) {
        NSMutableAttributedString *hiText = _innerText.mutableCopy;
        NSDictionary *newAttrs = _highlight.attributes;
        [newAttrs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            [hiText yy_setAttribute:key value:value range:_highlightRange];
        }];
        _highlightLayout = [YYTextLayout layoutWithContainer:_innerContainer text:hiText];
        _shrinkHighlightLayout = [YYLabel _shrinkLayoutWithLayout:_highlightLayout];
        if (!_highlightLayout) _highlight = nil;
    }
    
    if (_highlightLayout && !_state.showingHighlight) {
        _state.showingHighlight = YES;
        _state.contentsNeedFade = animated;
        [self _setLayoutNeedRedraw];
    }
}

- (void)_hideHighlightAnimated:(BOOL)animated {
    if (_state.showingHighlight) {
        _state.showingHighlight = NO;
        _state.contentsNeedFade = animated;
        [self _setLayoutNeedRedraw];
    }
}

- (void)_removeHighlightAnimated:(BOOL)animated {
    [self _hideHighlightAnimated:animated];
    _highlight = nil;
    _highlightLayout = nil;
    _shrinkHighlightLayout = nil;
}

- (void)_endTouch {
    [self _endLongPressTimer];
    [self _removeHighlightAnimated:YES];
    _state.trackingTouch = NO;
}

- (CGPoint)_convertPointToLayout:(CGPoint)point {
    CGSize boundingSize = self._innerLayout.textBoundingSize;
    if (self._innerLayout.container.isVerticalForm) {
        CGFloat w = self._innerLayout.textBoundingSize.width;
        if (w < self.bounds.size.width) w = self.bounds.size.width;
        point.x += self._innerLayout.container.size.width - w;
        if (_textVerticalAlignment == YYTextVerticalAlignmentCenter) {
            point.x += (self.bounds.size.width - boundingSize.width) * 0.5;
        } else if (_textVerticalAlignment == YYTextVerticalAlignmentBottom) {
            point.x += (self.bounds.size.width - boundingSize.width);
        }
        return point;
    } else {
        if (_textVerticalAlignment == YYTextVerticalAlignmentCenter) {
            point.y -= (self.bounds.size.height - boundingSize.height) * 0.5;
        } else if (_textVerticalAlignment == YYTextVerticalAlignmentBottom) {
            point.y -= (self.bounds.size.height - boundingSize.height);
        }
        return point;
    }
}

- (CGPoint)_convertPointFromLayout:(CGPoint)point {
    CGSize boundingSize = self._innerLayout.textBoundingSize;
    if (self._innerLayout.container.isVerticalForm) {
        CGFloat w = self._innerLayout.textBoundingSize.width;
        if (w < self.bounds.size.width) w = self.bounds.size.width;
        point.x -= self._innerLayout.container.size.width - w;
        if (boundingSize.width < self.bounds.size.width) {
            if (_textVerticalAlignment == YYTextVerticalAlignmentCenter) {
                point.x -= (self.bounds.size.width - boundingSize.width) * 0.5;
            } else if (_textVerticalAlignment == YYTextVerticalAlignmentBottom) {
                point.x -= (self.bounds.size.width - boundingSize.width);
            }
        }
        return point;
    } else {
        if (boundingSize.height < self.bounds.size.height) {
            if (_textVerticalAlignment == YYTextVerticalAlignmentCenter) {
                point.y += (self.bounds.size.height - boundingSize.height) * 0.5;
            } else if (_textVerticalAlignment == YYTextVerticalAlignmentBottom) {
                point.y += (self.bounds.size.height - boundingSize.height);
            }
        }
        return point;
    }
}

- (CGRect)_convertRectToLayout:(CGRect)rect {
    rect.origin = [self _convertPointToLayout:rect.origin];
    return rect;
}

- (CGRect)_convertRectFromLayout:(CGRect)rect {
    rect.origin = [self _convertPointFromLayout:rect.origin];
    return rect;
}

- (UIFont *)_defaultFont {
    return [UIFont systemFontOfSize:17];
}

- (NSShadow *)_shadowFromProperties {
    if (!_shadowColor || _shadowBlurRadius < 0) return nil;
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = _shadowColor;
#if !TARGET_INTERFACE_BUILDER
    shadow.shadowOffset = _shadowOffset;
#else
    shadow.shadowOffset = CGSizeMake(_shadowOffset.x, _shadowOffset.y);
#endif
    shadow.shadowBlurRadius = _shadowBlurRadius;
    return shadow;
}

- (void)_updateOuterLineBreakMode {
    if (_innerContainer.truncationType) {
        switch (_innerContainer.truncationType) {
            case YYTextTruncationTypeStart: {
                _lineBreakMode = NSLineBreakByTruncatingHead;
            } break;
            case YYTextTruncationTypeEnd: {
                _lineBreakMode = NSLineBreakByTruncatingTail;
            } break;
            case YYTextTruncationTypeMiddle: {
                _lineBreakMode = NSLineBreakByTruncatingMiddle;
            } break;
            default:break;
        }
    } else {
        _lineBreakMode = _innerText.yy_lineBreakMode;
    }
}

- (void)_updateOuterTextProperties {
    _text = [_innerText yy_plainTextForRange:NSMakeRange(0, _innerText.length)];
    _font = _innerText.yy_font;
    if (!_font) _font = [self _defaultFont];
    _textColor = _innerText.yy_color;
    if (!_textColor) _textColor = [UIColor blackColor];
    _textAlignment = _innerText.yy_alignment;
    _lineBreakMode = _innerText.yy_lineBreakMode;
    NSShadow *shadow = _innerText.yy_shadow;
    _shadowColor = shadow.shadowColor;
#if !TARGET_INTERFACE_BUILDER
    _shadowOffset = shadow.shadowOffset;
#else
    _shadowOffset = CGPointMake(shadow.shadowOffset.width, shadow.shadowOffset.height);
#endif
    
    _shadowBlurRadius = shadow.shadowBlurRadius;
    _attributedText = _innerText;
    [self _updateOuterLineBreakMode];
}

- (void)_updateOuterContainerProperties {
    _truncationToken = _innerContainer.truncationToken;
    _numberOfLines = _innerContainer.maximumNumberOfRows;
    _textContainerPath = _innerContainer.path;
    _exclusionPaths = _innerContainer.exclusionPaths;
    _textContainerInset = _innerContainer.insets;
    _verticalForm = _innerContainer.verticalForm;
    _linePositionModifier = _innerContainer.linePositionModifier;
    [self _updateOuterLineBreakMode];
}

- (void)_clearContents {
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(YYLabelGetReleaseQueue(), ^{
            CFRelease(image);
        });
    }
}

- (void)_initLabel {
    ((YYTextAsyncLayer *)self.layer).displaysAsynchronously = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    
    _attachmentViews = [NSMutableArray new];
    _attachmentLayers = [NSMutableArray new];
    
    _debugOption = [YYTextDebugOption sharedDebugOption];
    [YYTextDebugOption addDebugTarget:self];
    
    _font = [self _defaultFont];
    _textColor = [UIColor blackColor];
    _textVerticalAlignment = YYTextVerticalAlignmentCenter;
    _numberOfLines = 1;
    _lineBreakMode = NSLineBreakByTruncatingTail;
    _innerText = [NSMutableAttributedString new];
    _innerContainer = [YYTextContainer new];
    _innerContainer.truncationType = YYTextTruncationTypeEnd;
    _innerContainer.maximumNumberOfRows = _numberOfLines;
    _clearContentsBeforeAsynchronouslyDisplay = YES;
    _fadeOnAsynchronouslyDisplay = YES;
    _fadeOnHighlight = YES;
    
    self.isAccessibilityElement = YES;
}

#pragma mark - Override

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    [self _initLabel];
    self.frame = frame;
    return self;
}

- (void)dealloc {
    [YYTextDebugOption removeDebugTarget:self];
    [_longPressTimer invalidate];
}

+ (Class)layerClass {
    return [YYTextAsyncLayer class];
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        if (!_ignoreCommonProperties) {
            _state.layoutNeedUpdate = YES;
        }
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedRedraw];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        if (!_ignoreCommonProperties) {
            _state.layoutNeedUpdate = YES;
        }
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedRedraw];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (_ignoreCommonProperties) {
        return _innerLayout.textBoundingSize;
    }
    
    if (!_verticalForm && size.width <= 0) size.width = YYTextContainerMaxSize.width;
    if (_verticalForm && size.height <= 0) size.height = YYTextContainerMaxSize.height;
    
    if ((!_verticalForm && size.width == self.bounds.size.width) ||
        (_verticalForm && size.height == self.bounds.size.height)) {
        [self _updateIfNeeded];
        YYTextLayout *layout = self._innerLayout;
        BOOL contains = NO;
        if (layout.container.maximumNumberOfRows == 0) {
            if (layout.truncatedLine == nil) {
                contains = YES;
            }
        } else {
            if (layout.rowCount <= layout.container.maximumNumberOfRows) {
                contains = YES;
            }
        }
        if (contains) {
            return layout.textBoundingSize;
        }
    }
    
    if (!_verticalForm) {
        size.height = YYTextContainerMaxSize.height;
    } else {
        size.width = YYTextContainerMaxSize.width;
    }
    
    YYTextContainer *container = [_innerContainer copy];
    container.size = size;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:_innerText];
    return layout.textBoundingSize;
}

- (NSString *)accessibilityLabel {
    return [_innerLayout.text yy_plainTextForRange:_innerLayout.text.yy_rangeOfAll];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_attributedText forKey:@"attributedText"];
    [aCoder encodeObject:_innerContainer forKey:@"innerContainer"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _initLabel];
    YYTextContainer *innerContainer = [aDecoder decodeObjectForKey:@"innerContainer"];
    if (innerContainer) {
        _innerContainer = innerContainer;
    } else {
        _innerContainer.size = self.bounds.size;
    }
    [self _updateOuterContainerProperties];
    self.attributedText = [aDecoder decodeObjectForKey:@"attributedText"];
    [self _setLayoutNeedUpdate];
    return self;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _updateIfNeeded];
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    _highlight = [self _getHighlightAtPoint:point range:&_highlightRange];
    _highlightLayout = nil;
    _shrinkHighlightLayout = nil;
    _state.hasTapAction = _textTapAction != nil;
    _state.hasLongPressAction = _textLongPressAction != nil;
    
    if (_highlight || _textTapAction || _textLongPressAction) {
        _touchBeganPoint = point;
        _state.trackingTouch = YES;
        _state.swallowTouch = YES;
        _state.touchMoved = NO;
        [self _startLongPressTimer];
        if (_highlight) [self _showHighlightAnimated:NO];
    } else {
        _state.trackingTouch = NO;
        _state.swallowTouch = NO;
        _state.touchMoved = NO;
    }
    if (!_state.swallowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _updateIfNeeded];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        if (!_state.touchMoved) {
            CGFloat moveH = point.x - _touchBeganPoint.x;
            CGFloat moveV = point.y - _touchBeganPoint.y;
            if (fabs(moveH) > fabs(moveV)) {
                if (fabs(moveH) > kLongPressAllowableMovement) _state.touchMoved = YES;
            } else {
                if (fabs(moveV) > kLongPressAllowableMovement) _state.touchMoved = YES;
            }
            if (_state.touchMoved) {
                [self _endLongPressTimer];
            }
        }
        if (_state.touchMoved && _highlight) {
            YYTextHighlight *highlight = [self _getHighlightAtPoint:point range:NULL];
            if (highlight == _highlight) {
                [self _showHighlightAnimated:_fadeOnHighlight];
            } else {
                [self _hideHighlightAnimated:_fadeOnHighlight];
            }
        }
    }
    
    if (!_state.swallowTouch) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        [self _endLongPressTimer];
        if (!_state.touchMoved && _textTapAction) {
            NSRange range = NSMakeRange(NSNotFound, 0);
            CGRect rect = CGRectNull;
            CGPoint point = [self _convertPointToLayout:_touchBeganPoint];
            YYTextRange *textRange = [self._innerLayout textRangeAtPoint:point];
            CGRect textRect = [self._innerLayout rectForRange:textRange];
            textRect = [self _convertRectFromLayout:textRect];
            if (textRange) {
                range = textRange.asRange;
                rect = textRect;
            }
            _textTapAction(self, _innerText, range, rect);
        }
        
        if (_highlight) {
            if (!_state.touchMoved || [self _getHighlightAtPoint:point range:NULL] == _highlight) {
                YYTextAction tapAction = _highlight.tapAction ? _highlight.tapAction : _highlightTapAction;
                if (tapAction) {
                    YYTextPosition *start = [YYTextPosition positionWithOffset:_highlightRange.location];
                    YYTextPosition *end = [YYTextPosition positionWithOffset:_highlightRange.location + _highlightRange.length affinity:YYTextAffinityBackward];
                    YYTextRange *range = [YYTextRange rangeWithStart:start end:end];
                    CGRect rect = [self._innerLayout rectForRange:range];
                    rect = [self _convertRectFromLayout:rect];
                    tapAction(self, _innerText, _highlightRange, rect);
                }
            }
            [self _removeHighlightAnimated:_fadeOnHighlight];
        }
    }
    
    if (!_state.swallowTouch) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _endTouch];
    if (!_state.swallowTouch) [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Properties

- (void)setText:(NSString *)text {
    if (_text == text || [_text isEqualToString:text]) return;
    _text = text.copy;
    BOOL needAddAttributes = _innerText.length == 0 && text.length > 0;
    [_innerText replaceCharactersInRange:NSMakeRange(0, _innerText.length) withString:text ? text : @""];
    [_innerText yy_removeDiscontinuousAttributesInRange:NSMakeRange(0, _innerText.length)];
    if (needAddAttributes) {
        _innerText.yy_font = _font;
        _innerText.yy_color = _textColor;
        _innerText.yy_shadow = [self _shadowFromProperties];
        _innerText.yy_alignment = _textAlignment;
        switch (_lineBreakMode) {
            case NSLineBreakByWordWrapping:
            case NSLineBreakByCharWrapping:
            case NSLineBreakByClipping: {
                _innerText.yy_lineBreakMode = _lineBreakMode;
            } break;
            case NSLineBreakByTruncatingHead:
            case NSLineBreakByTruncatingTail:
            case NSLineBreakByTruncatingMiddle: {
                _innerText.yy_lineBreakMode = NSLineBreakByWordWrapping;
            } break;
            default: break;
        }
    }
    if ([_textParser parseText:_innerText selectedRange:NULL]) {
        [self _updateOuterTextProperties];
    }
    if (!_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setFont:(UIFont *)font {
    if (!font) {
        font = [self _defaultFont];
    }
    if (_font == font || [_font isEqual:font]) return;
    _font = font;
    _innerText.yy_font = _font;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) {
        textColor = [UIColor blackColor];
    }
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    _innerText.yy_color = textColor;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor == shadowColor || [_shadowColor isEqual:shadowColor]) return;
    _shadowColor = shadowColor;
    _innerText.yy_shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
    }
}

#if !TARGET_INTERFACE_BUILDER
- (void)setShadowOffset:(CGSize)shadowOffset {
    if (CGSizeEqualToSize(_shadowOffset, shadowOffset)) return;
    _shadowOffset = shadowOffset;
    _innerText.yy_shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
    }
}
#else
- (void)setShadowOffset:(CGPoint)shadowOffset {
    if (CGPointEqualToPoint(_shadowOffset, shadowOffset)) return;
    _shadowOffset = shadowOffset;
    _innerText.yy_shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
    }
}
#endif

- (void)setShadowBlurRadius:(CGFloat)shadowBlurRadius {
    if (_shadowBlurRadius == shadowBlurRadius) return;
    _shadowBlurRadius = shadowBlurRadius;
    _innerText.yy_shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    _innerText.yy_alignment = textAlignment;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode == lineBreakMode) return;
    _lineBreakMode = lineBreakMode;
    _innerText.yy_lineBreakMode = lineBreakMode;
    // allow multi-line break
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping:
        case NSLineBreakByCharWrapping:
        case NSLineBreakByClipping: {
            _innerContainer.truncationType = YYTextTruncationTypeNone;
            _innerText.yy_lineBreakMode = lineBreakMode;
        } break;
        case NSLineBreakByTruncatingHead:{
            _innerContainer.truncationType = YYTextTruncationTypeStart;
            _innerText.yy_lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        case NSLineBreakByTruncatingTail:{
            _innerContainer.truncationType = YYTextTruncationTypeEnd;
            _innerText.yy_lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        case NSLineBreakByTruncatingMiddle: {
            _innerContainer.truncationType = YYTextTruncationTypeMiddle;
            _innerText.yy_lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        default: break;
    }
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextVerticalAlignment:(YYTextVerticalAlignment)textVerticalAlignment {
    if (_textVerticalAlignment == textVerticalAlignment) return;
    _textVerticalAlignment = textVerticalAlignment;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    if (_truncationToken == truncationToken || [_truncationToken isEqual:truncationToken]) return;
    _truncationToken = truncationToken.copy;
    _innerContainer.truncationToken = truncationToken;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    _innerContainer.maximumNumberOfRows = numberOfLines;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length > 0) {
        _innerText = attributedText.mutableCopy;
        switch (_lineBreakMode) {
            case NSLineBreakByWordWrapping:
            case NSLineBreakByCharWrapping:
            case NSLineBreakByClipping: {
                _innerText.yy_lineBreakMode = _lineBreakMode;
            } break;
            case NSLineBreakByTruncatingHead:
            case NSLineBreakByTruncatingTail:
            case NSLineBreakByTruncatingMiddle: {
                _innerText.yy_lineBreakMode = NSLineBreakByWordWrapping;
            } break;
            default: break;
        }
    } else {
        _innerText = [NSMutableAttributedString new];
    }
    [_textParser parseText:_innerText selectedRange:NULL];
    if (!_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _updateOuterTextProperties];
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextContainerPath:(UIBezierPath *)textContainerPath {
    if (_textContainerPath == textContainerPath || [_textContainerPath isEqual:textContainerPath]) return;
    _textContainerPath = textContainerPath.copy;
    _innerContainer.path = textContainerPath;
    if (!_textContainerPath) {
        _innerContainer.size = self.bounds.size;
        _innerContainer.insets = _textContainerInset;
    }
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setExclusionPaths:(NSArray *)exclusionPaths {
    if (_exclusionPaths == exclusionPaths || [_exclusionPaths isEqual:exclusionPaths]) return;
    _exclusionPaths = exclusionPaths.copy;
    _innerContainer.exclusionPaths = exclusionPaths;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainerInset, textContainerInset)) return;
    _textContainerInset = textContainerInset;
    _innerContainer.insets = textContainerInset;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setVerticalForm:(BOOL)verticalForm {
    if (_verticalForm == verticalForm) return;
    _verticalForm = verticalForm;
    _innerContainer.verticalForm = verticalForm;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLinePositionModifier:(id<YYTextLinePositionModifier>)linePositionModifier {
    if (_linePositionModifier == linePositionModifier) return;
    _linePositionModifier = linePositionModifier;
    _innerContainer.linePositionModifier = linePositionModifier;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContents];
        }
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextParser:(id<YYTextParser>)textParser {
    if (_textParser == textParser || [_textParser isEqual:textParser]) return;
    _textParser = textParser;
    if ([_textParser parseText:_innerText selectedRange:NULL]) {
        [self _updateOuterTextProperties];
        if (!_ignoreCommonProperties) {
            if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
                [self _clearContents];
            }
            [self _setLayoutNeedUpdate];
            [self _endTouch];
            [self invalidateIntrinsicContentSize];
        }
    }
}

- (void)setTextLayout:(YYTextLayout *)textLayout {
    _innerLayout = textLayout;
    _shrinkInnerLayout = nil;
    
    if (_ignoreCommonProperties) {
        _innerText = (NSMutableAttributedString *)textLayout.text;
        _innerContainer = textLayout.container.copy;
    } else {
        _innerText = textLayout.text.mutableCopy;
        if (!_innerText) {
            _innerText = [NSMutableAttributedString new];
        }
        [self _updateOuterTextProperties];
        
        _innerContainer = textLayout.container.copy;
        if (!_innerContainer) {
            _innerContainer = [YYTextContainer new];
            _innerContainer.size = self.bounds.size;
            _innerContainer.insets = self.textContainerInset;
        }
        [self _updateOuterContainerProperties];
    }
    
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self _clearContents];
    }
    _state.layoutNeedUpdate = NO;
    [self _setLayoutNeedRedraw];
    [self _endTouch];
    [self invalidateIntrinsicContentSize];
}

- (YYTextLayout *)textLayout {
    [self _updateIfNeeded];
    return _innerLayout;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    _displaysAsynchronously = displaysAsynchronously;
    ((YYTextAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

#pragma mark - AutoLayout

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) return;
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    if (_preferredMaxLayoutWidth == 0) {
        YYTextContainer *container = [_innerContainer copy];
        container.size = YYTextContainerMaxSize;
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:_innerText];
        return layout.textBoundingSize;
    }
    
    CGSize containerSize = _innerContainer.size;
    if (!_verticalForm) {
        containerSize.height = YYTextContainerMaxSize.height;
        containerSize.width = _preferredMaxLayoutWidth;
        if (containerSize.width == 0) containerSize.width = self.bounds.size.width;
    } else {
        containerSize.width = YYTextContainerMaxSize.width;
        containerSize.height = _preferredMaxLayoutWidth;
        if (containerSize.height == 0) containerSize.height = self.bounds.size.height;
    }
    
    YYTextContainer *container = [_innerContainer copy];
    container.size = containerSize;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:_innerText];
    return layout.textBoundingSize;
}

#pragma mark - YYTextDebugTarget

- (void)setDebugOption:(YYTextDebugOption *)debugOption {
    BOOL needDraw = _debugOption.needDrawDebug;
    _debugOption = debugOption.copy;
    if (_debugOption.needDrawDebug != needDraw) {
        [self _setLayoutNeedRedraw];
    }
}

#pragma mark - YYTextAsyncLayerDelegate

- (YYTextAsyncLayerDisplayTask *)newAsyncDisplayTask {
    
    // capture current context
    BOOL contentsNeedFade = _state.contentsNeedFade;
    NSAttributedString *text = _innerText;
    YYTextContainer *container = _innerContainer;
    YYTextVerticalAlignment verticalAlignment = _textVerticalAlignment;
    YYTextDebugOption *debug = _debugOption;
    NSMutableArray *attachmentViews = _attachmentViews;
    NSMutableArray *attachmentLayers = _attachmentLayers;
    BOOL layoutNeedUpdate = _state.layoutNeedUpdate;
    BOOL fadeForAsync = _displaysAsynchronously && _fadeOnAsynchronouslyDisplay;
    __block YYTextLayout *layout = (_state.showingHighlight && _highlightLayout) ? self._highlightLayout : self._innerLayout;
    __block YYTextLayout *shrinkLayout = nil;
    __block BOOL layoutUpdated = NO;
    if (layoutNeedUpdate) {
        text = text.copy;
        container = container.copy;
    }
    
    // create display task
    YYTextAsyncLayerDisplayTask *task = [YYTextAsyncLayerDisplayTask new];
    
    task.willDisplay = ^(CALayer *layer) {
        [layer removeAnimationForKey:@"contents"];
        
        // If the attachment is not in new layout, or we don't know the new layout currently,
        // the attachment should be removed.
        for (UIView *view in attachmentViews) {
            if (layoutNeedUpdate || ![layout.attachmentContentsSet containsObject:view]) {
                if (view.superview == self) {
                    [view removeFromSuperview];
                }
            }
        }
        for (CALayer *layer in attachmentLayers) {
            if (layoutNeedUpdate || ![layout.attachmentContentsSet containsObject:layer]) {
                if (layer.superlayer == self.layer) {
                    [layer removeFromSuperlayer];
                }
            }
        }
        [attachmentViews removeAllObjects];
        [attachmentLayers removeAllObjects];
    };

    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (isCancelled()) return;
        if (text.length == 0) return;
        
        YYTextLayout *drawLayout = layout;
        if (layoutNeedUpdate) {
            layout = [YYTextLayout layoutWithContainer:container text:text];
            shrinkLayout = [YYLabel _shrinkLayoutWithLayout:layout];
            if (isCancelled()) return;
            layoutUpdated = YES;
            drawLayout = shrinkLayout ? shrinkLayout : layout;
        }
        
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (verticalAlignment == YYTextVerticalAlignmentCenter) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width) * 0.5;
            } else {
                point.y = (size.height - boundingSize.height) * 0.5;
            }
        } else if (verticalAlignment == YYTextVerticalAlignmentBottom) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width);
            } else {
                point.y = (size.height - boundingSize.height);
            }
        }
        point = YYTextCGPointPixelRound(point);
        [drawLayout drawInContext:context size:size point:point view:nil layer:nil debug:debug cancel:isCancelled];
    };

    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        YYTextLayout *drawLayout = layout;
        if (layoutUpdated && shrinkLayout) {
            drawLayout = shrinkLayout;
        }
        if (!finished) {
            // If the display task is cancelled, we should clear the attachments.
            for (YYTextAttachment *a in drawLayout.attachments) {
                if ([a.content isKindOfClass:[UIView class]]) {
                    if (((UIView *)a.content).superview == layer.delegate) {
                        [((UIView *)a.content) removeFromSuperview];
                    }
                } else if ([a.content isKindOfClass:[CALayer class]]) {
                    if (((CALayer *)a.content).superlayer == layer) {
                        [((CALayer *)a.content) removeFromSuperlayer];
                    }
                }
            }
            return;
        }
        [layer removeAnimationForKey:@"contents"];
        
        YYLabel *view = layer.delegate;
        if (!view) return;
        if (view->_state.layoutNeedUpdate && layoutUpdated) {
            view->_innerLayout = layout;
            view->_shrinkInnerLayout = shrinkLayout;
            view->_state.layoutNeedUpdate = NO;
        }
        
        CGSize size = layer.bounds.size;
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (verticalAlignment == YYTextVerticalAlignmentCenter) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width) * 0.5;
            } else {
                point.y = (size.height - boundingSize.height) * 0.5;
            }
        } else if (verticalAlignment == YYTextVerticalAlignmentBottom) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width);
            } else {
                point.y = (size.height - boundingSize.height);
            }
        }
        point = YYTextCGPointPixelRound(point);
        [drawLayout drawInContext:nil size:size point:point view:view layer:layer debug:nil cancel:NULL];
        for (YYTextAttachment *a in drawLayout.attachments) {
            if ([a.content isKindOfClass:[UIView class]]) [attachmentViews addObject:a.content];
            else if ([a.content isKindOfClass:[CALayer class]]) [attachmentLayers addObject:a.content];
        }
        
        if (contentsNeedFade) {
            CATransition *transition = [CATransition animation];
            transition.duration = kHighlightFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:@"contents"];
        } else if (fadeForAsync) {
            CATransition *transition = [CATransition animation];
            transition.duration = kAsyncFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:@"contents"];
        }
    };
    
    return task;
}

@end



@interface YYLabel(IBInspectableProperties)
@end

@implementation YYLabel (IBInspectableProperties)

- (BOOL)fontIsBold_:(UIFont *)font {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (UIFont *)boldFont_:(UIFont *)font {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:font.pointSize];
}

- (UIFont *)normalFont_:(UIFont *)font {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:font.pointSize];
}

- (void)setFontName_:(NSString *)fontName {
    if (!fontName) return;
    UIFont *font = self.font;
    if ((fontName.length == 0 || [fontName.lowercaseString isEqualToString:@"system"]) && ![self fontIsBold_:font]) {
        font = [UIFont systemFontOfSize:font.pointSize];
    } else if ([fontName.lowercaseString isEqualToString:@"system bold"]) {
        font = [UIFont boldSystemFontOfSize:font.pointSize];
    } else {
        if ([self fontIsBold_:font] && ![fontName.lowercaseString containsString:@"bold"]) {
            font = [UIFont fontWithName:fontName size:font.pointSize];
            font = [self boldFont_:font];
        } else {
            font = [UIFont fontWithName:fontName size:font.pointSize];
        }
    }
    if (font) self.font = font;
}

- (void)setFontSize_:(CGFloat)fontSize {
    if (fontSize <= 0) return;
    UIFont *font = self.font;
    font = [font fontWithSize:fontSize];
    if (font) self.font = font;
}

- (void)setFontIsBold_:(BOOL)fontBold {
    UIFont *font = self.font;
    if ([self fontIsBold_:font] == fontBold) return;
    if (fontBold) {
        font = [self boldFont_:font];
    } else {
        font = [self normalFont_:font];
    }
    if (font) self.font = font;
}

- (void)setInsetTop_:(CGFloat)textInsetTop {
    UIEdgeInsets insets = self.textContainerInset;
    insets.top = textInsetTop;
    self.textContainerInset = insets;
}

- (void)setInsetBottom_:(CGFloat)textInsetBottom {
    UIEdgeInsets insets = self.textContainerInset;
    insets.bottom = textInsetBottom;
    self.textContainerInset = insets;
}

- (void)setInsetLeft_:(CGFloat)textInsetLeft {
    UIEdgeInsets insets = self.textContainerInset;
    insets.left = textInsetLeft;
    self.textContainerInset = insets;
    
}

- (void)setInsetRight_:(CGFloat)textInsetRight {
    UIEdgeInsets insets = self.textContainerInset;
    insets.right = textInsetRight;
    self.textContainerInset = insets;
}

- (void)setDebugEnabled_:(BOOL)enabled {
    if (!enabled) {
        self.debugOption = nil;
    } else {
        YYTextDebugOption *debugOption = [YYTextDebugOption new];
        debugOption.baselineColor = [UIColor redColor];
        debugOption.CTFrameBorderColor = [UIColor redColor];
        debugOption.CTLineFillColor = [UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:0.180];
        debugOption.CGGlyphBorderColor = [UIColor colorWithRed:1.000 green:0.524 blue:0.000 alpha:0.200];
        self.debugOption = debugOption;
    }
}

@end
