//
//  ManualToolbarViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 30/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ManualToolbarViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"


@interface ManualToolbarViewController ()<UIPopoverPresentationControllerDelegate>

-(void)previousAction:(id)sender;
-(void)nextAction:(id)sender;
-(void)doneAction:(id)sender;



@end

@implementation ManualToolbarViewController
{
    IBOutlet UITextField *textField1;
    IBOutlet UITextField *textField2;
    IBOutlet UITextView *textView3;
    IBOutlet UITextField *textField4;
    
    IBOutlet UITextField *textField5;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [textField1 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];
    [textField1 setEnablePrevious:NO next:YES];
    
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];
    [textField2 setEnablePrevious:YES next:NO];

    [textView3 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];

    [textField4 setTitleTarget:self action:@selector(titleAction:)];
    textField4.placeholderText = @"Saved Users";
    
    [textField4 addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:YES];
    
    textField5.inputAccessoryView = [[UIView alloc] init];
}

-(void)previousAction:(id)sender
{
    if ([textField2 isFirstResponder])
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
}

-(void)doneAction:(id)sender
{
    [self.view endEditing:YES];
}

-(void)titleAction:(UIButton*)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"test@example.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        textField4.text = @"test@example.com";
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"demo@example.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        textField4.text = @"demo@example.com";
    }]];
    
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SettingsNavigationController"])
    {
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationPopover;
        segue.destinationViewController.popoverPresentationController.barButtonItem = sender;
        
        CGFloat heightWidth = MAX(CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
        segue.destinationViewController.preferredContentSize = CGSizeMake(heightWidth, heightWidth);
        segue.destinationViewController.popoverPresentationController.delegate = self;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

-(void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
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
