//
//  YYTextAttribute.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 14/10/26.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum Define

/// The attribute type
typedef NS_OPTIONS(NSInteger, YYTextAttributeType) {
    YYTextAttributeTypeNone     = 0,
    YYTextAttributeTypeUIKit    = 1 << 0, ///< UIKit attributes, such as UILabel/UITextField/drawInRect.
    YYTextAttributeTypeCoreText = 1 << 1, ///< CoreText attributes, used by CoreText.
    YYTextAttributeTypeYYText   = 1 << 2, ///< YYText attributes, used by YYText.
};

/// Get the attribute type from an attribute name.
extern YYTextAttributeType YYTextAttributeGetType(NSString *attributeName);

/**
 Line style in YYText (similar to NSUnderlineStyle).
 */
typedef NS_OPTIONS (NSInteger, YYTextLineStyle) {
    // basic style (bitmask:0xFF)
    YYTextLineStyleNone       = 0x00, ///< (        ) Do not draw a line (Default).
    YYTextLineStyleSingle     = 0x01, ///< (──────) Draw a single line.
    YYTextLineStyleThick      = 0x02, ///< (━━━━━━━) Draw a thick line.
    YYTextLineStyleDouble     = 0x09, ///< (══════) Draw a double line.
    
    // style pattern (bitmask:0xF00)
    YYTextLineStylePatternSolid      = 0x000, ///< (────────) Draw a solid line (Default).
    YYTextLineStylePatternDot        = 0x100, ///< (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    YYTextLineStylePatternDash       = 0x200, ///< (— — — —) Draw a line of dashes.
    YYTextLineStylePatternDashDot    = 0x300, ///< (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    YYTextLineStylePatternDashDotDot = 0x400, ///< (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    YYTextLineStylePatternCircleDot  = 0x900, ///< (••••••••••••) Draw a line of small circle dots.
};

/**
 Text vertical alignment.
 */
