//
//  TextFieldViewController.h
//  KeyboardTextFieldDemo

#import <UIKit/UIKit.h>

@interface TextFieldViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{    
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;    
}

- (IBAction)presentClicked:(id)sender;

@end
