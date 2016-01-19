//
//  SettingsViewController.m
//  IQKeyboard
//
//  Created by Iftekhar on 27/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "SettingsViewController.h"
#import "OptionsViewController.h"

#import "IQKeyboardManager.h"

#import "SwitchTableViewCell.h"
#import "StepperTableViewCell.h"
#import "NavigationTableViewCell.h"


@interface SettingsViewController ()<OptionsViewControllerDelegate>

@end

@implementation SettingsViewController
{
    NSArray *sectionTitles;
    NSArray *keyboardManagerProperties;
    NSArray *keyboardManagerPropertyDetails;
    
    NSIndexPath *selectedIndexPathForOptions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sectionTitles = [NSArray arrayWithObjects:@"UIKeyboard handling",
                     @"IQToolbar handling",
                     @"UITextView handling",
                     @"UIKeyboard appearance overriding",
                     @"Resign first responder handling",
                     @"UISound handling",
                     @"UIAnimation handling",nil];

    
    keyboardManagerProperties = [NSArray arrayWithObjects:
                                 [NSArray arrayWithObjects:@"Enable", @"Keyboard Distance From TextField", @"Prevent Showing Bottom Blank Space",nil],
                                 [NSArray arrayWithObjects:@"Enable AutoToolbar",@"Toolbar Manage Behaviour",@"Should Toolbar Uses TextField TintColor",@"Should Show TextField Placeholder",@"Placeholder Font",nil],
                                 [NSArray arrayWithObjects:@"Can Adjust TextView",@"Should Fix TextView Clip",nil],
                                 [NSArray arrayWithObjects:@"Override Keyboard Appearance",@"UIKeyboard Appearance",nil],
                                 [NSArray arrayWithObjects:@"Should Resign On Touch Outside",nil],
                                 [NSArray arrayWithObjects:@"Should Play Input Clicks",nil],
                                 [NSArray arrayWithObjects:@"Should Adopt Default Keyboard Animation",nil],nil];

    
    keyboardManagerPropertyDetails = [NSArray arrayWithObjects:
                                      [NSArray arrayWithObjects:@"Enable/Disable IQKeyboardManager",@"Set keyboard distance from textField",@"Prevent to show blank space between UIKeyboard and View",nil],
                                       [NSArray arrayWithObjects:@"Automatic add the IQToolbar on UIKeyboard",@"AutoToolbar previous/next button managing behaviour",@"Uses textField's tintColor property for IQToolbar",@"Add the textField's placeholder text on IQToolbar",@"UIFont for IQToolbar placeholder text",nil],
                                       [NSArray arrayWithObjects:@"Adjust textView's frame when it is too big in height",@"Adjust textView's contentInset to fix a bug",nil],
                                       [NSArray arrayWithObjects:@"Override the keyboardAppearance for all UITextField/UITextView",@"All the UITextField keyboardAppearance is set using this property",nil],
                                      [NSArray arrayWithObjects:@"Resigns Keyboard on touching outside of UITextField/View",nil],
                                       [NSArray arrayWithObjects:@"Plays inputClick sound on next/previous/done click",nil],
                                       [NSArray arrayWithObjects:@"Uses keyboard default animation curve style to move view",nil],nil];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**  UIKeyboard Handling    */

- (void)enableAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setEnable:sender.on];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)keyboardDistanceFromTextFieldAction:(UIStepper *)sender
{
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:sender.value];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)preventShowingBottomBlankSpaceAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setPreventShowingBottomBlankSpace:sender.on];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

/**  IQToolbar handling     */

- (void)enableAutoToolbarAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:sender.on];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shouldToolbarUsesTextFieldTintColorAction:(UISwitch *)sender
{
#ifdef NSFoundationVersionNumber_iOS_6_1
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:sender.on];
#endif
}

- (void)shouldShowTextFieldPlaceholder:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:sender.on];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

/**  UITextView handling    */

- (void)canAdjustTextViewAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setCanAdjustTextView:sender.on];
}

- (void)shouldFixTextViewClipwAction:(UISwitch *)sender
{
#ifdef NSFoundationVersionNumber_iOS_6_1
    [[IQKeyboardManager sharedManager] setShouldFixTextViewClip:sender.on];
#endif
}

/**  "Keyboard appearance overriding    */

- (void)overrideKeyboardAppearanceAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setOverrideKeyboardAppearance:sender.on];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}

/**  Resign first responder handling    */

- (void)shouldResignOnTouchOutsideAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:sender.on];
}

/**  Sound handling         */

- (void)shouldPlayInputClicksAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setShouldPlayInputClicks:sender.on];
}

/**  Animation handling     */

