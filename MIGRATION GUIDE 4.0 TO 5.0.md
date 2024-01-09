IQKeyboardManager MIGRATION GUIDE 4.0 TO 5.0
==========================

### 1. Removed UIView Category features
```swift
public var isAskingCanBecomeFirstResponder: Bool // This is not necessary now
```

### 1. Removed IQKeyboardManager features
```swift
public var shouldFixTextViewClip = true // These are internally handled, so no more needed
public var canAdjustTextView = false // These are internally handled, so no more needed
public var shouldAdoptDefaultKeyboardAnimation = true   // This no longer needed
```

### 2. IQKeyboardManager functions

#### Old IQKeyboardManager functions
```swift
public func disableDistanceHandlingInViewControllerClass(disabledClass : AnyClass)
public func removeDisableDistanceHandlingInViewControllerClass(disabledClass : AnyClass)
public func disabledInViewControllerClassesString() -> Set<String>
public func disableToolbarInViewControllerClass(toolbarDisabledClass : AnyClass)
public func removeDisableToolbarInViewControllerClass(toolbarDisabledClass : AnyClass)
public func disabledToolbarInViewControllerClassesString() -> Set<String>
public func considerToolbarPreviousNextInViewClass(toolbarPreviousNextConsideredClass : AnyClass)
public func removeConsiderToolbarPreviousNextInViewClass(toolbarPreviousNextConsideredClass : AnyClass)
public func consideredToolbarPreviousNextViewClassesString() -> Set<String>
```
#### New IQKeyboardManager functions
```swift
open var disabledDistanceHandlingClasses = [UIViewController.Type]()
open var enabledDistanceHandlingClasses = [UIViewController.Type]()
open var disabledToolbarClasses = [UIViewController.Type]()
open var enabledToolbarClasses = [UIViewController.Type]()
open var toolbarPreviousNextAllowedClasses = [UIView.Type]()
open var disabledTouchResignedClasses = [UIViewController.Type]()
open var enabledTouchResignedClasses = [UIViewController.Type]()
open var touchResignedGestureIgnoreClasses = [UIView.Type]()
```

### 3. UIView Category functions

#### Old UIView Category functions
```swift
public var shouldHideTitle: Bool?
public var drawingPlaceholderText: String?
public func setCustomPreviousTarget(target: AnyObject?, selector: Selector?)
public func setCustomNextTarget(target: AnyObject?, selector: Selector?)
```

#### New UIView Category functions
```swift
public var shouldHidePlaceholderText: Bool
public var keyboardToolbar: IQToolbar
public var shouldHideToolbarPlaceholder: Bool
public var drawingToolbarPlaceholder: String?
open func setTarget(_ target: AnyObject?, action: Selector?) // in IQBarButtonItem
```

### 4. New features

#### IQKeyboardManager
```swift
open var toolbarBarTintColor : UIColor?
open var keyboardShowing: Bool
open var movedDistance: CGFloat
open var enableDebugging = false
open var shouldFixInteractivePopGestureRecognizer = true
open var previousNextDisplayMode = IQPreviousNextDisplayMode.Default
open func reloadInputViews()
open func reloadLayoutIfNeeded()
open func registerAllNotifications()
open func registerTextFieldViewClass(_ aClass: UIView.Type, didBeginEditingNotificationName : String, didEndEditingNotificationName : String)
open func unregisterTextFieldViewClass(_ aClass: UIView.Type, didBeginEditingNotificationName : String, didEndEditingNotificationName : String)
```

#### UIScrollView Category
```swift
public var shouldIgnoreScrollingAdjustment: Bool
```

