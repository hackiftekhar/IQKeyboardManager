//
//  ViewController.m
//
//  Created by Mohd Iftekhar Qurashi on 01/07/13.


#import "ViewController.h"
#import "IQKeyBoardManager.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [textField1 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField3 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField4 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField5 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField6 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField7 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField8 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField9 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField10 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    [textField11 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousClicked:) nextAction:@selector(nextClicked:) doneAction:@selector(doneClicked:)];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)previousClicked:(UISegmentedControl*)segmentedControl
{
    if ([textField11 isFirstResponder])      [textField10 becomeFirstResponder];
    else if([textField10 isFirstResponder])  [textField9 becomeFirstResponder];
    else if([textField9 isFirstResponder])  [textField8 becomeFirstResponder];
    else if([textField8 isFirstResponder])  [textField7 becomeFirstResponder];
    else if([textField7 isFirstResponder])  [textField6 becomeFirstResponder];
    else if([textField6 isFirstResponder])  [textField5 becomeFirstResponder];
    else if([textField5 isFirstResponder])  [textField4 becomeFirstResponder];
    else if([textField4 isFirstResponder])  [textField3 becomeFirstResponder];
    else if([textField3 isFirstResponder])  [textField2 becomeFirstResponder];
    else if([textField2 isFirstResponder])  [textField1 becomeFirstResponder];
}

-(void)nextClicked:(UISegmentedControl*)segmentedControl
{
    if ([textField1 isFirstResponder])      [textField2 becomeFirstResponder];
    else if([textField2 isFirstResponder])  [textField3 becomeFirstResponder];
    else if([textField3 isFirstResponder])  [textField4 becomeFirstResponder];
    else if([textField4 isFirstResponder])  [textField5 becomeFirstResponder];
    else if([textField5 isFirstResponder])  [textField6 becomeFirstResponder];
    else if([textField6 isFirstResponder])  [textField7 becomeFirstResponder];
    else if([textField7 isFirstResponder])  [textField8 becomeFirstResponder];
    else if([textField8 isFirstResponder])  [textField9 becomeFirstResponder];
    else if([textField9 isFirstResponder])  [textField10 becomeFirstResponder];
    else if([textField10 isFirstResponder])  [textField11 becomeFirstResponder];
}

-(void)doneClicked:(UIBarButtonItem*)barButton
{
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == textField1)
    {
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:NO forSegmentAtIndex:0];
        [(UISegmentedControl*)[(UIBarButtonItem*)[[(UIToolbar*)textField.inputAccessoryView items] objectAtIndex:0] customView] setEnabled:YES forSegmentAtIndex:1];
    }
    else if(textField == textField11)
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

- (void)viewDidUnload
{
    textField1 = nil;
    textField2 = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
