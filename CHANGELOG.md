## master (xx-xx-xxxx)

#### Deprecations and Removed:
- Deprecated **isAskingCanBecomeFirstResponder** because this no longer useful now.
- Removed **shouldHidePreviousNext** in favor of **previousNextDisplayMode**.

## 4.0.9 (04-04-2017)

#### Bugfixes:

- Fixed an issue where **enabledDistanceHandlingClasses** for a class with **enabled=NO** configuration wasn't working well.

#### Features:

- Added **touchResignedGestureIgnoreClasses** property to ignore resigned touches for specific view classes.

#### Improvements:

- Updated to support **Swift 3.1**.
- Fixed some warnings about deprecations.

#### Documentation:

- Updated README.md documentation.


## 4.0.8 (22-12-2016)

#### Bugfixes:

- Fixed an issue with **keyboard long delay on first keyboard appearance**.
- Disabled library in **UIAlertController**.
- Fixed an issue where **shouldResignOnTouchOutside** wasn't working with **UITableViewController**.
- Fixed **isKeyboardShowing** bool value when library is disabled.
- Fixed an issue where **textField was hiding** when **orientation** occurs with **formSheet or pageSheet** presentation style.

#### Features:

- Added **previousNextDisplayMode** for better handling of previour/next buttons.

#### Improvements:

- Added ability to **detect textField left/right view**, if they can also become first responder.
- **Improved delgate callback behaviour** with IQKeyboardReturnKeyHandler class.

#### Deprecations and Removed:

- Deprecated **shouldHidePreviousNext** in favor of **previousNextDisplayMode** and this will be removed in future releases.

#### Documentation:

- Added **CHANGELOG.md**.
- Added **Carthage Documentation** in README.md file.


## 4.0.7 (19-10-2016)

#### Bugfixes:

- Fixed an issue where keyboard was dismissing by touching on **UIWebView** but layout doesn't change and user see blank area at bottom.

#### Improvements:

- Added **.swift-version** file for CocoaPods to know swift version of library.


## 4.0.6 (16-09-2016)

#### Improvements:

- Updated swift library to **swift 3.0**.
- Added new next/previous icons for **iOS10**.

## 4.0.5 (24-08-2016)

#### Bugfixes:

- Fixed an issue with iPad Form Sheet where view was pulling down.
- Fixed next/previous ordering issue when textFields are in header of UITableView.

#### Improvements:

- Moved library files to **development pods**.
- Added **method execution time** print with debugging logs.

#### Features:

- Moved **keyboardShowing** readonly property for public use.
- Added **movedDistance** readonly property to get adjustment distance by library.

#### Documentation:

- Updated **MANUAL MANAGEMENT.md** with more examples.


## 4.0.4 (25-06-2016)

#### Bugfixes:

- Fixed an issue with custom done button/image dynamic updation.
- Fixed an issue with Form Sheet where Form Sheet was resetting view frame internally.
- Fixed an issue where navigation controller sometimes return wrong frame when applied **pop gesture recognizer**.
- Fixed an issue where customized keyboardDistanceFromTextField property wasn't working UISearchBar.
- Fixed an issue where view was misplaced when **In Call Status Bar** show/hide.

#### Features:

- Added **setTitleTarget:action:** to use toolbar title as button to enhanced textField features.
- Added **enableDebugging** property to print logs.
- Added **shouldFixInteractivePopGestureRecognizer** property to fix a bug with navigation controller **pop gesture recognizer**.
- Added **shouldHidePreviousNext** property.
- Replaced **shouldHideTitle** with **shouldHidePlaceholderText**.
- Added **Carthage** support for **Objective-C** version.

#### Deprecations and Removed:

- Removed **canAdjustTextView** property since this now internally handled by adjusting **contentInset of UITextView**.
- Removed **shouldAdoptDefaultKeyboardAnimation** property.
- Removed **disableDistanceHandlingInViewControllerClass, removeDisableDistanceHandlingInViewControllerClass, disableToolbarInViewControllerClass, removeDisableToolbarInViewControllerClass, considerToolbarPreviousNextInViewClass, removeConsiderToolbarPreviousNextInViewClass** methods.
- Removed **IQKEYBOARDMANAGER_DEBUG** preprocessor macro.

#### Documentation:

- Enhanced **Settings Controller**.
- Moved **README.md** documentation to **MANUAL MANAGEMENT.md, PROPERTIES & FUNCTIONS.md, KNOWN ISSUES.md**.
- Updated **iOS NSNotification Mechanism** documentation mechanism.


## 4.0.3 (17-05-2016)

#### Bugfixes:

- Fixed an issue with UIScrollView where scrollView.isEnabled was set to false but library was still scrolling UIScrollView.

#### Features:

- Added **reloadLayoutIfNeeded** to adjust position on the fly.
- **UIAccessibility** support for next/previous/done buttons.
- Removed manual contentSize adjustment and this should now be calculated by user with their own logic or with Autolayout.
- Added **registerTextFieldViewClass, didBeginEditingNotificationName, didEndEditingNotificationName** method.

#### Deprecations and Removed:

