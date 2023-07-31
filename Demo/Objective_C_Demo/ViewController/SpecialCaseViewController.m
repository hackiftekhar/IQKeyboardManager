//
//  SpecialCaseViewController.m
//  KeyboardTextFieldDemo

#import "SpecialCaseViewController.h"
#import <IQKeyboardManager/IQUIView+Hierarchy.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <IQKeyboardManager/IQUIView+IQKeyboardToolbar.h>

@interface SpecialCaseViewController ()<UISearchBarDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate>

-(void)updateUI;

@end

@implementation SpecialCaseViewController
{
    IBOutlet UITextField *customWorkTextField;
    
    IBOutlet UITextField *textField6;
    IBOutlet UITextField *textField7;
    IBOutlet UITextField *textField8;
    
    IBOutlet UISwitch *switchInteraction1;
    IBOutlet UISwitch *switchInteraction2;
    IBOutlet UISwitch *switchInteraction3;
    IBOutlet UISwitch *switchEnabled1;
    IBOutlet UISwitch *switchEnabled2;
    IBOutlet UISwitch *switchEnabled3;
}

-(void)dealloc
{
    customWorkTextField = nil;
    textField6 = nil;
    textField7 = nil;
    textField8 = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    textField6.keyboardDistanceFromTextField = 50;
    
    textField6.userInteractionEnabled = switchInteraction1.on;
    textField7.userInteractionEnabled = switchInteraction2.on;
    textField8.userInteractionEnabled = switchInteraction3.on;

    textField6.enabled = switchEnabled1.on;
    textField7.enabled = switchEnabled2.on;
    textField8.enabled = switchEnabled3.on;
    
    [self updateUI];
}

- (IBAction)showAlertClicked:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"IQKeyboardManager",nil) message:NSLocalizedString(@"It doesn't affect UIAlertController (Doesn't add IQToolbar on it's textField",nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil) style:UIAlertActionStyleCancel handler:nil]];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Username",nil);
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Password",nil);
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)updateUI
{
    textField6.placeholder = [NSString stringWithFormat:@"%@, %@",textField6.enabled?@"enabled":@"",textField6.userInteractionEnabled?@"userInteractionEnabled":@""];
    textField7.placeholder = [NSString stringWithFormat:@"%@, %@",textField7.enabled?@"enabled":@"",textField7.userInteractionEnabled?@"userInteractionEnabled":@""];
    textField8.placeholder = [NSString stringWithFormat:@"%@, %@",textField8.enabled?@"enabled":@"",textField8.userInteractionEnabled?@"userInteractionEnabled":@""];
}

- (IBAction)switch1UserInteractionAction:(UISwitch *)sender
{
    textField6.userInteractionEnabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

- (IBAction)switch2UserInteractionAction:(UISwitch *)sender
{
    textField7.userInteractionEnabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

- (IBAction)switch3UserInteractionAction:(UISwitch *)sender
{
    textField8.userInteractionEnabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

- (IBAction)switch1Action:(UISwitch *)sender
{
    textField6.enabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

- (IBAction)switch2Action:(UISwitch *)sender
{
    textField7.enabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

- (IBAction)switch3Action:(UISwitch *)sender
{
    textField8.enabled = sender.on;
    [[IQKeyboardManager sharedManager] reloadInputViews];
    [self updateUI];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == customWorkTextField)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"IQKeyboardManager",nil) message:NSLocalizedString(@"Do your custom work here",nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];

        return NO;
    }
    else    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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
