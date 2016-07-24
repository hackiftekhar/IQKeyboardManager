##1) Manually enable IQKeyboardManager Swift Version.

From Swift 1.2, compiler no longer allows to override `class func load()` method, so you need to manually enable IQKeyboardManager using below line of code in AppDelegate.

```swift
    IQKeyboardManager.sharedManager().enable = true
```
##2) IQLayoutGuideConstraint with CocoaPods or Carthage.

For CoacoaPods or Carthage, IQLayoutGuideConstraints may not be visible in storyboard. For a workaround you should set it programmatically

##3) Keyboard does not appear in iOS Simulator
([#62](https://github.com/hackiftekhar/IQKeyboardManager/issues/62), [#72](https://github.com/hackiftekhar/IQKeyboardManager/issues/72), [#75](https://github.com/hackiftekhar/IQKeyboardManager/issues/75), [#90](https://github.com/hackiftekhar/IQKeyboardManager/issues/90), [#100](https://github.com/hackiftekhar/IQKeyboardManager/issues/100))

![Known Issue](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerKnownIssue1.png)

If keyboard does not appear in iOS Simulator and only toolbar is appearing over it (if enableAutoToolbar = YES), then check this setting

***Xcode 6:-*** Goto ***iOS Simulator->Menu->Hardware->Keyboard->Connect Hardware Keyboard***, and deselect that.

***Xcode 5 and earlier:-*** Goto ***iOS Simulator->Menu->Hardware->Simulate Hardware Keyboard***, and deselect that.

##4) setEnable = NO doesn't disable automatic UIToolbar
([#117](https://github.com/hackiftekhar/IQKeyboardManager/issues/117), [#136](https://github.com/hackiftekhar/IQKeyboardManager/issues/136), [#147](https://github.com/hackiftekhar/IQKeyboardManager/issues/147))

If you set ***[[IQKeyboardManager sharedManager] setEnable:NO]*** and still automatic toolbar appears on textFields? Probably you haven't heard about ***@property enableAutoToolbar***.

***@property enable :*** It enable/disable managing distance between keyboard and textField, and doesn't affect autoToolbar feature.

***@property enableAutoToolbar :*** It enable/disable automatic creation of toolbar, please set enableAutoToolbar to NO if you don't want to add automatic toolbar.

##3) Not working when pinning textfield from TopLayoutguide
([#124](https://github.com/hackiftekhar/IQKeyboardManager/issues/124), [#137](https://github.com/hackiftekhar/IQKeyboardManager/issues/137), [#160](https://github.com/hackiftekhar/IQKeyboardManager/issues/160), [#206](https://github.com/hackiftekhar/IQKeyboardManager/issues/206))

Now IQKeyboardManager can work with topLayoutConstraint and bottomLayoutConstraint with a bit of manual management. Please check below ***Manual Management->Working with TopLayoutGuide and BottomLayoutGuide*** section.

##5) Toolbar becomes black while popping from a view controller
([#374](https://github.com/hackiftekhar/IQKeyboardManager/issues/374))

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
