//
//  ViewController.m
//  KeyboardTextFieldDemo
//
//  Created by Mohd Iftekhar Qurashi on 11/12/13.
//  Copyright (c) 2013 Canopus. All rights reserved.
//

#import "ScrollViewController.h"
#import "IQKeyboardManager.h"

@implementation ScrollViewController
{
    NSMutableArray *textFields;
    UIView *textFieldView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//	Previous button action.
-(void)previousAction:(UISegmentedControl*)segmentedControl
{
	//Getting index of current textField.
	NSInteger index = [textFields indexOfObject:textFieldView]-1;
	
    for (; index>-1; index--)
    {
        UITextField *textField = [textFields objectAtIndex:index];
        
        if ([textField canBecomeFirstResponder]) 
        {
            [textField becomeFirstResponder];
            break;
        }
    }
}

//	Next button action.
-(void)nextAction:(UISegmentedControl*)segmentedControl
{
	//Getting index of current textField.
	NSInteger index = [textFields indexOfObject:textFieldView]+1;
	
    for (; index<textFields.count; index++)
    {
        UITextField *textField = [textFields objectAtIndex:index];
        
        if ([textField becomeFirstResponder]) 
        {
            break;
        }
    }
}

//	Done button action. Resigning current textField.
-(void)doneAction:(UIBarButtonItem*)barButton
{
    [textFieldView resignFirstResponder];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"UIScrollView Example"];

    textFields = [[NSMutableArray alloc] init];
    [textFields addObject:topTextField];
    [textFields addObject:bottomTextView];
    [textFields addObject:topTextView];
    [textFields addObject:bottomTextField];

    for (UITextField *textField in textFields)
    {
        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
    }

    [scrollViewDemo setContentSize:CGSizeMake(0,321)];
    [scrollViewInsideScrollView setContentSize:CGSizeMake(0,321)];
    [scrollViewOfTableViews setContentSize:CGSizeMake(0,scrollViewOfTableViews.bounds.size.height)];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5,7,135,30)];
        [textField setPlaceholder:identifier];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [cell.contentView addSubview:textField];
        [textField setDelegate:self];
        
        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
        [textFields addObject:textField];
    }

    return cell;
}


- (void)viewDidUnload
{
    simpleTableView = nil;
    scrollViewOfTableViews = nil;
    tableViewInsideScrollView = nil;
    topTextField = nil;
    topTextView = nil;
    bottomTextField = nil;
    bottomTextView = nil;
    scrollViewInsideScrollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textFieldView = textField;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    textFieldView = textView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
