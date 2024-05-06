IQKeyboardManager MIGRATION GUIDE 2.0 TO 3.0
==========================

### 1. New features

#### IQKeyboardManager
```objc
@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;
@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;
@property(nonatomic, assign) BOOL canAdjustTextView;
```

- Cocoapods support added

#### UIVIew Category
```objc
- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder;
- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder;
- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder;
```


