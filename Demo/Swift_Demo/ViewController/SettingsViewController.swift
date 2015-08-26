//
//  SettingsViewController.swift
//  Demo
//
//  Created by Iftekhar on 26/08/15.
//  Copyright (c) 2015 Iftekhar. All rights reserved.
//


class SettingsViewController: UITableViewController, OptionsViewControllerDelegate {

    let sectionTitles = [
        "UIKeyboard handling",
        "IQToolbar handling",
        "UITextView handling",
        "UIKeyboard appearance overriding",
        "Resign first responder handling",
        "UIScrollView handling",
        "UISound handling",
        "UIAnimation handling"]
    
    let keyboardManagerProperties = [
        ["Enable", "Keyboard Distance From TextField", "Prevent Showing Bottom Blank Space"],
        ["Enable AutoToolbar","Toolbar Manage Behaviour","Should Toolbar Uses TextField TintColor","Should Show TextField Placeholder","Placeholder Font"],
        ["Can Adjust TextView","Should Fix TextView Clip"],
        ["Override Keyboard Appearance","UIKeyboard Appearance"],
        ["Should Resign On Touch Outside"],
        ["Should Restore ScrollView ContentOffset"],
        ["Should Play Input Clicks"],
        ["Should Adopt Default Keyboard Animation"]]
    
    let keyboardManagerPropertyDetails = [
        ["Enable/Disable IQKeyboardManager","Set keyboard distance from textField","Prevent to show blank space between UIKeyboard and View"],
        ["Automatic add the IQToolbar on UIKeyboard","AutoToolbar previous/next button managing behaviour","Uses textField's tintColor property for IQToolbar","Add the textField's placeholder text on IQToolbar","UIFont for IQToolbar placeholder text"],
        ["Adjust textView's frame when it is too big in height","Adjust textView's contentInset to fix a bug"],
        ["Override the keyboardAppearance for all UITextField/UITextView","All the UITextField keyboardAppearance is set using this property"],
        ["Resigns Keyboard on touching outside of UITextField/View"],
        ["Restore scrollViewContentOffset when resigning from scrollView."],
        ["Plays inputClick sound on next/previous/done click"],
        ["Uses keyboard default animation curve style to move view"]]
        
    var selectedIndexPathForOptions : NSIndexPath?
    
    
    @IBAction func doneAction (sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**  UIKeyboard Handling    */
    func enableAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enable = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func keyboardDistanceFromTextFieldAction (sender: UIStepper) {
        
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = CGFloat(sender.value)
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func preventShowingBottomBlankSpaceAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  IQToolbar handling     */
    func enableAutoToolbarAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func shouldToolbarUsesTextFieldTintColorAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = sender.on
    }
    
    func shouldShowTextFieldPlaceholder (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  UITextView handling    */
    func canAdjustTextViewAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().canAdjustTextView = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func shouldFixTextViewClipAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldFixTextViewClip = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  "Keyboard appearance overriding    */
    func overrideKeyboardAppearanceAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().overrideKeyboardAppearance = sender.on
        
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**  Resign first responder handling    */
    func shouldResignOnTouchOutsideAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = sender.on
    }
    
    /**  UIScrollView handling    */
    func shouldRestoreScrollViewContentOffsetAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldRestoreScrollViewContentOffset = sender.on
    }
    
    /**  Sound handling         */
    func shouldPlayInputClicksAction (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = sender.on
    }
    
