//
//  ManualToolbarViewController.m
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
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

#import "ManualToolbarViewController.h"
#import <IQKeyboardManager/IQUIView+IQKeyboardToolbar.h>
#import <IQKeyboardManager/IQToolbar.h>
#import <IQKeyboardManager/IQTitleBarButtonItem.h>

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
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:nil]];
    
    __weak __typeof__(self) weakSelf = self;

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"test@example.com",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.textField4.text = NSLocalizedString(@"test@example.com",nil);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"demo@example.com",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.textField4.text = NSLocalizedString(@"demo@example.com",nil);
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
