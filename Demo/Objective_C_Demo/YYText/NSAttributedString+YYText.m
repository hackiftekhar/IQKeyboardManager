//
//  NSAttributedString+YYText.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 14/10/7.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSAttributedString+YYText.h"
#import "NSParagraphStyle+YYText.h"
#import "YYTextArchiver.h"
#import "YYTextRunDelegate.h"
#import "YYTextUtilities.h"
#import <CoreFoundation/CoreFoundation.h>


// Dummy class for category
@interface NSAttributedString_YYText : NSObject @end
@implementation NSAttributedString_YYText @end


static double _YYDeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

#ifndef kSystemVersion
#define kSystemVersion _YYDeviceSystemVersion()
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif



@implementation NSAttributedString (YYText)

- (NSData *)yy_archiveToData {
    NSData *data = nil;
    @try {
        data = [YYTextArchiver archivedDataWithRootObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return data;
}

+ (instancetype)yy_unarchiveFromData:(NSData *)data {
    NSAttributedString *one = nil;
    @try {
        one = [YYTextUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return one;
}

- (NSDictionary *)yy_attributesAtIndex:(NSUInteger)index {
    if (self.length > 0 && index == self.length) index--;
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)yy_attribute:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}

- (NSDictionary *)yy_attributes {
    return [self yy_attributesAtIndex:0];
}

- (UIFont *)yy_font {
    return [self yy_fontAtIndex:0];
}

- (UIFont *)yy_fontAtIndex:(NSUInteger)index {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    UIFont *font = [self yy_attribute:NSFontAttributeName atIndex:index];
    if (kSystemVersion <= 6) {
        if (font) {
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) {
                CTFontRef CTFont = (__bridge CTFontRef)(font);
                CFStringRef name = CTFontCopyPostScriptName(CTFont);
                CGFloat size = CTFontGetSize(CTFont);
                if (!name) {
                    font = nil;
                } else {
                    font = [UIFont fontWithName:(__bridge NSString *)(name) size:size];
                    CFRelease(name);
                }
            }
        }
    }
    return font;
}

- (NSNumber *)yy_kern {
    return [self yy_kernAtIndex:0];
}

- (NSNumber *)yy_kernAtIndex:(NSUInteger)index {
    return [self yy_attribute:NSKernAttributeName atIndex:index];
}

- (UIColor *)yy_color {
    return [self yy_colorAtIndex:0];
}

- (UIColor *)yy_colorAtIndex:(NSUInteger)index {
    UIColor *color = [self yy_attribute:NSForegroundColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self yy_attribute:(NSString *)kCTForegroundColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    if (color && ![color isKindOfClass:[UIColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        } else {
            color = nil;
        }
    }
    return color;
}

- (UIColor *)yy_backgroundColor {
    return [self yy_backgroundColorAtIndex:0];
}

- (UIColor *)yy_backgroundColorAtIndex:(NSUInteger)index {
    return [self yy_attribute:NSBackgroundColorAttributeName atIndex:index];
}

- (NSNumber *)yy_strokeWidth {
    return [self yy_strokeWidthAtIndex:0];
}

- (NSNumber *)yy_strokeWidthAtIndex:(NSUInteger)index {
    return [self yy_attribute:NSStrokeWidthAttributeName atIndex:index];
}

- (UIColor *)yy_strokeColor {
    return [self yy_strokeColorAtIndex:0];
}

- (UIColor *)yy_strokeColorAtIndex:(NSUInteger)index {
    UIColor *color = [self yy_attribute:NSStrokeColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self yy_attribute:(NSString *)kCTStrokeColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSShadow *)yy_shadow {
    return [self yy_shadowAtIndex:0];
}

- (NSShadow *)yy_shadowAtIndex:(NSUInteger)index {
    return [self yy_attribute:NSShadowAttributeName atIndex:index];
}

- (NSUnderlineStyle)yy_strikethroughStyle {
    return [self yy_strikethroughStyleAtIndex:0];
}

- (NSUnderlineStyle)yy_strikethroughStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self yy_attribute:NSStrikethroughStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)yy_strikethroughColor {
    return [self yy_strikethroughColorAtIndex:0];
}

- (UIColor *)yy_strikethroughColorAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:NSStrikethroughColorAttributeName atIndex:index];
    }
    return nil;
}

- (NSUnderlineStyle)yy_underlineStyle {
    return [self yy_underlineStyleAtIndex:0];
}

- (NSUnderlineStyle)yy_underlineStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self yy_attribute:NSUnderlineStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)yy_underlineColor {
    return [self yy_underlineColorAtIndex:0];
}

