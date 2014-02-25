Keyboard TextField Manager
==========================

Often while developing an app, We ran into an issues where the iPhone UIKeyboard slide up and cover the `UITextField/UITextView`.

## Screen Shot
![image](./KeyboardTextFieldDemo/Screenshot/IQKeyboardManagerScreenshot.png)


Installation
==========================

Cocoapod
---
IQKeyboardManager is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'IQKeyboardManager', '~>2.5.0'

Framework:-
---
Link your project against `KeyboardManager.framework` found in "KeyboardManagerFramework" directory. Drag and drop the resource bundle `IQKeyboardManager.bundle` found in same directory. add `-ObjC` flag in `other linker flag`. In your `appDelegate.m` import `#import <KeyboardManager/KeyboardManager.h>`. Write just one line of code.

Source Code:-
---
Just drag and drop `IQKeyBoardManager` directory from demo project to your project. In your `appDelegate.m` import `#import "IQKeyboardManager.h"`. Write just one line of code.

## Usage
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

    //(Optional)Setting toolbar behaviour to IQAutoToolbarBySubviews to manage previous/next according to UITextField's hierarchy in it's SuperView. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
    //[[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];

    //(Optional)Resign textField if touched outside of UITextField/UITextView.
    //[[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //(Optional)Giving permission to modify TextView's frame
    //[[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];

    //(Optional)Show TextField placeholder texts on autoToolbar
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];

    [self.window makeKeyAndVisible];
    return YES;
}



```

If you don't want to import these files you can use an older version of `IQKeyboardManager` in Tag 2.6.

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
 
 
LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: hack.iftekhar@gmail.com

