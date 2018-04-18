## 6.0.1 (16-4-2018 | 4 days)

#### Bug fixes
- Fixed an issue where `parentContainerViewController` method stuck with infinite loop

## 6.0.0 (12-4-2018 | 1 month, 3 days)

#### Bug fixes
- Fixed an issue where textView was going out of the screen of form sheet or page sheet style presentation on iPad.
- Fixed couple of memory leaks.
- Fixed animation glitch if constraint are pinned with layout guides or safe area.
- Fixed an issue where navigation bar moves with textFields.
- Introduce IQInvocation class to fix some memory leak issues.

#### Improvements
- Core logic changed to handle distance between textField and keyboard. This fixes most of the recent issues automatically.
- Renamed `sharedManager()` with`shared` for swift version.
- Renamed  `viewController()` method with `viewContainingController()` due to naming conflict with other third party SDK's.
- Supported toolbar placeholder text color
- Added @objc annotation to make swift library available for Objective-C files.
- Added **placeholderTextColor** to **IQTextView**

#### Deprecation and removed
- Deprecated **preventShowingBottomBlankSpace**, **shouldFixInteractivePopGestureRecognizer**, **canAdjustAdditionalSafeAreaInsets**

## 5.0.8 (09-3-2018 | 2 month, 23 days)

#### Bugfixes:
- Fixed couple of memory leak issues.

#### Features:
- Added **shouldResignOnTouchOutsideMode** in UITextFieldView category to override resign on touch outside behaviour for particular textField.

## 5.0.7 (17-12-2017 | 1 month, 12 days)

#### Bugfixes:

#### Improvements:
- Fixed a deprecated warning about **characters**.
- Improved IQToobar button frame calculations below iOS11.

#### Documentation:

- Updated **Update PROPERTIES & FUNCTIONS.md**.

## 5.0.6 (05-11-2017 | 1 day)

#### Bugfixes:
- Fixed a compilation issue due to **NSAttributedString**.

#### Improvements:
- Replaced some **Objective-C** style API's with **Swift** style API's.

## 5.0.5 (04-11-2017 | 22 days)

#### Improvements:
- Patched a tweak for **appearance proxy** where appearance proxy on **UIBarButtonItem** was also overriding IQBarButtonItem appearance, which shouldn't be intended.

## 5.0.4 (13-10-2017 | 10 days)

#### Bugfixes:
- Fixed a **crash** issue due to setting **tintColor proxy** on IQToolbar.

#### Improvements:
- Added **canAdjustAdditionalSafeAreaInsets** to control whether library is allow to change **additionalSafeAreaInsets** or not. Default is NO.

## 5.0.3 (03-10-2017 | 9 days)

#### Features:
- Added **ignoreSwitchingByNextPrevious** for textField/textView to ignore it while finding next/previous textField.

#### Improvements:
- Upgraded demo project with **Safe Area layout guide**.
- Improved keyboard/textfield handling with **additionalSafeAreaInsets** tweak.

## 5.0.2 (24-09-2017 | 0 days)

#### Bugfixes:
- Fixed some compilation issue cause due to @import.

## 5.0.1 (24-09-2017 | 5 days)

#### Improvements:
- Changed **#import <Framework/ClassName.h>** with **@import**.

## 5.0.0 (19-09-2017 | 28 days)

#### Bugfixes:
- Fixed an issue where custom bar button actions wasn't not passing UITextField/UITextView object to method.

#### Features:
- Added **shouldIgnoreScrollingAdjustment** property in UIScrollView category to prevent scrollView to scroll to adjust textField position. This will be useful if there are nested UIScrollView are having and we should like to scroll an specific one to autoscroll to correct position.

#### Improvements:
- Converted project to support **swift4**, with **backward compatibility** of **swift3.2** and **swift 3.0**.
- Migrated from **#import** statements to **@import**.

#### Deprecations and Removed:
- **Removed localizable.strings** files from Bundle since it's no longer useful.

## 4.0.13 (22-08-2017 | 3 days)

#### Bugfixes:
- Fixed an issue preventing to build project
- Fixed an issue where **keyboard toolbar** start displaying text from left with **iOS11**.

## 4.0.12 (19-08-2017 | 23 days) (Breaking changes)

#### Bugfixes:
- Fixed some text alignment issue with IQTextView
- Fixed an issue where **keyboard toolbar** wasn't displaying properly with **iOS11**.
- Fixed an out of bound index crash happening with swift version.

#### Improvements:
- Renamed **topMostController** to **topMostWindowController** due to a swift conflict

## 4.0.11 (27-07-2017 | 1 month 27 days)

#### Bugfixes:

- Removed some more references of **private API's**(We previously added those non-public API's for workarounds #865).
- Fixed a text alignment issue with IQTextView (Thanks to @yurihan)
- Fixed an issue where \_kbSize variable wasn't clearing when library is disabled.

#### Improvements:
- Splitted storyboard into multiple storyboard to improve demo performance.
- Added brief flow diagram for quick understanding.

#### Deprecations and Removed:
- Removed **isAskingCanBecomeFirstResponder** because this no longer useful now.

## 4.0.10 (01-06-2017 | 1 month 28 days)

#### Bugfixes:

- Fixed an issue where **Apple rejected apps** using libray due to referencing some **non-public API's** (We previously added those non-public API's for workarounds #865).

#### Improvements:
- Added **registerAllNotifications & unregisterAllNotifications** methods to completely disable library at developer risk