- (UIColor *)yy_underlineColorAtIndex:(NSUInteger)index {
    UIColor *color = nil;
    if (kSystemVersion >= 7) {
        color = [self yy_attribute:NSUnderlineColorAttributeName atIndex:index];
    }
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self yy_attribute:(NSString *)kCTUnderlineColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSNumber *)yy_ligature {
    return [self yy_ligatureAtIndex:0];
}

- (NSNumber *)yy_ligatureAtIndex:(NSUInteger)index {
    return [self yy_attribute:NSLigatureAttributeName atIndex:index];
}

- (NSString *)yy_textEffect {
    return [self yy_textEffectAtIndex:0];
}

- (NSString *)yy_textEffectAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:NSTextEffectAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)yy_obliqueness {
    return [self yy_obliquenessAtIndex:0];
}

- (NSNumber *)yy_obliquenessAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:NSObliquenessAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)yy_expansion {
    return [self yy_expansionAtIndex:0];
}

- (NSNumber *)yy_expansionAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:NSExpansionAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)yy_baselineOffset {
    return [self yy_baselineOffsetAtIndex:0];
}

- (NSNumber *)yy_baselineOffsetAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:NSBaselineOffsetAttributeName atIndex:index];
    }
    return nil;
}

- (BOOL)yy_verticalGlyphForm {
    return [self yy_verticalGlyphFormAtIndex:0];
}

- (BOOL)yy_verticalGlyphFormAtIndex:(NSUInteger)index {
    NSNumber *num = [self yy_attribute:NSVerticalGlyphFormAttributeName atIndex:index];
    return num.boolValue;
}

- (NSString *)yy_language {
    return [self yy_languageAtIndex:0];
}

- (NSString *)yy_languageAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self yy_attribute:(id)kCTLanguageAttributeName atIndex:index];
    }
    return nil;
}

- (NSArray *)yy_writingDirection {
    return [self yy_writingDirectionAtIndex:0];
}

- (NSArray *)yy_writingDirectionAtIndex:(NSUInteger)index {
    return [self yy_attribute:(id)kCTWritingDirectionAttributeName atIndex:index];
}

- (NSParagraphStyle *)yy_paragraphStyle {
    return [self yy_paragraphStyleAtIndex:0];
}

- (NSParagraphStyle *)yy_paragraphStyleAtIndex:(NSUInteger)index {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    NSParagraphStyle *style = [self yy_attribute:NSParagraphStyleAttributeName atIndex:index];
    if (style) {
        if (CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) { \
            style = [NSParagraphStyle yy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(style)];
        }
    }
    return style;
}

#define ParagraphAttribute(_attr_) \
NSParagraphStyle *style = self.yy_paragraphStyle; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

#define ParagraphAttributeAtIndex(_attr_) \
NSParagraphStyle *style = [self yy_paragraphStyleAtIndex:index]; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

- (NSTextAlignment)yy_alignment {
    ParagraphAttribute(alignment);
}

- (NSLineBreakMode)yy_lineBreakMode {
    ParagraphAttribute(lineBreakMode);
}

- (CGFloat)yy_lineSpacing {
    ParagraphAttribute(lineSpacing);
}

- (CGFloat)yy_paragraphSpacing {
    ParagraphAttribute(paragraphSpacing);
}

- (CGFloat)yy_paragraphSpacingBefore {
    ParagraphAttribute(paragraphSpacingBefore);
}

- (CGFloat)yy_firstLineHeadIndent {
    ParagraphAttribute(firstLineHeadIndent);
}

- (CGFloat)yy_headIndent {
    ParagraphAttribute(headIndent);
}

- (CGFloat)yy_tailIndent {
    ParagraphAttribute(tailIndent);
}

- (CGFloat)yy_minimumLineHeight {
    ParagraphAttribute(minimumLineHeight);
}

- (CGFloat)yy_maximumLineHeight {
    ParagraphAttribute(maximumLineHeight);
}

- (CGFloat)yy_lineHeightMultiple {
    ParagraphAttribute(lineHeightMultiple);
}

- (NSWritingDirection)yy_baseWritingDirection {
    ParagraphAttribute(baseWritingDirection);
}

- (float)yy_hyphenationFactor {
    ParagraphAttribute(hyphenationFactor);
}

- (CGFloat)yy_defaultTabInterval {
    if (!kiOS7Later) return 0;
    ParagraphAttribute(defaultTabInterval);
}

- (NSArray *)yy_tabStops {
    if (!kiOS7Later) return nil;
    ParagraphAttribute(tabStops);
}

