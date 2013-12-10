//
//  ViewController.m
//
//  Created by Mohd Iftekhar Qurashi on 01/07/13.


#import "ViewController.h"
#import "IQKeyBoardManager.h"

@implementation ViewController

#define numTextFields 10

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"IQKeyboard"];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Enable" style:UIBarButtonItemStyleBordered target:self action:@selector(enableKeyboardManger:)]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Disable" style:UIBarButtonItemStyleBordered target:self action:@selector(disableKeyboardManager:)]];
    
    for (int i=0; i<numTextFields; i++)
    {        
        UITextField *textField = (UITextField*)[self.view viewWithTag:100+i];
        textField.delegate = self;
        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
        
        // First textField
        if (i == 0)
        {
            [textField setEnablePrevious:NO next:YES];
        }
        // Last textField
        else if(i== numTextFields-1)
        {
            [textField setEnablePrevious:YES next:NO];
        }
    }
    
    if (!self.navigationController)
    {
        [buttonPop setHidden:YES];
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:@"Dismiss" forState:UIControlStateNormal];
    }
    else if(self.navigationController.viewControllers.count ==1)
    {
        [buttonPop setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)enableKeyboardManger:(UIBarButtonItem*)barButton
{
    [IQKeyboardManager enableKeyboardManger];
}

-(void)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    [IQKeyboardManager disableKeyboardManager];
}

-(void)previousClicked:(UISegmentedControl*)segmentedControl
{
    [(UITextField*)[self.view viewWithTag:selectedTextFieldTag-1] becomeFirstResponder];
}

-(void)nextClicked:(UISegmentedControl*)segmentedControl
{
    [(UITextField*)[self.view viewWithTag:selectedTextFieldTag+1] becomeFirstResponder];
}

-(void)doneClicked:(UIBarButtonItem*)barButton
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

// - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationMaskAll;
// }
//
// - (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
// }

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    selectedTextFieldTag = textView.tag;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectedTextFieldTag = textField.tag;
}

- (IBAction)pushClicked:(id)sender
{
    ViewController *controller = [[ViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)presentClicked:(id)sender
{
    @try {
        if (self.navigationController)
        {
            ViewController *controller = [[ViewController alloc] init];
            
            [controller setModalTransitionStyle:arc4random()%4];

            // TransitionStylePartialCurl can only be presented by FullScreen style.
            if (controller.modalTransitionStyle == UIModalTransitionStylePartialCurl)
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
            else
                controller.modalPresentationStyle = arc4random()%4;
            
            if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
            {
                [self presentViewController:controller animated:YES completion:nil];
            }
            else
            {
                [self presentModalViewController:controller animated:YES];
            }
            
        }
        else
        {
            if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception:%@",exception);
    }
    @finally {

    }
    
}

- (void)viewDidUnload
{
    buttonPop = nil;
    buttonPop = nil;
    buttonPush = nil;
    buttonPresent = nil;
    [super viewDidUnload];
}

- (IBAction)popClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
