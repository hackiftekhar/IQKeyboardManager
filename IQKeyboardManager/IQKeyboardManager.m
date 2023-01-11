//
// IQKeyboardManager.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-16 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IQKeyboardManager.h"
#import "IQUIView+Hierarchy.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "IQNSArray+Sort.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQUIScrollView+Additions.h"
#import "IQUITextFieldView+Additions.h"
#import "IQUIViewController+Additions.h"
#import "IQPreviousNextView.h"

#import <QuartzCore/CABase.h>

#import <objc/runtime.h>

#import <UIKit/UIAlertController.h>
#import <UIKit/UISearchBar.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITableViewController.h>
#import <UIKit/UICollectionViewController.h>
#import <UIKit/UICollectionViewCell.h>
#import <UIKit/UICollectionViewLayout.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UITouch.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIStackView.h>
#import <UIKit/NSLayoutConstraint.h>
#import <UIKit/UIStackView.h>
#import <UIKit/UIAccessibility.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#import <UIKit/UIWindowScene.h>
#import <UIKit/UIStatusBarManager.h>
#endif

NSInteger const kIQDoneButtonToolbarTag             =   -1002;
NSInteger const kIQPreviousNextButtonToolbarTag     =   -1005;

#define kIQCGPointInvalid CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)

typedef void (^SizeBlock)(CGSize size);

@interface IQKeyboardManager()<UIGestureRecognizerDelegate>

/*******************************************/

/** used to adjust contentInset of UITextView. */
@property(nonatomic, assign) UIEdgeInsets     startingTextViewContentInsets;

/** used to adjust scrollIndicatorInsets of UITextView. */
@property(nonatomic, assign) UIEdgeInsets   startingTextViewScrollIndicatorInsets;

/** used with textView to detect a textFieldView contentInset is changed or not. (Bug ID: #92)*/
@property(nonatomic, assign) BOOL    isTextViewContentInsetChanged;

/*******************************************/

/** To save UITextField/UITextView object voa textField/textView notifications. */
@property(nullable, nonatomic, weak) UIView       *textFieldView;

/** To save rootViewController.view.frame.origin. */
@property(nonatomic, assign) CGPoint    topViewBeginOrigin;

/** To save rootViewController */
@property(nullable, nonatomic, weak) UIViewController *rootViewController;

/** To overcome with popGestureRecognizer issue Bug ID: #1361 */
@property(nullable, nonatomic, weak) UIViewController *rootViewControllerWhilePopGestureRecognizerActive;
@property(nonatomic, assign) CGPoint    topViewBeginOriginWhilePopGestureRecognizerActive;

/** To know if we have any pending request to adjust view position. */
@property(nonatomic, assign) BOOL   hasPendingAdjustRequest;

/*******************************************/

/** Variable to save lastScrollView that was scrolled. */
@property(nullable, nonatomic, weak) UIScrollView     *lastScrollView;

/** LastScrollView's initial contentInsets. */
@property(nonatomic, assign) UIEdgeInsets   startingContentInsets;

/** LastScrollView's initial scrollIndicatorInsets. */
@property(nonatomic, assign) UIEdgeInsets   startingScrollIndicatorInsets;

/** LastScrollView's initial contentOffset. */
@property(nonatomic, assign) CGPoint        startingContentOffset;

/*******************************************/

/** To save keyboard animation duration. */
@property(nonatomic, assign) CGFloat    animationDuration;

/** To mimic the keyboard animation */
@property(nonatomic, assign) NSInteger  animationCurve;

/*******************************************/

/** TapGesture to resign keyboard on view's touch. It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one */
@property(nonnull, nonatomic, strong, readwrite) UITapGestureRecognizer  *resignFirstResponderGesture;

/**
 moved distance to the top used to maintain distance between keyboard and textField. Most of the time this will be a positive value.
 */
@property(nonatomic, assign, readwrite) CGFloat movedDistance;

/*******************************************/

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledDistanceHandlingClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledDistanceHandlingClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledToolbarClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledToolbarClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *toolbarPreviousNextAllowedClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledTouchResignedClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledTouchResignedClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *touchResignedGestureIgnoreClasses;

/*******************************************/

@end

@implementation IQKeyboardManager
{
	@package

    /*******************************************/
    
    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    NSNotification          *_kbShowNotification;
    
    /** To save keyboard size. */
    CGRect                   _kbFrame;

    CGSize                   _keyboardLastNotifySize;
    NSMutableDictionary<id<NSCopying>, SizeBlock>* _keyboardSizeObservers;

    /*******************************************/
}

//UIKeyboard handling
@synthesize enable                              =   _enable;
@synthesize keyboardDistanceFromTextField       =   _keyboardDistanceFromTextField;

//Keyboard Appearance handling
@synthesize overrideKeyboardAppearance          =   _overrideKeyboardAppearance;
@synthesize keyboardAppearance                  =   _keyboardAppearance;

//IQToolbar handling
@synthesize enableAutoToolbar                   =   _enableAutoToolbar;
@synthesize toolbarManageBehaviour              =   _toolbarManageBehaviour;

@synthesize shouldToolbarUsesTextFieldTintColor =   _shouldToolbarUsesTextFieldTintColor;
@synthesize toolbarTintColor                    =   _toolbarTintColor;
@synthesize toolbarBarTintColor                 =   _toolbarBarTintColor;
@synthesize shouldShowToolbarPlaceholder        =   _shouldShowToolbarPlaceholder;
@synthesize placeholderFont                     =   _placeholderFont;
@synthesize placeholderColor                    =   _placeholderColor;
@synthesize placeholderButtonColor              =   _placeholderButtonColor;

//Resign handling
@synthesize shouldResignOnTouchOutside          =   _shouldResignOnTouchOutside;
@synthesize resignFirstResponderGesture         =   _resignFirstResponderGesture;

//Sound handling
@synthesize shouldPlayInputClicks               =   _shouldPlayInputClicks;

//Animation handling
@synthesize layoutIfNeededOnUpdate              =   _layoutIfNeededOnUpdate;

#pragma mark - Initializing functions

/**
 Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code)
 
 @Note: If you want to disable `+ (void)load` method, you can add build setting in configurations. Like that:
       `{ 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) IQ_KEYBOARD_MANAGER_LOAD_METHOD_DISABLE=1' }`
 */
#if !IQ_KEYBOARD_MANAGER_LOAD_METHOD_DISABLE
+(void)load
{
    //Enabling IQKeyboardManager. Loading asynchronous on main thread
    [self performSelectorOnMainThread:@selector(sharedManager) withObject:nil waitUntilDone:NO];
}
#endif

/*  Singleton Object Initialization. */
-(instancetype)init
{
	if (self = [super init])
    {
        __weak __typeof__(self) weakSelf = self;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            __strong __typeof__(self) strongSelf = weakSelf;
            
            [strongSelf registerAllNotifications];

            //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
            strongSelf.resignFirstResponderGesture = [[UITapGestureRecognizer alloc] initWithTarget:strongSelf action:@selector(tapRecognized:)];
            strongSelf.resignFirstResponderGesture.cancelsTouchesInView = NO;
            [strongSelf.resignFirstResponderGesture setDelegate:strongSelf];
            strongSelf.resignFirstResponderGesture.enabled = strongSelf.shouldResignOnTouchOutside;
            strongSelf.topViewBeginOrigin = kIQCGPointInvalid;
            strongSelf.topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
            
            //Setting it's initial values
            strongSelf.animationDuration = 0.25;
            strongSelf.animationCurve = UIViewAnimationCurveEaseInOut;
            [strongSelf setEnable:YES];
			[strongSelf setKeyboardDistanceFromTextField:10.0];
            [strongSelf setShouldPlayInputClicks:YES];
            [strongSelf setShouldResignOnTouchOutside:NO];
            [strongSelf setOverrideKeyboardAppearance:NO];
            [strongSelf setKeyboardAppearance:UIKeyboardAppearanceDefault];
            [strongSelf setEnableAutoToolbar:YES];
            [strongSelf setShouldShowToolbarPlaceholder:YES];
            [strongSelf setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            [strongSelf setLayoutIfNeededOnUpdate:NO];
            [strongSelf setShouldToolbarUsesTextFieldTintColor:NO];

            //Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay (Bug ID: #550)
            {
                //If you experience exception breakpoint issue at below line then try these solutions https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
                UITextField *view = [[UITextField alloc] init];
                [view addDoneOnKeyboardWithTarget:nil action:nil];
                [view addPreviousNextDoneOnKeyboardWithTarget:nil previousAction:nil nextAction:nil doneAction:nil];
            }

            strongSelf->_keyboardSizeObservers = [[NSMutableDictionary alloc] init];
            //Initializing disabled classes Set.
            strongSelf.disabledDistanceHandlingClasses = [[NSMutableSet alloc] initWithObjects:[UITableViewController class],[UIAlertController class], nil];
            strongSelf.enabledDistanceHandlingClasses = [[NSMutableSet alloc] init];
            
            strongSelf.disabledToolbarClasses = [[NSMutableSet alloc] initWithObjects:[UIAlertController class], nil];
            strongSelf.enabledToolbarClasses = [[NSMutableSet alloc] init];
            
            strongSelf.toolbarPreviousNextAllowedClasses = [[NSMutableSet alloc] initWithObjects:[UITableView class],[UICollectionView class],[IQPreviousNextView class], nil];
            
            strongSelf.disabledTouchResignedClasses = [[NSMutableSet alloc] initWithObjects:[UIAlertController class], nil];
            strongSelf.enabledTouchResignedClasses = [[NSMutableSet alloc] init];
            strongSelf.touchResignedGestureIgnoreClasses = [[NSMutableSet alloc] initWithObjects:[UIControl class],[UINavigationBar class], nil];
        });
    }
    return self;
}

