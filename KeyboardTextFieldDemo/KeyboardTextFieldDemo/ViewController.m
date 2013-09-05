//
//  ViewController.m
//
//  Created by Mohd Iftekhar Qurashi on 01/07/13.


#import "ViewController.h"
#import "IQKeyBoardManager.h"

@implementation ViewController

#define numTextFields 11

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"IQKeyboard"];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Enable" style:UIBarButtonItemStyleBordered target:self action:@selector(enableKeyboardManger:)]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Desable" style:UIBarButtonItemStyleBordered target:self action:@selector(disableKeyboardManager:)]];
    
    for (int i=0; i<numTextFields; i++)
    {        
        UITextField *textField = (UITextField*)[self.view viewWithTag:100+i];
        textField.delegate = self;
        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [self.view.window.rootViewController.view setFrame:[[UIScreen mainScreen] applicationFrame]];
}

-(void)enableKeyboardManger:(UIBarButtonItem*)barButton
{
    [IQKeyBoardManager enableKeyboardManger];
}

-(void)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    [IQKeyBoardManager disableKeyboardManager];
}


-(void)previousClicked:(UISegmentedControl*)segmentedControl
{
    [(UITextField*)[self.view viewWithTag:selectedTextFieldTag-1] becomeFirstResponder];
}

-(void)nextClicked:(UISegmentedControl*)segmentedControl
{
    [(UITextField*)[self.view viewWithTag:selectedTextFieldTag+1] becomeFirstResponder];
}

-(void)doneClicked:(UIBarButtonItem*)barButton
{
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectedTextFieldTag = textField.tag;

    if (textField.tag == 100)
    {
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:NO forSegmentAtIndex:0];
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:YES forSegmentAtIndex:1];
    }
    else if(textField.tag == (100+(numTextFields-1)))
    {
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:YES forSegmentAtIndex:0];
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:NO forSegmentAtIndex:1];
    }
    else
    {
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:YES forSegmentAtIndex:0];
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:YES forSegmentAtIndex:1];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}

@end