- (NSTextAlignment)yy_alignmentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(alignment);
}

- (NSLineBreakMode)yy_lineBreakModeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineBreakMode);
}

- (CGFloat)yy_lineSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineSpacing);
}

- (CGFloat)yy_paragraphSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacing);
}

- (CGFloat)yy_paragraphSpacingBeforeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacingBefore);
}

- (CGFloat)yy_firstLineHeadIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(firstLineHeadIndent);
}

- (CGFloat)yy_headIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(headIndent);
}

- (CGFloat)yy_tailIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(tailIndent);
}

- (CGFloat)yy_minimumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(minimumLineHeight);
}

- (CGFloat)yy_maximumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(maximumLineHeight);
}

- (CGFloat)yy_lineHeightMultipleAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineHeightMultiple);
}

- (NSWritingDirection)yy_baseWritingDirectionAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(baseWritingDirection);
}

- (float)yy_hyphenationFactorAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(hyphenationFactor);
}

- (CGFloat)yy_defaultTabIntervalAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return 0;
    ParagraphAttributeAtIndex(defaultTabInterval);
}

- (NSArray *)yy_tabStopsAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return nil;
    ParagraphAttributeAtIndex(tabStops);
}

#undef ParagraphAttribute
#undef ParagraphAttributeAtIndex

- (YYTextShadow *)yy_textShadow {
    return [self yy_textShadowAtIndex:0];
}

- (YYTextShadow *)yy_textShadowAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextShadowAttributeName atIndex:index];
}

- (YYTextShadow *)yy_textInnerShadow {
    return [self yy_textInnerShadowAtIndex:0];
}

- (YYTextShadow *)yy_textInnerShadowAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextInnerShadowAttributeName atIndex:index];
}

- (YYTextDecoration *)yy_textUnderline {
    return [self yy_textUnderlineAtIndex:0];
}

- (YYTextDecoration *)yy_textUnderlineAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextUnderlineAttributeName atIndex:index];
}

- (YYTextDecoration *)yy_textStrikethrough {
    return [self yy_textStrikethroughAtIndex:0];
}

- (YYTextDecoration *)yy_textStrikethroughAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextStrikethroughAttributeName atIndex:index];
}

- (YYTextBorder *)yy_textBorder {
    return [self yy_textBorderAtIndex:0];
}

- (YYTextBorder *)yy_textBorderAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextBorderAttributeName atIndex:index];
}

- (YYTextBorder *)yy_textBackgroundBorder {
    return [self yy_textBackgroundBorderAtIndex:0];
}

- (YYTextBorder *)yy_textBackgroundBorderAtIndex:(NSUInteger)index {
    return [self yy_attribute:YYTextBackedStringAttributeName atIndex:index];
}

- (CGAffineTransform)yy_textGlyphTransform {
    return [self yy_textGlyphTransformAtIndex:0];
}

- (CGAffineTransform)yy_textGlyphTransformAtIndex:(NSUInteger)index {
    NSValue *value = [self yy_attribute:YYTextGlyphTransformAttributeName atIndex:index];
    if (!value) return CGAffineTransformIdentity;
    return [value CGAffineTransformValue];
}

