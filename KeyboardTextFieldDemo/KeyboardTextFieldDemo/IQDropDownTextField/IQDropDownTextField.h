//
//  IQDropDownTextField.h
// https://github.com/hackiftekhar/IQDropDownTextField
// Copyright (c) 2013-15 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>

#if !(__has_feature(objc_instancetype))
    #define instancetype id
#endif

/**
    @enum IQDropDownMode
 
    @abstract Drop Down Mode settings.
 
    @const IQDropDownModeTextPicker   Show pickerView with provided text data.
 
    @const IQDropDownModeTimePicker   Show UIDatePicker to pick time.
 
    @const IQDropDownModeDatePicker   Show UIDatePicker to pick date.
 */

#ifndef NS_ENUM

typedef enum IQDropDownMode {
    IQDropDownModeTextPicker,
    IQDropDownModeTimePicker,
    IQDropDownModeDatePicker,
}IQDropDownMode;

#else

typedef NS_ENUM(NSInteger, IQDropDownMode) {
    IQDropDownModeTextPicker,
    IQDropDownModeTimePicker,
    IQDropDownModeDatePicker,
};

#endif


@class IQDropDownTextField;

/**
    @protocol   IQDropDownTextFieldDelegate
 
    @abstract   Drop down text field delegate.
 */
@protocol IQDropDownTextFieldDelegate <UITextFieldDelegate>

@optional
-(void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item; //Called when textField changes it's selected item.

@end


/**
    @author     Iftekhar Qurashi
 
	@related    hack.iftekhar@gmail.com
 
    @class      IQDropDownTextField
 
	@abstract   Add a UIPickerView as inputView
 */
@interface IQDropDownTextField : UITextField

@property(nonatomic,assign) id<IQDropDownTextFieldDelegate> delegate;             // default is nil. weak reference

/**
    @property   dropDownMode
 
    @abstract   DropDownMode style to show in picker. Default is IQDropDownModeTextPicker.
 */
@property (nonatomic, assign) IQDropDownMode dropDownMode;



/*******************************************/


//  Title Selection

/**
    @property   selectedItem
 
    @abstract   Selected item of pickerView.
 */
@property (nonatomic, strong) NSString *selectedItem;

/**
    @method     setSelectedItem:animated
 
    @abstract   Set selected item of pickerView.
 */
- (void)setSelectedItem:(NSString*)selectedItem animated:(BOOL)animated;



/*******************************************/

/*-------------------------------------------------------*/
/******          IQDropDownModeTextPicker           ******/
/*-------------------------------------------------------*/

/**
    @property   itemList
 
    @abstract   Items to show in pickerView. Please use [ NSArray of NSString ] format for setter method, For example. @[ @"1", @"2", @"3", ]
 */
@property (nonatomic, strong) NSArray *itemList;

/**
    @property   isOptionalDropDown
 
 @abstract   If YES then it will add a 'Select' item at top of dropDown list. If NO then first field will automatically be selected. Default is YES
 */
@property (nonatomic, assign) BOOL isOptionalDropDown;

/**
    @property   selectedRow
 
    @abstract   Selected row index of selected item.
 */
@property (nonatomic, assign) NSInteger selectedRow;

/**
    @method     setSelectedRow:animated
 
    @abstract   Select row index of selected item.
 */
- (void)setSelectedRow:(NSInteger)row animated:(BOOL)animated;



/*-------------------------------------------------------*/
/*** IQdropDownModeDatePicker/IQDropDownModeTimePicker ***/
/*-------------------------------------------------------*/

/**
    @property   date
 
    @abstract   Selected date in UIDatePicker.
 */
@property(nonatomic, strong) NSDate *date;

/**
    @method     setDate:animated
 
    @abstract   Select date in UIDatePicker.
 */
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

/**
    @property   dateComponents
 
    @abstract   DateComponents for date picker.
 */
@property (nonatomic, readonly, copy) NSDateComponents *dateComponents;

/**
    @property   year
 
    @property   month
 
    @property   day
 
    @property   hour
 
    @property   minute
 
    @property   second
 
    @abstract   date component individual values.
 */
@property (nonatomic, readonly) NSInteger year;

@property (nonatomic, readonly) NSInteger month;

@property (nonatomic, readonly) NSInteger day;

@property (nonatomic, readonly) NSInteger hour;

@property (nonatomic, readonly) NSInteger minute;

@property (nonatomic, readonly) NSInteger second;



/*-------------------------------------------------------*/
/******          IQdropDownModeDatePicker           ******/
/*-------------------------------------------------------*/

/**
    @property   datePickerMode
 
    @abstract   Select date in UIDatePicker. Default is UIDatePickerModeDate
 */
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

/**
    @property   minimumDate
 
    @abstract   Minimum selectable date in UIDatePicker. Default is nil.
 */
@property (nonatomic, retain) NSDate *minimumDate;

/**
    @property   maximumDate
 
    @abstract   Maximum selectable date in UIDatePicker. Default is nil.
 */
@property (nonatomic, retain) NSDate *maximumDate;

/**
    @property   dateFormatter
 
    @abstract   Date formatter to show date as text in textField.
 */
@property (nonatomic, retain) NSDateFormatter *dateFormatter UI_APPEARANCE_SELECTOR;



/*-------------------------------------------------------*/
/******          IQDropDownModeTimePicker           ******/
/*-------------------------------------------------------*/

/**
 @property   timeFormatter
 
    @abstract   Time formatter to show time as text in textField.
 */
@property (nonatomic, retain) NSDateFormatter *timeFormatter;


@end
