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
    
    if (!self.navigationController)
    {
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:@"Dismiss" forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        if (self.navigationController)
        {
            TextFieldViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TextFieldViewController class])];

            [controller setModalTransitionStyle:arc4random()%4];
            
            // TransitionStylePartialCurl can only be presented by FullScreen style.
            if (controller.modalTransitionStyle == UIModalTransitionStylePartialCurl)
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
            else
                controller.modalPresentationStyle = arc4random()%4;
            
            [self presentViewController:controller animated:YES completion:nil];
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
