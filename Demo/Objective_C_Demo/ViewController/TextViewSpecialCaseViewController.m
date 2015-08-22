//
//  TextViewSpecialCaseViewController.m
//  KeyboardTextFieldDemo

#import "TextViewSpecialCaseViewController.h"
#import "IQKeyboardManager.h"

@interface TextViewSpecialCaseViewController ()

-(void)refreshUI;

@end

@implementation TextViewSpecialCaseViewController

-(IBAction)canAdjustTextView:(UIBarButtonItem*)barButton
{
    if ([[IQKeyboardManager sharedManager] canAdjustTextView])
    {
        [[IQKeyboardManager sharedManager] setCanAdjustTextView:NO];
    }
    else
    {
        [[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];
    }
    
    [self refreshUI];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    if ([[IQKeyboardManager sharedManager] canAdjustTextView])
    {
        [barButtonAdjust setTitle:@"Disable Adjust"];
    }
    else
    {
        [barButtonAdjust setTitle:@"Enable Adjust"];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (IBAction)presentClicked:(id)sender
{
    @try {
        if (self.navigationController)
        {
            TextViewSpecialCaseViewController *controller = [[TextViewSpecialCaseViewController alloc] init];
            
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
