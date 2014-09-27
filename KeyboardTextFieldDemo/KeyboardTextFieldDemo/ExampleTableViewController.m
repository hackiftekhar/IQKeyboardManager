//
//  ExampleTableViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 27/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ExampleTableViewController.h"

@interface ExampleTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ExampleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2)
    {
        return 40;
    }
    else
    {
        return 160;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (indexPath.row %2)
        {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5,5,tableView.frame.size.width-10,30)];
            [textField setPlaceholder:identifier];
            [textField setBorderStyle:UITextBorderStyleRoundedRect];
            [cell.contentView addSubview:textField];
        }
        else
        {
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5,5,tableView.frame.size.width-10,150)];
            textView.text = @"Sample Text";
            [cell.contentView addSubview:textView];
        }
    }
    
    return cell;
}

@end
