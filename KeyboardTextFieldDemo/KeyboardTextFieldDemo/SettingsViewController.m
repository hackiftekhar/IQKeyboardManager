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
    
    sectionTitles = @[@"UIKeyboard Handling",
                      @"IQToolbar handling",
                      @"UITextView handling",
                      @"Keyboard appearance overriding",
                      @"Resign first responder handling",
                      @"Sound handling",
                      @"Animation handling"];

    
    keyboardManagerProperties = @[@[@"Enable", @"Keyboard Distance From TextField", @"Prevent Showing Bottom Blank Space"],
                                  @[@"Enable Auto Toolbar",@"Toolbar Manage Behaviour",@"Should Toolbar Uses TextField TintColor",@"Should Show TextField Placeholder",@"Placeholder Font"],
                                  @[@"Can Adjust TextView"],
                                  @[@"Override Keyboard Appearance",@"Keyboard Appearance"],
                                  @[@"Should Resign On Touch Outside"],
                                  @[@"Should Play Input Clicks"],
                                  @[@"Should Adopt Default Keyboard Animation"],
                                  ];

    
    keyboardManagerPropertyDetails = @[@[@"Enable/Disable IQKeyboardManager",@"Set keyboard distance from textField",@"Prevent to show blank space between UIKeyboard and View"],
                                       @[@"Automatic add the IQToolbar on UIKeyboard",@"AutoToolbar previous/next button managing behaviour",@"Uses textField's tintColor property for IQToolbar",@"Add the textField's placeholder text on IQToolbar",@"UIFont for IQToolbar placeholder text"],
                                       @[@"Adjust textView's frame when it is too big in height"],
                                       @[@"Override the keyboardAppearance for all UITextField/UITextView",@"All the UITextField keyboardAppearance is set using this property"],
                                       @[@"Resigns Keyboard on touching outside of UITextField/View"],
                                       @[@"plays inputClick sound on next/previous/done click"],
                                       @[@"uses keyboard default animation curve style to move view"]];
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
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:sender.on];
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
            return ([[IQKeyboardManager sharedManager] isEnabled] == NO)  ?  1:  [keyboardManagerProperties[section] count];
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
                return [keyboardManagerProperties[section] count];
            }
        }
            break;
        case 3:
        {
            return ([[IQKeyboardManager sharedManager] overrideKeyboardAppearance] == NO)  ?  1:  [keyboardManagerProperties[section] count];
        }
            break;
        case 2:
        case 4:
        case 5:
        case 6:
            return [keyboardManagerProperties[section] count];
            break;

        default:
            return 0;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitles[section];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnabled];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(enableAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    StepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([StepperTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.stepper.value = [[IQKeyboardManager sharedManager] keyboardDistanceFromTextField];
                    cell.labelStepperValue.text = [NSString stringWithFormat:@"%.0f",[[IQKeyboardManager sharedManager] keyboardDistanceFromTextField]];
                    [cell.stepper removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.stepper addTarget:self action:@selector(keyboardDistanceFromTextFieldAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 2:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnableAutoToolbar];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(enableAutoToolbarAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    return cell;
                }
                    break;
                case 2:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldToolbarUsesTextFieldTintColor];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldToolbarUsesTextFieldTintColorAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 3:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldShowTextFieldPlaceholder];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldShowTextFieldPlaceholder:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 4:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] canAdjustTextView];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(canAdjustTextViewAction:) forControlEvents:UIControlEventValueChanged];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] overrideKeyboardAppearance];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(overrideKeyboardAppearanceAction:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 1:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
            controller.options = @[@"IQAutoToolbar By Subviews",@"IQAutoToolbar By Tag",@"IQAutoToolbar By Position"];
            controller.selectedIndex = [[IQKeyboardManager sharedManager] toolbarManageBehaviour];
        }
        else if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 4)
        {
            controller.title = @"Fonts";
            
            controller.options = @[@"Bold System Font",@"Italic system font",@"Regular"];
            
            NSArray *fonts = @[[UIFont boldSystemFontOfSize:12.0],[UIFont italicSystemFontOfSize:12],[UIFont systemFontOfSize:12]];
            
            UIFont *placeholderFont = [[IQKeyboardManager sharedManager] placeholderFont];
            
            if ([fonts containsObject:placeholderFont])
            {
                controller.selectedIndex = [fonts indexOfObject:placeholderFont];
            }
        }
        else if (selectedIndexPathForOptions.section == 3 && selectedIndexPathForOptions.row == 1)
        {
            controller.title = @"Keyboard Appearance";
            controller.options = @[@"UIKeyboardAppearance Default",@"UIKeyboardAppearance Dark",@"UIKeyboardAppearance Light"];
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
        NSArray *fonts = @[[UIFont boldSystemFontOfSize:12.0],[UIFont italicSystemFontOfSize:12],[UIFont systemFontOfSize:12]];
        
        [[IQKeyboardManager sharedManager] setPlaceholderFont:fonts[index]];
    }
    else if (selectedIndexPathForOptions.section == 3 && selectedIndexPathForOptions.row == 1)
    {
        [[IQKeyboardManager sharedManager] setKeyboardAppearance:index];
    }
}

@end
