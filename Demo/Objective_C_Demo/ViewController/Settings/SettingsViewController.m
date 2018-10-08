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
#import "ColorTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "ImageSwitchTableViewCell.h"

@interface SettingsViewController ()<OptionsViewControllerDelegate,ColorPickerTextFieldDelegate>

@end

@implementation SettingsViewController
{
    NSArray<NSString*> *sectionTitles;
    NSArray<NSArray*> *keyboardManagerProperties;
    NSArray<NSArray*> *keyboardManagerPropertyDetails;
    
    NSIndexPath *selectedIndexPathForOptions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sectionTitles = @[@"UIKeyboard handling",
                      @"IQToolbar handling",
                      @"UIKeyboard appearance overriding",
                      @"Resign first responder handling",
                      @"UISound handling",
                      @"IQKeyboardManager Debug"];

    
    keyboardManagerProperties = @[@[@"Enable", @"Keyboard Distance From TextField"],
                                  @[@"Enable AutoToolbar",@"Toolbar Manage Behaviour",@"Should Toolbar Uses TextField TintColor",@"Should Show TextField Placeholder",@"Placeholder Font",@"Toolbar Tint Color",@"Toolbar Done BarButtonItem Image",@"Toolbar Done Button Text"],
                                  @[@"Override Keyboard Appearance",@"UIKeyboard Appearance"],
                                  @[@"Should Resign On Touch Outside"],
                                  @[@"Should Play Input Clicks"],
                                  @[@"Debugging logs in Console"]];

    
    keyboardManagerPropertyDetails = @[@[@"Enable/Disable IQKeyboardManager",@"Set keyboard distance from textField"],
                                       @[@"Automatic add the IQToolbar on UIKeyboard",@"AutoToolbar previous/next button managing behaviour",@"Uses textField's tintColor property for IQToolbar",@"Add the textField's placeholder text on IQToolbar",@"UIFont for IQToolbar placeholder text",@"Override toolbar tintColor property",@"Replace toolbar done button text with provided image",@"Override toolbar done button text"],
                                       @[@"Override the keyboardAppearance for all UITextField/UITextView",@"All the UITextField keyboardAppearance is set using this property"],
                                       @[@"Resigns Keyboard on touching outside of UITextField/View"],
                                       @[@"Plays inputClick sound on next/previous/done click"],
                                       @[@"Setting enableDebugging to YES/No to turn on/off debugging mode"]];
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

- (void)shouldShowToolbarPlaceholder:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setShouldShowToolbarPlaceholder:sender.on];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)toolbarDoneBarButtonItemImage:(UISwitch *)sender
{
    if (sender.on)
    {
        [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemImage:[UIImage imageNamed:@"IQButtonBarArrowDown"]];
    }
    else
    {
        [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemImage:nil];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}


/**  "Keyboard appearance overriding    */

- (void)overrideKeyboardAppearanceAction:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setOverrideKeyboardAppearance:sender.on];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
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

/**  Debugging         */

- (void)enableDebugging:(UISwitch *)sender
{
    [[IQKeyboardManager sharedManager] setEnableDebugging:sender.on];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

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
            else if ([[IQKeyboardManager sharedManager] shouldShowToolbarPlaceholder] == NO)
            {
                return 4;
            }
            else
            {
                return [keyboardManagerProperties[section] count];
            }
        }
            break;
        case 2:
        {
            return ([[IQKeyboardManager sharedManager] overrideKeyboardAppearance] == NO)  ?  1:  [keyboardManagerProperties[section] count];
        }
            break;
        case 3:
        case 4:
        case 5:
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
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
                    StepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([StepperTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.stepper.value = [[IQKeyboardManager sharedManager] keyboardDistanceFromTextField];
                    cell.labelStepperValue.text = [NSString stringWithFormat:@"%.0f",[[IQKeyboardManager sharedManager] keyboardDistanceFromTextField]];
                    [cell.stepper removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.stepper addTarget:self action:@selector(keyboardDistanceFromTextFieldAction:) forControlEvents:UIControlEventValueChanged];
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
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    return cell;
                }
                    break;
                case 2:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
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
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldShowToolbarPlaceholder];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(shouldShowToolbarPlaceholder:) forControlEvents:UIControlEventValueChanged];
                    return cell;
                }
                    break;
                case 4:
                {
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    return cell;
                }
                    break;
                case 5:
                {
                    ColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ColorTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.colorPickerTextField.selectedColor = [[IQKeyboardManager sharedManager] toolbarTintColor];
                    cell.colorPickerTextField.tag = 15;
                    cell.colorPickerTextField.delegate = self;
                    return cell;
                }
                    break;
                case 6:
                {
                    ImageSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ImageSwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.arrowImageView.image = [[IQKeyboardManager sharedManager] toolbarDoneBarButtonItemImage];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] toolbarDoneBarButtonItemImage] != nil;
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(toolbarDoneBarButtonItemImage:) forControlEvents:UIControlEventValueChanged];

                    return cell;
                }
                    break;
                case 7:
                {
                    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TextFieldTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.textField.text = [[IQKeyboardManager sharedManager] toolbarDoneBarButtonItemText];
                    cell.textField.tag = 17;
                    cell.textField.delegate = self;
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
                    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
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
        case 4:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
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
        case 5:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
                    cell.switchEnable.enabled = YES;
                    cell.labelTitle.text = keyboardManagerProperties[indexPath.section][indexPath.row];
                    cell.labelSubtitle.text = keyboardManagerPropertyDetails[indexPath.section][indexPath.row];
                    cell.switchEnable.on = [[IQKeyboardManager sharedManager] enableDebugging];
                    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    [cell.switchEnable addTarget:self action:@selector(enableDebugging:) forControlEvents:UIControlEventValueChanged];
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

-(void)colorPickerTextField:(ColorPickerTextField*)textField selectedColorAttributes:(NSDictionary*)colorAttributes
{
    if (textField.tag == 15)
    {
        UIColor *color = colorAttributes[@"color"];
        
        if ([color isEqual:[UIColor clearColor]])
        {
            [[IQKeyboardManager sharedManager] setToolbarTintColor:nil];
        }
        else
        {
            [[IQKeyboardManager sharedManager] setToolbarTintColor:colorAttributes[@"color"]];
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 17)
    {
        [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:[textField.text length]?textField.text:nil];
    }
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
        else if (selectedIndexPathForOptions.section == 2 && selectedIndexPathForOptions.row == 1)
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
    else if (selectedIndexPathForOptions.section == 2 && selectedIndexPathForOptions.row == 1)
    {
        [[IQKeyboardManager sharedManager] setKeyboardAppearance:index];
    }
}

@end
