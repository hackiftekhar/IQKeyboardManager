IQKeyboardManager MIGRATION GUIDE 3.0 TO 4.0
==========================

### 1. New features

New Class
```objc
@interface IQKeyboardReturnKeyHandler : NSObject {
    //...
}
-(nonnull instancetype)initWithViewController:(nullable UIViewController*)controller
@property(nullable, nonatomic, weak) id<UITextFieldDelegate,UITextViewDelegate> delegate;
@property(nonatomic, assign) UIReturnKeyType lastTextFieldReturnKeyType;
-(void)addTextFieldView:(nonnull UIView*)textFieldView;
-(void)removeTextFieldView:(nonnull UIView*)textFieldView;
-(void)addResponderFromView:(nonnull UIView*)view;
-(void)removeResponderFromView:(nonnull UIView*)view;
@end
```

New Class
```objc
@interface IQTextView : UITextView
@property(nullable, nonatomic,copy)   NSString    *placeholder;
@end
```

#### IQKeyboardManager
```objc
@property(nonatomic, assign) BOOL preventShowingBottomBlankSpace;
@property(nonatomic, assign) BOOL shouldToolbarUsesTextFieldTintColor;
@property(nullable, nonatomic, strong) UIColor *toolbarTintColor;
@property(nullable, nonatomic, strong) UIImage *toolbarDoneBarButtonItemImage;
@property(nullable, nonatomic, strong) NSString *toolbarDoneBarButtonItemText;
@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;
@property(nullable, nonatomic, strong) UIFont *placeholderFont;
@property(nonatomic, assign) BOOL shouldFixTextViewClip;
@property(nonatomic, assign) BOOL overrideKeyboardAppearance;
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic, readonly) BOOL canGoPrevious;
@property (nonatomic, readonly) BOOL canGoNext;
@property(nonatomic, assign) BOOL shouldPlayInputClicks;
@property(nonatomic, assign) BOOL shouldAdoptDefaultKeyboardAnimation;
@property(nonatomic, assign) BOOL layoutIfNeededOnUpdate;
- (BOOL)goPrevious;
- (BOOL)goNext;
-(void)disableDistanceHandlingInViewControllerClass:(nonnull Class)disabledClass;
-(void)removeDisableDistanceHandlingInViewControllerClass:(nonnull Class)disabledClass;
-( NSSet* _Nonnull )disabledInViewControllerClasses;
-(void)disableToolbarInViewControllerClass:(nonnull Class)toolbarDisabledClass;
-(void)removeDisableToolbarInViewControllerClass:(nonnull Class)toolbarDisabledClass;
-( NSSet* _Nonnull )disabledToolbarInViewControllerClasses;
-(void)considerToolbarPreviousNextInViewClass:(nonnull Class)toolbarPreviousNextConsideredClass;
-(void)removeConsiderToolbarPreviousNextInViewClass:(nonnull Class)toolbarPreviousNextConsideredClass;
-(NSSet* _Nonnull)consideredToolbarPreviousNextViewClasses;
```

#### UIVIew Category
```objc
@property (assign, nonatomic) BOOL shouldHideTitle;
-(void)setCustomPreviousTarget:(nullable id)target action:(nullable SEL)action;
-(void)setCustomNextTarget:(nullable id)target action:(nullable SEL)action;
-(void)setCustomDoneTarget:(nullable id)target action:(nullable SEL)action;
- (void)addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;
- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;
- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;
- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;
- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;
```

#### UIVIew Category
```objc
@property (nonatomic, readonly) BOOL isAskingCanBecomeFirstResponder;
@property (nullable, nonatomic, readonly, strong) UIViewController *viewController;
@property (nullable, nonatomic, readonly, strong) UIViewController *topMostController;
-(nullable UIView*)superviewOfClassType:(nonnull Class)classType;
@property (nonatomic, getter=isSearchBarTextField, readonly) BOOL searchBarTextField;
@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;
-(CGAffineTransform)convertTransformToView:(nullable UIView*)toView;
```

#### UIScrollView Category
```objc
@property(nonatomic, assign) BOOL shouldRestoreScrollViewContentOffset;
```

#### UIView Category (For UITextField and UITextView)
```objc
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;
```

#### UIViewController Category
```objc
@property(nullable, nonatomic, strong) IBOutlet NSLayoutConstraint *IQLayoutGuideConstraint;
```

#### Swift version added
