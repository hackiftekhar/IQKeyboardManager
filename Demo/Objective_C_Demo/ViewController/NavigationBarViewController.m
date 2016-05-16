//
//  NavigationBarViewController.m
//  IQKeyboard

#import "NavigationBarViewController.h"

@interface NavigationBarViewController ()<UITextFieldDelegate>

@end

@implementation NavigationBarViewController
{
    __weak IBOutlet UITextField *textField2;
    IBOutlet UIScrollView *scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    scrollView.contentSize = self.view.bounds.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction)textFieldClicked:(UITextField *)sender
{
//    [[[UIAlertView alloc] initWithTitle:@"Message" message:@"New Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
