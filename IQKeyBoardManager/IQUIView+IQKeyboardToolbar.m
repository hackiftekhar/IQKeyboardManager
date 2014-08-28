//
//  UIView+IQToolbar.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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


#import "IQUIView+IQKeyboardToolbar.h"
#import "IQSegmentedNextPrevious.h"
#import "IQToolbar.h"
#import "IQTitleBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQBarButtonItem.h"

#import <UIKit/UIImage.h>
#import <UIKit/UILabel.h>
#import <objc/runtime.h>

IQ_LoadCategory(IQUIViewToolbar)


/*UIKeyboardToolbar Category implementation*/
@implementation UIView (IQToolbarAddition)

NSString const *IQ_shouldHideTitleKey = @"IQ_shouldHideTitle";

-(void)setShouldHideTitle:(BOOL)shouldHideTitle
{
    objc_setAssociatedObject(self, &IQ_shouldHideTitleKey, [NSNumber numberWithBool:shouldHideTitle], OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)shouldHideTitle
{
    NSNumber *shouldHideTitle = objc_getAssociatedObject(self, &IQ_shouldHideTitleKey);
    return [shouldHideTitle boolValue];
}


- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if ([titleText length] && self.shouldHideTitle == NO)
    {
        CGRect buttonFrame;
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            /*
             50 done button frame.
             24 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-50.0-24, 44);
        }
        else
        {
            /*
             57 done button frame.
             8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-57.0-8, 44);
        }
        
        IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithFrame:buttonFrame Title:titleText];
        [items addObject:title];
    }
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    IQBarButtonItem *nilButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:nilButton];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStyleDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:title];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action
{
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:nil];
}


- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if ([titleText length] && self.shouldHideTitle == NO)
    {
        CGRect buttonFrame;
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            /*
             50 done button frame.
             8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-64.0-12.0, 44);
        }
        else
        {
            /*
             57 done button frame.
             8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-57.0-8, 44);
        }
        
        IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithFrame:buttonFrame Title:titleText];
        [items addObject:title];
    }
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    IQBarButtonItem *nilButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:nilButton];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}


#pragma mark - Toolbar on UIKeyboard
-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addDoneOnKeyboardWithTarget:target action:action titleText:title];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    [self addDoneOnKeyboardWithTarget:target action:action titleText:nil];
}

- (void)addRightLeftOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle rightButtonAction:(SEL)rightAction leftButtonAction:(SEL)leftAction titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *cancelButton =[[IQBarButtonItem alloc] initWithTitle:leftTitle style:UIBarButtonItemStyleBordered target:target action:leftAction];
    [items addObject:cancelButton];
    
    if ([titleText length] && self.shouldHideTitle == NO)
    {
        CGRect buttonFrame;
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            /*
             66 Cancel button maximum x.
             50 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-50.0-16, 44);
        }
        else
        {
            /*
             66 Cancel button maximum x.
             57 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-57.0-16, 44);
        }
        
        IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithFrame:buttonFrame Title:titleText];
        [items addObject:title];
    }
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    IQBarButtonItem *nilButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:nilButton];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleBordered target:target action:rightAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightLeftOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle rightButtonAction:(SEL)rightAction leftButtonAction:(SEL)leftAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addRightLeftOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle rightButtonAction:rightAction leftButtonAction:leftAction titleText:title];
}

- (void)addRightLeftOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle rightButtonAction:(SEL)rightAction leftButtonAction:(SEL)leftAction
{
    [self addRightLeftOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle rightButtonAction:rightAction leftButtonAction:leftAction titleText:nil];
}

- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *cancelButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:target action:cancelAction];
    [items addObject:cancelButton];
    
    if ([titleText length] && self.shouldHideTitle == NO)
    {
        CGRect buttonFrame;
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            /*
             66 Cancel button maximum x.
             50 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-50.0-16, 44);
        }
        else
        {
            /*
             66 Cancel button maximum x.
             57 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-66-57.0-16, 44);
        }
        
        IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithFrame:buttonFrame Title:titleText];
        [items addObject:title];
    }
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    IQBarButtonItem *nilButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:nilButton];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:title];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction
{
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:nil];
}

- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	//  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
	
	if (IQ_IS_IOS7_OR_GREATER)
	{
//        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:target action:previousAction];
//        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:106 target:target action:nextAction];

		IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"] style:UIBarButtonItemStylePlain target:target action:previousAction];
		IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		[fixed setWidth:23];
		IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"] style:UIBarButtonItemStylePlain target:target action:nextAction];
		[items addObject:prev];
		[items addObject:fixed];
		[items addObject:next];
	}
	else
	{
        #pragma GCC diagnostic push
        #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		//  Create a next/previous button to switch between TextFieldViews.
		IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousAction:previousAction nextAction:nextAction];
        #pragma GCC diagnostic pop
		IQBarButtonItem *segButton = [[IQBarButtonItem alloc] initWithCustomView:segControl];
		[items addObject:segButton];
	}
	
    if ([titleText length] && self.shouldHideTitle == NO)
    {
        CGRect buttonFrame;
        
        if (IQ_IS_IOS7_OR_GREATER)
        {
            /*
             72.5 next/previous maximum x.
             50 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-72.5-50.0-16, 44);
        }
        else
        {
            /*
             135 next/previous maximum x.
             57 done button frame.
             8+8 distance maintenance
             */
            buttonFrame = CGRectMake(0, 0, toolbar.frame.size.width-135-57.0-16, 44);
        }
        
        IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithFrame:buttonFrame Title:titleText];
        [items addObject:title];
    }
    
    IQBarButtonItem *nilButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	[items addObject:nilButton];
	[items addObject:doneButton];
	
    //  Adding button to toolBar.
    [toolbar setItems:items];
	
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:title];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:nil];
}


