//
//  TextSelectionViewController.m
//  https://github.com/hackiftekhar/IQKeyboardManager
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TextSelectionViewController.h"

@interface TextSelectionViewController ()<UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSArray *data;

@end

@implementation TextSelectionViewController

@synthesize data = _data;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _data = @[@"Hello", @"This is a demo code", @"Issue #56", @"With mutiple cells", @"And some useless text.",
              @"Hello", @"This is a demo code", @"Issue #56", @"With mutiple cells", @"And some useless text.",
              @"Hello", @"This is a demo code", @"Issue #56", @"With mutiple cells", @"And some useless text."];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
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
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5,7,135,30)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textView.backgroundColor = [UIColor clearColor];
        textView.text = _data[indexPath.row];
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        textView.scrollEnabled = NO;
        textView.editable = NO;
        [cell.contentView addSubview:textView];
    }
    
    return cell;
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
