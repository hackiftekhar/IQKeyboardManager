//
//  CustomViewController.m
//  IQKeyboardManager
//
//  Created by InfoEnum02 on 21/04/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//

#import "CustomViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQPreviousNextView.h"

@interface CustomViewController ()<UIPopoverPresentationControllerDelegate>
{
    IBOutlet UIView *settingsView;
    IQKeyboardReturnKeyHandler *returnHandler;
    
    IBOutlet UISwitch *switchDisableViewController;
    IBOutlet UISwitch *switchEnableViewController;

    IBOutlet UISwitch *switchDisableToolbar;
    IBOutlet UISwitch *switchEnableToolbar;
    
    IBOutlet UISwitch *switchDisableTouchResign;
    IBOutlet UISwitch *switchEnableTouchResign;
    
    IBOutlet UISwitch *switchAllowPreviousNext;
    
    
    
    IBOutlet NSLayoutConstraint *settingsTopConstraint;
}

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingsView.layer.shadowColor = [[UIColor blackColor] CGColor];
    settingsView.layer.shadowOffset = CGSizeZero;
    settingsView.layer.shadowRadius = 5.0;
    settingsView.layer.shadowOpacity = 0.5;
    
    returnHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    returnHandler.lastTextFieldReturnKeyType = UIReturnKeyDone;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switchDisableViewController.on = ([[[IQKeyboardManager sharedManager] disabledDistanceHandlingClasses] containsObject:[self class]]);
    switchEnableViewController.on = ([[[IQKeyboardManager sharedManager] enabledDistanceHandlingClasses] containsObject:[self class]]);
    
    switchDisableToolbar.on = ([[[IQKeyboardManager sharedManager] disabledToolbarClasses] containsObject:[self class]]);
    switchEnableToolbar.on = ([[[IQKeyboardManager sharedManager] enabledToolbarClasses] containsObject:[self class]]);

    switchDisableTouchResign.on = ([[[IQKeyboardManager sharedManager] disabledTouchResignedClasses] containsObject:[self class]]);
    switchEnableTouchResign.on = ([[[IQKeyboardManager sharedManager] enabledTouchResignedClasses] containsObject:[self class]]);

    switchAllowPreviousNext.on = ([[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] containsObject:[IQPreviousNextView class]]);
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|7<<16 animations:^{
            
            if (settingsTopConstraint.constant != 0)
            {
                settingsTopConstraint.constant = 0;
            }
            else
            {
                settingsTopConstraint.constant = -settingsView.frame.size.height+30;
            }
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }];
    }
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

- (IBAction)enableInViewControllerAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] enabledDistanceHandlingClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] enabledDistanceHandlingClasses] removeObject:[self class]];
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

- (IBAction)enableToolbarAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] enabledToolbarClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] enabledToolbarClasses] removeObject:[self class]];
    }
}

- (IBAction)disableTouchOutsideAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] disabledTouchResignedClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] disabledTouchResignedClasses] removeObject:[self class]];
    }
}

- (IBAction)enableTouchOutsideAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] enabledTouchResignedClasses] addObject:[self class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] enabledTouchResignedClasses] removeObject:[self class]];
    }
}

- (IBAction)allowedPreviousNextAction:(UISwitch *)sender
{
    [self.view endEditing:YES];
    
    if (sender.on)
    {
        [[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] addObject:[IQPreviousNextView class]];
    }
    else
    {
        [[[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses] removeObject:[IQPreviousNextView class]];
    }
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

@end