- (NSString *)yy_plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound ||range.length == NSNotFound) return nil;
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) return result;
    NSString *string = self.string;
    [self enumerateAttribute:YYTextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        YYTextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

+ (NSMutableAttributedString *)yy_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                                        width:(CGFloat)width
                                                       ascent:(CGFloat)ascent
                                                      descent:(CGFloat)descent {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    
    YYTextAttachment *attach = [YYTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr yy_setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr yy_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)yy_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                               attachmentSize:(CGSize)attachmentSize
                                                  alignToFont:(UIFont *)font
                                                    alignment:(YYTextVerticalAlignment)alignment {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    
    YYTextAttachment *attach = [YYTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr yy_setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.width = attachmentSize.width;
    switch (alignment) {
        case YYTextVerticalAlignmentTop: {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case YYTextVerticalAlignmentCenter: {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case YYTextVerticalAlignmentBottom: {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        } break;
        default: {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        } break;
    }
    
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr yy_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)yy_attachmentStringWithEmojiImage:(UIImage *)image
                                                        fontSize:(CGFloat)fontSize {
    if (!image || fontSize <= 0) return nil;
    
    BOOL hasAnim = NO;
    if (image.images.count > 1) {
        hasAnim = YES;
    } else if (NSProtocolFromString(@"YYAnimatedImage") &&
               [image conformsToProtocol:NSProtocolFromString(@"YYAnimatedImage")]) {
        NSNumber *frameCount = [image valueForKey:@"animatedImageFrameCount"];
        if (frameCount.intValue > 1) hasAnim = YES;
    }
    
    CGFloat ascent = YYTextEmojiGetAscentWithFontSize(fontSize);
    CGFloat descent = YYTextEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = YYTextEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width + 2 * bounding.origin.x;
    
    YYTextAttachment *attachment = [YYTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, descent + bounding.origin.y, bounding.origin.x);
    if (hasAnim) {
        Class imageClass = NSClassFromString(@"YYAnimatedImageView");
        if (!imageClass) imageClass = [UIImageView class];
        UIImageView *view = (id)[imageClass new];
        view.frame = bounding;
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        attachment.content = view;
    } else {
        attachment.content = image;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    [atr yy_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr yy_setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}

- (NSRange)yy_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (BOOL)yy_isSharedAttributesInAllRange {
    __block BOOL shared = YES;
    __block NSDictionary *firstAttrs = nil;
    [self enumerateAttributesInRange:self.yy_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (range.location == 0) {
            firstAttrs = attrs;
        } else {
            if (firstAttrs.count != attrs.count) {
                shared = NO;
                *stop = YES;
            } else if (firstAttrs) {
                if (![firstAttrs isEqualToDictionary:attrs]) {
                    shared = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return shared;
}

- (BOOL)yy_canDrawWithUIKit {
    static NSMutableSet *failSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        failSet = [NSMutableSet new];
        [failSet addObject:(id)kCTGlyphInfoAttributeName];
        [failSet addObject:(id)kCTCharacterShapeAttributeName];
        if (kiOS7Later) {
            [failSet addObject:(id)kCTLanguageAttributeName];
        }
        [failSet addObject:(id)kCTRunDelegateAttributeName];
        [failSet addObject:(id)kCTBaselineClassAttributeName];
        [failSet addObject:(id)kCTBaselineInfoAttributeName];
        [failSet addObject:(id)kCTBaselineReferenceInfoAttributeName];
        if (kiOS8Later) {
            [failSet addObject:(id)kCTRubyAnnotationAttributeName];
        }
        [failSet addObject:YYTextShadowAttributeName];
        [failSet addObject:YYTextInnerShadowAttributeName];
        [failSet addObject:YYTextUnderlineAttributeName];
        [failSet addObject:YYTextStrikethroughAttributeName];
        [failSet addObject:YYTextBorderAttributeName];
        [failSet addObject:YYTextBackgroundBorderAttributeName];
        [failSet addObject:YYTextBlockBorderAttributeName];
        [failSet addObject:YYTextAttachmentAttributeName];
        [failSet addObject:YYTextHighlightAttributeName];
        [failSet addObject:YYTextGlyphTransformAttributeName];
    });
    
#define Fail { result = NO; *stop = YES; return; }
    __block BOOL result = YES;
    [self enumerateAttributesInRange:self.yy_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs.count == 0) return;
        for (NSString *str in attrs.allKeys) {
            if ([failSet containsObject:str]) Fail;
        }
        if (!kiOS7Later) {
            UIFont *font = attrs[NSFontAttributeName];
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) Fail;
        }
        if (attrs[(id)kCTForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) Fail;
        if (attrs[(id)kCTStrokeColorAttributeName] && !attrs[NSStrokeColorAttributeName]) Fail;
        if (attrs[(id)kCTUnderlineColorAttributeName]) {
            if (!kiOS7Later) Fail;
            if (!attrs[NSUnderlineColorAttributeName]) Fail;
        }
        NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
        if (style && CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) Fail;
    }];
    return result;
#undef Fail
}

@end

@implementation NSMutableAttributedString (YYText)

- (void)yy_setAttributes:(NSDictionary *)attributes {
    [self setYy_attributes:attributes];
}

- (void)setYy_attributes:(NSDictionary *)attributes {
    if (attributes == (id)[NSNull null]) attributes = nil;
    [self setAttributes:@{} range:NSMakeRange(0, self.length)];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self yy_setAttribute:key value:obj];
    }];
}

- (void)yy_setAttribute:(NSString *)name value:(id)value {
    [self yy_setAttribute:name value:value range:NSMakeRange(0, self.length)];
}

- (void)yy_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

- (void)yy_removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

#pragma mark - Property Setter

- (void)setYy_font:(UIFont *)font {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self yy_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setYy_kern:(NSNumber *)kern {
    [self yy_setKern:kern range:NSMakeRange(0, self.length)];
}

- (void)setYy_color:(UIColor *)color {
    [self yy_setColor:color range:NSMakeRange(0, self.length)];
}

- (void)setYy_backgroundColor:(UIColor *)backgroundColor {
    [self yy_setBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}

- (void)setYy_strokeWidth:(NSNumber *)strokeWidth {
    [self yy_setStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}

- (void)setYy_strokeColor:(UIColor *)strokeColor {
    [self yy_setStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}

- (void)setYy_shadow:(NSShadow *)shadow {
    [self yy_setShadow:shadow range:NSMakeRange(0, self.length)];
}

- (void)setYy_strikethroughStyle:(NSUnderlineStyle)strikethroughStyle {
    [self yy_setStrikethroughStyle:strikethroughStyle range:NSMakeRange(0, self.length)];
}

- (void)setYy_strikethroughColor:(UIColor *)strikethroughColor {
    [self yy_setStrokeColor:strikethroughColor range:NSMakeRange(0, self.length)];
}

- (void)setYy_underlineStyle:(NSUnderlineStyle)underlineStyle {
    [self yy_setUnderlineStyle:underlineStyle range:NSMakeRange(0, self.length)];
}

- (void)setYy_underlineColor:(UIColor *)underlineColor {
    [self yy_setUnderlineColor:underlineColor range:NSMakeRange(0, self.length)];
}

- (void)setYy_ligature:(NSNumber *)ligature {
    [self yy_setLigature:ligature range:NSMakeRange(0, self.length)];
}

- (void)setYy_textEffect:(NSString *)textEffect {
    [self yy_setTextEffect:textEffect range:NSMakeRange(0, self.length)];
}

- (void)setYy_obliqueness:(NSNumber *)obliqueness {
    [self yy_setObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}

- (void)setYy_expansion:(NSNumber *)expansion {
    [self yy_setExpansion:expansion range:NSMakeRange(0, self.length)];
}

- (void)setYy_baselineOffset:(NSNumber *)baselineOffset {
    [self yy_setBaselineOffset:baselineOffset range:NSMakeRange(0, self.length)];
}

- (void)setYy_verticalGlyphForm:(BOOL)verticalGlyphForm {
    [self yy_setVerticalGlyphForm:verticalGlyphForm range:NSMakeRange(0, self.length)];
}

- (void)setYy_language:(NSString *)language {
    [self yy_setLanguage:language range:NSMakeRange(0, self.length)];
}

- (void)setYy_writingDirection:(NSArray *)writingDirection {
    [self yy_setWritingDirection:writingDirection range:NSMakeRange(0, self.length)];
}

- (void)setYy_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self yy_setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setYy_alignment:(NSTextAlignment)alignment {
    [self yy_setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)setYy_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self yy_setBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}

- (void)setYy_lineSpacing:(CGFloat)lineSpacing {
    [self yy_setLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}

- (void)setYy_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self yy_setParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}

- (void)setYy_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self yy_setParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}

- (void)setYy_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self yy_setFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}

- (void)setYy_headIndent:(CGFloat)headIndent {
    [self yy_setHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}

- (void)setYy_tailIndent:(CGFloat)tailIndent {
    [self yy_setTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}

- (void)setYy_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self yy_setLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}

- (void)setYy_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self yy_setMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setYy_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self yy_setMaximumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setYy_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self yy_setLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}

- (void)setYy_hyphenationFactor:(float)hyphenationFactor {
    [self yy_setHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}

- (void)setYy_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self yy_setDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}

- (void)setYy_tabStops:(NSArray *)tabStops {
    [self yy_setTabStops:tabStops range:NSMakeRange(0, self.length)];
}

- (void)setYy_textShadow:(YYTextShadow *)textShadow {
    [self yy_setTextShadow:textShadow range:NSMakeRange(0, self.length)];
}

- (void)setYy_textInnerShadow:(YYTextShadow *)textInnerShadow {
    [self yy_setTextInnerShadow:textInnerShadow range:NSMakeRange(0, self.length)];
}

- (void)setYy_textUnderline:(YYTextDecoration *)textUnderline {
    [self yy_setTextUnderline:textUnderline range:NSMakeRange(0, self.length)];
}

- (void)setYy_textStrikethrough:(YYTextDecoration *)textStrikethrough {
    [self yy_setTextStrikethrough:textStrikethrough range:NSMakeRange(0, self.length)];
}

- (void)setYy_textBorder:(YYTextBorder *)textBorder {
    [self yy_setTextBorder:textBorder range:NSMakeRange(0, self.length)];
}

- (void)setYy_textBackgroundBorder:(YYTextBorder *)textBackgroundBorder {
    [self yy_setTextBackgroundBorder:textBackgroundBorder range:NSMakeRange(0, self.length)];
}

- (void)setYy_textGlyphTransform:(CGAffineTransform)textGlyphTransform {
    [self yy_setTextGlyphTransform:textGlyphTransform range:NSMakeRange(0, self.length)];
}

#pragma mark - Range Setter

- (void)yy_setFont:(UIFont *)font range:(NSRange)range {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self yy_setAttribute:NSFontAttributeName value:font range:range];
}

- (void)yy_setKern:(NSNumber *)kern range:(NSRange)range {
    [self yy_setAttribute:NSKernAttributeName value:kern range:range];
}

- (void)yy_setColor:(UIColor *)color range:(NSRange)range {
    [self yy_setAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    [self yy_setAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)yy_setBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self yy_setAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)yy_setStrokeWidth:(NSNumber *)strokeWidth range:(NSRange)range {
    [self yy_setAttribute:NSStrokeWidthAttributeName value:strokeWidth range:range];
}

- (void)yy_setStrokeColor:(UIColor *)strokeColor range:(NSRange)range {
    [self yy_setAttribute:(id)kCTStrokeColorAttributeName value:(id)strokeColor.CGColor range:range];
    [self yy_setAttribute:NSStrokeColorAttributeName value:strokeColor range:range];
}

- (void)yy_setShadow:(NSShadow *)shadow range:(NSRange)range {
    [self yy_setAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)yy_setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range {
    NSNumber *style = strikethroughStyle == 0 ? nil : @(strikethroughStyle);
    [self yy_setAttribute:NSStrikethroughStyleAttributeName value:style range:range];
}

- (void)yy_setStrikethroughColor:(UIColor *)strikethroughColor range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }
}

- (void)yy_setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range {
    NSNumber *style = underlineStyle == 0 ? nil : @(underlineStyle);
    [self yy_setAttribute:NSUnderlineStyleAttributeName value:style range:range];
}

- (void)yy_setUnderlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self yy_setAttribute:(id)kCTUnderlineColorAttributeName value:(id)underlineColor.CGColor range:range];
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }
}

- (void)yy_setLigature:(NSNumber *)ligature range:(NSRange)range {
    [self yy_setAttribute:NSLigatureAttributeName value:ligature range:range];
}

- (void)yy_setTextEffect:(NSString *)textEffect range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSTextEffectAttributeName value:textEffect range:range];
    }
}

