IQKeyboardManager MIGRATION GUIDE 5.0 TO 6.0
==========================

### 1. IQKeyboardManager functions

#### Old IQKeyboardManager functions
```swift
open class func sharedManager() -> IQKeyboardManager
@objc public class var shared: IQKeyboardManager
```
#### New IQKeyboardManager functions
```swift
```

### 2. UIView Category functions

#### Old UIView Category functions
```swift
public func viewController()->UIViewController?
```

#### New UIView Category functions
```swift
@objc public func viewContainingController()->UIViewController?
```

### 3. New features

#### IQKeyboardManager
```swift
@objc public var placeholderColor: UIColor?
@objc public var placeholderButtonColor: UIColor?
@objc public var canAdjustAdditionalSafeAreaInsets = false
```

#### UIView Category functions
```swift
@objc public var ignoreSwitchingByNextPrevious: Bool
@objc public var shouldResignOnTouchOutsideMode: IQEnableMode
@objc public func parentContainerViewController()->UIViewController?
```
