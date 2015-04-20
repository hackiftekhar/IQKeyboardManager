//
//  TableViewInContainerViewController.m
//  IQKeyboard
//
//  Created by Jeffrey Sambells on 2014-12-05.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "TableViewInContainerViewController.h"

@implementation TableViewInContainerViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

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
    textField.placeholder = [NSString stringWithFormat:@"Cell %@",[NSNumber numberWithInteger:indexPath.row]];
    
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