- (void)yy_setObliqueness:(NSNumber *)obliqueness range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSObliquenessAttributeName value:obliqueness range:range];
    }
}

- (void)yy_setExpansion:(NSNumber *)expansion range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSExpansionAttributeName value:expansion range:range];
    }
}

- (void)yy_setBaselineOffset:(NSNumber *)baselineOffset range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSBaselineOffsetAttributeName value:baselineOffset range:range];
    }
}

- (void)yy_setVerticalGlyphForm:(BOOL)verticalGlyphForm range:(NSRange)range {
    NSNumber *v = verticalGlyphForm ? @(YES) : nil;
    [self yy_setAttribute:NSVerticalGlyphFormAttributeName value:v range:range];
}

- (void)yy_setLanguage:(NSString *)language range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:(id)kCTLanguageAttributeName value:language range:range];
    }
}

- (void)yy_setWritingDirection:(NSArray *)writingDirection range:(NSRange)range {
    [self yy_setAttribute:(id)kCTWritingDirectionAttributeName value:writingDirection range:range];
}

- (void)yy_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self yy_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
                 inRange:range \
                 options:kNilOptions \
              usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
                  NSMutableParagraphStyle *style = nil; \
                  if (value) { \
                      if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
                          value = [NSParagraphStyle yy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                      } \
                      if (value. _attr_ == _attr_) return; \
                      if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
                          style = (id)value; \
                      } else { \
                          style = value.mutableCopy; \
                      } \
                  } else { \
                      if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
                      style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
                  } \
                  style. _attr_ = _attr_; \
                  [self yy_setParagraphStyle:style range:subRange]; \
              }];

