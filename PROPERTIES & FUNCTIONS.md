##Properties and functions usage:-


####UIKeyboard handling

***+(instancetype)sharedManager :***
Returns the default singleton instance.

***@property BOOL enable :***
Use this to enable/disable managing distance between keyboard & textField/textView).

***@property CGFloat keyboardDistanceFromTextField :***
Set Distance between keyboard & textField. Can't be less than zero. Default is 10.

***@property BOOL preventShowingBottomBlankSpace :***
Prevent to show bottom blanck area when keyboard slide up the view. Default is YES. ([#93](https://github.com/hackiftekhar/IQKeyboardManager/issues/93)).

####IQToolbar handling

***@property BOOL enableAutoToolbar :***
Enable autoToolbar behaviour. If It is set to NO. You have to manually create UIToolbar for keyboard. Default is YES.

***@property IQAutoToolbarManageBehaviour toolbarManageBehaviour :***
Setting toolbar behaviour to IQAutoToolbarBySubviews to manage previous/next according to UITextField's hierarchy in it's SuperView. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order. Default is IQAutoToolbarBySubviews.

***@property  BOOL shouldToolbarUsesTextFieldTintColor :***
If YES, then uses textField's tintColor property for IQToolbar, otherwise tintColor is black. Default is NO. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))

***@property BOOL shouldShowTextFieldPlaceholder :***
If YES, then it add the textField's placeholder text on IQToolbar. Default is YES. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))

***@property UIFont *placeholderFont :***
placeholder Font. Default is nil. ([#27](https://github.com/hackiftekhar/IQKeyboardManager/issues/27))


####UITextView handling

***@property BOOL canAdjustTextView :***
Giving permission to modify TextView's frame. Adjust textView's frame when it is too big in height. Default is NO. ([#30](https://github.com/hackiftekhar/IQKeyboardManager/issues/30))

***@property BOOL shouldFixTextViewClip :***
Adjust textView's contentInset to fix fix for iOS 7.0.x -([#Stackoverflow](http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string)). Default is YES.


####UIKeyboard Appearance overriding

***@property BOOL overrideKeyboardAppearance :***
Override the keyboardAppearance for all textField/textView. Default is NO.

***@property UIKeyboardAppearance keyboardAppearance :***
If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.


####UITextField/UITextView Resign handling

***@property BOOL shouldResignOnTouchOutside :***
Resign textField if touched outside of UITextField/UITextView. ([#14](https://github.com/hackiftekhar/IQKeyboardManager/issues/14))

***-(void)resignFirstResponder :***
Resigns currently first responder field.

####UISound handling

***@property BOOL shouldPlayInputClicks :***
If YES, then it plays inputClick sound on next/previous/done click. Default is NO.


####UIAnimation handling

***@property BOOL shouldAdoptDefaultKeyboardAnimation :***
If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseOut animation style. Default is YES.



## Feature:-

 1) Support Device Orientation.

 2) Enable/Disable Keyboard Manager when needed with `enable` boolean.

 3) Easiest integration.

 4) AutoHandle UIToolbar as a accessoryInputView of textField/textView with `enableAutoToolbar` boolean.

 5) AutoHandle UIToolbar can be manged by superview's hierarchy or can be managed by tag property of textField/textView using `toolbarManageBehaviour` enum.

 6) `UIView` Category for easily adding Next/Previous and Done button as Keyboard UIToolBar, even automatic with `enableAutoToolbar` boolean.

 7) Enable/Disable Next/Previous buttons with Category methods, even automatic with `enableAutoToolbar` boolean.

 8) Set keyboard distance from textFields using `keyboardDistanceFromTextField`.

 9) Resign keyboard on touching outside using `shouldResignOnTouchOutside`.

 10) Manage UITextView's frame when it's hight is too large to fit on screen with `canAdjustTextView` boolean.

 11) Can manage `UITextField/UITextView` inside `UITableView/UIScrollView`.

 12) Can play input sound on Next/Previous/Done click.