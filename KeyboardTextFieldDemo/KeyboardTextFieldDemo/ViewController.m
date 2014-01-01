//
//  ViewController.m
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 11/12/13.
//  Copyright (c) 2013 Canopus. All rights reserved.
//

#import "ViewController.h"

#import "TextFieldViewController.h"
#import "ScrollViewController.h"
#import "WebViewController.h"
#import "TextViewSpecialCaseViewController.h"


@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"IQKeyboardManager"];
}

-(IBAction)textFieldExampleClicked:(id)sender
{
    TextFieldViewController *obj = [[TextFieldViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)scrollViewExampleClicked:(id)sender
{
    ScrollViewController *obj = [[ScrollViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)webViewExampleClicked:(id)sender
{
    WebViewController *obj = [[WebViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

- (IBAction)textViewSpecialCaseClicked:(id)sender 
{
    TextViewSpecialCaseViewController *obj = [[TextViewSpecialCaseViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
