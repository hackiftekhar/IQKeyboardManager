//
//  NavigationBarViewController.m
//  IQKeyboard

#import "NavigationBarViewController.h"

@interface NavigationBarViewController ()<UITextFieldDelegate>

@end

@implementation NavigationBarViewController
{
    __weak IBOutlet UITextField *textField2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