typedef NS_ENUM(NSInteger, YYTextVerticalAlignment) {
    YYTextVerticalAlignmentTop =    0, ///< Top alignment.
    YYTextVerticalAlignmentCenter = 1, ///< Center alignment.
    YYTextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

/**
 The direction define in YYText.
 */
typedef NS_OPTIONS(NSUInteger, YYTextDirection) {
    YYTextDirectionNone   = 0,
    YYTextDirectionTop    = 1 << 0,
    YYTextDirectionRight  = 1 << 1,
    YYTextDirectionBottom = 1 << 2,
    YYTextDirectionLeft   = 1 << 3,
};

/**
 The trunction type, tells the truncation engine which type of truncation is being requested.
 */
typedef NS_ENUM (NSUInteger, YYTextTruncationType) {
    /// No truncate.
    YYTextTruncationTypeNone   = 0,
    
    /// Truncate at the beginning of the line, leaving the end portion visible.
    YYTextTruncationTypeStart  = 1,
    
    /// Truncate at the end of the line, leaving the start portion visible.
    YYTextTruncationTypeEnd    = 2,
    
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    YYTextTruncationTypeMiddle = 3,
};



#pragma mark - Attribute Name Defined in YYText

/// The value of this attribute is a `YYTextBackedString` object.
/// Use this attribute to store the original plain text if it is replaced by something else (such as attachment).
UIKIT_EXTERN NSString *const YYTextBackedStringAttributeName;

/// The value of this attribute is a `YYTextBinding` object.
/// Use this attribute to bind a range of text together, as if it was a single charactor.
UIKIT_EXTERN NSString *const YYTextBindingAttributeName;

/// The value of this attribute is a `YYTextShadow` object.
/// Use this attribute to add shadow to a range of text.
/// Shadow will be drawn below text glyphs. Use YYTextShadow.subShadow to add multi-shadow.
UIKIT_EXTERN NSString *const YYTextShadowAttributeName;

/// The value of this attribute is a `YYTextShadow` object.
/// Use this attribute to add inner shadow to a range of text.
/// Inner shadow will be drawn above text glyphs. Use YYTextShadow.subShadow to add multi-shadow.
UIKIT_EXTERN NSString *const YYTextInnerShadowAttributeName;

/// The value of this attribute is a `YYTextDecoration` object.
/// Use this attribute to add underline to a range of text.
/// The underline will be drawn below text glyphs.
UIKIT_EXTERN NSString *const YYTextUnderlineAttributeName;

/// The value of this attribute is a `YYTextDecoration` object.
/// Use this attribute to add strikethrough (delete line) to a range of text.
/// The strikethrough will be drawn above text glyphs.
UIKIT_EXTERN NSString *const YYTextStrikethroughAttributeName;

/// The value of this attribute is a `YYTextBorder` object.
/// Use this attribute to add cover border or cover color to a range of text.
/// The border will be drawn above the text glyphs.
UIKIT_EXTERN NSString *const YYTextBorderAttributeName;

/// The value of this attribute is a `YYTextBorder` object.
/// Use this attribute to add background border or background color to a range of text.
/// The border will be drawn below the text glyphs.
UIKIT_EXTERN NSString *const YYTextBackgroundBorderAttributeName;

/// The value of this attribute is a `YYTextBorder` object.
/// Use this attribute to add a code block border to one or more line of text.
/// The border will be drawn below the text glyphs.
UIKIT_EXTERN NSString *const YYTextBlockBorderAttributeName;

/// The value of this attribute is a `YYTextAttachment` object.
/// Use this attribute to add attachment to text.
/// It should be used in conjunction with a CTRunDelegate.
UIKIT_EXTERN NSString *const YYTextAttachmentAttributeName;

/// The value of this attribute is a `YYTextHighlight` object.
/// Use this attribute to add a touchable highlight state to a range of text.
UIKIT_EXTERN NSString *const YYTextHighlightAttributeName;

/// The value of this attribute is a `NSValue` object stores CGAffineTransform.
/// Use this attribute to add transform to each glyph in a range of text.
UIKIT_EXTERN NSString *const YYTextGlyphTransformAttributeName;



#pragma mark - String Token Define

UIKIT_EXTERN NSString *const YYTextAttachmentToken; ///< Object replacement character (U+FFFC), used for text attachment.
UIKIT_EXTERN NSString *const YYTextTruncationToken; ///< Horizontal ellipsis (U+2026), used for text truncation  "…".



#pragma mark - Attribute Value Define

/**
 The tap/long press action callback defined in YYText.
 
 @param containerView The text container view (such as YYLabel/YYTextView).
 @param text          The whole text.
 @param range         The text range in `text` (if no range, the range.location is NSNotFound).
 @param rect          The text frame in `containerView` (if no data, the rect is CGRectNull).
 */
typedef void(^YYTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);


/**
 YYTextBackedString objects are used by the NSAttributedString class cluster
 as the values for text backed string attributes (stored in the attributed 
 string under the key named YYTextBackedStringAttributeName).
 
 It may used for copy/paste plain text from attributed string.
 Example: If :) is replace by a custom emoji (such as😊), the backed string can be set to @":)".
 */
@interface YYTextBackedString : NSObject <NSCoding, NSCopying>
+ (instancetype)stringWithString:(nullable NSString *)string;
@property (nullable, nonatomic, copy) NSString *string; ///< backed string
@end


/**
 YYTextBinding objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named YYTextBindingAttributeName).
 
 Add this to a range of text will make the specified characters 'binding together'.
 YYTextView will treat the range of text as a single character during text 
 selection and edit.
 */
@interface YYTextBinding : NSObject <NSCoding, NSCopying>
+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm;
@property (nonatomic) BOOL deleteConfirm; ///< confirm the range when delete in YYTextView
@end


/**
 YYTextShadow objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named YYTextShadowAttributeName or YYTextInnerShadowAttributeName).
 
 It's similar to `NSShadow`, but offers more options.
 */
@interface YYTextShadow : NSObject <NSCoding, NSCopying>
+ (instancetype)shadowWithColor:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

@property (nullable, nonatomic, strong) UIColor *color; ///< shadow color
@property (nonatomic) CGSize offset;                    ///< shadow offset
@property (nonatomic) CGFloat radius;                   ///< shadow blur radius
@property (nonatomic) CGBlendMode blendMode;            ///< shadow blend mode
@property (nullable, nonatomic, strong) YYTextShadow *subShadow;  ///< a sub shadow which will be added above the parent shadow

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow; ///< convert NSShadow to YYTextShadow
- (NSShadow *)nsShadow; ///< convert YYTextShadow to NSShadow
@end


/**
 YYTextDecorationLine objects are used by the NSAttributedString class cluster
 as the values for decoration line attributes (stored in the attributed string under
 the key named YYTextUnderlineAttributeName or YYTextStrikethroughAttributeName).
 
 When it's used as underline, the line is drawn below text glyphs;
 when it's used as strikethrough, the line is drawn above text glyphs.
 */
@interface YYTextDecoration : NSObject <NSCoding, NSCopying>
+ (instancetype)decorationWithStyle:(YYTextLineStyle)style;
+ (instancetype)decorationWithStyle:(YYTextLineStyle)style width:(nullable NSNumber *)width color:(nullable UIColor *)color;
@property (nonatomic) YYTextLineStyle style;                   ///< line style
@property (nullable, nonatomic, strong) NSNumber *width;       ///< line width (nil means automatic width)
@property (nullable, nonatomic, strong) UIColor *color;        ///< line color (nil means automatic color)
@property (nullable, nonatomic, strong) YYTextShadow *shadow;  ///< line shadow
@end


/**
 YYTextBorder objects are used by the NSAttributedString class cluster
 as the values for border attributes (stored in the attributed string under
 the key named YYTextBorderAttributeName or YYTextBackgroundBorderAttributeName).
 
 It can be used to draw a border around a range of text, or draw a background
 to a range of text.
 
 Example:
    ╭──────╮
    │ Text │
    ╰──────╯
 */
@interface YYTextBorder : NSObject <NSCoding, NSCopying>
+ (instancetype)borderWithLineStyle:(YYTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(nullable UIColor *)color;
+ (instancetype)borderWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;
@property (nonatomic) YYTextLineStyle lineStyle;              ///< border line style
@property (nonatomic) CGFloat strokeWidth;                    ///< border line width
@property (nullable, nonatomic, strong) UIColor *strokeColor; ///< border line color
@property (nonatomic) CGLineJoin lineJoin;                    ///< border line join
@property (nonatomic) UIEdgeInsets insets;                    ///< border insets for text bounds
@property (nonatomic) CGFloat cornerRadius;                   ///< border corder radius
@property (nullable, nonatomic, strong) YYTextShadow *shadow; ///< border shadow
@property (nullable, nonatomic, strong) UIColor *fillColor;   ///< inner fill color
@end


/**
 YYTextAttachment objects are used by the NSAttributedString class cluster 
 as the values for attachment attributes (stored in the attributed string under 
 the key named YYTextAttachmentAttributeName).
 
 When display an attributed string which contains `YYTextAttachment` object,
 the content will be placed in text metric. If the content is `UIImage`, 
 then it will be drawn to CGContext; if the content is `UIView` or `CALayer`, 
 then it will be added to the text container's view or layer.
 */
@interface YYTextAttachment : NSObject<NSCoding, NSCopying>
+ (instancetype)attachmentWithContent:(nullable id)content;
@property (nullable, nonatomic, strong) id content;             ///< Supported type: UIImage, UIView, CALayer
@property (nonatomic) UIViewContentMode contentMode;            ///< Content display mode.
@property (nonatomic) UIEdgeInsets contentInsets;               ///< The insets when drawing content.
@property (nullable, nonatomic, strong) NSDictionary *userInfo; ///< The user information dictionary.
@end


/**
 YYTextHighlight objects are used by the NSAttributedString class cluster
 as the values for touchable highlight attributes (stored in the attributed string
 under the key named YYTextHighlightAttributeName).
 
 When display an attributed string in `YYLabel` or `YYTextView`, the range of 
 highlight text can be toucheds down by users. If a range of text is turned into 
 highlighted state, the `attributes` in `YYTextHighlight` will be used to modify 
 (set or remove) the original attributes in the range for display.
 */
@interface YYTextHighlight : NSObject <NSCoding, NSCopying>

/**
 Attributes that you can apply to text in an attributed string when highlight.
 Key:   Same as CoreText/YYText Attribute Name.
 Value: Modify attribute value when highlight (NSNull for remove attribute).
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *attributes;

/**
 Creates a highlight object with specified attributes.
 
 @param attributes The attributes which will replace original attributes when highlight,
        If the value is NSNull, it will removed when highlight.
 */
+ (instancetype)highlightWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 Convenience methods to create a default highlight with the specifeid background color.
 
 @param color The background border color.
 */
+ (instancetype)highlightWithBackgroundColor:(nullable UIColor *)color;

// Convenience methods below to set the `attributes`.
- (void)setFont:(nullable UIFont *)font;
- (void)setColor:(nullable UIColor *)color;
- (void)setStrokeWidth:(nullable NSNumber *)width;
- (void)setStrokeColor:(nullable UIColor *)color;
- (void)setShadow:(nullable YYTextShadow *)shadow;
- (void)setInnerShadow:(nullable YYTextShadow *)shadow;
- (void)setUnderline:(nullable YYTextDecoration *)underline;
- (void)setStrikethrough:(nullable YYTextDecoration *)strikethrough;
- (void)setBackgroundBorder:(nullable YYTextBorder *)border;
- (void)setBorder:(nullable YYTextBorder *)border;
- (void)setAttachment:(nullable YYTextAttachment *)attachment;

/**
 The user information dictionary, default is nil.
 */
@property (nullable, nonatomic, copy) NSDictionary *userInfo;

/**
 Tap action when user tap the highlight, default is nil.
 If the value is nil, YYTextView or YYLabel will ask it's delegate to handle the tap action.
 */
@property (nullable, nonatomic, copy) YYTextAction tapAction;

/**
 Long press action when user long press the highlight, default is nil.
 If the value is nil, YYTextView or YYLabel will ask it's delegate to handle the long press action.
 */
@property (nullable, nonatomic, copy) YYTextAction longPressAction;

@end

NS_ASSUME_NONNULL_END
