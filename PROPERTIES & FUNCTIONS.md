## UIKeyboard handling

***+(instancetype)sharedManager***
- Returns the default singleton instance. You are not allowed to create your own instances of this class.

***@property BOOL enable***
- Use this to enable/disable managing distance between keyboard & textField/textView).

***@property CGFloat keyboardDistanceFromTextField***
- Set Distance between keyboard & textField. Can't be less than zero. Default is 10.
- A property with same name is also available for UITextField/UITextView object to customize behaviour for single textField/textView.

***@property BOOL preventShowingBottomBlankSpace***
- Prevent to show bottom blanck area when keyboard slide up the view. Default is YES. ([#93](https://github.com/hackiftekhar/IQKeyboardManager/issues/93)).

***- (void)reloadLayoutIfNeeded***
- Refreshes textField/textView position if any external changes is explicitly made by user, for example height change of textView depending on it's text.

***@property(readonly) BOOL keyboardShowing***

***@property(readonly) CGFloat movedDistance***
- keyboardShowing Boolean is to know if keyboard is showing. The moved distance of the view to maintain distance between keyboard and textField. Most of the time this will be a positive value. These information might be necessary in some rare cases.


## IQToolbar handling

***@property BOOL enableAutoToolbar***
- Enable autoToolbar behaviour. If It is set to NO. You have to manually create UIToolbar for keyboard. Default is YES.

***@property IQAutoToolbarManageBehaviour toolbarManageBehaviour :***
- Setting toolbar behaviour to IQAutoToolbarBySubviews to manage previous/next according to UITextField's hierarchy in it's SuperView. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order. Default is IQAutoToolbarBySubviews.

***@property  BOOL shouldToolbarUsesTextFieldTintColor :***

***@property UIColor toolbarTintColor***

***@property UIColor toolbarBarTintColor***
- If shouldToolbarUsesTextFieldTintColor is YES, then textField's uses it's tintColor property for tinting toolbar buttons, otherwise tintColor is black. Default is NO. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))
- toolbarTintColor is used for tinting toolbar buttons. If shouldToolbarUsesTextFieldTintColor is YES then this property is ignored. Default is nil and uses black color.
- toolbarBarTintColor is used for toolbar.barTintColor. Default is nil and uses white color.

***@property BOOL shouldShowToolbarPlaceholder; //Previously known as shouldShowTextFieldPlaceholder***

***@property UIFont placeholderFont***
- If shouldShowTextFieldPlaceholder is YES, then textField placeholder is drawn at the middle of toolbar. Default is YES. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))
- Placeholder Font is used for toolbar placeholder font. Default is nil. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))

***@property IQPreviousNextDisplayMode previousNextDisplayMode***
- IQPreviousNextDisplayModeDefault:      Show NextPrevious when there are more than 1 textField otherwise hide.
- IQPreviousNextDisplayModeAlwaysHide:   Do not show NextPrevious buttons in any case.
- IQPreviousNextDisplayModeAlwaysShow:   Always show nextPrevious buttons, if there are more than 1 textField then both buttons will be visible but will be shown as disabled.

***@property UIImage toolbarDoneBarButtonItemImage***

***@property NSString toolbarDoneBarButtonItemText***
- Toolbar done button icon, If nothing is provided then check toolbarDoneBarButtonItemText to draw done button.
- Toolbar done button text, If nothing is provided then system default 'UIBarButtonSystemItemDone' will be used.
- Image gets first priority, then text and then system default button.

***- (void)reloadInputViews***
- This is used to reload toolbar buttons on the fly.

## UIKeyboard Appearance overriding

***@property BOOL overrideKeyboardAppearance***

***@property UIKeyboardAppearance keyboardAppearance***
- Override the keyboardAppearance for all textField/textView. Default is NO.
- If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.

## UITextField/UITextView Resign handling

