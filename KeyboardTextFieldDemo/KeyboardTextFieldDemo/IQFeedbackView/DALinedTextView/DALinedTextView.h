//
//  DALinedTextView.h
//  DALinedTextView
//
//  Created by Daniel Amitay on 5/12/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DALinedTextView : UITextView

@property (nonatomic, strong) UIColor *horizontalLineColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *verticalLineColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIEdgeInsets margins UI_APPEARANCE_SELECTOR;

@end
