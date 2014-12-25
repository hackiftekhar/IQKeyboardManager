//
//  TextFieldViewController.m
//  KeyboardTextFieldDemo

#import "TextFieldViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"

@implementation TextFieldViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    returnKeyHandler.toolbarManageBehaviour = IQAutoToolbarByPosition;
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
            navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
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
