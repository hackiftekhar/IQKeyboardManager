//
//  RefreshLayoutViewController.m
//  Demo
//
//  Created by IEMacBook01 on 21/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import "RefreshLayoutViewController.h"
#import "IQKeyboardManager.h"

@interface RefreshLayoutViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation RefreshLayoutViewController

- (IBAction)stepperChanged:(UIStepper *)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        self.textViewHeightConstraint.constant = sender.value;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)reloadLayoutAction:(UIButton *)sender
{
    [[IQKeyboardManager sharedManager] reloadLayoutIfNeeded];
}

@end
