//
//  CustomViewController.m
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CustomViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <IQKeyboardManager/IQKeyboardReturnKeyHandler.h>
#import <IQKeyboardManager/IQPreviousNextView.h>

@interface CustomViewController ()<UIPopoverPresentationControllerDelegate>
{
    IQKeyboardReturnKeyHandler *returnHandler;
    
    IBOutlet UISwitch *switchDisableViewController;
    IBOutlet UISwitch *switchEnableViewController;

    IBOutlet UISwitch *switchDisableToolbar;
    IBOutlet UISwitch *switchEnableToolbar;
    
    IBOutlet UISwitch *switchDisableTouchResign;
    IBOutlet UISwitch *switchEnableTouchResign;
    
    IBOutlet UISwitch *switchAllowPreviousNext;
}

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *settingsTopConstraint;
@property(nonatomic, strong) IBOutlet UIView *settingsView;

@end

@implementation CustomViewController

-(void)dealloc
{
    returnHandler = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.settingsView.layer.shadowOffset = CGSizeZero;
    self.settingsView.layer.shadowRadius = 5.0;
    self.settingsView.layer.shadowOpacity = 0.5;
    
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
        __weak __typeof__(self) weakSelf = self;

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|7<<16 animations:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;

            if (strongSelf.settingsTopConstraint.constant != 0)
            {
                strongSelf.settingsTopConstraint.constant = 0;
            }
            else
            {
                strongSelf.settingsTopConstraint.constant = -strongSelf.settingsView.frame.size.height+30;
            }
            
            [strongSelf.view setNeedsLayout];
            [strongSelf.view layoutIfNeeded];

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
