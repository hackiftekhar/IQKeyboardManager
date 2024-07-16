<p align="center">
  <img src="https://raw.githubusercontent.com/hackiftekhar/IQKeyboardManager/master/Demo/Resources/icon.png" alt="Icon"/>
</p>
<H1 align="center">IQKeyboardManager</H1>
<p align="center">
  <img src="https://img.shields.io/github/license/hackiftekhar/IQKeyboardManager.svg"
  alt="GitHub license"/>


[![Build Status](https://travis-ci.org/hackiftekhar/IQKeyboardManager.svg)](https://travis-ci.org/hackiftekhar/IQKeyboardManager)


While developing iOS apps, we often run into issues where the iPhone keyboard slides up and covers the `UITextField/UITextView`. `IQKeyboardManager` allows you to prevent this issue of keyboard sliding up and covering `UITextField/UITextView` without needing you to write any code or make any additional setup. To use `IQKeyboardManager` you simply need to add source files to your project.


#### Key Features

1) `One Lines of Code`

2) `Works Automatically`

3) `No More UIScrollView`

4) `No More Subclasses`

5) `No More Manual Work`

6) `No More #imports`

`IQKeyboardManager` works on all orientations, and with the toolbar. It also has nice optional features allowing you to customize the distance from the text field, behaviour of previous, next and done buttons in the keyboard toolbar, play sound when the user navigates through the form and more.


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
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

|                        | Language | Minimum iOS Target | Minimum Xcode Version |
|------------------------|----------|--------------------|-----------------------|
| IQKeyboardManager      | Obj-C    | iOS 11.0            | Xcode 13             |
| IQKeyboardManagerSwift | Swift    | iOS 13.0            | Xcode 13             |
| Demo Project           |          |                     | Xcode 15             |

#### Swift versions support

| Swift             | Xcode | IQKeyboardManagerSwift |
|-------------------|-------|------------------------|
| 5.9, 5.8, 5.7, 5.6| 15  | >= 7.0.0       |
| 5.5, 5.4, 5.3, 5.2, 5.1, 5.0, 4.2| 11  | >= 6.5.7       |
| 5.1, 5.0, 4.2, 4.0, 3.2, 3.0| 11  | >= 6.5.0       |
| 5.0,4.2, 4.0, 3.2, 3.0| 10.2  | >= 6.2.1           |
| 4.2, 4.0, 3.2, 3.0| 10.0  | >= 6.0.4               |
| 4.0, 3.2, 3.0     | 9.0   | 5.0.0                  |

## 7.0.0 version notes
- In this major release, a lot of variables and functions have been moved here and there. We have mentioned most of the major things in the MIGRATION GUIDE. So please take a look to make changes in your project when upgrading to this version.
- The 7.0.0 version adopted the latest Swift Concurrency/Actor feature and only available iOS 13.0 and above.
- Internal keyboard management handling have been updated with a different and better approach than legacy versions. However when adopting 7.0.0, please verify if it is working as expected in your apps, if there are any serious problems with 7.0.0 please open an issue with all the details and switch back to legacy version temporarily.

Installation
==========================

#### Installation with CocoaPods

[![CocoaPods](https://img.shields.io/cocoapods/v/IQKeyboardManager.svg)](http://cocoadocs.org/docsets/IQKeyboardManager)

***IQKeyboardManager (Objective-C):*** IQKeyboardManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile: ([#9](https://github.com/hackiftekhar/IQKeyboardManager/issues/9))

```ruby
pod 'IQKeyboardManager' #iOS13 and later
```

***IQKeyboardManager (Swift):*** IQKeyboardManagerSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile: ([#236](https://github.com/hackiftekhar/IQKeyboardManager/issues/236))

*Swift 5.9, 5.8, 5.7, 5.6, 5.5 (Xcode 15)*

```ruby
pod 'IQKeyboardManagerSwift'
```

*Or you can choose the version you need based on Swift support table from [Requirements](README.md#requirements)*

```ruby
pod 'IQKeyboardManagerSwift', '6.3.0'
```

In AppDelegate.swift, just import IQKeyboardManagerSwift framework and enable IQKeyboardManager.

```swift
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

      IQKeyboardManager.shared.enable = true

      return true
    }
}
```

#### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `IQKeyboardManger` or `IQKeyboardManagerSwift` into your Xcode project using Carthage, add the following line to your `Cartfile`:

```ogdl
github "hackiftekhar/IQKeyboardManager"
```

Run `carthage` to build the frameworks and drag the appropriate framework (`IQKeyboardManager.framework` or `IQKeyboardManagerSwift.framework`) into your Xcode project based on your need. Make sure to add only one framework and not both.


#### Installation with Source Code

[![Github tag](https://img.shields.io/github/tag/hackiftekhar/iqkeyboardmanager.svg)]()



***IQKeyboardManager (Objective-C):*** Just ***drag and drop*** `IQKeyboardManager` directory from demo project to your project. That's it.

***IQKeyboardManager (Swift):*** ***Drag and drop*** `IQKeyboardManagerSwift` directory from demo project to your project

In AppDelegate.swift, just enable IQKeyboardManager.

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

      IQKeyboardManager.shared.enable = true

      return true
    }
}
```

#### Installation with Swift Package Manager

[Swift Package Manager(SPM)](https://swift.org/package-manager/) is Apple's dependency manager tool. It is now supported in Xcode 11. So it can be used in all appleOS types of projects. It can be used alongside other tools like CocoaPods and Carthage as well. 

To install IQKeyboardManagerSwift package via Xcode

 * Go to File -> Swift Packages -> Add Package Dependency...
 * Then search for https://github.com/hackiftekhar/IQKeyboardManager.git
 * And choose the version you want

Migration Guide
==========================
- [IQKeyboardManager 6.0.0 Migration Guide](https://github.com/hackiftekhar/IQKeyboardManager/wiki/IQKeyboardManager-6.0.0-Migration-Guide)
- [IQKeyboardManager 7.0.0 Migration Guide](https://github.com/hackiftekhar/IQKeyboardManager/wiki/IQKeyboardManager-7.0.0-Migration-Guide)

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
