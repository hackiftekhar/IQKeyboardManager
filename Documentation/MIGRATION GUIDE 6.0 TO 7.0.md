IQKeyboardManager MIGRATION GUIDE 6.0 TO 7.0
==========================

### 1. Removed IQKeyboardManager functions
```swift
@objc public var preventShowingBottomBlankSpace = true
@objc public var shouldFixInteractivePopGestureRecognizer = true
@objc public var canAdjustAdditionalSafeAreaInsets = false
@objc func registerTextFieldViewClass(_ aClass: UIView.Type,
                                      didBeginEditingNotificationName: String,
                                      didEndEditingNotificationName: String)
@objc func unregisterTextFieldViewClass(_ aClass: UIView.Type,
                                        didBeginEditingNotificationName: String,
                                        didEndEditingNotificationName: String)                                          
```

### 2. Removed UIViewController functions
```swift
@IBOutlet @objc public var IQLayoutGuideConstraint: NSLayoutConstraint?
```

### 3. IQKeyboardManager functions

#### Old IQKeyboardManager functions
```swift
@objc var shouldResignOnTouchOutside: Bool
@objc var shouldPlayInputClicks: Bool

@objc var toolbarManageBehaviour: IQAutoToolbarManageBehavior
@objc var shouldToolbarUsesTextFieldTintColor: Bool
@objc var toolbarTintColor: UIColor?
@objc var toolbarBarTintColor: UIColor?
@objc var previousNextDisplayMode: IQPreviousNextDisplayMode

@objc var toolbarPreviousBarButtonItemImage: UIImage?
@objc var toolbarPreviousBarButtonItemText: String?
@objc var toolbarPreviousBarButtonItemAccessibilityLabel: String?

@objc var toolbarNextBarButtonItemImage: UIImage?
@objc var toolbarNextBarButtonItemText: String?
@objc var toolbarNextBarButtonItemAccessibilityLabel: String?

@objc var toolbarDoneBarButtonItemImage: UIImage?
@objc var toolbarDoneBarButtonItemText: String?
@objc var toolbarDoneBarButtonItemAccessibilityLabel: String?

@objc var toolbarTitlBarButtonItemAccessibilityLabel: String?
@objc var shouldShowToolbarPlaceholder: Bool
@objc var placeholderFont: UIFont?
@objc var placeholderColor: UIColor?
@objc var placeholderButtonColor: UIColor?

@objc var overrideKeyboardAppearance: Bool
@objc var keyboardAppearance: UIKeyboardAppearance

@objc func registerKeyboardSizeChange(identifier: AnyHashable, sizeHandler: @escaping SizeBlock)
@objc func unregisterKeyboardSizeChange(identifier: AnyHashable) {}   
@objc var keyboardShowing: Bool
@objc var keyboardFrame: CGRect
```
#### New IQKeyboardManager functions
```swift
@objc public var resignOnTouchOutside: Bool
@objc public var playInputClicks: Bool

@objc public let toolbarConfiguration: IQToolbarConfiguration = .init()
/*
toolbarConfiguration.manageBehavior
toolbarConfiguration.useTextFieldTintColor
toolbarConfiguration.tintColor
toolbarConfiguration.barTintColor
toolbarConfiguration.previousNextDisplayMode
*/

@objc public var previousBarButtonConfiguration: IQBarButtonItemConfiguration?
/*
toolbarConfiguration.previousBarButtonConfiguration.image
toolbarConfiguration.previousBarButtonConfiguration.title
toolbarConfiguration.previousBarButtonConfiguration.accessibilityLabel    
*/

@objc public var nextBarButtonConfiguration: IQBarButtonItemConfiguration?
/*
toolbarConfiguration.nextBarButtonConfiguration.image
toolbarConfiguration.nextBarButtonConfiguration.title
toolbarConfiguration.nextBarButtonConfiguration.accessibilityLabel    
*/

@objc public var doneBarButtonConfiguration: IQBarButtonItemConfiguration?
/*
toolbarConfiguration.doneBarButtonConfiguration.image
toolbarConfiguration.doneBarButtonConfiguration.title
toolbarConfiguration.doneBarButtonConfiguration.accessibilityLabel    
*/

@objc public let placeholderConfiguration: IQToolbarPlaceholderConfiguration
/*
toolbarConfiguration.placeholderConfiguration.accessibilityLabel
toolbarConfiguration.placeholderConfiguration.showPlaceholder
toolbarConfiguration.placeholderConfiguration.font
toolbarConfiguration.placeholderConfiguration.color
toolbarConfiguration.placeholderConfiguration.buttonColor
*/

@objc public let keyboardConfiguration: IQKeyboardConfiguration
/*
keyboardConfiguration.overrideAppearance
keyboardConfiguration.appearance
*/

class IQKeyboardListener {
    public var keyboardShowing: Bool
    public var frame: CGRect
    public init()
    public func registerSizeChange(identifier: AnyHashable, changeHandler: @escaping SizeCompletion)
    public func unregisterSizeChange(identifier: AnyHashable)
}
}
```