/*  Automatically called from the `+(void)load` method. */
+ (IQKeyboardManager*)sharedManager
{
	//Singleton instance
	static IQKeyboardManager *kbManager;
	
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        kbManager = [[self alloc] init];
    });
	
	return kbManager;
}

#pragma mark - Dealloc
-(void)dealloc
{
    //  Disable the keyboard manager.
	[self setEnable:NO];
    
    //Removing notification observers on dealloc.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Property functions
-(void)setEnable:(BOOL)enable
{
	// If not enabled, enable it.
    if (enable == YES &&
        _enable == NO)
    {
		//Setting YES to _enable.
		_enable = enable;
        
		//If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
		if (_kbShowNotification)	[self keyboardWillShow:_kbShowNotification];

        [self showLog:@"Enabled"];
    }
	//If not disable, desable it.
    else if (enable == NO &&
             _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original position.
		[self keyboardWillHide:nil];
        
		//Setting NO to _enable.
		_enable = enable;
		
        [self showLog:@"Disabled"];
    }
	//If already disabled.
	else if (enable == NO &&
             _enable == NO)
	{
        [self showLog:@"Already Disabled"];
	}
	//If already enabled.
	else if (enable == YES &&
             _enable == YES)
	{
        [self showLog:@"Already Enabled"];
	}
}

-(BOOL)privateIsEnabled
{
    BOOL enable = _enable;
    
    IQEnableMode enableMode = _textFieldView.enableMode;

    if (enableMode == IQEnableModeEnabled)
    {
        enable = YES;
    }
    else if (enableMode == IQEnableModeDisabled)
    {
        enable = NO;
    }
    else
    {
        __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

        UIViewController *textFieldViewController = [strongTextFieldView viewContainingController];
        
        if (textFieldViewController)
        {
            //If it is searchBar textField embedded in Navigation Bar
            if ([strongTextFieldView textFieldSearchBar] != nil && [textFieldViewController isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController*)textFieldViewController;
                if (navController.topViewController) {
                    textFieldViewController = navController.topViewController;
                }
            }

            if (enable == NO)
            {
                //If viewController is kind of enable viewController class, then assuming it's enabled.
                for (Class enabledClass in _enabledDistanceHandlingClasses)
                {
                    if ([textFieldViewController isKindOfClass:enabledClass])
                    {
                        enable = YES;
                        break;
                    }
                }
            }
            
            if (enable)
            {
                //If viewController is kind of disable viewController class, then assuming it's disable.
                for (Class disabledClass in _disabledDistanceHandlingClasses)
                {
                    if ([textFieldViewController isKindOfClass:disabledClass])
                    {
                        enable = NO;
                        break;
                    }
                }
                
                //Special Controllers
                if (enable == YES)
                {
                    NSString *classNameString = NSStringFromClass([textFieldViewController class]);
                    
                    //_UIAlertControllerTextFieldViewController
                    if ([classNameString containsString:@"UIAlertController"] && [classNameString hasSuffix:@"TextFieldViewController"])
                    {
                        enable = NO;
                    }
                }
            }
        }
    }
    
    return enable;
}

//	Setting keyboard distance from text field.
-(void)setKeyboardDistanceFromTextField:(CGFloat)keyboardDistanceFromTextField
{
    //Can't be less than zero. Minimum is zero.
	_keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);

    [self showLog:[NSString stringWithFormat:@"keyboardDistanceFromTextField: %.2f",_keyboardDistanceFromTextField]];
}

/** Enabling/disable gesture on touching. */
-(void)setShouldResignOnTouchOutside:(BOOL)shouldResignOnTouchOutside
{
    [self showLog:[NSString stringWithFormat:@"shouldResignOnTouchOutside: %@",shouldResignOnTouchOutside?@"Yes":@"No"]];
    
    _shouldResignOnTouchOutside = shouldResignOnTouchOutside;
    
    //Enable/Disable gesture recognizer   (Enhancement ID: #14)
    [_resignFirstResponderGesture setEnabled:[self privateShouldResignOnTouchOutside]];
}

-(BOOL)privateShouldResignOnTouchOutside
{
    BOOL shouldResignOnTouchOutside = _shouldResignOnTouchOutside;
    
    __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

    IQEnableMode enableMode = strongTextFieldView.shouldResignOnTouchOutsideMode;
    
    if (enableMode == IQEnableModeEnabled)
    {
        shouldResignOnTouchOutside = YES;
    }
    else if (enableMode == IQEnableModeDisabled)
    {
        shouldResignOnTouchOutside = NO;
    }
    else
    {
        UIViewController *textFieldViewController = [strongTextFieldView viewContainingController];
        
        if (textFieldViewController)
        {
            //If it is searchBar textField embedded in Navigation Bar
            if ([strongTextFieldView textFieldSearchBar] != nil && [textFieldViewController isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController*)textFieldViewController;
                if (navController.topViewController) {
                    textFieldViewController = navController.topViewController;
                }
            }

            if (shouldResignOnTouchOutside == NO)
            {
                //If viewController is kind of enable viewController class, then assuming shouldResignOnTouchOutside is enabled.
                for (Class enabledClass in _enabledTouchResignedClasses)
                {
                    if ([textFieldViewController isKindOfClass:enabledClass])
                    {
                        shouldResignOnTouchOutside = YES;
                        break;
                    }
                }
            }
            
            if (shouldResignOnTouchOutside)
            {
                //If viewController is kind of disable viewController class, then assuming shouldResignOnTouchOutside is disable.
                for (Class disabledClass in _disabledTouchResignedClasses)
                {
                    if ([textFieldViewController isKindOfClass:disabledClass])
                    {
                        shouldResignOnTouchOutside = NO;
                        break;
                    }
                }
                
                //Special Controllers
                if (shouldResignOnTouchOutside == YES)
                {
                    NSString *classNameString = NSStringFromClass([textFieldViewController class]);
                    
                    //_UIAlertControllerTextFieldViewController
                    if ([classNameString containsString:@"UIAlertController"] && [classNameString hasSuffix:@"TextFieldViewController"])
                    {
                        shouldResignOnTouchOutside = NO;
                    }
                }
            }
        }
    }
    
    return shouldResignOnTouchOutside;
}

/** Setter of movedDistance property. */
-(void)setMovedDistance:(CGFloat)movedDistance
{
    _movedDistance = movedDistance;
    if (self.movedDistanceChanged != nil) {
        self.movedDistanceChanged(movedDistance);
    }
}

/** Enable/disable autotoolbar. Adding and removing toolbar if required. */
-(void)setEnableAutoToolbar:(BOOL)enableAutoToolbar
{
    _enableAutoToolbar = enableAutoToolbar;
    
    [self showLog:[NSString stringWithFormat:@"enableAutoToolbar: %@",enableAutoToolbar?@"Yes":@"No"]];

    //If enabled then adding toolbar.
    if ([self privateIsEnableAutoToolbar] == YES)
    {
        [self addToolbarIfRequired];
    }
    //Else removing toolbar.
    else
    {
        [self removeToolbarIfRequired];
    }
}

