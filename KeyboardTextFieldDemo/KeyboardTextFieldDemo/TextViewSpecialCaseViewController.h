//
//  TextViewSpecialCaseViewController.h
//  KeyboardTextFieldDemo

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