- (void)yy_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ParagraphStyleSet(alignment);
}

- (void)yy_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ParagraphStyleSet(baseWritingDirection);
}

- (void)yy_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ParagraphStyleSet(lineSpacing);
}

- (void)yy_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacing);
}

- (void)yy_setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)yy_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)yy_setHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ParagraphStyleSet(headIndent);
}

- (void)yy_setTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ParagraphStyleSet(tailIndent);
}

- (void)yy_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ParagraphStyleSet(lineBreakMode);
}

- (void)yy_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ParagraphStyleSet(minimumLineHeight);
}

- (void)yy_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ParagraphStyleSet(maximumLineHeight);
}

- (void)yy_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)yy_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ParagraphStyleSet(hyphenationFactor);
}

- (void)yy_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(defaultTabInterval);
}

- (void)yy_setTabStops:(NSArray *)tabStops range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(tabStops);
}

#undef ParagraphStyleSet

- (void)yy_setSuperscript:(NSNumber *)superscript range:(NSRange)range {
    if ([superscript isEqualToNumber:@(0)]) {
        superscript = nil;
    }
    [self yy_setAttribute:(id)kCTSuperscriptAttributeName value:superscript range:range];
}

- (void)yy_setGlyphInfo:(CTGlyphInfoRef)glyphInfo range:(NSRange)range {
    [self yy_setAttribute:(id)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:range];
}