#### Deprecations and Removed:
- Deprecated **isAskingCanBecomeFirstResponder** because this no longer useful now.
- Removed **shouldHidePreviousNext** in favor of **previousNextDisplayMode**.

## 4.0.9 (04-04-2017 | 3 months 13 days)

#### Bugfixes:

- Fixed an issue where **enabledDistanceHandlingClasses** for a class with **enabled=NO** configuration wasn't working well.

#### Features:

- Added **touchResignedGestureIgnoreClasses** property to ignore resigned touches for specific view classes.

#### Improvements:

- Updated to support **Swift 3.1**.
- Fixed some warnings about deprecations.

#### Documentation:

- Updated README.md documentation.


## 4.0.8 (22-12-2016 | 2 months 3 days)

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


## 4.0.7 (19-10-2016 | 1 month 3 days)

#### Bugfixes:

- Fixed an issue where keyboard was dismissing by touching on **UIWebView** but layout doesn't change and user see blank area at bottom.

#### Improvements:

- Added **.swift-version** file for CocoaPods to know swift version of library.


## 4.0.6 (16-09-2016 | 23 days)

#### Improvements:

- Updated swift library to **swift 3.0**.
- Added new next/previous icons for **iOS10**.

## 4.0.5 (24-08-2016 | 2 months)

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


## 4.0.4 (25-06-2016 | 1 month 8 days)

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


## 4.0.3 (17-05-2016 | 25 days)

#### Bugfixes:

- Fixed an issue with UIScrollView where scrollView.isEnabled was set to false but library was still scrolling UIScrollView.

#### Features:

- Added **reloadLayoutIfNeeded** to adjust position on the fly.
- **UIAccessibility** support for next/previous/done buttons.
- Removed manual contentSize adjustment and this should now be calculated by user with their own logic or with Autolayout.
- Added **registerTextFieldViewClass, didBeginEditingNotificationName, didEndEditingNotificationName** method.

#### Deprecations and Removed:

- Removed **addTextFieldViewDidBeginEditingNotificationName:didEndEditingNotificationName** method.


## 4.0.2 (22-04-2016 | 18 days)

#### Bugfixes:

- Fixed a compilation issue with carthage due to recently added **IQPreviousNextView**.

#### Documentation:

- Removed **shouldFixTextViewClip** because this no longer needs since we dropped support for iOS7.


## 4.0.1 (04-04-2016 | 2 months 1 day)

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


## 4.0.0 (13-02-2016 | 8 days)

#### Improvements:

- Updated swift library to **swift 2.1.1**.

#### Deprecations and Removed:

- **Dropped iOS7 support**.

#### Documentation:

- Removed deprecated **disableInViewControllerClass, removeDisableInViewControllerClass** methods.
- Removed deprecated **shouldRestoreScrollViewContentOffset** property.


## 3.3.7 (05-02-2016 | 16 days)

#### Bugfixes:

- Fixed a compilation issue with Carthage.

#### Features:

- Added **toolbarDoneBarButtonItemImage** property.


## 3.3.6 (20-01-2016 | 20 days)

#### Bugfixes:

- Fixed an issue where done button was showing smaller than usual.

#### Features:

- Added **disableDistanceHandlingInViewControllerClass, removeDisableDistanceHandlingInViewControllerClass** method.
- Added **toolbarDoneBarButtonItemText, toolbarTintColor** property.
- Added **shouldRestoreScrollViewContentOffset** to UIScrollView category.

#### Deprecations and Removed:

- Deprecated **disableInViewControllerClass, removeDisableInViewControllerClass** and replaced with new one for better name understanding, this will be remove in future release.
- Deprecated **shouldRestoreScrollViewContentOffset** of IQKeyboardManager class, this will be remove in future release.


## 3.3.5 (31-12-2015 | 2 months 3 days)

#### Bugfixes:

- Fixed a bug with Pass through touches when resigning on touch outside.
- Fixed an issue where contentSize of UIScrollView doesn't restored to it's original size.

#### Performance:

- Loading Appearance proxy to load at app start to improve performance for showing keyboard first time.

#### Deprecations and Removed:

- **Dropped iOS6 support**.


## 3.3.4 (28-10-2015 | 4 days)

#### Improvements:

- Updated swift library to **swift 2.1**.

#### Deprecations and Removed:

- Removed **toolbarManageBehaviour** from **IQKeyboardReturnKeyHandler**, now this will read from **IQKeyboardManager** property.


## 3.3.3.1 (24-10-2015 | 2 days)

#### Bugfixes:

- Fixed an crash where some custom view's doesn't support to call **setInputAccessoryView**.
- Fixed some more critical crashes happened due to latest updates.


## 3.3.3 (22-10-2015 | 1 month 3 days)

#### Bugfixes:

- Fixed some appearance proxy related issues with toolbar and toolbar buttons.

#### Improvements:

- Added **Travis CI** for build status.

#### Deprecations and Removed:

- **Dropped iOS5 support**.


## 3.3.2 (19-09-2015 | 9 days)

#### Improvements:

- Updated swift library to **swift 2.0**.


## 3.3.1 (10-09-2015 | 11 days)

#### Bugfixes:

- Added different movement logic for **bottomLayoutGuide** and **topLayoutGuide**.
- Fixed an issue with iOS8 where **toolbar arrows were missing** with CocoaPods when use