***@property BOOL shouldResignOnTouchOutside***
- Resign textField if touched outside of UITextField/UITextView. ([#14](https://github.com/hackiftekhar/IQKeyboardManager/issues/14))

***-(void)resignFirstResponder***
- Resigns currently first responder field.

***@property(readonly) UITapGestureRecognizer resignFirstResponderGesture***
- It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one. This might be necessary if you have added any other gesture and that doesn't work due to this gesture.

***@property (readonly) BOOL canGoPrevious***

***@property (readonly) BOOL canGoNext***

***- (BOOL)goPrevious***

***- (BOOL)goNext***
- canGoPrevious and canGoNext return a BOOL to tell if we are able to navigate to next textField/textView.
- goPrevious and goNext is used to programmatically move to previous/next textField/textView

## UISound handling

***@property BOOL shouldPlayInputClicks***
If YES, then it plays inputClick sound on next/previous/done click. Default is NO.

## UIAnimation handling

***@property BOOL layoutIfNeededOnUpdate***
- If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view. This might be required when you are animating content on keyboard appear/disappear event.

## InteractivePopGestureRecognizer handling

***@property BOOL shouldFixInteractivePopGestureRecognizer***
- If YES, then always consider UINavigationController.view begin point as {0,0}, this is a workaround to fix a bug #464 because there are no notification mechanism exist when UINavigationController.view.frame gets changed internally.

## Safe Area

***@property BOOL canAdjustAdditionalSafeAreaInsets***
- If YES, then library will try to adjust viewController.additionalSafeAreaInsets to automatically handle layout guide in iOS11. Default is NO because enabling it have sometimes break user UI logics.

## Class Level enabling/disabling methods

***@property(readonly) NSMutableSet\<Class> disabledDistanceHandlingClasses***

***@property(readonly) NSMutableSet\<Class> enabledDistanceHandlingClasses***
- disabledDistanceHandlingClasses disable distance handling in registered viewControllers. Default is [UITableViewController, UIAlertController, _UIAlertControllerTextFieldViewController].
- enabledDistanceHandlingClasses enable distance handling in registered viewControllers. Default is [].
- Within these scope, 'enabled' property is ignored. Classes should be kind of UIViewController

***@property(readonly) NSMutableSet\<Class> disabledToolbarClasses***

***@property(readonly) NSMutableSet\<Class> enabledToolbarClasses***
- disabledToolbarClasses disable automatic toolbar creation in registered viewControllers. Default is [UIAlertController, _UIAlertControllerTextFieldViewController].
- enabledToolbarClasses enable automatic toolbar creation in registered viewControllers. Default is [].
- Within these scope, 'enableAutoToolbar' property is ignored. Classes should be kind of UIViewController.

***@property(readonly) NSMutableSet\<Class> toolbarPreviousNextAllowedClasses***
- toolbarPreviousNextAllowedClasses allow to navigate between textField contains in different superview. Default is [UITableView, UICollectionView, IQPreviousNextView].
- Classes should be kind of UIView.
- A native class IQPreviousNextView is provided by library without any internal logic. You can safely use it to make things work.

***@property(readonly) NSMutableSet\<Class> disabledTouchResignedClasses***

***@property(readonly) NSMutableSet\<Class> enabledTouchResignedClasses***
- disabledTouchResignedClasses is used to ignore 'shouldResignOnTouchOutside' property in registered viewControllers. Default is [UIAlertController, UIAlertControllerTextFieldViewController]
- enabledTouchResignedClasses is used to forcefully enable 'shouldResignOnTouchOutsite' in registered viewControllers. Default is [].
- Class should be kind of UIViewController.

***@property(readonly) NSMutableSet\<Class> touchResignedGestureIgnoreClasses***
- touchResignedGestureIgnoreClasses is used to customize shouldResignOnTouchOutside behaviour in special views.
- If shouldResignOnTouchOutside is enabled then you can customise the behaviour to not recognise gesture touches on some specific view subclasses.
Class should be kind of UIView. Default is [UIControl, UINavigationBar]

## Debugging & Developer options

***@property(nonatomic, assign) BOOL enableDebugging***
- Enabling this feature will start printing all debugging logs to the console. This is useful when something is happening wrong and you don't know what might be the problem. This will provide you a brief idea about what library is doing behind the scene.

***-(void)registerAllNotifications***

***-(void)unregisterAllNotifications***
- Use these methods to completely enable/disable notifications registered by library internally.
- @warning Please keep in mind that library is totally dependent on NSNotification of UITextField, UITextField, Keyboard etc. If you do unregisterAllNotifications then library will not work at all. You should only use below methods if you want to completedly disable all library functions. You should use below methods at your own risk.
