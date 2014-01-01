//
//  TextViewSpecialCaseViewController.m
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 01/01/14.
//  Copyright (c) 2014 Canopus. All rights reserved.
//

#import "TextViewSpecialCaseViewController.h"
#import "IQKeyboardManager.h"

@implementation TextViewSpecialCaseViewController

-(void)canAdjustTextView:(UIBarButtonItem*)barButton
{
    if ([barButton.title isEqualToString:@"Disable Adjust"])
    {
        [[IQKeyboardManager sharedManager] setCanAdjustTextView:NO];
        [barButton setTitle:@"Enable Adjust"];
    }
    else
    {
        [[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];
        [barButton setTitle:@"Disable Adjust"];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle:@"Special Case"];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[[IQKeyboardManager sharedManager] canAdjustTextView]?@"Disable Adjust":@"Enable Adjust" style:UIBarButtonItemStylePlain target:self action:@selector(canAdjustTextView:)]];
    
    if (!self.navigationController)
    {
        [buttonPop setHidden:YES];
        [buttonPush setHidden:YES];
        [buttonPresent setTitle:@"Dismiss" forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}


- (IBAction)popClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pushClicked:(id)sender
{
    TextViewSpecialCaseViewController *controller = [[TextViewSpecialCaseViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
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

@end
