//
//  NavigationBarViewController.m
//  IQKeyboard

#import "NavigationBarViewController.h"
#import "IQKeyboardReturnKeyHandler.h"

@interface NavigationBarViewController ()<UITextFieldDelegate>

@end

@implementation NavigationBarViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
    __weak IBOutlet UITextField *textField2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
}

-(void)dealloc
{
    returnKeyHandler = nil;
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


//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if (textField == textField2)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

@end
