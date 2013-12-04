//
//  ViewController.h
//
//  Created by Mohd Iftekhar Qurashi on 01/07/13.


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
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
