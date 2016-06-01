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

`pod 'IQKeyboardManagerSwift', '4.0.3'`

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

You can find known issues list [here](https://github.com/hackiftekhar/IQKeyboardManager/blob/master/KNOWN ISSUES.md).

Manual Management:-
---

You can find some manual management tweaks & examples [here](https://github.com/hackiftekhar/IQKeyboardManager/blob/master/MANUAL MANAGEMENT.md).



## Control Flow Diagram
[![IQKeyboardManager CFD](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerCFD.jpg)](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/v3.3.0/Screenshot/IQKeyboardManagerCFD.jpg)


##Properties and functions usage:-

You can find some documentation about properties, methods and their uses [here](https://github.com/hackiftekhar/IQKeyboardManager/blob/master/PROPERTIES & FUNCTIONS.md).


LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: hack.iftekhar@gmail.com