-(BOOL)privateIsEnableAutoToolbar
{
    BOOL enableAutoToolbar = _enableAutoToolbar;
    
    __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

    UIViewController *textFieldViewController = [strongTextFieldView viewContainingController];
    
    if (textFieldViewController)
    {
        //If it is searchBar textField embedded in Navigation Bar
        if ([strongTextFieldView textFieldSearchBar] != nil && [textFieldViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *navController = (UINavigationController*)textFieldViewController;
            if (navController.topViewController) {
                textFieldViewController = navController.topViewController;
            }
        }

        if (enableAutoToolbar == NO)
        {
            //If found any toolbar enabled classes then return.
            for (Class enabledToolbarClass in _enabledToolbarClasses)
            {
                if ([textFieldViewController isKindOfClass:enabledToolbarClass])
                {
                    enableAutoToolbar = YES;
                    break;
                }
            }
        }
        
        if (enableAutoToolbar)
        {
            //If found any toolbar disabled classes then return.
            for (Class disabledToolbarClass in _disabledToolbarClasses)
            {
                if ([textFieldViewController isKindOfClass:disabledToolbarClass])
                {
                    enableAutoToolbar = NO;
                    break;
                }
            }
            
            
            //Special Controllers
            if (enableAutoToolbar == YES)
            {
                NSString *classNameString = NSStringFromClass([textFieldViewController class]);
                
                //_UIAlertControllerTextFieldViewController
                if ([classNameString containsString:@"UIAlertController"] && [classNameString hasSuffix:@"TextFieldViewController"])
                {
                    enableAutoToolbar = NO;
                }
            }
        }
    }
    
    return enableAutoToolbar;
}

#pragma mark - Private Methods

/** Getting keyWindow. */
-(UIWindow *)keyWindow
{
    UIView *textFieldView = _textFieldView;

    if (textFieldView.window)
    {
        return textFieldView.window;
    }
    else
    {
        static __weak UIWindow *cachedKeyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = nil;

        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            originalKeyWindow = window;
                            break;
                        }
                    }
                }
            }
        } else
        #endif
        {
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        #endif
        }

        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow)
        {
            cachedKeyWindow = originalKeyWindow;
        }

        __strong UIWindow *strongCachedKeyWindow = cachedKeyWindow;

        return strongCachedKeyWindow;
    }
}

-(void)optimizedAdjustPosition
{
    if (_hasPendingAdjustRequest == NO)
    {
        _hasPendingAdjustRequest = YES;
        
        __weak __typeof__(self) weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;

            [strongSelf adjustPosition];
            strongSelf.hasPendingAdjustRequest = NO;
        }];
    }
}

