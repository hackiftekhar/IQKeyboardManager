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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:123];
    if (!field) {
        field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        field.tag = 123;
    }
    field.placeholder = [NSString stringWithFormat:@"Cell %@", @(indexPath.row)];
    [cell.contentView addSubview:field];
    
    return cell;
}

@end