- Removed **addTextFieldViewDidBeginEditingNotificationName:didEndEditingNotificationName** method.


## 4.0.2 (22-04-2016)

#### Bugfixes:

- Fixed a compilation issue with carthage due to recently added **IQPreviousNextView**.

#### Documentation:

- Removed **shouldFixTextViewClip** because this no longer needs since we dropped support for iOS7.


## 4.0.1 (04-04-2016)

#### Improvements:

- Updated swift library to **swift 2.2**.
- Optimized movement calculation when **hardware keyboard is attached**.

#### Features:

- Added **reloadInputViews** method.
- Added **RTL language direction support** for next/previous images.
- Added support for **third party customized textView/textField** by adding **addTextFieldViewDidBeginEditingNotificationName:didEndEditingNotificationName** method.
- Added **disabledDistanceHandlingClasses, enabledDistanceHandlingClasses, disabledToolbarClasses, enabledToolbarClasses, toolbarPreviousNextAllowedClasses, toolbarPreviousNextDeniedClasses, disabledTouchResignedClasses, enabledTouchResignedClasses** properties.
- Added **IQPreviousNextView** class to Improve Next Previous experience for all inner deep responder subviews.

#### Deprecations and Removed:

- Deprecated **disableDistanceHandlingInViewControllerClass, removeDisableDistanceHandlingInViewControllerClass, disableToolbarInViewControllerClass, removeDisableToolbarInViewControllerClass, considerToolbarPreviousNextInViewClass, removeConsiderToolbarPreviousNextInViewClass** methods and replaced with NSMutableSet properties.

#### Documentation:

- Updated README.


## 4.0.0 (13-02-2016)

#### Improvements:

- Updated swift library to **swift 2.1.1**.

#### Deprecations and Removed:

- **Dropped iOS7 support**.

#### Documentation:

- Removed deprecated **disableInViewControllerClass, removeDisableInViewControllerClass** methods.
- Removed deprecated **shouldRestoreScrollViewContentOffset** property.


## 3.3.7 (05-02-2016)

#### Bugfixes:

- Fixed a compilation issue with Carthage.

#### Features:

- Added **toolbarDoneBarButtonItemImage** property.


## 3.3.6 (20-01-2016)

#### Bugfixes:

- Fixed an issue where done button was showing smaller than usual.

#### Features:

- Added **disableDistanceHandlingInViewControllerClass, removeDisableDistanceHandlingInViewControllerClass** method.
- Added **toolbarDoneBarButtonItemText, toolbarTintColor** property.
- Added **shouldRestoreScrollViewContentOffset** to UIScrollView category.

#### Deprecations and Removed:

- Deprecated **disableInViewControllerClass, removeDisableInViewControllerClass** and replaced with new one for better name understanding, this will be remove in future release.
- Deprecated **shouldRestoreScrollViewContentOffset** of IQKeyboardManager class, this will be remove in future release.


## 3.3.5 (31-12-2015)

#### Bugfixes:

- Fixed a bug with Pass through touches when resigning on touch outside.
- Fixed an issue where contentSize of UIScrollView doesn't restored to it's original size.

#### Performance:

- Loading Appearance proxy to load at app start to improve performance for showing keyboard first time.

#### Deprecations and Removed:

- **Dropped iOS6 support**.


## 3.3.4 (28-10-2015)

#### Improvements:

- Updated swift library to **swift 2.1**.

#### Deprecations and Removed:

- Removed **toolbarManageBehaviour** from **IQKeyboardReturnKeyHandler**, now this will read from **IQKeyboardManager** property.


## 3.3.3.1 (24-10-2015)

#### Bugfixes:

- Fixed an crash where some custom view's doesn't support to call **setInputAccessoryView**.
- Fixed some more critical crashes happened due to latest updates.


## 3.3.3 (22-10-2015)

#### Bugfixes:

- Fixed some appearance proxy related issues with toolbar and toolbar buttons.

#### Improvements:

- Added **Travis CI** for build status.

#### Deprecations and Removed:

- **Dropped iOS5 support**.


## 3.3.2 (19-09-2015)

#### Improvements:

- Updated swift library to **swift 2.0**.


## 3.3.1 (10-09-2015)

#### Bugfixes:

- Added different movement logic for **bottomLayoutGuide** and **topLayoutGuide**.
- Fixed an issue with iOS8 where **toolbar arrows were missing** with CocoaPods when used with **user_framework!** option.

#### Unit Tests:

- Added **UI Test cases**.


## 3.3.0 (30-08-2015)

#### Bugfixes:

- Fixed a condition when UITextView is inside UIScrollView.
- Fixed an issue with wrong title on toolbar.

#### Features:

- Added **Carthage Support**.


## 3.2.4 (04-06-2015)

#### Bugfixes:

- Fixed an issue with adjusting UiTextView height.

#### Features:

- Added **isDisableInViewControllerClass, isDisableToolbarInViewControllerClass, isConsiderToolbarPreviousNextInViewClass** methods.
- Added **keyboardDistanceFromTextField** customization property to set for specific UITextField/UITextView.
- Added **layoutIfNeededOnUpdate** property.
- Added **IQLayoutGuideConstraint** property with UIViewController category.

