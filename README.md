<p align="center">
  <img src="https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Demo/Resources/icon.png" alt="Icon"/>
</p>
<H1 align="center">IQKeyboardManager</H1>
<p align="center">
  <img src="https://img.shields.io/github/license/hackiftekhar/IQKeyboardManager.svg"
  alt="GitHub license"/>


[![Build Status](https://travis-ci.org/hackiftekhar/IQKeyboardManager.svg)](https://travis-ci.org/hackiftekhar/IQKeyboardManager)
[![Coverage Status](http://img.shields.io/coveralls/hackiftekhar/IQKeyboardManager/master.svg)](https://coveralls.io/r/hackiftekhar/IQKeyboardManager?branch=master)
[![Code Health](https://landscape.io/github/hackiftekhar/IQKeyboardManager/master/landscape.svg?style=flat)](https://landscape.io/github/hackiftekhar/IQKeyboardManager/master)


Often while developing an app, We ran into an issues where the iPhone keyboard slide up and cover the `UITextField/UITextView`. `IQKeyboardManager` allows you to prevent issues of the keyboard sliding up and cover `UITextField/UITextView` without needing you to enter any code and no additional setup required. To use `IQKeyboardManager` you simply need to add source files to your project.


####Key Features

[![Issue Stats](http://issuestats.com/github/hackiftekhar/iqkeyboardmanager/badge/pr?style=flat)](http://issuestats.com/github/hackiftekhar/iqkeyboardmanager)
[![Issue Stats](http://issuestats.com/github/hackiftekhar/iqkeyboardmanager/badge/issue?style=flat)](http://issuestats.com/github/hackiftekhar/iqkeyboardmanager)

1) `**CODELESS**, Zero Line Of Code`

2) `Works Automatically`

3) `No More UIScrollView`

4) `No More Subclasses`

5) `No More Manual Work`

6) `No More #imports`

`IQKeyboardManager` works on all orientations, and with the toolbar. There are also nice optional features allowing you to customize the distance from the text field, add the next/previous done button as a keyboard UIToolbar, play sounds when the user navigations through the form and more.


## Screenshot
[![IQKeyboardManager](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerScreenshot.png)](http://youtu.be/6nhLw6hju2A)
[![Settings](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerSettings.png)](http://youtu.be/6nhLw6hju2A)

## GIF animation
[![IQKeyboardManager](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManager.gif)](http://youtu.be/6nhLw6hju2A)

## Video

<a href="http://youtu.be/WAYc2Qj-OQg" target="_blank"><img src="http://img.youtube.com/vi/WAYc2Qj-OQg/0.jpg"
alt="IQKeyboardManager Demo Video" width="480" height="360" border="10" /></a>

## Warning

- **If you're planning to build SDK/library/framework and wants to handle UITextField/UITextView with IQKeyboardManager then you're totally going on wrong way.** I would never suggest to add IQKeyboardManager as dependency/adding/shipping with any third-party library, instead of adding IQKeyboardManager you should implement your custom solution to achieve same result. IQKeyboardManager is totally designed for projects to help developers for their convenience, it's not designed for adding/dependency/shipping with any third-party library, because **doing this could block adoption by other developers for their projects as well(who are not using IQKeyboardManager and implemented their custom solution to handle UITextField/UITextView throught the project).**
- If IQKeybaordManager conflicts with other third-party library, then it's developer responsibility to enable/disable IQKeyboardManager when presenting/dismissing third-party library UI. Third-party libraries are not responsible to handle IQKeyboardManager.

## Requirements
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

#### IQKeyboardManager:-
[![Objective-c](https://img.shields.io/badge/Language-Objective C-blue.svg?style=flat)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

Minimum iOS Target: iOS 8.0

Minimum Xcode Version: Xcode 6.0.1

#### IQKeyboardManagerSwift:-
[![Swift 2.2 compatible](https://img.shields.io/badge/Language-Swift2-blue.svg?style=flat)](https://developer.apple.com/swift)

Minimum iOS Target: iOS 8.0

Minimum Xcode Version: Xcode 7.3

#### Demo Project:-

Minimum Xcode Version: Xcode 7.3


Installation
==========================

#### Cocoapod Method:-

[![CocoaPods](https://img.shields.io/cocoapods/v/IQKeyboardManager.svg)](http://cocoadocs.org/docsets/IQKeyboardManager)

**Note:-** 3.3.7 is the last iOS 7 supported version.

***IQKeyboardManager (Objective-C):-*** IQKeyboardManager is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile: ([#9](https://github.com/hackiftekhar/IQKeyboardManager/issues/9))

`pod 'IQKeyboardManager'`

***IQKeyboardManager (Swift):-*** IQKeyboardManagerSwift is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile: ([#236](https://github.com/hackiftekhar/IQKeyboardManager/issues/236))

*Swift 2.2 (Xcode 7.3)*

`pod 'IQKeyboardManagerSwift'`

*Or*

`pod 'IQKeyboardManagerSwift', '4.0.2'`

*Swift 2.1.1 (Xcode 7.2)* `pod 'IQKeyboardManagerSwift', '4.0.0'`

*Swift 2.0 (Xcode 7.0)* `pod 'IQKeyboardManagerSwift', '3.3.3.1'`

In AppDelegate.swift, just import IQKeyboardManagerSwift framework and enable IQKeyboardManager.

```swift
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    IQKeyboardManager.sharedManager().enable = true

    return true
    }
}
```



#### Source Code Method:-

[![Github tag](https://img.shields.io/github/tag/hackiftekhar/iqkeyboardmanager.svg)]()



***IQKeyboardManager (Objective-C):-*** Just ***drag and drop*** `IQKeyboardManager` directory from demo project to your project. That's it.

***IQKeyboardManager (Swift):-*** ***Drag and drop*** `IQKeyboardManagerSwift` directory from demo project to your project

In AppDelegate.swift, just enable IQKeyboardManager.

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    IQKeyboardManager.sharedManager().enable = true

    return true
    }
}
```


## Known Issues:-

![Known Issue 1](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerKnownIssue1.png)

####1) Keyboard does not appear in iOS Simulator ([#62](https://github.com/hackiftekhar/IQKeyboardManager/issues/62), [#72](https://github.com/hackiftekhar/IQKeyboardManager/issues/72), [#75](https://github.com/hackiftekhar/IQKeyboardManager/issues/75), [#90](https://github.com/hackiftekhar/IQKeyboardManager/issues/90), [#100](https://github.com/hackiftekhar/IQKeyboardManager/issues/100))

If keyboard does not appear in iOS Simulator and only toolbar is appearing over it (if enableAutoToolbar = YES), then check this setting

***Xcode 6:-*** Goto ***iOS Simulator->Menu->Hardware->Keyboard->Connect Hardware Keyboard***, and deselect that.

***Xcode 5 and earlier:-*** Goto ***iOS Simulator->Menu->Hardware->Simulate Hardware Keyboard***, and deselect that.

####2) setEnable = NO doesn't disable automatic UIToolbar ([#117](https://github.com/hackiftekhar/IQKeyboardManager/issues/117), [#136](https://github.com/hackiftekhar/IQKeyboardManager/issues/136), [#147](https://github.com/hackiftekhar/IQKeyboardManager/issues/147))

If you set ***[[IQKeyboardManager sharedManager] setEnable:NO]*** and still automatic toolbar appears on textFields? Probably you haven't heard about ***@property enableAutoToolbar***.

***@property enable :*** It enable/disable managing distance between keyboard and textField, and doesn't affect autoToolbar feature.

***@property enableAutoToolbar :*** It enable/disable automatic creation of toolbar, please set enableAutoToolbar to NO if you don't want to add automatic toolbar.

####3) Not working when pinning textfield from TopLayoutguide ([#124](https://github.com/hackiftekhar/IQKeyboardManager/issues/124), [#137](https://github.com/hackiftekhar/IQKeyboardManager/issues/137), [#160](https://github.com/hackiftekhar/IQKeyboardManager/issues/160), [#206](https://github.com/hackiftekhar/IQKeyboardManager/issues/206))

Now IQKeyboardManager can work with topLayoutConstraint and bottomLayoutConstraint with a bit of manual management. Please check below ***Manual Management->Working with TopLayoutGuide and BottomLayoutGuide*** section.

####4) Toolbar becomes black while popping from a view controller ([#374](https://github.com/hackiftekhar/IQKeyboardManager/issues/374))

This issue happens when there is a textField active on a view controller and you navigate to another view controller without resigning currently active textField. This is an iOS issue and happens even if you don't integrate library.

![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/BlackToolbarIssue.jpg)

For a workaround, you can resign currently active textField in `viewWillDisappear` method.

```objc
  -(void)viewWillDisappear:(BOOL)animated
  {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
  }
```

## Known Issues (Swift):-

####1) Manually enable IQKeyboardManager Swift Version.

From Swift 1.2, compiler no longer allows to override `class func load()` method, so you need to manually enable IQKeyboardManager using below line of code in AppDelegate.

```swift
    IQKeyboardManager.sharedManager().enable = true
```


Manual Management:-
---

#### UINavigationBar:-

  If you don't want to hide the default UINavigationBar of UINavigationController when keyboardManager slides up the view, then just change the UIView class to UIScrollView from the storyboard or xib.([#21](https://github.com/hackiftekhar/IQKeyboardManager/issues/21), [#24](https://github.com/hackiftekhar/IQKeyboardManager/issues/24))

![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/UINavigationBarExample.jpg)


  If you are not using storyboard or xib and creating your view programmatically. Then you need to override '-(void)loadView' method of UIViewController, and need to set an UIScrollView instance to self.view.

```objc
    -(void)loadView
    {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.view = scrollView;
    }
```

#### Working with TopLayoutGuide and BottomLayoutGuide:-

 Technically IQKeyboardManager moves upwards/downwards of currently presentedViewController's view. So if you're pinning your UITextfield/UITextView with TopLayoutGuide/BottomLayoutGuide then you're saying **Keep x distance from screen top(I don't care about where is self.view)**'. In this case your view is moved upwards but textField remains at same position and keeping x distance from screen top.

 To fix it, just let IQKeyboardManager know the constraint which is pinned with **TopLayoutGuide/BottomLayoutGuide**, just map **TopLayoutGuide/BottomLayoutGuide** constraint with **IQLayoutGuideConstraint**. Here is the screenshot:-
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/TopLayoutGuideDirectMapping.jpg)

 If your textFields are inside any UIView and your UIView is pinned with **TopLayoutGuide/BotomLayoutGuide** then also you can map **TopLayoutGuide/BottomLayoutGuide** constraint with **IQLayoutGuideConstraint**. here are the screenshots:-
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/TopLayoutGuideIndirectMapping.jpg)
![image](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/BottomLayoutGuideIndirectMapping.jpg)


#### Working with Full Screen UITextView:-

 Often we have a situation where a **full screen UITextView** need to show in full screen mode with keyboard handling. To deal with this kind of situation, here is an easy workaround.

 Assuming that `UITextView` needs to be displayed in full screen within a ViewController View and default UINavigationBar of UINavigationController is displaying at at the top of ViewController. Assuming that `Adjust Sroll View Insets` checkmark is ticked. Add these constraint to UITextView:-

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/FullScreenTextView.jpeg)

 - Top Space to SuperView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to Bottom Layout Guide (Important)

 Connect bottom layout guide constraint with `IQLayoutGuideConstraint` and that's all. You have a full working **UITextViewController**.

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/FullScreenTextViewStoryboard.jpeg)


#### Working with Chat Screen UITableView:-

 Often we have another situation where we have to implement our own **Chat Style Screen** with keyboard handling. To deal with this kind of situation, here is an easy workaround.

 Assuming that `ChatViewController` is subclass of `UIViewController` not `UITableViewController`. Assuming that `ChatViewController` has `UITableView` at top and `UIView` at bottom. Bottom UIView contains a `UITextField/UITextView` with a `Send` button. Assuming that default UINavigationBar of UINavigationController is displaying at at the top of `ChatViewController`. Assuming that `Adjust Sroll View Insets` checkmark is ticked. Add these constraint to UITableView:-

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/ChatScreenTableView.jpg)

 - Top Space to SuperView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to bottom UIView

Add thse constraint to bottom UIView
 - Leading Space to SuperView
 - Trailing Space to SuperView
 - Bottom Space to Bottom Layout Guide (Important)

 Connect bottom layout guide constraint with `IQLayoutGuideConstraint`.

 Map UITextField/UITextView Outlet with a textField object in `ChatViewController`.

 Add this two line in viewDidLoad
 
```objc
    self.textField.inputAccessoryView = [[UIView alloc] init];  //This will remove toolbar which have done button.
    self.textField.keyboardDistanceFromTextField = 8; //This will modify default distance between textField and keyboard. For exact value, please manually check how far your textField from the bottom of the page. Mine was 8pt.
```

That's all. You have a working keyboard handling with **ChatViewController**.

![image](https://github.com/hackiftekhar/IQKeyboardManager/raw/master/Screenshot/ChatScreenTableView.jpg)


#### Disable for a ViewController:-

 If you would like to disable `IQKeyboardManager` for a particular ViewController then register ViewController with `-(void)disableDistanceHandlingInViewControllerClass:(Class)disabledClass` method in AppDelegate.([#117](https://github.com/hackiftekhar/IQKeyboardManager/issues/117),[#139](https://github.com/hackiftekhar/IQKeyboardManager/issues/139))

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[ViewController class]];
    return YES;
}
```

#### Disable toolbar for a ViewController:-

If you would like to disable `Auto Toolbar` for a particular ViewController then register ViewController with `-(void)disableToolbarInViewControllerClass:(Class)disabledClass` method in AppDelegate.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[ViewController class]];
    return YES;
}
```

#### Considering Previous/Next buttons for textField inside customViews:-

If your textFields are on different customView and do not show previous/next to navigate between textField. Then you should create a SpecialView subclass of UIView, then put all customView inside SpecialView, then register SpecialView class using `-(void)considerToolbarPreviousNextInViewClass:(Class)toolbarPreviousNextConsideredClass` method in AppDelegate.([#154](https://github.com/hackiftekhar/IQKeyboardManager/issues/154), [#179](https://github.com/hackiftekhar/IQKeyboardManager/issues/179))

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[IQKeyboardManager sharedManager] considerToolbarPreviousNextInViewClass:[SpecialView class]];
    return YES;
}
```

#### Keyboard Return Key Handling:-
  If you would like to implement keyboard **Return Key** as **Next/Done** button, then you can use **IQKeyboardReturnKeyHandler**.([#38](https://github.com/hackiftekhar/IQKeyboardManager/issues/38), [#63](https://github.com/hackiftekhar/IQKeyboardManager/issues/63))

  1) Create an instance variable of `IQKeyboardReturnKeyHandler` and instantiate it in `viewDidLoad` with ViewController object like this:-

```objc
@implementation ViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
}
```

   It assign all the responderView delegates to self, and change keybord Return Key to Next key.

2) set instance variable to nil in `dealloc` method.

```objc
-(void)dealloc
{
    returnKeyHandler = nil;
}
```


#### UIToolbar(IQToolbar):-

1) If you don't want to add automatic toolbar over keyboard for a specific textField then you should add a UIView as it's toolbar like this:-([#89](https://github.com/hackiftekhar/IQKeyboardManager/issues/89))

```objc
textField.inputAccessoryView = [[UIView alloc] init];
```

2) If you need your own control over the previous/next/done button then you should use the UIView category methods to add toolbar over your textField. The UIView category methods are defined in `IQUIView+IQKeyboardToolbar.h` file. You can use them like this:-([#40](https://github.com/hackiftekhar/IQKeyboardManager/issues/40))

```objc
-(void)viewDidLoad
{
    [super viewDidLoad];

    //Adding done button for textField1
    [textField1 addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];

    //Adding previous/next/done button for textField2
    [textField2 addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];

    //Adding cancel/done button for textField3
    [textField3 addCancelDoneOnKeyboardWithTarget:self cancelAction:@selector(cancelAction:) doneAction:@selector(doneAction:)];
}

/*!	previousAction. */
-(void)previousAction:(id)button
{
    //previousAction
}

/*!	nextAction. */
-(void)nextAction:(id)button
{
    //nextAction
}

/*!	doneAction. */
-(void)doneAction:(UIBarButtonItem*)barButton
{
    //doneAction
}

/*!	cancelAction. */
-(void)cancelAction:(UIBarButtonItem*)barButton
{
    //cancelAction
}

```

#### Doing custom work on textField with returning NO in `textFieldShouldBeginEditing:` delegate:-

Generally if developer need to perform some custom task on a particular textField click, then usually developer write their custom code inside ***textFieldShouldBeginEditing:*** and returning NO for that textField. But if you are using IQKeyboardManager, then IQKeyboardManager also asks textField to recognize it can become first responder or not using ***canBecomeFirstResponder*** in `IQUIView+Hierarchy` category, and textField asks it's delegate to respond from `textFieldShouldBeginEditing:`, so this method is called for each textField everytime when a textField becomeFirstResponder. Unintentionally custom code runs multiple times even when we do not touch the textField to become it as first responder. To overcome this situation please use ***isAskingCanBecomeFirstResponder*** BOOL property to check that the delegate is called by IQKeyboardManager or not. ([#88](https://github.com/hackiftekhar/IQKeyboardManager/issues/88))

1) You may need to import `IQUIView+Hierarchy` category

```objc
#import "IQUIView+Hierarchy.h"
```

2) check for ***isAskingCanBecomeFirstResponder*** in `textFieldShouldBeginEditing:` delegate.

```objc
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == customWorkTextField)
    {
        if (textField.isAskingCanBecomeFirstResponder == NO)
        {
            //Do your work on tapping textField.
            [[[UIAlertView alloc] initWithTitle:@"IQKeyboardManager" message:@"Do your custom work here" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }

        return NO;
    }
    else    return YES;
}
```

## Control Flow Diagram
[![IQKeyboardManager CFD](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerCFD.jpg)](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerCFD.jpg)


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

LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: hack.iftekhar@gmail.com

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/hackiftekhar/iqkeyboardmanager/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