/* Adjusting RootViewController's frame according to interface orientation. */
-(void)adjustPosition
{
    UIView *textFieldView = _textFieldView;

    //  Getting RootViewController.  (Bug ID: #1, #4)
    UIViewController *rootController = _rootViewController;
    
    //  Getting KeyWindow object.
    UIWindow *keyWindow = [self keyWindow];
    
    //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
    if (_hasPendingAdjustRequest == NO ||
        textFieldView == nil ||
        rootController == nil ||
        keyWindow == nil)
        return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRectInWindow = [[textFieldView superview] convertRect:textFieldView.frame toView:keyWindow];
    CGRect textFieldViewRectInRootSuperview = [[textFieldView superview] convertRect:textFieldView.frame toView:rootController.view.superview];
    //  Getting RootView origin.
    CGPoint rootViewOrigin = rootController.view.frame.origin;

    //Maintain keyboardDistanceFromTextField
    CGFloat specialKeyboardDistanceFromTextField = textFieldView.keyboardDistanceFromTextField;

    {
        UISearchBar *searchBar = textFieldView.textFieldSearchBar;
        
        if (searchBar)
        {
            specialKeyboardDistanceFromTextField = searchBar.keyboardDistanceFromTextField;
        }
    }
    
    CGFloat keyboardDistanceFromTextField = (specialKeyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance)?_keyboardDistanceFromTextField:specialKeyboardDistanceFromTextField;

    CGSize kbSize;
    
    {
        CGRect kbFrame = _kbFrame;
        
        kbFrame.origin.y -= keyboardDistanceFromTextField;
        kbFrame.size.height += keyboardDistanceFromTextField;
        
        //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
        CGRect intersectRect = CGRectIntersection(kbFrame, keyWindow.frame);
        
        if (CGRectIsNull(intersectRect))
        {
            kbSize = CGSizeMake(kbFrame.size.width, 0);
        }
        else
        {
            kbSize = intersectRect.size;
        }
    }


    CGFloat navigationBarAreaHeight = 0;

    if (rootController.navigationController != nil) {
        navigationBarAreaHeight = CGRectGetMaxY(rootController.navigationController.navigationBar.frame);
    } else {
        CGFloat statusBarHeight = 0;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            statusBarHeight = [self keyWindow].windowScene.statusBarManager.statusBarFrame.size.height;

        } else
    #endif
        {
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    #endif
        }

        navigationBarAreaHeight = statusBarHeight;
    }

    CGFloat layoutAreaHeight = rootController.view.layoutMargins.top;
    
    CGFloat topLayoutGuide = MAX(navigationBarAreaHeight, layoutAreaHeight) + 5;
    CGFloat bottomLayoutGuide = ([textFieldView respondsToSelector:@selector(isEditable)] && [textFieldView isKindOfClass:[UIScrollView class]]) ? 0 : rootController.view.layoutMargins.bottom; //Validation of textView for case where there is a tab bar at the bottom or running on iPhone X and textView is at the bottom.

    //  +Move positive = textField is hidden.
    //  -Move negative = textField is showing.
    //  Calculating move position. Common for both normal and special cases.
    CGFloat move = MIN(CGRectGetMinY(textFieldViewRectInRootSuperview)-topLayoutGuide, CGRectGetMaxY(textFieldViewRectInWindow)-(CGRectGetHeight(keyWindow.frame)-kbSize.height)+bottomLayoutGuide);

    [self showLog:[NSString stringWithFormat:@"Need to move: %.2f",move]];

    UIScrollView *superScrollView = nil;
    UIScrollView *superView = (UIScrollView*)[textFieldView superviewOfClassType:[UIScrollView class]];

    //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
    while (superView)
    {
        if (superView.isScrollEnabled && superView.shouldIgnoreScrollingAdjustment == NO)
        {
            superScrollView = superView;
            break;
        }
        else
        {
            //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
            superView = (UIScrollView*)[superView superviewOfClassType:[UIScrollView class]];
        }
    }
    
    __strong __typeof__(UIScrollView) *strongLastScrollView = _lastScrollView;

    //If there was a lastScrollView.    //  (Bug ID: #34)
    if (strongLastScrollView)
    {
        //If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if (superScrollView == nil)
        {
            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, _startingContentInsets) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(_startingContentInsets)]];
                
                __weak __typeof__(self) weakSelf = self;

                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                    strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
                } completion:NULL];
            }
            
            if (strongLastScrollView.shouldRestoreScrollViewContentOffset && CGPointEqualToPoint(strongLastScrollView.contentOffset, _startingContentOffset) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentOffset to : %@",NSStringFromCGPoint(_startingContentOffset)]];
                
                BOOL animatedContentOffset = ([textFieldView superviewOfClassType:[UIStackView class] belowView:strongLastScrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                if (animatedContentOffset) {
                    [strongLastScrollView setContentOffset:_startingContentOffset animated:UIView.areAnimationsEnabled];
                } else {
                    strongLastScrollView.contentOffset = _startingContentOffset;
                }
            }

            _startingContentInsets = UIEdgeInsetsZero;
            _startingScrollIndicatorInsets = UIEdgeInsetsZero;
            _startingContentOffset = CGPointZero;
            _lastScrollView = nil;
            strongLastScrollView = _lastScrollView;
        }
        //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
        else if (superScrollView != strongLastScrollView)
        {
            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, _startingContentInsets) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(_startingContentInsets)]];

                __weak __typeof__(self) weakSelf = self;
                
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                    strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
                } completion:NULL];
            }

            if (strongLastScrollView.shouldRestoreScrollViewContentOffset && CGPointEqualToPoint(strongLastScrollView.contentOffset, _startingContentOffset) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentOffset to : %@",NSStringFromCGPoint(_startingContentOffset)]];

                BOOL animatedContentOffset = ([textFieldView superviewOfClassType:[UIStackView class] belowView:strongLastScrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                if (animatedContentOffset) {
                    [strongLastScrollView setContentOffset:_startingContentOffset animated:UIView.areAnimationsEnabled];
                } else {
                    strongLastScrollView.contentOffset = _startingContentOffset;
                }
            }
            
            _lastScrollView = superScrollView;
            strongLastScrollView = _lastScrollView;
            _startingContentInsets = superScrollView.contentInset;
            _startingContentOffset = superScrollView.contentOffset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
            if (@available(iOS 11.1, *)) {
                _startingScrollIndicatorInsets = superScrollView.verticalScrollIndicatorInsets;
            } else
#endif
            {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;
#endif
            }

            [self showLog:[NSString stringWithFormat:@"Saving New contentInset: %@ and contentOffset : %@",NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
        }
        //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        _lastScrollView = superScrollView;
        strongLastScrollView = _lastScrollView;
        _startingContentInsets = superScrollView.contentInset;
        _startingContentOffset = superScrollView.contentOffset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 11.1, *)) {
            _startingScrollIndicatorInsets = superScrollView.verticalScrollIndicatorInsets;
        } else
#endif
        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;
#endif
        }

        [self showLog:[NSString stringWithFormat:@"Saving contentInset: %@ and contentOffset : %@",NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
    }
    
    //  Special case for ScrollView.
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (strongLastScrollView)
        {
            //Saving
            UIView *lastView = textFieldView;
            superScrollView = strongLastScrollView;

            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView)
            {
                BOOL shouldContinue = NO;
                
                if (move > 0)
                {
                    shouldContinue = move > (-superScrollView.contentOffset.y-superScrollView.contentInset.top);
                }
                else
                {
                    //Special treatment for UITableView due to their cell reusing logic
                    if ([superScrollView isKindOfClass:[UITableView class]])
                    {
                        shouldContinue = superScrollView.contentOffset.y>0;

                        UITableView *tableView = (UITableView*)superScrollView;
                        UITableViewCell *tableCell = nil;
                        NSIndexPath *indexPath = nil;
                        NSIndexPath *previousIndexPath = nil;

                        if (shouldContinue &&
                            (tableCell = (UITableViewCell*)[textFieldView superviewOfClassType:[UITableViewCell class]]) &&
                            (indexPath = [tableView indexPathForCell:tableCell]) &&
                            (previousIndexPath = [tableView previousIndexPathOfIndexPath:indexPath]))
                        {
                            CGRect previousCellRect = [tableView rectForRowAtIndexPath:previousIndexPath];
                            if (CGRectIsEmpty(previousCellRect) == NO)
                            {
                                CGRect previousCellRectInRootSuperview = [tableView convertRect:previousCellRect toView:rootController.view.superview];
                                move = MIN(0, CGRectGetMaxY(previousCellRectInRootSuperview) - topLayoutGuide);
                            }
                        }
                    }
                    //Special treatment for UICollectionView due to their cell reusing logic
                    else if ([superScrollView isKindOfClass:[UICollectionView class]])
                    {
                        shouldContinue = superScrollView.contentOffset.y>0;
                        
                        UICollectionView *collectionView = (UICollectionView*)superScrollView;
                        UICollectionViewCell *collectionCell = nil;
                        NSIndexPath *indexPath = nil;
                        NSIndexPath *previousIndexPath = nil;

                        if (shouldContinue &&
                            (collectionCell = (UICollectionViewCell*)[textFieldView superviewOfClassType:[UICollectionViewCell class]]) &&
                            (indexPath = [collectionView indexPathForCell:collectionCell]) &&
                            (previousIndexPath = [collectionView previousIndexPathOfIndexPath:indexPath]))
                        {
                            UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:previousIndexPath];
                            
                            CGRect previousCellRect = attributes.frame;
                            if (CGRectIsEmpty(previousCellRect) == NO)
                            {
                                CGRect previousCellRectInRootSuperview = [collectionView convertRect:previousCellRect toView:rootController.view.superview];
                                move = MIN(0, CGRectGetMaxY(previousCellRectInRootSuperview) - topLayoutGuide);
                            }
                        }
                    }
                    else
                    {
                        //If the textField is hidden at the top
                        shouldContinue = textFieldViewRectInRootSuperview.origin.y < topLayoutGuide;
                        
                        if (shouldContinue) {
                            move = MIN(0, textFieldViewRectInRootSuperview.origin.y - topLayoutGuide);
                        }
                    }
                }
                
                if (shouldContinue == NO)
                {
                    move = 0;
                    break;
                }

                UIScrollView *nextScrollView = nil;
                UIScrollView *tempScrollView = (UIScrollView*)[superScrollView superviewOfClassType:[UIScrollView class]];
                
                //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
                while (tempScrollView)
                {
                    if (tempScrollView.isScrollEnabled && tempScrollView.shouldIgnoreScrollingAdjustment == NO)
                    {
                        nextScrollView = tempScrollView;
                        break;
                    }
                    else
                    {
                        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                        tempScrollView = (UIScrollView*)[tempScrollView superviewOfClassType:[UIScrollView class]];
                    }
                }

                //Getting lastViewRect.
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y);
                
                //[textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                //[superScrollView superviewOfClassType:[UIScrollView class]] == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierarchy.)
                //shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                if ([textFieldView respondsToSelector:@selector(isEditable)]  && [textFieldView isKindOfClass:[UIScrollView class]] &&
                    nextScrollView == nil &&
                    (shouldOffsetY >= 0))
                {
                    //  Converting Rectangle according to window bounds.
                    CGRect currentTextFieldViewRect = [[textFieldView superview] convertRect:textFieldView.frame toView:keyWindow];
                    
                    //Calculating expected fix distance which needs to be managed from navigation bar
                    CGFloat expectedFixDistance = CGRectGetMinY(currentTextFieldViewRect) - topLayoutGuide;
                    
                    //Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                    shouldOffsetY = MIN(shouldOffsetY, superScrollView.contentOffset.y + expectedFixDistance);
                    
                    //Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic. 
                    move = 0;
                }
                else
                {
                    //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                    move -= (shouldOffsetY-superScrollView.contentOffset.y);
                }

                
                CGPoint newContentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);
                
                if (CGPointEqualToPoint(superScrollView.contentOffset, newContentOffset) == NO)
                {
                    __weak __typeof__(self) weakSelf = self;

                    //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;

                        [strongSelf showLog:[NSString stringWithFormat:@"Adjusting %.2f to %@ ContentOffset",(superScrollView.contentOffset.y-shouldOffsetY),[superScrollView _IQDescription]]];
                        [strongSelf showLog:[NSString stringWithFormat:@"Remaining Move: %.2f",move]];
                        
                        BOOL animatedContentOffset = ([textFieldView superviewOfClassType:[UIStackView class] belowView:superScrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                        if (animatedContentOffset) {
                            [superScrollView setContentOffset:newContentOffset animated:UIView.areAnimationsEnabled];
                        } else {
                            superScrollView.contentOffset = newContentOffset;
                        }
                    } completion:^(BOOL finished){
                        
                        __strong __typeof__(self) strongSelf = weakSelf;

                        if ([superScrollView isKindOfClass:[UITableView class]] || [superScrollView isKindOfClass:[UICollectionView class]])
                        {
                            //This will update the next/previous states
                            [strongSelf addToolbarIfRequired];
                        }
                    }];
                }

                //  Getting next lastView & superScrollView.
                lastView = superScrollView;
                superScrollView = nextScrollView;
            }
            
            //Updating contentInset
            if (strongLastScrollView.shouldIgnoreContentInsetAdjustment == NO)
            {
                CGRect lastScrollViewRect = [[strongLastScrollView superview] convertRect:strongLastScrollView.frame toView:keyWindow];

                CGFloat bottomInset = (kbSize.height)-(CGRectGetHeight(keyWindow.frame)-CGRectGetMaxY(lastScrollViewRect));
                CGFloat bottomScrollIndicatorInset = bottomInset - keyboardDistanceFromTextField;

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                bottomInset = MAX(_startingContentInsets.bottom, bottomInset);
                bottomScrollIndicatorInset = MAX(_startingScrollIndicatorInsets.bottom, bottomScrollIndicatorInset);

                if (@available(iOS 11, *)) {
                    bottomInset -= strongLastScrollView.safeAreaInsets.bottom;
                    bottomScrollIndicatorInset -= strongLastScrollView.safeAreaInsets.bottom;
                }

                UIEdgeInsets movedInsets = strongLastScrollView.contentInset;
                movedInsets.bottom = bottomInset;

                if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, movedInsets) == NO)
                {
                    [self showLog:[NSString stringWithFormat:@"old ContentInset : %@ new ContentInset : %@", NSStringFromUIEdgeInsets(strongLastScrollView.contentInset), NSStringFromUIEdgeInsets(movedInsets)]];
                    
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        strongLastScrollView.contentInset = movedInsets;
                        UIEdgeInsets newScrollIndicatorInset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
                        if (@available(iOS 11.1, *)) {
                            newScrollIndicatorInset = strongLastScrollView.verticalScrollIndicatorInsets;
                        } else
#endif
                        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                            newScrollIndicatorInset = strongLastScrollView.scrollIndicatorInsets;
#endif
                        }

                        newScrollIndicatorInset.bottom = bottomScrollIndicatorInset;
                        strongLastScrollView.scrollIndicatorInsets = newScrollIndicatorInset;
                        
                    } completion:NULL];
                }
            }
        }
        //Going ahead. No else if.
    }
    
    {
        //Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if ([textFieldView isKindOfClass:[UIScrollView class]] && [(UIScrollView*)textFieldView isScrollEnabled] && [textFieldView respondsToSelector:@selector(isEditable)])
        {
            UIScrollView *textView = (UIScrollView*)textFieldView;

            CGFloat keyboardYPosition = CGRectGetHeight(keyWindow.frame)-(kbSize.height-keyboardDistanceFromTextField);

            CGRect rootSuperViewFrameInWindow = [rootController.view.superview convertRect:rootController.view.superview.bounds toView:keyWindow];

            CGFloat keyboardOverlapping = CGRectGetMaxY(rootSuperViewFrameInWindow) - keyboardYPosition;

            CGFloat textViewHeight = MIN(CGRectGetHeight(textFieldView.frame), (CGRectGetHeight(rootSuperViewFrameInWindow)-topLayoutGuide-keyboardOverlapping));
            
            if (textFieldView.frame.size.height-textView.contentInset.bottom>textViewHeight)
            {
                //_isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                if (self.isTextViewContentInsetChanged == NO)
                {
                    self.startingTextViewContentInsets = textView.contentInset;
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
                    if (@available(iOS 11.1, *)) {
                        self.startingTextViewScrollIndicatorInsets = textView.verticalScrollIndicatorInsets;
                    } else
#endif
                    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                        self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets;
#endif
                    }
                }

                CGFloat bottomInset = textFieldView.frame.size.height-textViewHeight;

                if (@available(iOS 11, *)) {
                    bottomInset -= textFieldView.safeAreaInsets.bottom;
                }

                UIEdgeInsets newContentInset = textView.contentInset;
                newContentInset.bottom = bottomInset;

                self.isTextViewContentInsetChanged = YES;

                if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, newContentInset) == NO)
                {
                    __weak __typeof__(self) weakSelf = self;
                    
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;
                        
                        [strongSelf showLog:[NSString stringWithFormat:@"Old UITextView.contentInset : %@ New UITextView.contentInset : %@", NSStringFromUIEdgeInsets(textView.contentInset), NSStringFromUIEdgeInsets(textView.contentInset)]];
                        
                        textView.contentInset = newContentInset;
                        textView.scrollIndicatorInsets = newContentInset;
                    } completion:NULL];
                }
            }
        }

        {
            __weak __typeof__(self) weakSelf = self;

            //  +Positive or zero.
            if (move>=0)
            {
                rootViewOrigin.y -= move;
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                rootViewOrigin.y = MAX(rootViewOrigin.y, MIN(0, -(kbSize.height-keyboardDistanceFromTextField)));

                [self showLog:@"Moving Upward"];
                //  Setting adjusted rootViewOrigin.ty
                
                //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    //  Setting it's new frame
                    CGRect rect = rootController.view.frame;
                    rect.origin = rootViewOrigin;
                    rootController.view.frame = rect;
                    
                    //Animating content if needed (Bug ID: #204)
                    if (strongSelf.layoutIfNeededOnUpdate)
                    {
                        //Animating content (Bug ID: #160)
                        [rootController.view setNeedsLayout];
                        [rootController.view layoutIfNeeded];
                    }
                    
                    [strongSelf showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",rootController,NSStringFromCGPoint(rootViewOrigin)]];
                } completion:NULL];

                self.movedDistance = (_topViewBeginOrigin.y-rootViewOrigin.y);
            }
            //  -Negative
            else
            {
                CGFloat disturbDistance = rootController.view.frame.origin.y-_topViewBeginOrigin.y;
                
                //  disturbDistance Negative = frame disturbed. Pull Request #3
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<=0)
                {
                    rootViewOrigin.y -= MAX(move, disturbDistance);
                    
                    [self showLog:@"Moving Downward"];
                    //  Setting adjusted rootViewRect
                    
                    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;
                        
                        //  Setting it's new frame
                        CGRect rect = rootController.view.frame;
                        rect.origin = rootViewOrigin;
                        rootController.view.frame = rect;
                        
                        //Animating content if needed (Bug ID: #204)
                        if (strongSelf.layoutIfNeededOnUpdate)
                        {
                            //Animating content (Bug ID: #160)
                            [rootController.view setNeedsLayout];
                            [rootController.view layoutIfNeeded];
                        }
                        
                        [strongSelf showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",rootController,NSStringFromCGPoint(rootViewOrigin)]];
                    } completion:NULL];

                    self.movedDistance = (_topViewBeginOrigin.y-rootController.view.frame.origin.y);
                }
            }
        }
    }
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

