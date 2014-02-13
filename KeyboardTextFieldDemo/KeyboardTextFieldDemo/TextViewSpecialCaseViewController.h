//
//  TextViewSpecialCaseViewController.h
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 01/01/14.
//  Copyright (c) 2014 Canopus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewSpecialCaseViewController : UIViewController
{
    IBOutlet UIButton *buttonPop;
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;
}

- (IBAction)popClicked:(id)sender;
- (IBAction)presentClicked:(id)sender;

-(IBAction)canAdjustTextView:(UIBarButtonItem*)barButton;

@end
