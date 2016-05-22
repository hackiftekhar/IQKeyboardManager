//
//  HFColorPickerView.m
//  HFColorPickerDemo
//
//  Created by Hendrik Frahmann on 30.04.14.
//  Copyright (c) 2014 Hendrik Frahmann. All rights reserved.
//

#import "HFColorPickerView.h"
#import "HFColorButton.h"

@interface HFColorPickerView()

@property (nonatomic, strong) NSMutableArray* colorButtons;

- (void)setupColorButtons;
- (void)buttonClicked:(id)sender;
- (void)selectButton:(HFColorButton*)button;
- (void)calculateButtonFrames;

@end


@implementation HFColorPickerView

@synthesize colorButtons   = _colorButtons;
@synthesize colors         = _colors;
@synthesize buttonDiameter = _buttonDiameter;
@synthesize selectedIndex  = _selectedIndex;
@synthesize numberOfColorsPerRow       = _numberOfColorsPerRow;

- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self setupColorButtons];
}

- (void)setButtonDiameter:(CGFloat)buttonDiameter
{
    _buttonDiameter = buttonDiameter;
    [self calculateButtonFrames];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if(selectedIndex >= _colorButtons.count)
        selectedIndex = _colorButtons.count - 1;
    
    _selectedIndex = selectedIndex;
    
    HFColorButton* button = [_colorButtons objectAtIndex:selectedIndex];
    [self selectButton:button];
}

- (CGFloat)buttonDiameter
{
    if(_buttonDiameter == 0.0)
        _buttonDiameter = 40.0;
    return _buttonDiameter;
}

-(NSUInteger)numberOfColorsPerRow
{
    if (_numberOfColorsPerRow == 0)
        _numberOfColorsPerRow = 5;
    
    return _numberOfColorsPerRow;
}

- (NSMutableArray*)colorButtons
{
    if(_colorButtons == nil)
        _colorButtons = [NSMutableArray new];
    return _colorButtons;
}

- (void)setupColorButtons
{
    // remove all buttons
    for (HFColorButton* button in self.colorButtons)
    {
        [button removeFromSuperview];
    }
    [_colorButtons removeAllObjects];
    
    CGFloat buttonCount = 0;
    
    // create new buttons
    for (UIColor* color in _colors)
    {
        HFColorButton* button = [HFColorButton new];
        [button setColor:color];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setClipsToBounds:NO];
        
        if(buttonCount == 0)
            button.selected = YES;
        buttonCount++;
        
        [self addSubview:button];
        [_colorButtons addObject:button];
    }
    
    [self calculateButtonFrames];
}

-(void)layoutSubviews
{
    [self calculateButtonFrames];
}

- (void)calculateButtonFrames
{
    NSInteger buttonCount = self.colorButtons.count;
    
    NSInteger buttonsPerRow = self.numberOfColorsPerRow;
    if(buttonsPerRow > buttonCount)
        buttonsPerRow = buttonCount;
    
    NSInteger numberOfRows = ceil((CGFloat)buttonCount/(CGFloat)buttonsPerRow);

    CGFloat buttonWidth = self.buttonDiameter;
    CGFloat rowWidth = self.frame.size.width/buttonsPerRow;
    CGFloat rowHeight = self.frame.size.height/numberOfRows;

    CGFloat i = 0;
    CGFloat j = 0;
    
    NSInteger currentIndex = 0;
    for (HFColorButton* button in self.colorButtons)
    {
        button.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
        button.center = CGPointMake(i * rowWidth + rowWidth/2,
                                    j * rowHeight + rowHeight/2);
        
        currentIndex++;
        j = currentIndex/buttonsPerRow;
        i = currentIndex%buttonsPerRow;
    }
}

- (void)buttonClicked:(id)sender
{
    NSInteger index = [_colorButtons indexOfObject:sender];
    if(index >= 0)
    {
        [self selectButton:sender];
        
        UIColor* color = [_colors objectAtIndex:index];
        if(_delegate != nil)
            [_delegate colorPicker:self selectedColor:color];
    }
}

- (void)selectButton:(HFColorButton *)button
{
    for (HFColorButton* button in self.colorButtons)
    {
        button.selected = NO;
    }
    button.selected = YES;
}

@end
