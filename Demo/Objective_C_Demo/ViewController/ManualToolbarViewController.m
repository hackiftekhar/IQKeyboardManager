//
//  ManualToolbarViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 30/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ManualToolbarViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "IQToolbar.h"
#import "IQTitleBarButtonItem.h"

@interface ManualToolbarViewController ()<UIPopoverPresentationControllerDelegate>

-(void)previousAction:(id)sender;
-(void)nextAction:(id)sender;
-(void)doneAction:(id)sender;

@property(nonatomic, strong) IBOutlet UITextField *textField4;

@end

@implementation ManualToolbarViewController
{
    IBOutlet UITextField *textField1;
    IBOutlet UITextField *textField2;
    IBOutlet UITextView *textView3;
    
    IBOutlet UITextField *textField5;
}

-(void)dealloc
{
    textField1 = nil;
    textField2 = nil;
    textView3 = nil;
    textField5 = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [textField1 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];
    textField1.keyboardToolbar.previousBarButton.enabled = NO;
    textField1.keyboardToolbar.nextBarButton.enabled = YES;

    
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];
    textField2.keyboardToolbar.previousBarButton.enabled = YES;
    textField2.keyboardToolbar.nextBarButton.enabled = NO;

    [textView3 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:YES];

    [self.textField4.keyboardToolbar.titleBarButton setTarget:self action:@selector(titleAction:)];
    self.textField4.toolbarPlaceholder = @"Saved Users";
    
    [self.textField4 addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:YES];
    
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
    
    __weak typeof(self) weakSelf = self;

    [alertController addAction:[UIAlertAction actionWithTitle:@"test@example.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.textField4.text = @"test@example.com";
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"demo@example.com" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.textField4.text = @"demo@example.com";
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

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
