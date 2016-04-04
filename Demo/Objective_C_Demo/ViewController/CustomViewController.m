//
//  CustomViewController.m
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 21/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

#import "CustomViewController.h"
#import "IQKeyboardManager.h"
#import "CustomSubclassView.h"
#import "IQKeyboardReturnKeyHandler.h"

@interface CustomViewController ()
{
    IQKeyboardReturnKeyHandler *returnHandler;
    IBOutlet UISwitch *switchDisableViewController;
    IBOutlet UISwitch *switchDisableToolbar;
    IBOutlet UISwitch *switchConsiderPreviousNext;
}

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    returnHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    returnHandler.lastTextFieldReturnKeyType = UIReturnKeyDone;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    switchDisableViewController.on = ([[[IQKeyboardManager sharedManager] disabledDistanceHandlingClasses] containsObject:[self class]]);
    switchDisableToolbar.on = ([[[IQKeyboardManager sharedManager] disabledToolbarClasses] containsObject:[self class]]);
    switchConsiderPreviousNext.on = ([[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] containsObject:[self class]]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disableInViewControllerAction:(UISwitch *)sender
{
    [self.view endEditing:YES];

    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] disabledDistanceHandlingClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] disabledDistanceHandlingClasses] removeObject:[self class]];
    }
}

- (IBAction)disableToolbarAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] disabledToolbarClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] disabledToolbarClasses] removeObject:[self class]];
    }
}

- (IBAction)considerPreviousNextAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] addObject:[CustomSubclassView class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] removeObject:[CustomSubclassView class]];
    }
}

@end