- (void)yy_setCharacterShape:(NSNumber *)characterShape range:(NSRange)range {
    [self yy_setAttribute:(id)kCTCharacterShapeAttributeName value:characterShape range:range];
}

- (void)yy_setRunDelegate:(CTRunDelegateRef)runDelegate range:(NSRange)range {
    [self yy_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
}

- (void)yy_setBaselineClass:(CFStringRef)baselineClass range:(NSRange)range {
    [self yy_setAttribute:(id)kCTBaselineClassAttributeName value:(__bridge id)baselineClass range:range];
}

- (void)yy_setBaselineInfo:(CFDictionaryRef)baselineInfo range:(NSRange)range {
    [self yy_setAttribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineInfo range:range];
}

- (void)yy_setBaselineReferenceInfo:(CFDictionaryRef)referenceInfo range:(NSRange)range {
    [self yy_setAttribute:(id)kCTBaselineReferenceInfoAttributeName value:(__bridge id)referenceInfo range:range];
}

- (void)yy_setRubyAnnotation:(CTRubyAnnotationRef)ruby range:(NSRange)range {
    if (kSystemVersion >= 8) {
        [self yy_setAttribute:(id)kCTRubyAnnotationAttributeName value:(__bridge id)ruby range:range];
    }
}

- (void)yy_setAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSAttachmentAttributeName value:attachment range:range];
    }
}

- (void)yy_setLink:(id)link range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self yy_setAttribute:NSLinkAttributeName value:link range:range];
    }
}

- (void)yy_setTextBackedString:(YYTextBackedString *)textBackedString range:(NSRange)range {
    [self yy_setAttribute:YYTextBackedStringAttributeName value:textBackedString range:range];
}

- (void)yy_setTextBinding:(YYTextBinding *)textBinding range:(NSRange)range {
    [self yy_setAttribute:YYTextBindingAttributeName value:textBinding range:range];
}

- (void)yy_setTextShadow:(YYTextShadow *)textShadow range:(NSRange)range {
    [self yy_setAttribute:YYTextShadowAttributeName value:textShadow range:range];
}

- (void)yy_setTextInnerShadow:(YYTextShadow *)textInnerShadow range:(NSRange)range {
    [self yy_setAttribute:YYTextInnerShadowAttributeName value:textInnerShadow range:range];
}

- (void)yy_setTextUnderline:(YYTextDecoration *)textUnderline range:(NSRange)range {
    [self yy_setAttribute:YYTextUnderlineAttributeName value:textUnderline range:range];
}

- (void)yy_setTextStrikethrough:(YYTextDecoration *)textStrikethrough range:(NSRange)range {
    [self yy_setAttribute:YYTextStrikethroughAttributeName value:textStrikethrough range:range];
}

- (void)yy_setTextBorder:(YYTextBorder *)textBorder range:(NSRange)range {
    [self yy_setAttribute:YYTextBorderAttributeName value:textBorder range:range];
}

- (void)yy_setTextBackgroundBorder:(YYTextBorder *)textBackgroundBorder range:(NSRange)range {
    [self yy_setAttribute:YYTextBackgroundBorderAttributeName value:textBackgroundBorder range:range];
}

- (void)yy_setTextAttachment:(YYTextAttachment *)textAttachment range:(NSRange)range {
    [self yy_setAttribute:YYTextAttachmentAttributeName value:textAttachment range:range];
}

- (void)yy_setTextHighlight:(YYTextHighlight *)textHighlight range:(NSRange)range {
    [self yy_setAttribute:YYTextHighlightAttributeName value:textHighlight range:range];
}

