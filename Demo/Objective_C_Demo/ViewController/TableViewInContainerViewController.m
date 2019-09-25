//
//  TableViewInContainerViewController.m
//  IQKeyboard
//
//  Created by Jeffrey Sambells on 2014-12-05.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "TableViewInContainerViewController.h"

@interface TableViewInContainerViewController ()<UIPopoverPresentationControllerDelegate>

@end

@implementation TableViewInContainerViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 40;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
//    view.backgroundColor = [UIColor colorWithRed:0.9 green:1 blue:1 alpha:1];
//   
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, 280, 30)];
//    textField.placeholder = [NSString stringWithFormat:@"Header %ld",(long)section];
//    [view addSubview:textField];
//    return view;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
//    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.9 alpha:1];
//    
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, 280, 30)];
//    textField.placeholder = [NSString stringWithFormat:@"Footer %ld",(long)section];
//    [view addSubview:textField];
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10,0,cell.contentView.frame.size.width-20,33)];
        textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        textField.center = cell.contentView.center;
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        textField.tag = 123;
        [cell.contentView addSubview:textField];
    }
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:123];
    textField.placeholder = [NSString stringWithFormat:@"Cell %@",@(indexPath.row)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SettingsNavigationController"])
    {
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationPopover;
        segue.destinationViewController.popoverPresentationController.barButtonItem = sender;
        
        CGFloat heightWidth = MAX(CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
        segue.destinationViewController.preferredContentSize = CGSizeMake(heightWidth, heightWidth);
        segue.destinationViewController.popoverPresentationController.delegate = self;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

-(void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
