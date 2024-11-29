<p align="center">
  <img src="https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/Social.png" alt="Icon"/>
</p>

[![LICENSE.md](https://img.shields.io/github/license/hackiftekhar/IQKeyboardManager.svg)]([https://travis-ci.org/hackiftekhar/IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager/blob/master/LICENSE.md))
[![Build Status](https://travis-ci.org/hackiftekhar/IQKeyboardManager.svg)](https://travis-ci.org/hackiftekhar/IQKeyboardManager)
![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)
[![CocoaPods](https://img.shields.io/cocoapods/v/IQKeyboardManagerSwift.svg)](http://cocoadocs.org/docsets/IQKeyboardManagerSwift)
[![Github tag](https://img.shields.io/github/tag/hackiftekhar/iqkeyboardmanager.svg)](https://github.com/hackiftekhar/IQKeyboardManager/tags)

## Major updates have arrived!

#### First of all, Thank You for using IQKeyboardManager!
It's been 12 years since it's first release in 2013. The library has grown a lot and we have added many new features since then.

#### Motivation
Recently while working on bug fixes, I realized that in 2013 there were only 2 files IQKeyboardManager.{h,m} in Objective-C version, while now in Swift version there were 50+ files (version 7.x.x) which makes the debugging a lot difficult than before. Also, some of the features are rarely used in apps.

#### New Idea
I realized that some of the features are not tightly linked to each other and can be moved out of the library easily. For Example:-
- `IQTextView` class
- `IQKeyboardListener` class
- `IQTextFieldViewListener` class
- `IQReturnKeyHandler` class
- Toolbar related features like `IQToolbar` and `IQBarButtonItem` and their support classes.
- ...

Moving above things out will make the library more lightweight and user can plug in/out features as per their needs.

#### Action Plan Execution
I had decided to move loosely linked features out, and publish them to their separate github repo, and use them as dependencies as per requirements.

- [x] Published [IQKeyboardCore](https://github.com/hackiftekhar/IQKeyboardCore)
 - This contains necessary classes and functions to be used by `IQKeyboardManager` related libraries. Please note that you shouldn't directly install this as dependency
- [x] Published [IQTextView](https://github.com/hackiftekhar/IQTextView)
 - This is purely separated a separate library now.
 - This is usually used for showing placeholder in `UITextView`.
- [x] Published [IQKeyboardReturnManager](https://github.com/hackiftekhar/IQKeyboardReturnManager)
 - This is a renamed of `IQReturnKeyHandler`. This is also separated from the library and can be used independently.
 - This depends on `IQKeyboardCore` for `TextInputView` type confirmation.
- [x] Published [IQTextInputViewNotification](https://github.com/hackiftekhar/IQTextInputViewNotification)
 - This is a renamed of `IQTextFieldViewListener`. This can be used independently to subscribe/unsubscribe for `UITextView`/`UITextField` beginEditing/endEditing events.
 - This depends on the `IQKeyboardCore` to add some additional customized features for `UITextView`/`UITextField`.
- [x] Published [IQKeyboardToolbar](https://github.com/hackiftekhar/IQKeyboardToolbar)
 - This contains toolbar related classes like `IQKeyboardToolbar`, `IQBarButtonItem`, `IQTitleBarButtonItems`, their configuration classes and other useful functions to add toolbar in keyboard. This can be used independently to add toolbar in keyboard.
 - This depends on the `IQKeyboardCore` to add some additional customized features for `UITextView`/`UITextField`.
- [x] Published [IQKeyboardToolbarManager](https://github.com/hackiftekhar/IQKeyboardToolbarManager)
 - This is something similar to `IQKeyboardManager`. This has been moved out of the library as a huge update. 
 - This depends on the `IQTextInputViewNotification` to know which textField is currently in focus.
 - This depends on the `IQKeyboardToolbar` to add/remove toolbars over keyboard.
- [x] Published [IQKeyboardNotification](https://github.com/hackiftekhar/IQKeyboardNotification)
 - This is a renamed of `IQKeyboardListener`. This can be used independently to subscribe/unsubscribe for keyboard events.
- [x] Published [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) 7.2.0 for all the current support without any compilation error but by deprecating most of the things which are moved out of the library.
 - This now only contains functions for handling distance between `UITextView`/`UITextField` and their useful functions.
 - This depends on the `IQKeyboardNotification` to get keyboard notification callbacks.
 - This depends on the `IQTextInputViewNotification` to know which textField is currently in focus.
 - Now there are subspecs support since 7.2.0.
  - `IQKeyboardManagerSwift/Appearance`
  - `IQKeyboardManagerSwift/IQKeyboardReturnManager`
  - `IQKeyboardManagerSwift/IQKeyboardToolbarManager`
  - `IQKeyboardManagerSwift/IQTextView`
  - `IQKeyboardManagerSwift/Resign`
- [x] Published [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) 8.0.0 by marking deprecated classes as unavailable.
 - In this release, we removed deprecated classes and marking some of them as unavailable for easier migration.
- [ ] Bug fixes which may have arrived due to the library segregation.
 - We need your support on this one.

## Introduction
While developing iOS apps, we often run into issues where the iPhone keyboard slides up and covers the `UITextField/UITextView`. `IQKeyboardManager` allows you to prevent this issue of keyboard sliding up and covering `UITextField/UITextView` without needing you to write any code or make any additional setup. To use `IQKeyboardManager` you simply need to add source files to your project.


## Key Features

1) `One Lines of Code`

2) `Works Automatically`

3) `No More UIScrollView`

4) `No More Subclasses`

5) `No More Manual Work`

6) `No More #imports`

`IQKeyboardManager` works on all orientations, and with the toolbar. It also has nice optional features allowing you to customize the distance from the text field, behavior of previous, next and done buttons in the keyboard toolbar, play sound when the user navigates through the form and more.


## Screenshot
[![Screenshot 1](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/README_Screenshot1.png)](http://youtu.be/6nhLw6hju2A)
[![Screenshot 2](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/README_Screenshot2.png)](http://youtu.be/6nhLw6hju2A)
[![Screenshot 3](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/README_Screenshot3.png)](http://youtu.be/6nhLw6hju2A)
[![Screenshot 4](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/README_Screenshot4.png)](http://youtu.be/6nhLw6hju2A)
[![Screenshot 5](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/README_Screenshot5.png)](http://youtu.be/6nhLw6hju2A)

## GIF animation
[![IQKeyboardManager](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManager.gif)](http://youtu.be/6nhLw6hju2A)

## Video

<a href="http://youtu.be/WAYc2Qj-OQg" target="_blank"><img src="http://img.youtube.com/vi/WAYc2Qj-OQg/0.jpg"
alt="IQKeyboardManager Demo Video" width="480" height="360" border="10" /></a>

## Tutorial video by @rebeloper ([#1135](https://github.com/hackiftekhar/IQKeyboardManager/issues/1135))

@rebeloper demonstrated two videos on how to implement **IQKeyboardManager** at it's core:

<a href="https://www.youtube.com/playlist?list=PL_csAAO9PQ8aTL87XnueOXi3RpWE2m_8v" target="_blank"><img src="https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/ThirdPartyYoutubeTutorial.jpg"
alt="Youtube Tutorial Playlist"/></a>

https://www.youtube.com/playlist?list=PL_csAAO9PQ8aTL87XnueOXi3RpWE2m_8v

## Warning

- **If you're planning to build SDK/library/framework and want to handle UITextField/UITextView with IQKeyboardManager then you're totally going the wrong way.** I would never suggest to add **IQKeyboardManager** as **dependency/adding/shipping** with any third-party library. Instead of adding **IQKeyboardManager** you should implement your own solution to achieve same kind of results. **IQKeyboardManager** is totally designed for projects to help developers for their convenience, it's not designed for **adding/dependency/shipping** with any **third-party library**, because **doing this could block adoption by other developers for their projects as well (who are not using IQKeyboardManager and have implemented their custom solution to handle UITextField/UITextView in the project).**
- If **IQKeyboardManager** conflicts with other **third-party library**, then it's **developer responsibility** to **enable/disable IQKeyboardManager** when **presenting/dismissing** third-party library UI. Third-party libraries are not responsible to handle IQKeyboardManager.

## Requirements

|                        | Language | Minimum iOS Target | Minimum Xcode Version |
|------------------------|----------|--------------------|-----------------------|
| IQKeyboardManager      | Obj-C    | iOS 13.0            | Xcode 13             |
| IQKeyboardManagerSwift | Swift    | iOS 13.0            | Xcode 13             |
| Demo Project           |          |                     | Xcode 15             |

#### Swift versions support

| Swift             | Xcode | IQKeyboardManagerSwift |
|-------------------|-------|------------------------|
| 5.9, 5.8, 5.7     | 16    | >= 7.0.0       |
| 5.9, 5.8, 5.7, 5.6| 15    | >= 7.0.0       |
| 5.5, 5.4, 5.3, 5.2, 5.1, 5.0, 4.2| 11  | >= 6.5.7       |
| 5.1, 5.0, 4.2, 4.0, 3.2, 3.0| 11  | >= 6.5.0       |
| 5.0,4.2, 4.0, 3.2, 3.0| 10.2  | >= 6.2.1           |
| 4.2, 4.0, 3.2, 3.0| 10.0  | >= 6.0.4               |
| 4.0, 3.2, 3.0     | 9.0   | 5.0.0                  |


Installation
==========================

#### CocoaPods

***IQKeyboardManager (Objective-C):*** To install it, simply add the following line to your Podfile: ([#9](https://github.com/hackiftekhar/IQKeyboardManager/issues/9))

```ruby
pod 'IQKeyboardManager' #iOS13 and later
```

***IQKeyboardManager (Swift):*** To install it, simply add the following line to your Podfile: ([#236](https://github.com/hackiftekhar/IQKeyboardManager/issues/236))

```ruby
pod 'IQKeyboardManagerSwift'
```

*Or you can choose the version you need based on Swift support table from [Requirements](README.md#requirements)*

```ruby
pod 'IQKeyboardManagerSwift', '8.0.0'
```

#### Carthage

To integrate `IQKeyboardManger` or `IQKeyboardManagerSwift` into your Xcode project using Carthage, add the following line to your `Cartfile`:

```ogdl
github "hackiftekhar/IQKeyboardManager"
```

Run `carthage update --use-xcframeworks` to build the frameworks and drag the appropriate framework (`IQKeyboardManager.xcframework` or `IQKeyboardManagerSwift.xcframework`) into your Xcode project based on your need. Make sure to add only one framework, not both.

#### Swift Package Manager (SPM)

To install `IQKeyboardManagerSwift` package via Xcode

 * Go to File -> Swift Packages -> Add Package Dependency...
 * Then search for https://github.com/hackiftekhar/IQKeyboardManager.git
 * And choose the version you want

#### Source Code

***IQKeyboardManager (Objective-C):*** Just ***drag and drop*** `IQKeyboardManager` directory from demo project to your project. That's it.

***IQKeyboardManager (Swift):*** Source code installation is not supported (since 7.2.0) because now the library depends on some other independent libraries. Due to this you may face compilation issues.

#### Basic Usage

In `AppDelegate.swift`, just `import IQKeyboardManagerSwift` framework and enable IQKeyboardManager.

```swift
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

      IQKeyboardManager.shared.isEnabled = true

      return true
    }
}
```



Migration Guide
==========================
- [IQKeyboardManager 8.0.0 Migration Guide](https://github.com/hackiftekhar/IQKeyboardManager/blob/master/Documentation/MIGRATION%20GUIDE%207.0%20TO%208.0.md)

Other Links
==========================

- [Known Issues](https://github.com/hackiftekhar/IQKeyboardManager/wiki/Known-Issues)
- [Manual Management Tweaks](https://github.com/hackiftekhar/IQKeyboardManager/wiki/Manual-Management)
- [Properties and functions usage](https://github.com/hackiftekhar/IQKeyboardManager/wiki/Properties-&-Functions)

## Flow Diagram
[![IQKeyboardManager CFD](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/IQKeyboardManagerFlowDiagram.jpg)](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Screenshot/IQKeyboardManagerFlowDiagram.jpg)

If you would like to see detailed Flow diagram then check [Detailed Flow Diagram](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerCFD.jpg).


LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: hack.iftekhar@gmail.com
