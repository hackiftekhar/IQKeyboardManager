//
//  BottomBlankSpaceViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 15/10/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "BottomBlankSpaceViewController.h"
#import "IQKeyboardManager.h"

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


@end
