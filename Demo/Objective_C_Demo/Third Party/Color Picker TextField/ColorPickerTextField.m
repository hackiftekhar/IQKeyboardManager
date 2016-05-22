//
//  ColorPickerTextField.m
//  IQKeyboard
//
//  Created by Iftekhar on 27/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ColorPickerTextField.h"
#import "HFColorPickerView.h"
#import "HFColorButton.h"
#import "UIColor+HexColors.h"

@interface ColorPickerTextField ()<HFColorPickerViewDelegate>

@end

@implementation ColorPickerTextField
{
    HFColorPickerView *colorPickerView;
    HFColorButton *circleView;
}

@dynamic delegate;

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
//    if (@selector(cut:) == action || @selector(copy:) == action || @selector(paste:) == action || @selector(select:) == action || @selector(selectAll:) == action)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
}


+(NSArray *)colorAttributes
{
    return @[@{@"name":@"No Color",
               @"color":[UIColor clearColor]},
             
             @{@"name":@"Black",
               @"color":[UIColor colorWithRed:0 green:0 blue:0 alpha:1]},
             
             @{@"name":@"Dark Gray",
               @"color":[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]},
             
             @{@"name":@"Gray",
               @"color":[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]},
             
             @{@"name":@"White",
               @"color":[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]},
             
             
             
             @{@"name":@"Brown",
               @"color":[UIColor colorWithRed:121.0/255.0f green:85.0/255.0f blue:72.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Red",
               @"color":[UIColor colorWithRed:244.0/255.0f green:67.0/255.0f blue:54.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Deep Orange",
               @"color":[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1.0]},
             
             @{@"name":@"Orange",
               @"color":[UIColor colorWithRed:255.0/255.0 green:152.0/255.0 blue:0.0/255.0 alpha:1.0]},
             
             @{@"name":@"Amber",
               @"color":[UIColor colorWithRed:255.0/255.0 green:193.0/255.0 blue:7.0/255.0 alpha:1.0]},
             

             
             @{@"name":@"Teal",
               @"color":[UIColor colorWithRed:0.0/255.0f green:150.0/255.0f blue:136.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Green",
               @"color":[UIColor colorWithRed:76.0/255.0f green:175.0/255.0f blue:80.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Light Green",
               @"color":[UIColor colorWithRed:139.0/255.0f green:195.0/255.0f blue:74.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Lime",
               @"color":[UIColor colorWithRed:205.0/255.0f green:220.0/255.0f blue:57.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Yellow",
               @"color":[UIColor colorWithRed:255.0/255.0f green:235.0/255.0f blue:59.0/255.0f alpha:1.0f]},
             
             
             
             @{@"name":@"Indigo",
               @"color":[UIColor colorWithRed:63.0/255.0f green:81.0/255.0f blue:181.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Blue Gray",
               @"color":[UIColor colorWithRed:96.0/255.0f green:125.0/255.0f blue:139.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Blue",
               @"color":[UIColor colorWithRed:33.0/255.0f green:150.0/255.0f blue:243.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Light Blue",
               @"color":[UIColor colorWithRed:3.0/255.0f green:169.0/255.0f blue:244.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Cyan",
               @"color":[UIColor colorWithRed:0.0/255.0f green:188.0/255.0f blue:212.0/255.0f alpha:1.0f]},
             

             
             @{@"name":@"Deep Purple",
               @"color":[UIColor colorWithRed:103.0/255.0f green:58.0/255.0f blue:183.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Purple",
               @"color":[UIColor colorWithRed:156.0/255.0f green:39.0/255.0f blue:176.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Pink",
               @"color":[UIColor colorWithRed:233.0/255.0f green:30.0/255.0f blue:99.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Tomato",
               @"color":[UIColor  colorWithRed:255.0/255.0f green:99.0/255.0f blue:71.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Wheat",
               @"color":[UIColor colorWithRed:255.0/255.0f green:222.0/255.0f blue:179.0/255.0f alpha:1.0f]},
             ];
}

-(void)commonInit
{
    colorPickerView = [[HFColorPickerView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 180)];
    colorPickerView.layer.shadowColor = [UIColor blackColor].CGColor;
    colorPickerView.layer.shadowOffset = CGSizeMake(0, 1);
    colorPickerView.layer.shadowRadius = 2;
    colorPickerView.layer.shadowOpacity = 0.3;
    colorPickerView.backgroundColor = [UIColor clearColor];
    colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    colorPickerView.delegate = self;
    colorPickerView.colors = [[[self class] colorAttributes] valueForKey:@"color"];
    self.inputView = colorPickerView;
   
    circleView = [[HFColorButton alloc] initWithFrame:CGRectMake(0,0, 25, 25)];
    circleView.selected = YES;
    circleView.userInteractionEnabled = NO;
    self.rightView = circleView;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.tintColor = [UIColor clearColor];
    
    self.selectedColor = [UIColor clearColor];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self commonInit];
}

-(void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;

    NSArray *colorArray = [[self class] colorAttributes];
    for (int i =0; i<[colorArray count]; i++)
    {
        NSDictionary *colorAttributes = [colorArray objectAtIndex:i];
        
        UIColor *color = [colorAttributes objectForKey:@"color"];
        
        if ([[color hexValue] isEqualToString:[selectedColor hexValue]] && CGColorGetAlpha(color.CGColor) == CGColorGetAlpha(selectedColor.CGColor))
        {
            _selectedColorAttributes = colorAttributes;
            self.text = [colorAttributes objectForKey:@"name"];
            colorPickerView.selectedIndex = i;
            circleView.color = color;
            [circleView setNeedsDisplay];
            break;
        }
    }
}

- (void)colorPicker:(HFColorPickerView*)colorPickerView selectedColor:(UIColor*)selectedColor
{
    self.selectedColor = selectedColor;

    if ([self.delegate respondsToSelector:@selector(colorPickerTextField:selectedColorAttributes:)])
    {
        [self.delegate colorPickerTextField:self selectedColorAttributes:self.selectedColorAttributes];
    }
}

@end