-(void)restorePosition
{
    _hasPendingAdjustRequest = NO;

    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (_rootViewController && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid) == false)
    {
        __weak __typeof__(self) weakSelf = self;
        
        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;
            UIViewController *strongRootController = strongSelf.rootViewController;
            
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring %@ origin to : %@",strongRootController,NSStringFromCGPoint(strongSelf.topViewBeginOrigin)]];
                
                //Restoring
                CGRect rect = strongRootController.view.frame;
                rect.origin = strongSelf.topViewBeginOrigin;
                strongRootController.view.frame = rect;

                strongSelf.movedDistance = 0;
                
                if (strongRootController.navigationController.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                    strongSelf.rootViewControllerWhilePopGestureRecognizerActive = strongRootController;
                    strongSelf.topViewBeginOriginWhilePopGestureRecognizerActive = strongSelf.topViewBeginOrigin;
                }
                
                //Animating content if needed (Bug ID: #204)
                if (strongSelf.layoutIfNeededOnUpdate)
                {
                    //Animating content (Bug ID: #160)
                    [strongRootController.view setNeedsLayout];
                    [strongRootController.view layoutIfNeeded];
                }
            }
            
        } completion:NULL];
        _rootViewController = nil;
    }
}

#pragma mark - Public Methods

/*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
- (void)reloadLayoutIfNeeded
{
    if ([self privateIsEnabled] == YES)
    {
        UIView *textFieldView = _textFieldView;
        
        if (textFieldView &&
            _keyboardShowing == YES &&
            CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid) == false &&
            [textFieldView isAlertViewTextField] == NO)
        {
            [self optimizedAdjustPosition];
        }
    }
}

#pragma mark - UIKeyboad Notification methods
/*  UIKeyboardWillShowNotification. */
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    _kbShowNotification = aNotification;
	
    //  Boolean to know keyboard is showing/hiding
    _keyboardShowing = YES;
    
    //  Getting keyboard animation.
    NSInteger curve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _animationCurve = curve<<16;

    //  Getting keyboard animation duration
    CGFloat duration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    _animationDuration = duration;
    
    CGRect oldKBFrame = _kbFrame;
    
    //  Getting UIKeyboardSize.
    _kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [self notifyKeyboardSize:_kbFrame.size];

    if ([self privateIsEnabled] == NO)
    {
        [self restorePosition];
        _topViewBeginOrigin = kIQCGPointInvalid;
        return;
    }
	
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    UIView *textFieldView = _textFieldView;

    if (textFieldView && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [textFieldView parentContainerViewController];
        _rootViewController = rootController;
        
        if (_rootViewControllerWhilePopGestureRecognizerActive == rootController)
        {
            _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive;
        }
        else
        {
            _topViewBeginOrigin = rootController.view.frame.origin;
        }
        
        _rootViewControllerWhilePopGestureRecognizerActive = nil;
        _topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
        
        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",rootController,NSStringFromCGPoint(_topViewBeginOrigin)]];
    }

    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGRectEqualToRect(_kbFrame, oldKBFrame))
    {
        //If _textFieldView is inside AlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is AlertView textField then do not affect anything (Bug ID: #70).
        if (_keyboardShowing == YES &&
            textFieldView &&
            [textFieldView isAlertViewTextField] == NO)
        {
            [self optimizedAdjustPosition];
        }
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardDidShowNotification. */
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if ([self privateIsEnabled] == NO)	return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    UIView *textFieldView = _textFieldView;

    //  Getting topMost ViewController.
    UIViewController *controller = [textFieldView topMostController];

    //If _textFieldView viewController is presented as formSheet, then adjustPosition again because iOS internally update formSheet frame on keyboardShown. (Bug ID: #37, #74, #76)
    if (_keyboardShowing == YES &&
        textFieldView &&
        (controller.modalPresentationStyle == UIModalPresentationFormSheet || controller.modalPresentationStyle == UIModalPresentationPageSheet) &&
        [textFieldView isAlertViewTextField] == NO)
    {
        [self optimizedAdjustPosition];
    }
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //If it's not a fake notification generated by [self setEnable:NO].
    if (aNotification)	_kbShowNotification = nil;
    
    //  Boolean to know keyboard is showing/hiding
    _keyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        _animationDuration = aDuration;
    }
    
    //If not enabled then do nothing.
    if ([self privateIsEnabled] == NO)	return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    //Commented due to #56. Added all the conditions below to handle WKWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //Restoring the contentOffset of the lastScrollView
    __strong __typeof__(UIScrollView) *strongLastScrollView = _lastScrollView;

    if (strongLastScrollView)
    {
        __weak __typeof__(self) weakSelf = self;
        __weak __typeof__(UIView) *weakTextFieldView = self.textFieldView;

        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;
            __strong __typeof__(UIView) *strongTextFieldView = weakTextFieldView;

            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, strongSelf.startingContentInsets) == NO)
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingContentInsets)]];

                strongLastScrollView.contentInset = strongSelf.startingContentInsets;
                strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            }
            
            if (strongLastScrollView.shouldRestoreScrollViewContentOffset && CGPointEqualToPoint(strongLastScrollView.contentOffset, strongSelf.startingContentOffset) == NO)
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring ScrollView contentOffset to : %@",NSStringFromCGPoint(strongSelf.startingContentOffset)]];

                BOOL animatedContentOffset = ([strongTextFieldView superviewOfClassType:[UIStackView class] belowView:strongLastScrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                if (animatedContentOffset) {
                    [strongLastScrollView setContentOffset:strongSelf.startingContentOffset animated:UIView.areAnimationsEnabled];
                } else {
                    strongLastScrollView.contentOffset = strongSelf.startingContentOffset;
                }
            }
            
            // TODO: restore scrollView state
            // This is temporary solution. Have to implement the save and restore scrollView state
            UIScrollView *superscrollView = strongLastScrollView;
            do
            {
                CGSize contentSize = CGSizeMake(MAX(superscrollView.contentSize.width, CGRectGetWidth(superscrollView.frame)), MAX(superscrollView.contentSize.height, CGRectGetHeight(superscrollView.frame)));
                
                CGFloat minimumY = contentSize.height-CGRectGetHeight(superscrollView.frame);
                
                if (minimumY<superscrollView.contentOffset.y)
                {
                    CGPoint newContentOffset = CGPointMake(superscrollView.contentOffset.x, minimumY);
                    if (CGPointEqualToPoint(superscrollView.contentOffset, newContentOffset) == NO)
                    {
                        [self showLog:[NSString stringWithFormat:@"Restoring contentOffset to : %@",NSStringFromCGPoint(newContentOffset)]];

                        BOOL animatedContentOffset = ([strongSelf.textFieldView superviewOfClassType:[UIStackView class] belowView:superscrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                        if (animatedContentOffset) {
                            [superscrollView setContentOffset:newContentOffset animated:UIView.areAnimationsEnabled];
                        } else {
                            superscrollView.contentOffset = newContentOffset;
                        }
                    }
                }
            } while ((superscrollView = (UIScrollView*)[superscrollView superviewOfClassType:[UIScrollView class]]));

        } completion:NULL];
    }
    
    [self restorePosition];

    //Reset all values
    _lastScrollView = nil;
    _kbFrame = CGRectZero;
    [self notifyKeyboardSize:_kbFrame.size];
    _startingContentInsets = UIEdgeInsetsZero;
    _startingScrollIndicatorInsets = UIEdgeInsetsZero;
    _startingContentOffset = CGPointZero;

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardDidHideNotification. So topViewBeginRect can be set to CGRectZero. */
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    _topViewBeginOrigin = kIQCGPointInvalid;

    _kbFrame = CGRectZero;
    [self notifyKeyboardSize:_kbFrame.size];

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

