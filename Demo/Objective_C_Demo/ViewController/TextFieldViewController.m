//
//  TextFieldViewController.m
//  KeyboardTextFieldDemo

#import "TextFieldViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQDropDownTextField.h"
#import "IQUIView+IQKeyboardToolbar.h"

@interface TextFieldViewController ()

-(void)refreshUI;

@end

@implementation TextFieldViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
    IBOutlet IQDropDownTextField *dropDownTextField;
}

#pragma mark - View lifecycle

-(IBAction)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    if ([[IQKeyboardManager sharedManager] isEnabled])
    {
        [[IQKeyboardManager sharedManager] setEnable:NO];
    }
    else
    {
        [[IQKeyboardManager sharedManager] setEnable:YES];
    }

    [self refreshUI];
}

-(void)previousAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
}

-(void)nextAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
}

-(void)doneAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [dropDownTextField setCustomPreviousTarget:self action:@selector(previousAction:)];
    [dropDownTextField setCustomNextTarget:self action:@selector(nextAction:)];
    [dropDownTextField setCustomDoneTarget:self action:@selector(doneAction:)];
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    
    [dropDownTextField setItemList:[NSArray arrayWithObjects:@"Zero Line Of Code",
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
                                     @"play sound on next/prev/done",nil]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentingViewController)
    {
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:@"Dismiss" forState:UIControlStateNormal];
    }

    [self refreshUI];
}

-(void)refreshUI
{
    if ([[IQKeyboardManager sharedManager] isEnabled])
    {
        [barButtonDisable setTitle:@"Disable"];
    }
    else
    {
        [barButtonDisable setTitle:@"Enable"];
    }
}

-(void)dealloc
{
    returnKeyHandler = nil;
}

- (IBAction)presentClicked:(id)sender
{
    @try {
        if (!self.presentingViewController)
        {
            TextFieldViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TextFieldViewController class])];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            
#ifdef NSFoundationVersionNumber_iOS_6_1
            navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
#endif
            navigationController.navigationBar.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
            
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
