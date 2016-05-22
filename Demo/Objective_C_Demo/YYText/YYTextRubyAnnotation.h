//
//  YYTextRubyAnnotation.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/24.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapper for CTRubyAnnotationRef.
 
 Example:
 
     YYTextRubyAnnotation *ruby = [YYTextRubyAnnotation new];
     ruby.textBefore = @"zhù yīn";
     CTRubyAnnotationRef ctRuby = ruby.CTRubyAnnotation;
     if (ctRuby) {
        /// add to attributed string
        CFRelease(ctRuby);
     }
 
 */
@interface YYTextRubyAnnotation : NSObject <NSCopying, NSCoding>

/// Specifies how the ruby text and the base text should be aligned relative to each other.
@property (nonatomic) CTRubyAlignment alignment;

/// Specifies how the ruby text can overhang adjacent characters.
@property (nonatomic) CTRubyOverhang overhang;

/// Specifies the size of the annotation text as a percent of the size of the base text.
@property (nonatomic) CGFloat sizeFactor;


/// The ruby text is positioned before the base text;
/// i.e. above horizontal text and to the right of vertical text.
@property (nullable, nonatomic, copy) NSString *textBefore;

/// The ruby text is positioned after the base text;
/// i.e. below horizontal text and to the left of vertical text.
@property (nullable, nonatomic, copy) NSString *textAfter;

/// The ruby text is positioned to the right of the base text whether it is horizontal or vertical.
/// This is the way that Bopomofo annotations are attached to Chinese text in Taiwan.
@property (nullable, nonatomic, copy) NSString *textInterCharacter;

/// The ruby text follows the base text with no special styling.
@property (nullable, nonatomic, copy) NSString *textInline;


/**
 Create a ruby object from CTRuby object.
 
 @param ctRuby  A CTRuby object.
 
 @return A ruby object, or nil when an error occurs.
 */
+ (instancetype)rubyWithCTRubyRef:(CTRubyAnnotationRef)ctRuby NS_AVAILABLE_IOS(8_0);

/**
 Create a CTRuby object from the instance.
 
 @return A new CTRuby object, or NULL when an error occurs.
 The returned value should be release after used.
 */
- (nullable CTRubyAnnotationRef)CTRubyAnnotation CF_RETURNS_RETAINED NS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END