- (void)yy_setTextBlockBorder:(YYTextBorder *)textBlockBorder range:(NSRange)range {
    [self yy_setAttribute:YYTextBlockBorderAttributeName value:textBlockBorder range:range];
}

- (void)yy_setTextRubyAnnotation:(YYTextRubyAnnotation *)ruby range:(NSRange)range {
    if (kiOS8Later) {
        CTRubyAnnotationRef rubyRef = [ruby CTRubyAnnotation];
        [self yy_setRubyAnnotation:rubyRef range:range];
        if (rubyRef) CFRelease(rubyRef);
    }
}

- (void)yy_setTextGlyphTransform:(CGAffineTransform)textGlyphTransform range:(NSRange)range {
    NSValue *value = CGAffineTransformIsIdentity(textGlyphTransform) ? nil : [NSValue valueWithCGAffineTransform:textGlyphTransform];
    [self yy_setAttribute:YYTextGlyphTransformAttributeName value:value range:range];
}

- (void)yy_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                        userInfo:(NSDictionary *)userInfo
                       tapAction:(YYTextAction)tapAction
                 longPressAction:(YYTextAction)longPressAction {
    YYTextHighlight *highlight = [YYTextHighlight highlightWithBackgroundColor:backgroundColor];
    highlight.userInfo = userInfo;
    highlight.tapAction = tapAction;
    highlight.longPressAction = longPressAction;
    if (color) [self yy_setColor:color range:range];
    [self yy_setTextHighlight:highlight range:range];
}

- (void)yy_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                       tapAction:(YYTextAction)tapAction {
    [self yy_setTextHighlightRange:range
                         color:color
               backgroundColor:backgroundColor
                      userInfo:nil
                     tapAction:tapAction
               longPressAction:nil];
}

- (void)yy_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                        userInfo:(NSDictionary *)userInfo {
    [self yy_setTextHighlightRange:range
                         color:color
               backgroundColor:backgroundColor
                      userInfo:userInfo
                     tapAction:nil
               longPressAction:nil];
}

- (void)yy_insertString:(NSString *)string atIndex:(NSUInteger)location {
    [self replaceCharactersInRange:NSMakeRange(location, 0) withString:string];
    [self yy_removeDiscontinuousAttributesInRange:NSMakeRange(location, string.length)];
}

- (void)yy_appendString:(NSString *)string {
    NSUInteger length = self.length;
    [self replaceCharactersInRange:NSMakeRange(length, 0) withString:string];
    [self yy_removeDiscontinuousAttributesInRange:NSMakeRange(length, string.length)];
}

- (void)yy_setClearColorToJoinedEmoji {
    NSString *str = self.string;
    if (str.length < 8) return;
    
    // Most string do not contains the joined-emoji, test the joiner first.
    BOOL containsJoiner = NO;
    {
        CFStringRef cfStr = (__bridge CFStringRef)str;
        BOOL needFree = NO;
        UniChar *chars = NULL;
        chars = (void *)CFStringGetCharactersPtr(cfStr);
        if (!chars) {
            chars = malloc(str.length * sizeof(UniChar));
            if (chars) {
                needFree = YES;
                CFStringGetCharacters(cfStr, CFRangeMake(0, str.length), chars);
            }
        }
        if (!chars) { // fail to get unichar..
            containsJoiner = YES;
        } else {
            for (int i = 0, max = (int)str.length; i < max; i++) {
                if (chars[i] == 0x200D) { // 'ZERO WIDTH JOINER' (U+200D)
                    containsJoiner = YES;
                    break;
                }
            }
            if (needFree) free(chars);
        }
    }
    if (!containsJoiner) return;
    
    // NSRegularExpression is designed to be immutable and thread safe.
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))" options:kNilOptions error:nil];
    });
    
    UIColor *clear = [UIColor clearColor];
    [regex enumerateMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self yy_setColor:clear range:result.range];
    }];
}

- (void)yy_removeDiscontinuousAttributesInRange:(NSRange)range {
    NSArray *keys = [NSMutableAttributedString yy_allDiscontinuousAttributeKeys];
    for (NSString *key in keys) {
        [self removeAttribute:key range:range];
    }
}

+ (NSArray *)yy_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName,
                 YYTextBackedStringAttributeName,
                 YYTextBindingAttributeName,
                 YYTextAttachmentAttributeName].mutableCopy;
        if (kiOS8Later) {
            [keys addObject:(id)kCTRubyAnnotationAttributeName];
        }
        if (kiOS7Later) {
            [keys addObject:NSAttachmentAttributeName];
        }
    });
    return keys;
}

@end
