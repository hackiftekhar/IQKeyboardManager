## 3.2.0.3 (05-12-2014)

#### Bugfixes:

- Fixed an issue with UIAlertView's internal UIViewController.

#### Enhancement:

- Added isAskingCanBecomeFirstResponder for a workaround with textFieldShouldBeginEditing.


## 3.2.0.2 (29-10-2014)

#### Bugfixes:

- Fixed an overflow crash with **textFieldViewDidChange**.
- Fixed an issue where some textField refuse to resign specially textFields are on UITableView and tableView reload on **textFieldShouldEndEditing**.
- Fixed an scrolling issue with UIScrollView and it's subclasses.

#### Enhancement:

- Instance variable name changes.
- Restructured project.
- Dropped compatibility for versions lower than iOS7, now library support iOS7 as minimum deployment target.
- Added support for **UICollectionView**.

#### Features:

- Added **preventShowingBottomBlankSpace** property.
- Added **IQAutoToolbarByPosition**.
- Fully updated Swift version to match Objective-C version.

#### Documentation:

- Improved README and added some more documentation on how to use library.


## 3.2.0.1 (14-10-2014)

#### Bugfixes:

- Fixed some bugs with UIScrollView handling.
- Fixed an issue whre previous/next enable/disable was not working properly.
- Fixed some issues where UIViewController's view wasn't restoring to initial position.
- Fixed an issue where return key wasn't updated by IQKeyboardReturnKeyHandler.
- Fixed some issues with canAdjustTextView for iOS8 due to orientation API changes.

#### Enhancement:

- Improve distance calculation logic with status bar frame.


## 3.2.0 (28-09-2014)

#### Bugfixes:

- Fixed some issues with **UiAlertSheetTextField** in iOS8.
- Fixed an issue with **inputAccessoryView cache**.
- Fixed an issue where keyWindow doesn't get updated if application keyWindow change.
- Fixed an isssue where keyboard get dismissed with resetting textView frame.

#### Performance:

- Migrated syntax to **Modern ObjC**.


#### Features:

- Added UIView hierarchy debugging methods.
- Added **Swift** version support.


## 3.1.1 (16-09-2014)

#### Bugfixes:

- Optimized for iOS8.
- Fixed UIToolbar resizing issue finally.

#### Features:

- Added delegate support in **IQKeyboardReturnKeyHandler**.

#### Documentation:

- Updated documentation regarding **IQKeyboardReturnKeyHandler**.


## 3.1.0 (29-08-2014)

#### Features:

- Added **IQKeyboardReturnKeyHandler**.


## 3.0.8 (27-08-2014)

#### Bugfixes:

- Fixed tintColor issue with IQToolbar UIBarButtonItem's.
- Reverted UIToolbar resizing related fixes done with 3.0.6.


## 3.0.7 (30-06-2014)

#### Bugfixes:

- Fixed an issue with detecting UISearchBar textField.


## 3.0.6 (29-06-2014)

#### Bugfixes:

- Fixed an issue with iOS7 UITableViewCell internal UIScrollView.
- Fixed an issue with UIToolbar resizing bug. (Later this fix introduce another bug)

#### Documentation:

- Enhanced demo app.


## 3.0.5 (05-05-2014)

#### Features:

- Added **overrideKeyboardAppearance, keyboardAppearance** property.
- Added **shouldHideTitle** property in IQUIView+IQKeyboardToolbar.


## 3.0.4 (01-04-2014)

#### Bugfixes:

- Fixed IQTextView placeholder update issues for older iOS versions.
- Fixed a bug with UIScrollView contentOffset restoration.
- Fixed a bug where any toolbar added by user is removed by library.

#### Features:

- Added **placeholderFont** property.

#### Documentation:

- Improved documentation for **Manual Management**.


## 3.0.3 (21-03-2014)

#### Bugfixes:

- Fixed a bug with resetting textView frame when orientation.

#### Features:

- Added Spanish localization.


## 3.0.2 (13-03-2014)

#### Bugfixes:

- Fixed an issue with resetting textView frame to it's original position when resigning.

#### Features:

- Added **shouldAdoptDefaultKeyboardAnimation** property.


## 3.0.1 (06-03-2014)

#### Bugfixes:

- Disabled toolbar for **UISearchBar** and **UIAlertView** inner textField'.
- Fixed toolbar resizing issue on orientation change.
- Fixed buggy animations when keyboard show/hide.
- Replaced **UIBarButtonItem** with **IQBarButtonItem** to overcome with appearance proxy related bugs.

#### Features:

- Added **shouldPlayInputClicks, shouldToolbarUsesTextFieldTintColor** property.
- Overrided **+(void)load** method to load **IQKeyboardManager** on class load.
- Added easy category methods to **UIView+IQKeyboardToolbar.h** file.
- Added **IQTextView** for **placeholder** support.

#### Documentation:

- Updated read me with video link.


## 3.0.0 (25-02-2014)

#### Features:

- Added **shouldShowTextFieldPlaceholder** property.


## 2.6 (15-02-2014)

#### Bugfixes:

- Fixed a contentOffset bug with UITextView in iOS7.

#### Features:

- Added **IQKEYBOARDMANAGER_DEBUG** preprocessor for debugging purposes.
- Added **UITableView** support.


## 2.2 (01-01-2014)

#### Bugfixes:

- Fixed an issue where textView height is too big.

#### Features:

- Added **shouldResignOnTouchOutside** property.
- Added **canAdjustTextView** property.


#### Documentation:

- Added how to use example.


## 2.1 (13-12-2013)

#### Features:

- Added **UIScrollView** support.


## 2.0 (11-12-2013)

#### Features:

- Added UIView category methods to easily add **Next Previous** button toolbars.
- Added iOS7 style previous next button images.
- Added **enableAutoToolbar** support by **Subviews** and **Tag**.
- **sharedInstance** support.


## 1.0 (25-12-2013)

#### Bugfixes:

- Fixes framing bug with **ModalViewController** when presentation style is FormSheet/PageSheet in iPad.
- fixed some issues with LandscapeLeft offset calculations
- Optimized for iOS7.

#### Features:

- Basic distance handling of UITextField and UITextView.
- Added **Previous/Next UISegmentControl** for moving between textFields.
- Added **enableKeyboardManager, disableKeyboardManager** methods.
- Added **keyboardDistanceFromTextField**, enabled properties.
- Added **Device Orientation** support.

#### Documentation:

- Added Read Me.
- Added iOS NSNotification Mechanism chart.
