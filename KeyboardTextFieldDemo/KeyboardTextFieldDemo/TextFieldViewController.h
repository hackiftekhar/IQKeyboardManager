//
//  TextFieldViewController.h
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 12/12/13.
//  Copyright (c) 2013 Canopus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{    
    NSInteger selectedTextFieldTag;
    
    IBOutlet UIButton *buttonPop;
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;
    
}
- (IBAction)popClicked:(id)sender;
- (IBAction)pushClicked:(id)sender;
- (IBAction)presentClicked:(id)sender;

@end
