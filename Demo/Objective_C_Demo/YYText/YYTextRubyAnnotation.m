//
//  YYTextRubyAnnotation.m
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/24.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTextRubyAnnotation.h"

@implementation YYTextRubyAnnotation

- (instancetype)init {
    self = super.init;
    self.alignment = kCTRubyAlignmentAuto;
    self.overhang = kCTRubyOverhangAuto;
    self.sizeFactor = 0.5;
    return self;
}

+ (instancetype)rubyWithCTRubyRef:(CTRubyAnnotationRef)ctRuby {
    if (!ctRuby) return nil;
    YYTextRubyAnnotation *one = [self new];
    one.alignment = CTRubyAnnotationGetAlignment(ctRuby);
    one.overhang = CTRubyAnnotationGetOverhang(ctRuby);
    one.sizeFactor = CTRubyAnnotationGetSizeFactor(ctRuby);
    one.textBefore = (__bridge NSString *)(CTRubyAnnotationGetTextForPosition(ctRuby, kCTRubyPositionBefore));
    one.textAfter = (__bridge NSString *)(CTRubyAnnotationGetTextForPosition(ctRuby, kCTRubyPositionAfter));
    one.textInterCharacter = (__bridge NSString *)(CTRubyAnnotationGetTextForPosition(ctRuby, kCTRubyPositionInterCharacter));
    one.textInline = (__bridge NSString *)(CTRubyAnnotationGetTextForPosition(ctRuby, kCTRubyPositionInline));
    return one;
}

- (CTRubyAnnotationRef)CTRubyAnnotation CF_RETURNS_RETAINED {
    if (((long)CTRubyAnnotationCreate + 1) == 1) return NULL; // system not support
    
    CFStringRef text[kCTRubyPositionCount];
    text[kCTRubyPositionBefore] = (__bridge CFStringRef)(_textBefore);
    text[kCTRubyPositionAfter] = (__bridge CFStringRef)(_textAfter);
    text[kCTRubyPositionInterCharacter] = (__bridge CFStringRef)(_textInterCharacter);
    text[kCTRubyPositionInline] = (__bridge CFStringRef)(_textInline);
    CTRubyAnnotationRef ruby = CTRubyAnnotationCreate(_alignment, _overhang, _sizeFactor, text);
    return ruby;
}

- (id)copyWithZone:(NSZone *)zone {
    YYTextRubyAnnotation *one = [self.class new];
    one.alignment = _alignment;
    one.overhang = _overhang;
    one.sizeFactor = _sizeFactor;
    one.textBefore = _textBefore;
    one.textAfter = _textAfter;
    one.textInterCharacter = _textInterCharacter;
    one.textInline = _textInline;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_alignment) forKey:@"alignment"];
    [aCoder encodeObject:@(_overhang) forKey:@"overhang"];
    [aCoder encodeObject:@(_sizeFactor) forKey:@"sizeFactor"];
    [aCoder encodeObject:_textBefore forKey:@"textBefore"];
    [aCoder encodeObject:_textAfter forKey:@"textAfter"];
    [aCoder encodeObject:_textInterCharacter forKey:@"textInterCharacter"];
    [aCoder encodeObject:_textInline forKey:@"textInline"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    _alignment = ((NSNumber *)[aDecoder decodeObjectForKey:@"alignment"]).intValue;
    _overhang = ((NSNumber *)[aDecoder decodeObjectForKey:@"overhang"]).intValue;
    _sizeFactor = ((NSNumber *)[aDecoder decodeObjectForKey:@"sizeFactor"]).intValue;
    _textBefore = [aDecoder decodeObjectForKey:@"textBefore"];
    _textAfter = [aDecoder decodeObjectForKey:@"textAfter"];
    _textInterCharacter = [aDecoder decodeObjectForKey:@"textInterCharacter"];
    _textInline = [aDecoder decodeObjectForKey:@"textInline"];
    return self;
}

@end