-(void)registerKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier sizeHandler:(void (^_Nonnull)(CGSize size))sizeHandler
{
    _keyboardSizeObservers[identifier] = sizeHandler;
}

-(void)unregisterKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier
{
    _keyboardSizeObservers[identifier] = nil;
}

-(void)notifyKeyboardSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, _keyboardLastNotifySize)) {
        _keyboardLastNotifySize = size;
        for (SizeBlock block in _keyboardSizeObservers.allValues) {
            block(size);
        }
    }
}

#pragma mark - UITextFieldView Delegate methods
/**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    UIView *object = (UIView*)notification.object;
    if (object.window.isKeyWindow == NO) {
        return;
    }

    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", notification.object]];

    //  Getting object
    _textFieldView = object;
    
    UIView *textFieldView = _textFieldView;

    if (_overrideKeyboardAppearance == YES)
    {
        UITextField *textField = (UITextField*)textFieldView;
        
        if ([textField respondsToSelector:@selector(keyboardAppearance)])
        {
            //If keyboard appearance is not like the provided appearance
            if (textField.keyboardAppearance != _keyboardAppearance)
            {
                //Setting textField keyboard appearance and reloading inputViews.
                textField.keyboardAppearance = _keyboardAppearance;
                [textField reloadInputViews];
            }
        }
    }
    
	//If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
	if ([self privateIsEnableAutoToolbar])
    {
        //UITextView special case. Keyboard Notification is firing before textView notification so we need to reload it's inputViews.
        if ([textFieldView respondsToSelector:@selector(isEditable)] && [textFieldView isKindOfClass:[UIScrollView class]] &&
            textFieldView.inputAccessoryView == nil)
        {
            __weak __typeof__(self) weakSelf = self;

            [UIView animateWithDuration:0.00001 delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{

                __strong __typeof__(self) strongSelf = weakSelf;

                [strongSelf addToolbarIfRequired];
            } completion:^(BOOL finished) {

                __strong __typeof__(self) strongSelf = weakSelf;

                //On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                [strongSelf.textFieldView reloadInputViews];
            }];
        }
        //Else adding toolbar
        else
        {
            [self addToolbarIfRequired];
        }
    }
    else
    {
        [self removeToolbarIfRequired];
    }
    
    //Adding Geture recognizer to window    (Enhancement ID: #14)
    [_resignFirstResponderGesture setEnabled:[self privateShouldResignOnTouchOutside]];
    [textFieldView.window addGestureRecognizer:_resignFirstResponderGesture];

    if ([self privateIsEnabled] == NO)
    {
        [self restorePosition];
        _topViewBeginOrigin = kIQCGPointInvalid;
    }
    else
    {
        if (CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
        {
            //  keyboard is not showing(At the beginning only).
            UIViewController *rootController = [textFieldView parentContainerViewController];
            _rootViewController = rootController;
            
            if (_rootViewControllerWhilePopGestureRecognizerActive == rootController)
            {
                _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive;
            }
            else
            {
                _topViewBeginOrigin = rootController.view.frame.origin;
            }
            
            _rootViewControllerWhilePopGestureRecognizerActive = nil;
            _topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
            
            [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",rootController, NSStringFromCGPoint(_topViewBeginOrigin)]];
        }
        
        //If textFieldView is inside AlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is AlertView textField then do not affect anything (Bug ID: #70).
        if (_keyboardShowing == YES &&
            textFieldView &&
            [textFieldView isAlertViewTextField] == NO)
        {
            //  keyboard is already showing. adjust frame.
            [self optimizedAdjustPosition];
        }
    }
    
//    if ([textFieldView isKindOfClass:[UITextField class]])
//    {
//        [(UITextField*)textFieldView addTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    UIView *object = (UIView*)notification.object;
    if (object.window.isKeyWindow == NO) {
        return;
    }

    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", notification.object]];

    UIView *textFieldView = _textFieldView;

    //Removing gesture recognizer   (Enhancement ID: #14)
    [textFieldView.window removeGestureRecognizer:_resignFirstResponderGesture];
    
//    if ([textFieldView isKindOfClass:[UITextField class]])
//    {
//        [(UITextField*)textFieldView removeTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    }

    // We check if there's a change in original frame or not.
    if(_isTextViewContentInsetChanged == YES &&
       [textFieldView respondsToSelector:@selector(isEditable)] && [textFieldView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *textView = (UIScrollView*)textFieldView;
        self.isTextViewContentInsetChanged = NO;
        if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, self.startingTextViewContentInsets) == NO)
        {
            __weak __typeof__(self) weakSelf = self;
            
            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong __typeof__(self) strongSelf = weakSelf;
                
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring textView.contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];
                
                //Setting textField to it's initial contentInset
                textView.contentInset = strongSelf.startingTextViewContentInsets;
                textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;
                
            } completion:NULL];
        }
    }


    //Setting object to nil
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if (@available(iOS 16.0, *)) {
        if ([textFieldView isKindOfClass:[UITextView class]] && [(UITextView*)textFieldView isFindInteractionEnabled]) {
            //Not setting it nil, because it may be doing find interaction.
            //As of now, here textView.findInteraction.isFindNavigatorVisible returns NO
            //So there is no way to detect if this is dismissed due to findInteraction
        } else {
            textFieldView = nil;
        }
    } else
#endif
    {
        textFieldView = nil;
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

//-(void)editingDidEndOnExit:(UITextField*)textField
//{
//    [self showLog:[NSString stringWithFormat:@"ReturnKey %@",NSStringFromSelector(_cmd)]];
//}

#pragma mark - UIStatusBar Notification methods
/**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    UIInterfaceOrientation currentStatusBarOrientation = UIInterfaceOrientationUnknown;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        currentStatusBarOrientation = [self keyWindow].windowScene.interfaceOrientation;
    } else
#endif
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
        currentStatusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
#endif
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIInterfaceOrientation statusBarOrientation = [aNotification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
#pragma clang diagnostic pop
    
    if (statusBarOrientation != currentStatusBarOrientation) {
        return;
    }
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

    //If textViewContentInsetChanged is changed then restore it.
    if (_isTextViewContentInsetChanged == YES &&
        [strongTextFieldView respondsToSelector:@selector(isEditable)] && [strongTextFieldView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *textView = (UIScrollView*)strongTextFieldView;
        self.isTextViewContentInsetChanged = NO;
        if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, self.startingTextViewContentInsets) == NO)
        {
            __weak __typeof__(self) weakSelf = self;
            
            //Due to orientation callback we need to set it's original position.
            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong __typeof__(self) strongSelf = weakSelf;
                
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring textView.contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];
                
                //Setting textField to it's initial contentInset
                textView.contentInset = strongSelf.startingTextViewContentInsets;
                textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;
            } completion:NULL];
        }
    }

    [self restorePosition];

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

#pragma mark AutoResign methods

/** Resigning on tap gesture. */
- (void)tapRecognized:(UITapGestureRecognizer*)gesture  // (Enhancement ID: #14)
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        //Resigning currently responder textField.
        [self resignFirstResponder];
    }
}

/** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

/** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145)
    for (Class aClass in self.touchResignedGestureIgnoreClasses)
    {
        if ([[touch view] isKindOfClass:aClass])
        {
            return NO;
        }
    }

    return YES;
}

/** Resigning textField. */
- (BOOL)resignFirstResponder
{
    UIView *textFieldView = _textFieldView;

    if (textFieldView)
    {
        //  Retaining textFieldView
        UIView *textFieldRetain = textFieldView;
        
        //Resigning first responder
        BOOL isResignFirstResponder = [textFieldView resignFirstResponder];
        
        //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
        if (isResignFirstResponder == NO)
        {
            //If it refuses to resign then becoming it first responder again for getting notifications callback.
            [textFieldRetain becomeFirstResponder];
            
            [self showLog:[NSString stringWithFormat:@"Refuses to Resign first responder: %@",textFieldView]];
        }
        
        return isResignFirstResponder;
    }
    else
    {
        return NO;
    }
}

/** Returns YES if can navigate to previous responder textField/textView, otherwise NO. */
-(BOOL)canGoPrevious
{
    //Getting all responder view's.
    NSArray<UIView*> *textFields = [self responderViews];

    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];

    //If it is not first textField. then it's previous object can becomeFirstResponder.
    if (index != NSNotFound &&
        index > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/** Returns YES if can navigate to next responder textField/textView, otherwise NO. */
-(BOOL)canGoNext
{
    //Getting all responder view's.
    NSArray<UIView*> *textFields = [self responderViews];
    
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];
    
    //If it is not last textField. then it's next object becomeFirstResponder.
    if (index != NSNotFound &&
        index < textFields.count-1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/** Navigate to previous responder textField/textView.  */
-(BOOL)goPrevious
{
    //Getting all responder view's.
    NSArray<__kindof UIView*> *textFields = [self responderViews];
    
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];
    
    //If it is not first textField. then it's previous object becomeFirstResponder.
    if (index != NSNotFound &&
        index > 0)
    {
        UITextField *nextTextField = textFields[index-1];
        
        BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];

        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if (isAcceptAsFirstResponder == NO)
        {
            [self showLog:[NSString stringWithFormat:@"Refuses to become first responder: %@",nextTextField]];
        }

        return isAcceptAsFirstResponder;
    }
    else
    {
        return NO;
    }
}

/** Navigate to next responder textField/textView.  */
-(BOOL)goNext
{
    //Getting all responder view's.
    NSArray<__kindof UIView*> *textFields = [self responderViews];
    
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];
    
    //If it is not last textField. then it's next object becomeFirstResponder.
    if (index != NSNotFound &&
        index < textFields.count-1)
    {
        UITextField *nextTextField = textFields[index+1];

        BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];

        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if (isAcceptAsFirstResponder == NO)
        {
            [self showLog:[NSString stringWithFormat:@"Refuses to become first responder: %@",nextTextField]];
        }

        return isAcceptAsFirstResponder;
    }
    else
    {
        return NO;
    }
}

#pragma mark AutoToolbar methods

/**    Get all UITextField/UITextView siblings of textFieldView. */
-(NSArray<__kindof UIView*>*)responderViews
{
    UIView *superConsideredView;
    
    UIView *textFieldView = _textFieldView;

    //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
    for (Class consideredClass in _toolbarPreviousNextAllowedClasses)
    {
        superConsideredView = [textFieldView superviewOfClassType:consideredClass];
        
        if (superConsideredView)
            break;
    }
    
    //If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
    if (superConsideredView)
    {
        return [superConsideredView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        NSArray<UIView*> *textFields = [textFieldView responderSiblings];
        
        //Sorting textFields according to behaviour
        switch (_toolbarManageBehaviour)
        {
                //If autoToolbar behaviour is bySubviews, then returning it.
            case IQAutoToolbarBySubviews:
                return textFields;
                break;
                
                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case IQAutoToolbarByTag:
                return [textFields sortedArrayByTag];
                break;
                
                //If autoToolbar behaviour is by tag, then sorting it according to tag property.
            case IQAutoToolbarByPosition:
                return [textFields sortedArrayByPosition];
                break;
            default:
                return nil;
                break;
        }
    }
}

/** Add toolbar if it is required to add on textFields and it's siblings. */
-(void)addToolbarIfRequired
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];
    
    //    Getting all the sibling textFields.
    NSArray<UIView*> *siblings = [self responderViews];
    
    [self showLog:[NSString stringWithFormat:@"Found %lu responder sibling(s)",(unsigned long)siblings.count]];

    UIView *textFieldView = _textFieldView;

    //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
    //setInputAccessoryView: check   (Bug ID: #307)
    if ([textFieldView respondsToSelector:@selector(setInputAccessoryView:)])
    {
        if ([textFieldView inputAccessoryView] == nil ||
            [[textFieldView inputAccessoryView] tag] == kIQPreviousNextButtonToolbarTag ||
            [[textFieldView inputAccessoryView] tag] == kIQDoneButtonToolbarTag)
        {
            UITextField *textField = (UITextField*)textFieldView;

            IQBarButtonItemConfiguration *rightConfiguration = nil;
            
            //Supporting Custom Done button image (Enhancement ID: #366)
            if (_toolbarDoneBarButtonItemImage)
            {
                rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:_toolbarDoneBarButtonItemImage action:@selector(doneAction:)];
            }
            //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
            else if (_toolbarDoneBarButtonItemText)
            {
                rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:_toolbarDoneBarButtonItemText action:@selector(doneAction:)];
            }
            else
            {
                rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone action:@selector(doneAction:)];
            }
            rightConfiguration.accessibilityLabel = _toolbarDoneBarButtonItemAccessibilityLabel ? : @"Done";

            //    If only one object is found, then adding only Done button.
            if ((siblings.count <= 1 && self.previousNextDisplayMode == IQPreviousNextDisplayModeDefault) || self.previousNextDisplayMode == IQPreviousNextDisplayModeAlwaysHide)
            {
                [textField addKeyboardToolbarWithTarget:self titleText:(_shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder : nil) rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:nil nextBarButtonConfiguration:nil];

                textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            }
            //If there is multiple siblings of textField
            else if ((self.previousNextDisplayMode == IQPreviousNextDisplayModeDefault) || self.previousNextDisplayMode == IQPreviousNextDisplayModeAlwaysShow)
            {
                IQBarButtonItemConfiguration *prevConfiguration = nil;
                
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarPreviousBarButtonItemImage)
                {
                    prevConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:_toolbarPreviousBarButtonItemImage action:@selector(previousAction:)];
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarPreviousBarButtonItemText)
                {
                    prevConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:_toolbarPreviousBarButtonItemText action:@selector(previousAction:)];
                }
                else
                {
                    prevConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardPreviousImage] action:@selector(previousAction:)];
                }
                prevConfiguration.accessibilityLabel = _toolbarPreviousBarButtonItemAccessibilityLabel ? : @"Previous";
                
                IQBarButtonItemConfiguration *nextConfiguration = nil;
                
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarNextBarButtonItemImage)
                {
                    nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:_toolbarNextBarButtonItemImage action:@selector(nextAction:)];
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarNextBarButtonItemText)
                {
                    nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:_toolbarNextBarButtonItemText action:@selector(nextAction:)];
                }
                else
                {
                    nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardNextImage] action:@selector(nextAction:)];
                }
                nextConfiguration.accessibilityLabel = _toolbarNextBarButtonItemAccessibilityLabel ? : @"Next";

                [textField addKeyboardToolbarWithTarget:self titleText:(_shouldShowToolbarPlaceholder ? textField.drawingToolbarPlaceholder : nil) rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:prevConfiguration nextBarButtonConfiguration:nextConfiguration];

                textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
            }
            
            IQToolbar *toolbar = textField.keyboardToolbar;
            
            //Bar style according to keyboard appearance
            if ([textField respondsToSelector:@selector(keyboardAppearance)])
            {
                //Setting toolbar tintColor //  (Enhancement ID: #30)
                if (_shouldToolbarUsesTextFieldTintColor)
                {
                    toolbar.tintColor = [textField tintColor];
                }
                else if (_toolbarTintColor)
                {
                    toolbar.tintColor = _toolbarTintColor;
                }
                else
                {
                    toolbar.tintColor = nil;
                }

                switch ([textField keyboardAppearance])
                {
                    case UIKeyboardAppearanceDark:
                    {
                        toolbar.barStyle = UIBarStyleBlack;
                        [toolbar setBarTintColor:nil];
                    }
                        break;
                    default:
                    {
                        toolbar.barStyle = UIBarStyleDefault;
                        toolbar.barTintColor = _toolbarBarTintColor;
                    }
                        break;
                }
                
                //If need to show placeholder
                if (_shouldShowToolbarPlaceholder &&
                    textField.shouldHideToolbarPlaceholder == NO)
                {
                    //Updating placeholder     //(Bug ID: #148, #272)
                    if (toolbar.titleBarButton.title == nil ||
                        [toolbar.titleBarButton.title isEqualToString:textField.drawingToolbarPlaceholder] == NO)
                    {
                        [toolbar.titleBarButton setTitle:textField.drawingToolbarPlaceholder];
                    }
                    
                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if (_placeholderFont &&
                        [_placeholderFont isKindOfClass:[UIFont class]])
                    {
                        [toolbar.titleBarButton setTitleFont:_placeholderFont];
                    }

                    //Setting toolbar title color.   //  (Enhancement ID: #880)
                    if (_placeholderColor)
                    {
                        [toolbar.titleBarButton setTitleColor:_placeholderColor];
                    }

                    //Setting toolbar button title color.   //  (Enhancement ID: #880)
                    if (_placeholderButtonColor)
                    {
                        [toolbar.titleBarButton setSelectableTitleColor:_placeholderButtonColor];
                    }
                }
                else
                {
                    //Updating placeholder     //(Bug ID: #272)
                    toolbar.titleBarButton.title = nil;
                }
            }

            //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
            //    If firstTextField, then previous should not be enabled.
            if (siblings.firstObject == textField)
            {
                if (siblings.count == 1)
                {
                    textField.keyboardToolbar.previousBarButton.enabled = NO;
                    textField.keyboardToolbar.nextBarButton.enabled = NO;
                }
                else
                {
                    textField.keyboardToolbar.previousBarButton.enabled = NO;
                    textField.keyboardToolbar.nextBarButton.enabled = YES;
                }
            }
            //    If lastTextField then next should not be enaled.
            else if ([siblings lastObject] == textField)
            {
                textField.keyboardToolbar.previousBarButton.enabled = YES;
                textField.keyboardToolbar.nextBarButton.enabled = NO;
            }
            else
            {
                textField.keyboardToolbar.previousBarButton.enabled = YES;
                textField.keyboardToolbar.nextBarButton.enabled = YES;
            }
        }
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/** Remove any toolbar if it is IQToolbar. */
-(void)removeToolbarIfRequired  //  (Bug ID: #18)
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    //    Getting all the sibling textFields.
    NSArray<UIView*> *siblings = [self responderViews];
    
    [self showLog:[NSString stringWithFormat:@"Found %lu responder sibling(s)",(unsigned long)siblings.count]];

    for (UITextField *textField in siblings)
    {
        UIView *toolbar = [textField inputAccessoryView];
        
        //  (Bug ID: #78)
        //setInputAccessoryView: check   (Bug ID: #307)
        if ([textField respondsToSelector:@selector(setInputAccessoryView:)] &&
            ([toolbar isKindOfClass:[IQToolbar class]] && (toolbar.tag == kIQDoneButtonToolbarTag || toolbar.tag == kIQPreviousNextButtonToolbarTag)))
        {
            textField.inputAccessoryView = nil;
            [textField reloadInputViews];
        }
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/**    reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
- (void)reloadInputViews
{
    //If enabled then adding toolbar.
    if ([self privateIsEnableAutoToolbar] == YES)
    {
        [self addToolbarIfRequired];
    }
    //Else removing toolbar.
    else
    {
        [self removeToolbarIfRequired];
    }
}

#pragma mark previous/next/done functionality
/**    previousAction. */
-(void)previousAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    if ([self canGoPrevious])
    {
        UIView *currentTextFieldView = _textFieldView;
        BOOL isAcceptAsFirstResponder = [self goPrevious];
        
        NSInvocation *invocation = barButton.invocation;
        UIView *sender = currentTextFieldView;

        //Handling search bar special case
        {
            UISearchBar *searchBar = currentTextFieldView.textFieldSearchBar;
            
            if (searchBar)
            {
                invocation = searchBar.keyboardToolbar.previousBarButton.invocation;
                sender = searchBar;
            }
        }

        if (isAcceptAsFirstResponder == YES && invocation)
        {
            if (invocation.methodSignature.numberOfArguments > 2)
            {
                [invocation setArgument:&sender atIndex:2];
            }

            [invocation invoke];
        }
    }
}

