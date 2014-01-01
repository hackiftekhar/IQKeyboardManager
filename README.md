Keyboard TextField Manager
==========================

Often while developing an app, We ran into an issues where the iPhone UIKeyboard slide up and cover the UITextField/UITextView.

## Screen Shot
![image](./KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png)


Usage
---
Just drag and drop IQKeyboardManager class in your project. In your appDelegate.m write just one line of code. This will handle all UITextField/UITextView covering problem.

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
 
 2) Easy integration.

 3) UITextField Category for easily adding Next/Previous and Done button as Keyboard UIToolBar, even automatic with 'EnableAutomaticToolbar' boolean.

 4) Enable/Disable Keyboard Manager when needed.

 5) Enable/Disable Next/Previous with Category methods, even automatic with 'EnableAutomaticToolbar' boolean.

 6) Set keyboard distance from textFields.
 
 7) AutoHandle UIToolbar as a accessoryInputView of textField/textView.

 8) AutoHandle UIToolbar can be manged by superview's hierarchy or can be managed by tag property of textField/textView.

 9) Autohandle in Whole application without any extra work or code.

 10) Manage UITextView's frame when it's hight is too large to fit on screen with 'canAdjustTextView' boolean.
 
