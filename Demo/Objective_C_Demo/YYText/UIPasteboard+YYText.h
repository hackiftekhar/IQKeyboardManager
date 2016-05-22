//
//  UIPasteboard+YYText.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/2.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Extend UIPasteboard to support image and attributed string.
 */
@interface UIPasteboard (YYText)

@property (nullable, nonatomic, copy) NSData *yy_PNGData;    ///< PNG file data
@property (nullable, nonatomic, copy) NSData *yy_JPEGData;   ///< JPEG file data
@property (nullable, nonatomic, copy) NSData *yy_GIFData;    ///< GIF file data
@property (nullable, nonatomic, copy) NSData *yy_WEBPData;   ///< WebP file data
@property (nullable, nonatomic, copy) NSData *yy_ImageData;  ///< image file data

/// Attributed string,
/// Set this attributed will also set the string property which is copy from the attributed string.
/// If the attributed string contains one or more image, it will also set the `images` property.
@property (nullable, nonatomic, copy) NSAttributedString *yy_AttributedString;

@end


/// The name identifying the attributed string in pasteboard.
UIKIT_EXTERN NSString *const YYTextPasteboardTypeAttributedString;

/// The UTI Type identifying WebP data in pasteboard.
UIKIT_EXTERN NSString *const YYTextUTTypeWEBP;

NS_ASSUME_NONNULL_END
