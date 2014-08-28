//
//  ViewController.m
//  KeyboardTextFieldDemo

#import "ScrollViewController.h"
#import "IQKeyboardReturnKeyHandler.h"

@implementation ScrollViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];

    [scrollViewDemo setContentSize:CGSizeMake(0,321)];
    [scrollViewInsideScrollView setContentSize:CGSizeMake(0,321)];
//    [scrollViewOfTableViews setContentSize:CGSizeMake(0,scrollViewOfTableViews.bounds.size.height)];
}

-(void)dealloc
{
    returnKeyHandler = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5,7,135,30)];
        [textField setPlaceholder:identifier];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [cell.contentView addSubview:textField];
    }

    return cell;
}

@end
