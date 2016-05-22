//
//  YYTextAttribute.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 14/10/26.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextAttribute.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "NSAttributedString+YYText.h"
#import "YYTextArchiver.h"


static double _YYDeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}


NSString *const YYTextBackedStringAttributeName = @"YYTextBackedString";
NSString *const YYTextBindingAttributeName = @"YYTextBinding";
NSString *const YYTextShadowAttributeName = @"YYTextShadow";
NSString *const YYTextInnerShadowAttributeName = @"YYTextInnerShadow";
NSString *const YYTextUnderlineAttributeName = @"YYTextUnderline";
NSString *const YYTextStrikethroughAttributeName = @"YYTextStrikethrough";
NSString *const YYTextBorderAttributeName = @"YYTextBorder";
NSString *const YYTextBackgroundBorderAttributeName = @"YYTextBackgroundBorder";
NSString *const YYTextBlockBorderAttributeName = @"YYTextBlockBorder";
NSString *const YYTextAttachmentAttributeName = @"YYTextAttachment";
NSString *const YYTextHighlightAttributeName = @"YYTextHighlight";
NSString *const YYTextGlyphTransformAttributeName = @"YYTextGlyphTransform";

NSString *const YYTextAttachmentToken = @"\uFFFC";
NSString *const YYTextTruncationToken = @"\u2026";


YYTextAttributeType YYTextAttributeGetType(NSString *name){
    if (name.length == 0) return YYTextAttributeTypeNone;
    
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = [NSMutableDictionary new];
        NSNumber *All = @(YYTextAttributeTypeUIKit | YYTextAttributeTypeCoreText | YYTextAttributeTypeYYText);
        NSNumber *CoreText_YYText = @(YYTextAttributeTypeCoreText | YYTextAttributeTypeYYText);
        NSNumber *UIKit_YYText = @(YYTextAttributeTypeUIKit | YYTextAttributeTypeYYText);
        NSNumber *UIKit_CoreText = @(YYTextAttributeTypeUIKit | YYTextAttributeTypeCoreText);
        NSNumber *UIKit = @(YYTextAttributeTypeUIKit);
        NSNumber *CoreText = @(YYTextAttributeTypeCoreText);
        NSNumber *YYText = @(YYTextAttributeTypeYYText);
        
        dic[NSFontAttributeName] = All;
        dic[NSKernAttributeName] = All;
        dic[NSForegroundColorAttributeName] = UIKit;
        dic[(id)kCTForegroundColorAttributeName] = CoreText;
        dic[(id)kCTForegroundColorFromContextAttributeName] = CoreText;
        dic[NSBackgroundColorAttributeName] = UIKit;
        dic[NSStrokeWidthAttributeName] = All;
        dic[NSStrokeColorAttributeName] = UIKit;
        dic[(id)kCTStrokeColorAttributeName] = CoreText_YYText;
        dic[NSShadowAttributeName] = UIKit_YYText;
        dic[NSStrikethroughStyleAttributeName] = UIKit;
        dic[NSUnderlineStyleAttributeName] = UIKit_CoreText;
        dic[(id)kCTUnderlineColorAttributeName] = CoreText;
        dic[NSLigatureAttributeName] = All;
        dic[(id)kCTSuperscriptAttributeName] = UIKit; //it's a CoreText attrubite, but only supported by UIKit...
        dic[NSVerticalGlyphFormAttributeName] = All;
        dic[(id)kCTGlyphInfoAttributeName] = CoreText_YYText;
        dic[(id)kCTCharacterShapeAttributeName] = CoreText_YYText;
        dic[(id)kCTRunDelegateAttributeName] = CoreText_YYText;
        dic[(id)kCTBaselineClassAttributeName] = CoreText_YYText;
        dic[(id)kCTBaselineInfoAttributeName] = CoreText_YYText;
        dic[(id)kCTBaselineReferenceInfoAttributeName] = CoreText_YYText;
        dic[(id)kCTWritingDirectionAttributeName] = CoreText_YYText;
        dic[NSParagraphStyleAttributeName] = All;
        
        if (_YYDeviceSystemVersion() >= 7) {
            dic[NSStrikethroughColorAttributeName] = UIKit;
            dic[NSUnderlineColorAttributeName] = UIKit;
            dic[NSTextEffectAttributeName] = UIKit;
            dic[NSObliquenessAttributeName] = UIKit;
            dic[NSExpansionAttributeName] = UIKit;
            dic[(id)kCTLanguageAttributeName] = CoreText_YYText;
            dic[NSBaselineOffsetAttributeName] = UIKit;
            dic[NSWritingDirectionAttributeName] = All;
            dic[NSAttachmentAttributeName] = UIKit;
            dic[NSLinkAttributeName] = UIKit;
        }
        if (_YYDeviceSystemVersion() >= 8) {
            dic[(id)kCTRubyAnnotationAttributeName] = CoreText;
        }
        
        dic[YYTextBackedStringAttributeName] = YYText;
        dic[YYTextBindingAttributeName] = YYText;
        dic[YYTextShadowAttributeName] = YYText;
        dic[YYTextInnerShadowAttributeName] = YYText;
        dic[YYTextUnderlineAttributeName] = YYText;
        dic[YYTextStrikethroughAttributeName] = YYText;
        dic[YYTextBorderAttributeName] = YYText;
        dic[YYTextBackgroundBorderAttributeName] = YYText;
        dic[YYTextBlockBorderAttributeName] = YYText;
        dic[YYTextAttachmentAttributeName] = YYText;
        dic[YYTextHighlightAttributeName] = YYText;
        dic[YYTextGlyphTransformAttributeName] = YYText;
    });
    NSNumber *num = dic[name];
    if (num) return num.integerValue;
    return YYTextAttributeTypeNone;
}


