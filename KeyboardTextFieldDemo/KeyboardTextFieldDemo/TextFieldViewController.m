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

-(IBAction)enableKeyboardManger:(UIBarButtonItem*)barButton
{
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

-(IBAction)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    
    if (!self.navigationController)
    {
        [buttonPop setHidden:YES];
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:@"Dismiss" forState:UIControlStateNormal];
    }
}

-(void)dealloc
{
    returnKeyHandler = nil;
}

- (IBAction)popClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

@end
