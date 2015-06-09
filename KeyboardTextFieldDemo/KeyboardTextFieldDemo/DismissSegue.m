/**
 DismissSegue.m
 IQKeyboardManager

 Created by Joachim Schuster on 09.06.15.
    Copyright (c) 2015 Iftekhar. All rights reserved.
 */

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController* sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
