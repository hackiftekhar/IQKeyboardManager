//
//  SpecialCaseViewController.m
//  KeyboardTextFieldDemo
//
//  Created by Canopus 4 on 26/02/14.
//  Copyright (c) 2014 Canopus. All rights reserved.
//

#import "SpecialCaseViewController.h"

@interface SpecialCaseViewController ()<UISearchBarDelegate>

@end

@implementation SpecialCaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (IBAction)showAlertClicked:(UIButton *)sender
{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"It doesn't add IQToolbar on UIAlertView & UiSearchBar TextField" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
