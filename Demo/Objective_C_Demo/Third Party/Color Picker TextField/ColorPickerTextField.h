//
//  ColorPickerTextField.h
//  IQKeyboard
//
//  Created by Iftekhar on 27/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerTextField;

@protocol ColorPickerTextFieldDelegate <UITextFieldDelegate>

@optional
-(void)colorPickerTextField:(nonnull ColorPickerTextField*)textField selectedColorAttributes:(nonnull NSDictionary<NSString*,id>*)colorAttributes;

@end

@interface ColorPickerTextField : UITextField

@property(nullable, nonatomic, strong) UIColor *selectedColor;
@property(nullable, strong, nonatomic) NSDictionary *selectedColorAttributes;
@property (nullable, weak, nonatomic)id<ColorPickerTextFieldDelegate> delegate;

@end
