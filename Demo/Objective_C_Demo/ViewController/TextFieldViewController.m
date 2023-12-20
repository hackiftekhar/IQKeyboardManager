//
//  TextFieldViewController.m
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

#import "TextFieldViewController.h"
#import <IQDropDownTextField/IQDropDownTextField.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface TextFieldViewController ()<UIPopoverPresentationControllerDelegate>

@end

@implementation TextFieldViewController
{
    IBOutlet UITextField *textField3;
    IBOutlet UITextView *textView1;
    IBOutlet UITextView *textView2;
    IBOutlet UITextView *textView3;
    IBOutlet IQDropDownTextField *dropDownTextField;
}

#pragma mark - View lifecycle

-(void)dealloc
{
    textField3 = nil;
    dropDownTextField = nil;
}

-(void)previousAction:(UITextField*)textField
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)nextAction:(UITextField*)textField
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)doneAction:(UITextField*)textField
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textView2.enableMode = IQEnableModeDisabled;
    
    textField3.delegate = self;
    [textField3.keyboardToolbar.previousBarButton setTarget:self action:@selector(previousAction:)];
    [textField3.keyboardToolbar.nextBarButton setTarget:self action:@selector(nextAction:)];
    [textField3.keyboardToolbar.doneBarButton setTarget:self action:@selector(doneAction:)];


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if (@available(iOS 16.0, *)) {
        textView3.findInteractionEnabled = YES;
    }
#endif

    dropDownTextField.keyboardDistanceFromTextField = 150;
    
    [dropDownTextField setItemList:@[@"Zero Line Of Code",
                                     @"No More UIScrollView",
                                     @"No More Subclasses",
                                     @"No More Manual Work",
                                     @"No More #imports",
                                     @"Device Orientation support",
                                     @"UITextField Category for Keyboard",
                                     @"Enable/Desable Keyboard Manager",
                                     @"Customize InputView support",
                                     @"IQTextView for placeholder support",
                                     @"Automanage keyboard toolbar",
                                     @"Can set keyboard and textFiled distance",
                                     @"Can resign on touching outside",
                                     @"Auto adjust textView's height ",
                                     @"Adopt tintColor from textField",
                                     @"Customize keyboardAppearance",
                                     @"play sound on next/prev/done"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentingViewController)
    {
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:NSLocalizedString(@"Dismiss",nil) forState:UIControlStateNormal];
    }

    [[IQKeyboardManager sharedManager] registerKeyboardSizeChangeWithIdentifier: @"TextFieldViewController" sizeHandler:^(CGSize size) {
        NSLog(@"%@", NSStringFromCGSize(size));
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];

    [[IQKeyboardManager sharedManager] unregisterKeyboardSizeChangeWithIdentifier: @"TextFieldViewController"];
}

- (IBAction)presentClicked:(id)sender
{
    @try {
        if (!self.presentingViewController)
        {
            TextFieldViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TextFieldViewController class])];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            
            navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
            
            [navigationController setModalTransitionStyle:arc4random()%4];
            
            // TransitionStylePartialCurl can only be presented by FullScreen style.
            if (navigationController.modalTransitionStyle == UIModalTransitionStylePartialCurl)
                navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            else
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception:%@",exception);
    }
    @finally {
        
    }
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == textField3) {
//        textField.keyboardToolbar.doneBarButton.enabled = textField.text.length > 0;
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == textField3) {
//        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        textField.keyboardToolbar.doneBarButton.enabled = newText.length > 0;
    }
    
    return YES;
}

@end
