//
//  ViewController.m
//  KeyboardTextFieldDemo

#import "ViewController.h"
#import "UIView+IQKeyboardToolbar.h"

@interface ViewController ()
{
    IBOutlet UITextField *cancelTextField;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [cancelTextField addCancelDoneOnKeyboardWithTarget:cancelTextField cancelAction:@selector(resignFirstResponder) doneAction:@selector(resignFirstResponder) shouldShowPlaceholder:YES];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
