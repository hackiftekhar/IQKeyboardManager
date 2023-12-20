//
//  OptionsViewController.m
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

#import "OptionsViewController.h"
#import "OptionTableViewCell.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

@synthesize delegate, options, selectedIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OptionTableViewCell class])];

    cell.labelOption.text = (self.options)[indexPath.row];

    cell.accessoryType = (indexPath.row == self.selectedIndex)  ? UITableViewCellAccessoryCheckmark    :   UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndex = indexPath.row;
    
    if ([self.delegate respondsToSelector:@selector(optionsViewController:didSelectIndex:)])
    {
        [self.delegate optionsViewController:self didSelectIndex:indexPath.row];
    }
    
    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
}

@end
