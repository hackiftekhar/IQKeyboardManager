//
//  NavigationBarViewController.m
//  IQKeyboard

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction)textFieldClicked:(UITextField *)sender
{
//    [[[UIAlertView alloc] initWithTitle:@"Message" message:@"New Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
