//
//  ManualToolbarViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 30/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ManualToolbarViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"


@interface ManualToolbarViewController ()

-(void)previousAction:(id)sender;
-(void)nextAction:(id)sender;
-(void)doneAction:(id)sender;



@end

@implementation ManualToolbarViewController
{
    __weak IBOutlet UITextField *textField1;
    __weak IBOutlet UITextField *textField2;
    __weak IBOutlet UITextView *textView3;
    __weak IBOutlet UITextField *textField4;
    
    __weak IBOutlet UITextField *textField5;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [textField1 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
    [textField1 setEnablePrevious:NO next:YES];
    
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];

    [textView3 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];

    [textField4 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
    [textField4 setEnablePrevious:YES next:NO];
    
    textField5.inputAccessoryView = [[UIView alloc] init];
}

-(void)previousAction:(id)sender
{
    if ([textField4 isFirstResponder])
    {
        [textField2 becomeFirstResponder];
    }
    else if ([textField2 isFirstResponder])
    {
        [textView3 becomeFirstResponder];
    }
    else if ([textView3 isFirstResponder])
    {
        [textField1 becomeFirstResponder];
    }
}

-(void)nextAction:(id)sender
{
    if ([textField1 isFirstResponder])
    {
        [textView3 becomeFirstResponder];
    }
    else if ([textView3 isFirstResponder])
    {
        [textField2 becomeFirstResponder];
    }
    else if ([textField2 isFirstResponder])
    {
        [textField4 becomeFirstResponder];
    }
}

-(void)doneAction:(id)sender
{
    [self.view endEditing:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
