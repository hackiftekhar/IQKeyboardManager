//
//  TextViewSpecialCaseViewController.h
//  KeyboardTextFieldDemo

#import <UIKit/UIKit.h>

@interface TextViewSpecialCaseViewController : UIViewController
{
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;
    IBOutlet UIBarButtonItem *barButtonAdjust;
}

- (IBAction)presentClicked:(id)sender;

-(IBAction)canAdjustTextView:(UIBarButtonItem*)barButton;

@end
