//
//  TextFieldViewController.h
//  KeyboardTextFieldDemo

#import <UIKit/UIKit.h>

@interface TextFieldViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{    
    IBOutlet UIButton *buttonPop;
    IBOutlet UIButton *buttonPush;
    IBOutlet UIButton *buttonPresent;    
}
- (IBAction)popClicked:(id)sender;
- (IBAction)presentClicked:(id)sender;

-(IBAction)enableKeyboardManger:(UIBarButtonItem*)barButton;
-(IBAction)disableKeyboardManager:(UIBarButtonItem*)barButton;

@end
