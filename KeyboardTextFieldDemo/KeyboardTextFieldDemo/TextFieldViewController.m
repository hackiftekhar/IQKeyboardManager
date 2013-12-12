//
//  TextFieldViewController.m
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 12/12/13.
//  Copyright (c) 2013 Canopus. All rights reserved.
//

#import "TextFieldViewController.h"
#import "IQKeyboardManager.h"

@implementation TextFieldViewController

#pragma mark - View lifecycle

-(void)enableKeyboardManger:(UIBarButtonItem*)barButton
{
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

-(void)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"IQKeyboard"];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Enable" style:UIBarButtonItemStylePlain target:self action:@selector(enableKeyboardManger:)]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Disable" style:UIBarButtonItemStylePlain target:self action:@selector(disableKeyboardManager:)]];
    
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

    // Do any additional setup after loading the view from its nib.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)popClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pushClicked:(id)sender
{
    TextFieldViewController *controller = [[TextFieldViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)presentClicked:(id)sender
{
    @try {
        if (self.navigationController)
        {
            TextFieldViewController *controller = [[TextFieldViewController alloc] init];
            
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
