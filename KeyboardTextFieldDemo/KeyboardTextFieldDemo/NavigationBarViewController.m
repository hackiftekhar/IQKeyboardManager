//
//  NavigationBarViewController.m
//  IQKeyboard

#import "NavigationBarViewController.h"
#import "IQKeyboardReturnKeyHandler.h"

@interface NavigationBarViewController ()

@end

@implementation NavigationBarViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
}

-(void)dealloc
{
    returnKeyHandler = nil;
}

@end
