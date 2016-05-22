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
-(void)colorPickerTextField:(ColorPickerTextField*)textField selectedColorAttributes:(NSDictionary*)colorAttributes;

@end

@interface ColorPickerTextField : UITextField

@property(nonatomic, strong) UIColor *selectedColor;
@property(strong, nonatomic) NSDictionary *selectedColorAttributes;
@property (weak,nonatomic)id<ColorPickerTextFieldDelegate> delegate;

@end
