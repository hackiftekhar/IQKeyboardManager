IQKeyboardManager MIGRATION GUIDE 1.0 TO 2.0
==========================

### 1. Class Name changed

Old class name
```objc
@interface IQKeyBoardManager : NSObject {
    //...
}
```
New Class Name
```objc
@interface IQKeyboardManager : NSObject {
    //...
}
```

### 2. Function name changes

Old function and property names
```objc
+(void)installKeyboardManager;
+(void)setTextFieldDistanceFromKeyboard:(CGFloat)distance;
+(void)enableKeyboardManger;
+(void)disableKeyboardManager;
```
New function and property names
```objc
+ (IQKeyboardManager*)sharedManager;
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;
@property(nonatomic, assign, getter = isEnabled) BOOL enable;
```

### 3. New features

#### IQKeyboardManager
```objc
@property(nonatomic, assign, getter = isEnableAutoToolbar) BOOL enableAutoToolbar;
@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;
- (void)resignFirstResponder;
```

- Cocoapods support added

#### UIVIew Category
```objc
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction;
```


