//
//  HFColorPickerView.h
//  HFColorPickerDemo
//
//  Created by Hendrik Frahmann on 30.04.14.
//  Copyright (c) 2014 Hendrik Frahmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HFColorPickerViewDelegate;

@interface HFColorPickerView : UIView

@property (nonatomic, assign) IBOutlet id<HFColorPickerViewDelegate> delegate;
@property (nonatomic, strong) NSArray* colors;
@property (nonatomic) CGFloat buttonDiameter;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSUInteger numberOfColorsPerRow;

@end


@protocol HFColorPickerViewDelegate <NSObject>

- (void)colorPicker:(HFColorPickerView*)colorPickerView selectedColor:(UIColor*)selectedColor;

@end