/**    nextAction. */
-(void)nextAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    if ([self canGoNext])
    {
        UIView *currentTextFieldView = _textFieldView;
        BOOL isAcceptAsFirstResponder = [self goNext];
        
        NSInvocation *invocation = barButton.invocation;
        UIView *sender = currentTextFieldView;

        //Handling search bar special case
        {
            UISearchBar *searchBar = currentTextFieldView.textFieldSearchBar;
            
            if (searchBar)
            {
                invocation = searchBar.keyboardToolbar.nextBarButton.invocation;
                sender = searchBar;
            }
        }

        if (isAcceptAsFirstResponder == YES && invocation)
        {
            if (invocation.methodSignature.numberOfArguments > 2)
            {
                [invocation setArgument:&sender atIndex:2];
            }

            [invocation invoke];
        }
    }
}

/**    doneAction. Resigning current textField. */
-(void)doneAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    UIView *currentTextFieldView = _textFieldView;
    BOOL isResignedFirstResponder = [self resignFirstResponder];
    
    NSInvocation *invocation = barButton.invocation;
    UIView *sender = currentTextFieldView;

    //Handling search bar special case
    {
        UISearchBar *searchBar = currentTextFieldView.textFieldSearchBar;
        
        if (searchBar)
        {
            invocation = searchBar.keyboardToolbar.doneBarButton.invocation;
            sender = searchBar;
        }
    }

    if (isResignedFirstResponder == YES && invocation)
    {
        if (invocation.methodSignature.numberOfArguments > 2)
        {
            [invocation setArgument:&sender atIndex:2];
        }

        [invocation invoke];
    }
}

#pragma mark - Customised textField/textView support.

/**
 Add customised Notification for third party customised TextField/TextView.
 */
-(void)registerTextFieldViewClass:(nonnull Class)aClass
  didBeginEditingNotificationName:(nonnull NSString *)didBeginEditingNotificationName
    didEndEditingNotificationName:(nonnull NSString *)didEndEditingNotificationName
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:didBeginEditingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:didEndEditingNotificationName object:nil];
}

/**
 Remove customised Notification for third party customised TextField/TextView.
 */
-(void)unregisterTextFieldViewClass:(nonnull Class)aClass
    didBeginEditingNotificationName:(nonnull NSString *)didBeginEditingNotificationName
      didEndEditingNotificationName:(nonnull NSString *)didEndEditingNotificationName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:didBeginEditingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:didEndEditingNotificationName object:nil];
}

-(void)registerAllNotifications
{
    //  Registering for keyboard notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //  Registering for UITextField notification.
    [self registerTextFieldViewClass:[UITextField class]
     didBeginEditingNotificationName:UITextFieldTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextFieldTextDidEndEditingNotification];
    
    //  Registering for UITextView notification.
    [self registerTextFieldViewClass:[UITextView class]
     didBeginEditingNotificationName:UITextViewTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextViewTextDidEndEditingNotification];
    
    //  Registering for orientation changes notification
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
}

-(void)unregisterAllNotifications
{
    //  Unregistering for keyboard notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    //  Unregistering for UITextField notification.
    [self unregisterTextFieldViewClass:[UITextField class]
     didBeginEditingNotificationName:UITextFieldTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextFieldTextDidEndEditingNotification];
    
    //  Unregistering for UITextView notification.
    [self unregisterTextFieldViewClass:[UITextView class]
     didBeginEditingNotificationName:UITextViewTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextViewTextDidEndEditingNotification];
    
    //  Unregistering for orientation changes notification
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
}

-(void)showLog:(NSString*)logString
{
    [self showLog:logString indentation:0];
}

-(void)showLog:(NSString*)logString indentation:(NSInteger)indent
{
    static NSInteger indentation = 0;
    
    if (indent < 0)
    {
        indentation = MAX(0, indentation + indent);
    }
    
    if (_enableDebugging)
    {
        NSMutableString *preLog = [[NSMutableString alloc] init];
        
        for (int i = 0; i<=indentation; i++) {
            [preLog appendString:@"|\t"];
        }

        [preLog appendString:logString];
        NSLog(@"%@",preLog);
    }
    
    if (indent > 0)
    {
        indentation += indent;
    }
}

@end
