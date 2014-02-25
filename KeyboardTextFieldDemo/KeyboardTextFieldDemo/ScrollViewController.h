//
//  ViewController.h
//  KeyboardTextFieldDemo

#import <UIKit/UIKit.h>

@interface ScrollViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    IBOutlet UIScrollView *scrollViewDemo;
    IBOutlet UITableView *simpleTableView;
    IBOutlet UIScrollView *scrollViewOfTableViews;
    IBOutlet UITableView *tableViewInsideScrollView;
    IBOutlet UIScrollView *scrollViewInsideScrollView;
    
    
    IBOutlet UITextField *topTextField;
    IBOutlet UITextField *bottomTextField;
    
    IBOutlet UITextView *topTextView;
    IBOutlet UITextView *bottomTextView;
}
@end
