//
//  TextFieldViewController.h
//  KeyboardTextFieldDemo

#import <UIKit/UIKit.h>

@interface TextFieldViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{    
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;    
    IBOutlet UIBarButtonItem *barButtonDisable;
}

- (IBAction)presentClicked:(id)sender;

-(IBAction)disableKeyboardManager:(UIBarButtonItem*)barButton;

@end
