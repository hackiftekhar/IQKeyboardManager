Keyboard TextField Manager
==========================

Often while developing an app, We ran into an issues where the iPhone UIKeyboard slide up and cover the `UITextField/UITextView`.

## Screen Shot
![image](./KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png)


Usage
---
Just drag and drop `IQKeyboardManager` class in your project. In your `appDelegate.m` write just one line of code. This will handle all UITextField/UITextView covering problem.

```  objc
//AppDelegate.m

#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //ONE LINE OF CODE.
    //Enabling keyboard manager(Use this line to enable managing distance between keyboard & textField/textView).
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    //(Optional)Set Distance between keyboard & textField, Default is 10.
    //[[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:15];

    //(Optional)Enable autoToolbar behaviour. If It is set to NO. You have to manually create UIToolbar for keyboard.
    //[[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];

    //(Optional)Setting toolbar behaviour to IQAutoToolbarBySubviews to manage previous/next according to UITextField's hirarchy in it's SuperView. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
    //[[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];

    //(Optional)Resign textField if touched outside of UITextField/UITextView.
    //[[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //(Optional)Giving permission to modify TextView's frame
    //[[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];

    [self.window makeKeyAndVisible];
    return YES;
}



```


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
