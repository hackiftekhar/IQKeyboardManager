IQKeyboardManager MIGRATION GUIDE 7.0 TO 8.0
==========================

### 1. Features removed (Moved to their own independent libraries)
- All features related to toolbar handling has been moved to `IQKeyboardToolbarManager` [Link](https://github.com/hackiftekhar/IQKeyboardToolbarManager)
- `IQKeyboardListener` [Link](https://github.com/hackiftekhar/IQKeyboardNotification) (Renamed to `IQKeyboardNotification`)
- `IQTextFieldViewListener` [Link](https://github.com/hackiftekhar/IQTextInputViewNotification) (Renamed to `IQTextInputViewNotification`)
- `IQReturnKeyHandler` [Link](https://github.com/hackiftekhar/IQKeyboardReturnManager) (Renamed to `IQKeyboardReturnManager`)
- `IQKeyboardToolbar` [Link](https://github.com/hackiftekhar/IQKeyboardToolbar)
- `IQTextView` [Link](https://github.com/hackiftekhar/IQTextView)

### 2. Features moved to IQKeyboardToolbarManager
- `IQPreviousNextView` class (Renamed to `IQDeepResponderContainerView`)
    If you are using `IQPreviousNextView` in your storyboard then you have to change the class to `IQDeepResponderContainerView` and also have to change the module to `IQKeyboardToolbarManager`.
- `IQToolbarConfiguration` class (Renamed to `IQKeyboardToolbarConfiguration`)
- `IQToolbarPlaceholderConfiguration` class (Renamed to `IQKeyboardToolbarPlaceholderConfiguration`)
- `public enum IQAutoToolbarManageBehavior: Int`
- `public enum IQPreviousNextDisplayMode: Int`
- `IQBarButtonItemConfiguration` class

```swift
// These were part of IQKeyboardManager
var enableAutoToolbar: Bool (Renamed to `isEnabled`)
var toolbarConfiguration: IQToolbarConfiguration
var playInputClicks: Bool
var disabledToolbarClasses: [UIViewController.Type]
var enabledToolbarClasses: [UIViewController.Type]
var deepResponderAllowedContainerClasses: [UIView.Type]
var canGoPrevious: Bool
var canGoNext: Bool
func goPrevious() -> Bool
func goNext() -> Bool
func reloadInputViews()
```
```swift
// UITextField/UITextView extensions, This can be used like textField.iq.ignoreSwitchingByNextPrevious = true
var ignoreSwitchingByNextPrevious: Bool
```

### 3. Features moved to IQKeyboardToolbar
- `IQToolbar` class (Renamed to `IQKeyboardToolbar`)
- `IQToolbarConfiguration` class (Renamed to `IQKeyboardToolbarConfiguration`)
- `IQToolbarPlaceholderConfiguration` class (Renamed to `IQKeyboardToolbarPlaceholderConfiguration`)
- `IQBarButtonItemConfiguration` class
- `IQTitleBarButtonItem` class
- `IQBarButtonItem` class
- `IQInvocation` class
- `IQPlaceholderable` protocol

```swift
// UITextField/UITextView extensions, This can be used like textField.iq.hidePlaceholder = true
var toolbar: IQToolbar
var hidePlaceholder: Bool
var placeholder: String?
var drawingPlaceholder: String?
func addToolbar(target: AnyObject?,
                    previousConfiguration: IQBarButtonItemConfiguration? = nil,
                    nextConfiguration: IQBarButtonItemConfiguration? = nil,
                    rightConfiguration: IQBarButtonItemConfiguration? = nil,
                    title: String?,
                    titleAccessibilityLabel: String? = nil)
func addDone(...)
func addRightButton(...)
func addRightLeft(...)
func addPreviousNextRight(...)
func addPreviousNextDone(...)
```


### 1. Features moved to subspecs (Cocoapods)
- `IQKeyboardManagerSwift/Appearance`
```swift
// IQKeyboardManager
public var overrideAppearance: Bool
public var appearance: UIKeyboardAppearance
```
- `IQKeyboardManagerSwift/IQKeyboardReturnManager`
```swift
// https://github.com/hackiftekhar/IQKeyboardReturnManager
- This subspec add `IQKeyboardReturnManager` as dependency for easier migration.
```
- `IQKeyboardManagerSwift/IQKeyboardToolbarManager`
```swift
// https://github.com/hackiftekhar/IQKeyboardToolbarManager
- This subspec add `IQKeyboardToolbarManager` as dependency for easier migration.
```
- `IQKeyboardManagerSwift/IQTextView`
```swift
// https://github.com/hackiftekhar/IQTextView
- This subspec add `IQTextView` as dependency for easier migration.
```
- `IQKeyboardManagerSwift/Resign`
```swift
// IQKeyboardManager
var resignOnTouchOutside: Bool
var resignGesture: UITapGestureRecognizer
var disabledTouchResignedClasses: [UIViewController.Type]
var enabledTouchResignedClasses: [UIViewController.Type]
var touchResignedGestureIgnoreClasses: [UIView.Type]
func resignFirstResponder() -> Bool
```
```swift
// UITextField/UITextView extensions, This can be used like textField.iq.resignOnTouchOutsideMode = .default
var resignOnTouchOutsideMode: IQEnableMode
```