@implementation YYTextBackedString

+ (instancetype)stringWithString:(NSString *)string {
    YYTextBackedString *one = [self new];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _string = [aDecoder decodeObjectForKey:@"string"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.string = self.string;
    return one;
}

@end


@implementation YYTextBinding

+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm {
    YYTextBinding *one = [self new];
    one.deleteConfirm = deleteConfirm;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.deleteConfirm) forKey:@"deleteConfirm"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _deleteConfirm = ((NSNumber *)[aDecoder decodeObjectForKey:@"deleteConfirm"]).boolValue;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.deleteConfirm = self.deleteConfirm;
    return one;
}

@end


@implementation YYTextShadow

+ (instancetype)shadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius {
    YYTextShadow *one = [self new];
    one.color = color;
    one.offset = offset;
    one.radius = radius;
    return one;
}

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow {
    if (!nsShadow) return nil;
    YYTextShadow *shadow = [self new];
    shadow.offset = nsShadow.shadowOffset;
    shadow.radius = nsShadow.shadowBlurRadius;
    id color = nsShadow.shadowColor;
    if (color) {
        if (CGColorGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(color))) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        }
        if ([color isKindOfClass:[UIColor class]]) {
            shadow.color = color;
        }
    }
    return shadow;
}

- (NSShadow *)nsShadow {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = self.offset;
    shadow.shadowBlurRadius = self.radius;
    shadow.shadowColor = self.color;
    return shadow;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:@(self.radius) forKey:@"radius"];
    [aCoder encodeObject:[NSValue valueWithCGSize:self.offset] forKey:@"offset"];
    [aCoder encodeObject:self.subShadow forKey:@"subShadow"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _color = [aDecoder decodeObjectForKey:@"color"];
    _radius = ((NSNumber *)[aDecoder decodeObjectForKey:@"radius"]).floatValue;
    _offset = ((NSValue *)[aDecoder decodeObjectForKey:@"offset"]).CGSizeValue;
    _subShadow = [aDecoder decodeObjectForKey:@"subShadow"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.color = self.color;
    one.radius = self.radius;
    one.offset = self.offset;
    one.subShadow = self.subShadow.copy;
    return one;
}

@end


@implementation YYTextDecoration

- (instancetype)init {
    self = [super init];
    _style = YYTextLineStyleSingle;
    return self;
}

+ (instancetype)decorationWithStyle:(YYTextLineStyle)style {
    YYTextDecoration *one = [self new];
    one.style = style;
    return one;
}
+ (instancetype)decorationWithStyle:(YYTextLineStyle)style width:(NSNumber *)width color:(UIColor *)color {
    YYTextDecoration *one = [self new];
    one.style = style;
    one.width = width;
    one.color = color;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.style) forKey:@"style"];
    [aCoder encodeObject:self.width forKey:@"width"];
    [aCoder encodeObject:self.color forKey:@"color"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.style = ((NSNumber *)[aDecoder decodeObjectForKey:@"style"]).unsignedIntegerValue;
    self.width = [aDecoder decodeObjectForKey:@"width"];
    self.color = [aDecoder decodeObjectForKey:@"color"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.style = self.style;
    one.width = self.width;
    one.color = self.color;
    return one;
}

@end


@implementation YYTextBorder

+ (instancetype)borderWithLineStyle:(YYTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(UIColor *)color {
    YYTextBorder *one = [self new];
    one.lineStyle = lineStyle;
    one.strokeWidth = width;
    one.strokeColor = color;
    return one;
}

+ (instancetype)borderWithFillColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    YYTextBorder *one = [self new];
    one.fillColor = color;
    one.cornerRadius = cornerRadius;
    one.insets = UIEdgeInsetsMake(-2, 0, 0, -2);
    return one;
}

- (instancetype)init {
    self = [super init];
    self.lineStyle = YYTextLineStyleSingle;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.lineStyle) forKey:@"lineStyle"];
    [aCoder encodeObject:@(self.strokeWidth) forKey:@"strokeWidth"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeObject:@(self.lineJoin) forKey:@"lineJoin"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.insets] forKey:@"insets"];
    [aCoder encodeObject:@(self.cornerRadius) forKey:@"cornerRadius"];
    [aCoder encodeObject:self.shadow forKey:@"shadow"];
    [aCoder encodeObject:self.fillColor forKey:@"fillColor"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _lineStyle = ((NSNumber *)[aDecoder decodeObjectForKey:@"lineStyle"]).unsignedIntegerValue;
    _strokeWidth = ((NSNumber *)[aDecoder decodeObjectForKey:@"strokeWidth"]).doubleValue;
    _strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
    _lineJoin = (CGLineJoin)((NSNumber *)[aDecoder decodeObjectForKey:@"join"]).unsignedIntegerValue;
    _insets = ((NSValue *)[aDecoder decodeObjectForKey:@"insets"]).UIEdgeInsetsValue;
    _cornerRadius = ((NSNumber *)[aDecoder decodeObjectForKey:@"cornerRadius"]).doubleValue;
    _shadow = [aDecoder decodeObjectForKey:@"shadow"];
    _fillColor = [aDecoder decodeObjectForKey:@"fillColor"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.lineStyle = self.lineStyle;
    one.strokeWidth = self.strokeWidth;
    one.strokeColor = self.strokeColor;
    one.lineJoin = self.lineJoin;
    one.insets = self.insets;
    one.cornerRadius = self.cornerRadius;
    one.shadow = self.shadow.copy;
    one.fillColor = self.fillColor;
    return one;
}

@end


@implementation YYTextAttachment

+ (instancetype)attachmentWithContent:(id)content {
    YYTextAttachment *one = [self new];
    one.content = content;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.contentInsets] forKey:@"contentInsets"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _content = [aDecoder decodeObjectForKey:@"content"];
    _contentInsets = ((NSValue *)[aDecoder decodeObjectForKey:@"contentInsets"]).UIEdgeInsetsValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    if ([self.content respondsToSelector:@selector(copy)]) {
        one.content = [self.content copy];
    } else {
        one.content = self.content;
    }
    one.contentInsets = self.contentInsets;
    one.userInfo = self.userInfo.copy;
    return one;
}