#### Documentation:

- Enhanced **README.md** with more examples.


## 3.2.3 (21-04-2015)

#### Bugfixes:

- Fixed placeholder text position with IQTextView.
- Fixed an issue where hidden UITextFields were not skipping.
- Fixed a contentInset issue with UIScrollView support.

#### Improvements:

- Updated swift library to **swift 1.2**.

#### Features:

- Added to go next/previous programmatically, added **canGoPrevious, canGoNext** properties and **goPrevious, goNext** methods.


## 3.2.2 (27-03-2015)

#### Bugfixes:

- Fixed an issue with iOS8 where **toolbar arrows were missing with CocoaPods** installation.

#### Features:

- Added **shouldRestoreScrollViewContentOffset**.


## 3.2.1.2 (22-03-2015)

#### Features:

- Added **disableInViewControllerClass, disableToolbarInViewControllerClass, considerToolbarPreviousNextInViewClass** methods.


## 3.2.1.1 (12-02-2015)

#### Bugfixes:

- Adopted KeyboardAppearance style for keyboard toolbar.
- Fixed some toolbar caching and next/previous enable/disable related issues.

#### Features:

- Added **shouldFixTextViewClip** property.
- Added **custom previous/next/done call methods registration**.

#### Deprecations and Removed:

- **Removed support for Framework**, now developer needs to compile for framework if they need.


## 3.2.1.0 (11-01-2015)

#### Bugfixes:

- Fixed an issue where textField was hiding behind keyboard when textField was in UIScrollView and it's contentSize is less than it's height.
- Fixed an issue where shouldResignOnTouchOutside preventing tap to UIControl subclasses.
- Fixed some next/previous issues related to UITableView.
- Fixed an issue for **UIPageViewController internal scrollView**.

#### Debugging:

- **Enhanced logging** by printing all internal calculation in console.

#### Improvements:

- Improved swift version with recommended style guide.


## 3.2.0.3 (05-12-2014)

#### Bugfixes:

- Fixed an issue with **UIAlertView's internal UIViewController**.

#### Enhancement:

- Added **isAskingCanBecomeFirstResponder** for a workaround with **textFieldShouldBeginEditing** delegate method.


## 3.2.0.2 (29-10-2014)

#### Bugfixes:

- Fixed an overflow crash with **textFieldViewDidChange**.
- Fixed an issue where some textField refuse to resign specially when textFields were on UITableView and tableView reload on **textFieldShouldEndEditing**.
- Fixed an scrolling issue with UIScrollView and it's subclasses.

#### Enhancement:

- Instance variable name changes.
- Restructured project.
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
- Fixed an issue where previous/next enable/disable was not working properly.
- Fixed some issues where UIViewController's view wasn't restoring to initial position.
- Fixed an issue where return key wasn't updated by IQKeyboardReturnKeyHandler.
- Fixed some issues with **canAdjustTextView** for iOS8 due to **orientation API changes**.

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

#### Improvements:

- Added **UIView hierarchy debugging methods**.

#### Features:

- Added **Swift** version support.


## 3.1.1 (16-09-2014)

#### Bugfixes:

- Optimized for iOS8.
- Fixed **UIToolbar resizing issue** finally.

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

- Fixed an issue with iOS7 **UITableViewCell internal UIScrollView**.
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


## 3.0.2 (13-03-2014)

#### Bugfixes:

- Fixed an issue with resetting textView frame to it's original position when resigning.

#### Features:

- Added **shouldAdoptDefaultKeyboardAnimation** property.


## 3.0.1 (06-03-2014)

#### Bugfixes:

- Disabled toolbar for **UISearchBar** and **UIAlertView** inner textField'.
- Fixed toolbar resizing issue on orientation change.
- Fixed **buggy animations** when keyboard show/hide.
- Replaced **UIBarButtonItem** with **IQBarButtonItem** to overcome with appearance proxy related bugs.

#### Features:

- Added **shouldPlayInputClicks, shouldToolbarUsesTextFieldTintColor** property.
- Overrided **+(void)load** method to load **IQKeyboardManager** on class load.
- Added easy category methods to **UIView+IQKeyboardToolbar.h** file.
- Added **IQTextView** for **placeholder** support.

#### Documentation:

- Updated **README.md** with video link.


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

- Fixed an issue with a case where textView height is too big.

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
- Added **iOS7 style previous/next button images**.
- Added **enableAutoToolbar** support by **Subviews** and **Tag**.
- **sharedInstance** support.


## 1.0 (25-12-2013)

#### Bugfixes:

- Fixes framing bug with **ModalViewController** when presentation style is FormSheet/PageSheet in iPad.
- fixed some issues with **LandscapeLeft offset calculations**.
- Optimized for iOS7.

#### Features:

- Basic distance handling of UITextField and UITextView.
- Added **Previous/Next UISegmentControl** for moving between textFields.
- Added **enableKeyboardManager, disableKeyboardManager** methods.
- Added **keyboardDistanceFromTextField**, enabled properties.
- Added **Device Orientation** support.

#### Documentation:

- Added **README.md**.
- Added **iOS NSNotification Mechanism** chart.