- (void)shouldAdoptDefaultKeyboardAnimation:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setShouldAdoptDefaultKeyboardAnimation:sender.on];
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return ([[IQKeyboardManager sharedManager] isEnabled] == NO)  ?  1:  [[keyboardManagerProperties objectAtIndex:section] count];
        }
            break;
        case 1:
        {
            if ([[IQKeyboardManager sharedManager] isEnableAutoToolbar] == NO)
            {
                return 1;
            }
            else if ([[IQKeyboardManager sharedManager] shouldShowTextFieldPlaceholder] == NO)
            {
                return 4;
            }
            else
            {
                return [[keyboardManagerProperties objectAtIndex:section] count];
            }
        }
            break;
        case 3:
        {
            return ([[IQKeyboardManager sharedManager] overrideKeyboardAppearance] == NO)  ?  1:  [[keyboardManagerProperties objectAtIndex:section] count];
        }
            break;
        case 2:
        case 4:
        case 5:
        case 6:
            return [[keyboardManagerProperties objectAtIndex:section] count];
            break;

        default:
            return 0;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnabled];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(enableAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    StepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([StepperTableViewCell class])];
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.stepper.value = [[IQKeyboardManager sharedManager] keyboardDistanceFromTextField];
                    cell.labelStepperValue.text = [NSString stringWithFormat:@"%.0f",[[IQKeyboardManager sharedManager] keyboardDistanceFromTextField]];
                    [cell.stepper removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.stepper addTarget:self action:@selector(keyboardDistanceFromTextFieldAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 2:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] preventShowingBottomBlankSpace];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(preventShowingBottomBlankSpaceAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnableAutoToolbar];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(enableAutoToolbarAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    return cell;
                }
                    break;
                case 2:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    
#ifdef NSFoundationVersionNumber_iOS_6_1
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldToolbarUsesTextFieldTintColor];
#else
                    cell.switchEnable.on = NO;
                    cell.switchEnable.enabled = NO;
#endif
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldToolbarUsesTextFieldTintColorAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 3:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldShowTextFieldPlaceholder];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldShowTextFieldPlaceholder:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 4:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] canAdjustTextView];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(canAdjustTextViewAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    
#ifdef NSFoundationVersionNumber_iOS_6_1
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldFixTextViewClip];
#else
                    cell.switchEnable.on = NO;
                    cell.switchEnable.enabled = NO;
#endif
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldFixTextViewClipwAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] overrideKeyboardAppearance];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(overrideKeyboardAppearanceAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 4:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldResignOnTouchOutside];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldResignOnTouchOutsideAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 5:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldPlayInputClicks];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldPlayInputClicksAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
            }
        }
            break;
        case 6:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldAdoptDefaultKeyboardAnimation];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldAdoptDefaultKeyboardAnimation:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
            }
        }
            break;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([OptionsViewController class])])
    {
        OptionsViewController *controller = segue.destinationViewController;
        
        controller.delegate = self;

        UITableViewCell *cell = (UITableViewCell*)sender;
        selectedIndexPathForOptions = [self.tableView indexPathForCell:cell];

        if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 1)
        {
            controller.title = @"Toolbar Manage Behaviour";
            controller.options = [NSArray arrayWithObjects:@"IQAutoToolbar By Subviews",@"IQAutoToolbar By Tag",@"IQAutoToolbar By Position",nil];
            controller.selectedIndex = [[IQKeyboardManager sharedManager] toolbarManageBehaviour];
        }
        else if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 4)
        {
            controller.title = @"Fonts";
            
            controller.options = [NSArray arrayWithObjects:@"Bold System Font",@"Italic system font",@"Regular",nil];
            
            NSArray *fonts = [NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:12.0],[UIFont italicSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
            
            UIFont *placeholderFont = [[IQKeyboardManager sharedManager] placeholderFont];
            
            if ([fonts containsObject:placeholderFont])
            {
                controller.selectedIndex = [fonts indexOfObject:placeholderFont];
            }
        }
        else if (selectedIndexPathForOptions.section == 3 && selectedIndexPathForOptions.row == 1)
        {
            controller.title = @"Keyboard Appearance";
            controller.options = [NSArray arrayWithObjects:@"UIKeyboardAppearance Default",@"UIKeyboardAppearance Dark",@"UIKeyboardAppearance Light",nil];
            controller.selectedIndex = [[IQKeyboardManager sharedManager] keyboardAppearance];
        }
    }
}

-(void)optionsViewController:(OptionsViewController*)controller didSelectIndex:(NSInteger)index
{
    if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 1)
    {
        [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:(IQAutoToolbarManageBehaviour)index];
    }
    else if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 4)
    {
        NSArray *fonts = [NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:12.0],[UIFont italicSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
        
        [[IQKeyboardManager sharedManager] setPlaceholderFont:[fonts objectAtIndex:index]];
    }
    else if (selectedIndexPathForOptions.section == 3 && selectedIndexPathForOptions.row == 1)
    {
        [[IQKeyboardManager sharedManager] setKeyboardAppearance:index];
    }
}

@end