@end


@implementation YYTextHighlight

+ (instancetype)highlightWithAttributes:(NSDictionary *)attributes {
    YYTextHighlight *one = [self new];
    one.attributes = attributes;
    return one;
}

+ (instancetype)highlightWithBackgroundColor:(UIColor *)color {
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = color;
    
    YYTextHighlight *one = [self new];
    [one setBackgroundBorder:highlightBorder];
    return one;
}

- (void)setAttributes:(NSDictionary *)attributes {
    _attributes = attributes.mutableCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSData *data = nil;
    @try {
        data = [YYTextArchiver archivedDataWithRootObject:self.attributes];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    [aCoder encodeObject:data forKey:@"attributes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    NSData *data = [aDecoder decodeObjectForKey:@"attributes"];
    @try {
        _attributes = [YYTextUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.attributes = self.attributes.mutableCopy;
    return one;
}

- (void)_makeMutableAttributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    } else if (![_attributes isKindOfClass:[NSMutableDictionary class]]) {
        _attributes = _attributes.mutableCopy;
    }
}

- (void)setFont:(UIFont *)font {
    [self _makeMutableAttributes];
    if (font == (id)[NSNull null] || font == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTFontAttributeName] = [NSNull null];
    } else {
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        if (ctFont) {
            ((NSMutableDictionary *)_attributes)[(id)kCTFontAttributeName] = (__bridge id)(ctFont);
            CFRelease(ctFont);
        }
    }
}

- (void)setColor:(UIColor *)color {
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTForegroundColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTForegroundColorAttributeName] = (__bridge id)(color.CGColor);
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
    }
}

- (void)setStrokeWidth:(NSNumber *)width {
    [self _makeMutableAttributes];
    if (width == (id)[NSNull null] || width == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = width;
    }
}

- (void)setStrokeColor:(UIColor *)color {
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeColorAttributeName] = (__bridge id)(color.CGColor);
        ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = color;
    }
}

- (void)setTextAttribute:(NSString *)attribute value:(id)value {
    [self _makeMutableAttributes];
    if (value == nil) value = [NSNull null];
    ((NSMutableDictionary *)_attributes)[attribute] = value;
}

- (void)setShadow:(YYTextShadow *)shadow {
    [self setTextAttribute:YYTextShadowAttributeName value:shadow];
}

- (void)setInnerShadow:(YYTextShadow *)shadow {
    [self setTextAttribute:YYTextInnerShadowAttributeName value:shadow];
}

- (void)setUnderline:(YYTextDecoration *)underline {
    [self setTextAttribute:YYTextUnderlineAttributeName value:underline];
}

- (void)setStrikethrough:(YYTextDecoration *)strikethrough {
    [self setTextAttribute:YYTextStrikethroughAttributeName value:strikethrough];
}

- (void)setBackgroundBorder:(YYTextBorder *)border {
    [self setTextAttribute:YYTextBackgroundBorderAttributeName value:border];
}

- (void)setBorder:(YYTextBorder *)border {
    [self setTextAttribute:YYTextBorderAttributeName value:border];
}

- (void)setAttachment:(YYTextAttachment *)attachment {
    [self setTextAttribute:YYTextAttachmentAttributeName value:attachment];
}

@end

