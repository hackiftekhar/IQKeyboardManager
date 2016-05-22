//
//  BottomBlankSpaceViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 15/10/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "BottomBlankSpaceViewController.h"
#import "IQKeyboardManager.h"

@interface BottomBlankSpaceViewController () <UIPopoverPresentationControllerDelegate>

@end

@implementation BottomBlankSpaceViewController
{
    IBOutlet UISwitch *switchPreventShowingBottomBlankSpace;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    switchPreventShowingBottomBlankSpace.on = [[IQKeyboardManager sharedManager] preventShowingBottomBlankSpace];
}

- (IBAction)preventSwitchAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setPreventShowingBottomBlankSpace:switchPreventShowingBottomBlankSpace.on];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SettingsNavigationController"])
    {
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationPopover;
        segue.destinationViewController.popoverPresentationController.barButtonItem = sender;
        
        CGFloat heightWidth = MAX(CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
        segue.destinationViewController.preferredContentSize = CGSizeMake(heightWidth, heightWidth);
        segue.destinationViewController.popoverPresentationController.delegate = self;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

-(void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    [self.view endEditing:YES];
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
