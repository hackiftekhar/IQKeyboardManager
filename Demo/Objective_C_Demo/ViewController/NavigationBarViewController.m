//
//  NavigationBarViewController.m
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

#import "NavigationBarViewController.h"
#import <IQKeyboardManager/IQKeyboardReturnKeyHandler.h>
#import <IQKeyboardManager/IQUIView+IQKeyboardToolbar.h>
#import <IQKeyboardManager/IQUITextFieldView+Additions.h>

@interface NavigationBarViewController ()<UITextFieldDelegate,UIPopoverPresentationControllerDelegate>

@end

@implementation NavigationBarViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
    IBOutlet UITextField *textField2;
    IBOutlet UITextField *textField3;
    IBOutlet UIScrollView *scrollView;
}

-(void)dealloc
{
    returnKeyHandler = nil;
    textField3 = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textField3.toolbarPlaceholder = @"This is the customised placeholder title for displaying as toolbar title";
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
}

- (IBAction)enableScrollAction:(UISwitch *)sender {
    
    scrollView.scrollEnabled = sender.on;
}

- (IBAction)shouldHideTitle:(UISwitch *)sender
{
    textField2.shouldHideToolbarPlaceholder = !textField2.shouldHideToolbarPlaceholder;
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (IBAction)textFieldClicked:(UITextField *)sender
{
//    [[[UIAlertView alloc] initWithTitle:@"Message" message:@"New Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
