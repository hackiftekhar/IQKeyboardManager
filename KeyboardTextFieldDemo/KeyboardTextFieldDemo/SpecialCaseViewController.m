//
//  SpecialCaseViewController.m
//  KeyboardTextFieldDemo

#import "SpecialCaseViewController.h"

@interface SpecialCaseViewController ()<UISearchBarDelegate>

@end

@implementation SpecialCaseViewController

- (IBAction)showAlertClicked:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"It doesn't affect UIAlertView (Doesn't add IQToolbar on it's textField" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
