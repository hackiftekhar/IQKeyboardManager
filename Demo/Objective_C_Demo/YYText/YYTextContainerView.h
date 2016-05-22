//
//  YYTextContainerView.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/4/21.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYText/YYText.h>)
#import <YYText/YYTextLayout.h>
#else
#import "YYTextLayout.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 A simple view to diaplay `YYTextLayout`.

 @discussion This view can become first responder. If this view is first responder,
 all the action (such as UIMenu's action) would forward to the `hostView` property.
 Typically, you should not use this class directly.
 
 @warning All the methods in this class should be called on main thread.
 */
@interface YYTextContainerView : UIView

/// First responder's aciton will forward to this view.
@property (nullable, nonatomic, weak) UIView *hostView;

/// Debug option for layout debug. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, copy) YYTextDebugOption *debugOption;

/// Text vertical alignment.
@property (nonatomic) YYTextVerticalAlignment textVerticalAlignment;

/// Text layout. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, strong) YYTextLayout *layout;

/// The contents fade animation duration when the layout's contents changed. Default is 0 (no animation).
@property (nonatomic) NSTimeInterval contentsFadeDuration;

/// Convenience method to set `layout` and `contentsFadeDuration`.
/// @param layout  Same as `layout` property.
/// @param fadeDuration  Same as `contentsFadeDuration` property.
- (void)setLayout:(nullable YYTextLayout *)layout withFadeDuration:(NSTimeInterval)fadeDuration;

@end

NS_ASSUME_NONNULL_END