    /**  Animation handling     */
    func shouldAdoptDefaultKeyboardAnimation (sender: UISwitch) {
        
        IQKeyboardManager.sharedManager().shouldAdoptDefaultKeyboardAnimation = sender.on
    }
    
    
    
//    #pragma mark - Table view data source
//    
//    -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//    {
//    return sectionTitles.count;
//    }
//    
//    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//    {
//    switch (section)
//    {
//    case 0:
//    {
//    return ([[IQKeyboardManager sharedManager] isEnabled] == NO)  ?  1:  [[keyboardManagerProperties objectAtIndex:section] count];
//    }
//    break;
//    case 1:
//    {
//    if ([[IQKeyboardManager sharedManager] isEnableAutoToolbar] == NO)
//    {
//    return 1;
//    }
//    else if ([[IQKeyboardManager sharedManager] shouldShowTextFieldPlaceholder] == NO)
//    {
//    return 4;
//    }
//    else
//    {
//    return [[keyboardManagerProperties objectAtIndex:section] count];
//    }
//    }
//    break;
//    case 3:
//    {
//    return ([[IQKeyboardManager sharedManager] overrideKeyboardAppearance] == NO)  ?  1:  [[keyboardManagerProperties objectAtIndex:section] count];
//    }
//    break;
//    case 2:
//    case 4:
//    case 5:
//    case 6:
//    case 7:
//    return [[keyboardManagerProperties objectAtIndex:section] count];
//    break;
//    
//    default:
//    return 0;
//    break;
//    }
//    }
//    
//    -(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//    {
//    return [sectionTitles objectAtIndex:section];
//    }
//    
//    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    switch (indexPath.section)
//    {
//    case 0:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnabled];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(enableAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 1:
//    {
//    StepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([StepperTableViewCell class])];
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.stepper.value = [[IQKeyboardManager sharedManager] keyboardDistanceFromTextField];
//    cell.labelStepperValue.text = [NSString stringWithFormat:@"%.0f",[[IQKeyboardManager sharedManager] keyboardDistanceFromTextField]];
//    [cell.stepper removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.stepper addTarget:self action:@selector(keyboardDistanceFromTextFieldAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 2:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] preventShowingBottomBlankSpace];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(preventShowingBottomBlankSpaceAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 1:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] isEnableAutoToolbar];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(enableAutoToolbarAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 1:
//    {
//    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    return cell;
//    }
//    break;
//    case 2:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    #ifdef NSFoundationVersionNumber_iOS_6_1
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldToolbarUsesTextFieldTintColor];
//    #else
//    cell.switchEnable.on = NO;
//    cell.switchEnable.enabled = NO;
//    #endif
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldToolbarUsesTextFieldTintColorAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 3:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldShowTextFieldPlaceholder];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldShowTextFieldPlaceholder:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 4:
//    {
//    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 2:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] canAdjustTextView];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(canAdjustTextViewAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 1:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    
//    #ifdef NSFoundationVersionNumber_iOS_6_1
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldFixTextViewClip];
//    #else
//    cell.switchEnable.on = NO;
//    cell.switchEnable.enabled = NO;
//    #endif
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldFixTextViewClipwAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 3:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] overrideKeyboardAppearance];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(overrideKeyboardAppearanceAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    case 1:
//    {
//    NavigationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NavigationTableViewCell class])];
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 4:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldResignOnTouchOutside];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldResignOnTouchOutsideAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 5:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldRestoreScrollViewContentOffset];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldRestoreScrollViewContentOffsetAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 6:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldPlayInputClicks];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldPlayInputClicksAction:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    case 7:
//    {
//    switch (indexPath.row)
//    {
//    case 0:
//    {
//    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class])];
//    cell.switchEnable.enabled = YES;
//    cell.labelTitle.text = [[keyboardManagerProperties objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.labelSubtitle.text = [[keyboardManagerPropertyDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.switchEnable.on = [[IQKeyboardManager sharedManager] shouldAdoptDefaultKeyboardAnimation];
//    [cell.switchEnable removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [cell.switchEnable addTarget:self action:@selector(shouldAdoptDefaultKeyboardAnimation:) forControlEvents:UIControlEventValueChanged];
//    return cell;
//    }
//    break;
//    }
//    }
//    break;
//    }
//    
//    return nil;
//    }
//    
//    -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    
//    -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//    {
//    if ([segue.identifier isEqualToString:NSStringFromClass([OptionsViewController class])])
//    {
//    OptionsViewController *controller = segue.destinationViewController;
//    
//    controller.delegate = self;
//    
//    UITableViewCell *cell = (UITableViewCell*)sender;
//    selectedIndexPathForOptions = [self.tableView indexPathForCell:cell];
//    
//    if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 1)
//    {
//    controller.title = @"Toolbar Manage Behaviour";
//    controller.options = [NSArray arrayWithObjects:@"IQAutoToolbar By Subviews",@"IQAutoToolbar By Tag",@"IQAutoToolbar By Position",nil];
//    controller.selectedIndex = [[IQKeyboardManager sharedManager] toolbarManageBehaviour];
//    }
//    else if (selectedIndexPathForOptions.section == 1 && selectedIndexPathForOptions.row == 4)
//    {
//    controller.title = @"Fonts";
//    
//    controller.options = [NSArray arrayWithObjects:@"Bold System Font",@"Italic system font",@"Regular",nil];
//    
//    NSArray *fonts = [NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:12.0],[UIFont italicSystemFontOfSize:12],[UIFont systemFontOfSize:12],nil];
//    
//    UIFont *placeholderFont = [[IQKeyboardManager sharedManager] placeholderFont];
//    
//    if ([fonts containsObject:placeholderFont])
//    {
//    controller.selectedIndex = [fonts indexOfObject:placeholderFont];
//    }
//    }
//    else if (selectedIndexPathForOptions.section == 3 && selectedIndexPathForOptions.row == 1)
//    {
//    controller.title = @"Keyboard Appearance";
//    controller.options = [NSArray arrayWithObjects:@"UIKeyboardAppearance Default",@"UIKeyboardAppearance Dark",@"UIKeyboardAppearance Light",nil];
//    controller.selectedIndex = [[IQKeyboardManager sharedManager] keyboardAppearance];
//    }
//    }
//    }
//    
    
    
    func optionsViewController(controller: OptionsViewController, index: NSInteger) {

        if let selectedIndexPath = selectedIndexPathForOptions {
            
            if selectedIndexPath.section == 1 && selectedIndexPath.row == 1 {
                IQKeyboardManager.sharedManager().toolbarManageBehaviour = IQAutoToolbarManageBehaviour(rawValue: index)!
            } else if selectedIndexPath.section == 1 && selectedIndexPath.row == 4 {
                
                let fonts = [UIFont.boldSystemFontOfSize(12),UIFont.italicSystemFontOfSize(12),UIFont.systemFontOfSize(12)]
                IQKeyboardManager.sharedManager().placeholderFont = fonts[index]
            } else if selectedIndexPath.section == 3 && selectedIndexPath.row == 1 {
                
                IQKeyboardManager.sharedManager().keyboardAppearance = UIKeyboardAppearance(rawValue: index)!
            }
        }
    }
}
