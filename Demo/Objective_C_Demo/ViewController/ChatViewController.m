//
//  ChatViewController.m
//  Demo
//
//  Created by IEMacBook01 on 21/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController
{
    NSMutableArray<NSString*> *texts;
    
    IBOutlet UIButton *buttonSend;
    IBOutlet UITextField *inputTextField;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    texts = [[NSMutableArray alloc] initWithObjects:@"This is demo text chat. Enter your message and hit `Send` to add more chat.", nil];
    
    inputTextField.inputAccessoryView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:inputTextField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:inputTextField];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return texts.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatTableViewCell" forIndexPath:indexPath];
    cell.chatLabel.text = texts[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)sendAction:(UIButton *)sender
{
    NSString *text = [inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length != 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:0] inSection:0];

        [texts addObject:text];
        inputTextField.text = @"";
        buttonSend.enabled = NO;
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{

}

-(void)textFieldDidChange:(NSNotification*)notification
{
    NSString *text = [inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    buttonSend.enabled = text.length != 0;
}

@end