-(void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled
{
    //  Getting inputAccessoryView.
    IQToolbar *inputAccessoryView = (IQToolbar*)[self inputAccessoryView];
    
    //  If it is IQToolbar and it's items are greater than zero.
    if ([inputAccessoryView isKindOfClass:[IQToolbar class]] && [[inputAccessoryView items] count]>0)
    {
		if (IQ_IS_IOS7_OR_GREATER && [[inputAccessoryView items] count]>3)
		{
			//  Getting first item from inputAccessoryView.
			IQBarButtonItem *prevButton = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
			IQBarButtonItem *nextButton = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:2];
			
			//  If it is UIBarButtonItem and it's customView is not nil.
			if ([prevButton isKindOfClass:[IQBarButtonItem class]] && [nextButton isKindOfClass:[IQBarButtonItem class]])
			{
                if (prevButton.enabled != isPreviousEnabled)
                    [prevButton setEnabled:isPreviousEnabled];
                if (nextButton.enabled != isNextEnabled)
                    [nextButton setEnabled:isNextEnabled];
			}
		}
		else
		{
			//  Getting first item from inputAccessoryView.
			IQBarButtonItem *barButtonItem = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
			
			//  If it is IQBarButtonItem and it's customView is not nil.
			if ([barButtonItem isKindOfClass:[IQBarButtonItem class]] && [barButtonItem customView] != nil)
			{
				//  Getting it's customView.
                #pragma GCC diagnostic push
                #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
				IQSegmentedNextPrevious *segmentedControl = (IQSegmentedNextPrevious*)[barButtonItem customView];
				//  If its customView is IQSegmentedNextPrevious and has 2 segments
				if ([segmentedControl isKindOfClass:[IQSegmentedNextPrevious class]] && [segmentedControl numberOfSegments]==2)
                #pragma GCC diagnostic pop
				{
                    if ([segmentedControl isEnabledForSegmentAtIndex:0] != isPreviousEnabled)
                    {
                        //  Setting it's first segment enable/disable.
                        [segmentedControl setEnabled:isPreviousEnabled forSegmentAtIndex:0];
                    }
                    
                    if ([segmentedControl isEnabledForSegmentAtIndex:1] != isNextEnabled)
                    {
                        //  Setting it's second segment enable/disable.
                        [segmentedControl setEnabled:isNextEnabled forSegmentAtIndex:1];
                    }
      			}
			}
		}
    }
}

@end