### 1. UIScrollView extension functions

#### Old functions
```swift
var shouldIgnoreScrollingAdjustment: Bool
var shouldIgnoreContentInsetAdjustment: Bool
var shouldRestoreScrollViewContentOffset: Bool
```
#### New functions
```swift
var iq: IQKeyboardManagerWrapper<UIScrollView>
/*
iq.ignoreScrollingAdjustment
iq.ignoreContentInsetAdjustment
iq.restoreContentOffset
*/
```

### 1. UIView extension functions

#### Old functions
```swift
var keyboardDistanceFromTextField: CGFloat
var ignoreSwitchingByNextPrevious: Bool
var enableMode: IQEnableMode
var shouldResignOnTouchOutsideMode: IQEnableMode
```
#### New functions
```swift
var iq: IQKeyboardManagerWrapper<UIView>
/*
iq.distanceFromKeyboard
iq.ignoreSwitchingByNextPrevious
iq.enableMode
iq.resignOnTouchOutsideMode
*/
```


### 2. UIView extension functions

#### Old UIView extension functions
```swift
func viewContainingController() -> UIViewController?
func topMostController() -> UIViewController?
func parentContainerViewController() -> UIViewController?
func superviewOfClassType(_ classType: UIView.Type, belowView: UIView? = nil) -> UIView?
```

#### New UIView extension functions
```swift
var iq: IQKeyboardManagerWrapper<UIView>
/*
iq.viewContainingController()
iq.topMostController()
iq.parentContainerViewController()
iq.superviewOf(type:belowView:)
*/
```

### 2. UIView extension functions

#### Old UIView extension functions
```swift
var keyboardToolbar: IQToolbar
var shouldHideToolbarPlaceholder: Bool
var toolbarPlaceholder: String?
var drawingToolbarPlaceholder: String?
func addKeyboardToolbarWithTarget(target: AnyObject?,
                                  titleText: String?,
                                  titleAccessibilityLabel: String? = nil,
                                  rightBarButtonConfiguration: IQBarButtonItemConfiguration?,
                                  previousBarButtonConfiguration: IQBarButtonItemConfiguration? = nil,
                                  nextBarButtonConfiguration: IQBarButtonItemConfiguration? = nil)
```

#### New UIView extension functions
```swift
var iq: IQKeyboardManagerWrapper<UIView>
/*
iq.toolbar
iq.hidePlaceholder
iq.placeholder
iq.drawingPlaceholder
iq.addToolbar(target:previousConfiguration:nextConfiguration:rightConfiguration:title:titleAccessibilityLabel:)
*/
```


### 2. UIViewController extension functions

#### Old UIViewController extension functions
```swift
open func parentIQContainerViewController() -> UIViewController?
```

#### New UIViewController extension functions
```swift
open func iq_parentContainerViewController() -> UIViewController?
```

### 3. New features

#### IQKeyboardManager
```swift
```

#### UIView Category functions
```swift
@property(nonatomic, assign) BOOL shouldIgnoreContentInsetAdjustment;
@property(nonatomic, assign) IQEnableMode enableMode;
```
#### UIViewController functions
```swift
-(nullable UIViewController*)parentIQContainerViewController;
```
