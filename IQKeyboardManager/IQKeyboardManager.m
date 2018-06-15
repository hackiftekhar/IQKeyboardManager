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
#import <UIKit/UINavigationController.h>
#import <UIKit/UITouch.h>
#import <UIKit/UIWindow.h>
#import <UIKit/NSLayoutConstraint.h>


NSInteger const kIQDoneButtonToolbarTag             =   -1002;
NSInteger const kIQPreviousNextButtonToolbarTag     =   -1005;

#define kIQCGPointInvalid CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)

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
@property(nonatomic, weak) UIView       *textFieldView;

/** To save rootViewController.view.frame.origin. */
@property(nonatomic, assign) CGPoint    topViewBeginOrigin;

/** To save rootViewController */
@property(nonatomic, weak) UIViewController *rootViewController;

/** To know if we have any pending request to adjust view position. */
@property(nonatomic, assign) BOOL   hasPendingAdjustRequest;

/*******************************************/

/** Variable to save lastScrollView that was scrolled. */
@property(nonatomic, weak) UIScrollView     *lastScrollView;

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

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *registeredClasses;

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
    CGSize                   _kbSize;
    
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
@dynamic shouldShowTextFieldPlaceholder;
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

/** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
+(void)load
{
    //Enabling IQKeyboardManager. Loading asynchronous on main thread
    [self performSelectorOnMainThread:@selector(sharedManager) withObject:nil waitUntilDone:NO];
}

/*  Singleton Object Initialization. */
-(instancetype)init
{
	if (self = [super init])
    {
        __weak typeof(self) weakSelf = self;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.registeredClasses = [[NSMutableSet alloc] init];

            [strongSelf registerAllNotifications];

            //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
            strongSelf.resignFirstResponderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            strongSelf.resignFirstResponderGesture.cancelsTouchesInView = NO;
            [strongSelf.resignFirstResponderGesture setDelegate:self];
            strongSelf.resignFirstResponderGesture.enabled = strongSelf.shouldResignOnTouchOutside;
            strongSelf.topViewBeginOrigin = kIQCGPointInvalid;
            
            //Setting it's initial values
            strongSelf.animationDuration = 0.25;
            strongSelf.animationCurve = UIViewAnimationCurveEaseInOut;
            [self setEnable:YES];
			[self setKeyboardDistanceFromTextField:10.0];
            [self setShouldPlayInputClicks:YES];
            [self setShouldResignOnTouchOutside:NO];
            [self setOverrideKeyboardAppearance:NO];
            [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
            [self setEnableAutoToolbar:YES];
            [self setShouldShowToolbarPlaceholder:YES];
            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            [self setLayoutIfNeededOnUpdate:NO];
            
            //Loading IQToolbar, IQTitleBarButtonItem, IQBarButtonItem to fix first time keyboard appearance delay (Bug ID: #550)
            {
                //If you experience exception breakpoint issue at below line then try these solutions https://stackoverflow.com/questions/27375640/all-exception-break-point-is-stopping-for-no-reason-on-simulator
                UITextField *view = [[UITextField alloc] init];
                [view addDoneOnKeyboardWithTarget:nil action:nil];
                [view addPreviousNextDoneOnKeyboardWithTarget:nil previousAction:nil nextAction:nil doneAction:nil];
            }
            
            //Initializing disabled classes Set.
            strongSelf.disabledDistanceHandlingClasses = [[NSMutableSet alloc] initWithObjects:[UITableViewController class],[UIAlertController class], nil];
            strongSelf.enabledDistanceHandlingClasses = [[NSMutableSet alloc] init];
            
            strongSelf.disabledToolbarClasses = [[NSMutableSet alloc] initWithObjects:[UIAlertController class], nil];
            strongSelf.enabledToolbarClasses = [[NSMutableSet alloc] init];
            
            strongSelf.toolbarPreviousNextAllowedClasses = [[NSMutableSet alloc] initWithObjects:[UITableView class],[UICollectionView class],[IQPreviousNextView class], nil];
            
            strongSelf.disabledTouchResignedClasses = [[NSMutableSet alloc] initWithObjects:[UIAlertController class], nil];
            strongSelf.enabledTouchResignedClasses = [[NSMutableSet alloc] init];
            strongSelf.touchResignedGestureIgnoreClasses = [[NSMutableSet alloc] initWithObjects:[UIControl class],[UINavigationBar class], nil];
            
            [self setShouldToolbarUsesTextFieldTintColor:NO];
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
		//Setting NO to _enable.
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
    
//    IQEnableMode enableMode = _textFieldView.enableMode;
//
//    if (enableMode == IQEnableModeEnabled)
//    {
//        enable = YES;
//    }
//    else if (enableMode == IQEnableModeDisabled)
//    {
//        enable = NO;
//    }
//    else
    {
        UIViewController *textFieldViewController = [_textFieldView viewContainingController];
        
        if (textFieldViewController)
        {
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

-(BOOL)shouldShowTextFieldPlaceholder
{
    return _shouldShowToolbarPlaceholder;
}

-(void)setShouldShowTextFieldPlaceholder:(BOOL)shouldShowTextFieldPlaceholder
{
    _shouldShowToolbarPlaceholder = shouldShowTextFieldPlaceholder;
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
    
    UIView *textFieldView = _textFieldView;
    IQEnableMode enableMode = textFieldView.shouldResignOnTouchOutsideMode;
    
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
        UIViewController *textFieldViewController = [textFieldView viewContainingController];
        
        if (textFieldViewController)
        {
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
    
    UIViewController *textFieldViewController = [_textFieldView viewContainingController];
    
    if (textFieldViewController)
    {
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
        static __weak UIWindow *_keyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow &&
            _keyWindow != originalKeyWindow)
        {
            _keyWindow = originalKeyWindow;
        }
        
        return _keyWindow;
    }
}

-(void)optimizedAdjustPosition
{
    if (_hasPendingAdjustRequest == NO)
    {
        _hasPendingAdjustRequest = YES;
        
        __weak typeof(self) weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self adjustPosition];
            weakSelf.hasPendingAdjustRequest = NO;
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
    
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
    if (_hasPendingAdjustRequest == NO ||
        textFieldView == nil ||
        rootController == nil ||
        keyWindow == nil)
        return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRectInWindow = [[textFieldView superview] convertRect:textFieldView.frame toView:keyWindow];
    CGRect textFieldViewRectInRootSuperview = [[textFieldView superview] convertRect:textFieldView.frame toView:rootController.view.superview];
    //  Getting RootView origin.
    CGPoint rootViewOrigin = rootController.view.frame.origin;

    //Maintain keyboardDistanceFromTextField
    CGFloat specialKeyboardDistanceFromTextField = textFieldView.keyboardDistanceFromTextField;

    {
        UISearchBar *searchBar = textFieldView.searchBar;
        
        if (searchBar)
        {
            specialKeyboardDistanceFromTextField = searchBar.keyboardDistanceFromTextField;
        }
    }
    
    CGFloat keyboardDistanceFromTextField = (specialKeyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance)?_keyboardDistanceFromTextField:specialKeyboardDistanceFromTextField;
    CGSize kbSize = _kbSize;
    kbSize.height += keyboardDistanceFromTextField;
    
    CGFloat topLayoutGuide = rootController.view.layoutMargins.top+5;
    CGFloat bottomLayoutGuide = rootController.view.layoutMargins.bottom;

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
    
    //If there was a lastScrollView.    //  (Bug ID: #34)
    if (_lastScrollView)
    {
        //If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if (superScrollView == nil)
        {
            [self showLog:[NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];

            __weak typeof(self) weakSelf = self;

            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong typeof(self) strongSelf = weakSelf;
                UIScrollView *strongLastScrollView = strongSelf.lastScrollView;

                [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            } completion:NULL];
            
            if (_lastScrollView.shouldRestoreScrollViewContentOffset)
            {
                [_lastScrollView setContentOffset:_startingContentOffset animated:UIView.areAnimationsEnabled];
            }

            _startingContentInsets = UIEdgeInsetsZero;
            _startingScrollIndicatorInsets = UIEdgeInsetsZero;
            _startingContentOffset = CGPointZero;
            _lastScrollView = nil;
        }
        //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
        else if (superScrollView != _lastScrollView)
        {
            [self showLog:[NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];

            __weak typeof(self) weakSelf = self;

            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong typeof(self) strongSelf = weakSelf;
                UIScrollView *strongLastScrollView = strongSelf.lastScrollView;

                [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            } completion:NULL];

            if (_lastScrollView.shouldRestoreScrollViewContentOffset)
            {
                [_lastScrollView setContentOffset:_startingContentOffset animated:UIView.areAnimationsEnabled];
            }
            
            _lastScrollView = superScrollView;
            _startingContentInsets = superScrollView.contentInset;
            _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;
            _startingContentOffset = superScrollView.contentOffset;

            [self showLog:[NSString stringWithFormat:@"Saving New %@ contentInset: %@ and contentOffset : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
        }
        //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        _lastScrollView = superScrollView;
        _startingContentInsets = superScrollView.contentInset;
        _startingContentOffset = superScrollView.contentOffset;
        _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;

        [self showLog:[NSString stringWithFormat:@"Saving %@ contentInset: %@ and contentOffset : %@",[_lastScrollView _IQDescription],NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
    }
    
    //  Special case for ScrollView.
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (_lastScrollView)
        {
            //Saving
            UIView *lastView = textFieldView;
            superScrollView = _lastScrollView;

            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView &&
                   (move>0?(move > (-superScrollView.contentOffset.y-superScrollView.contentInset.top)):superScrollView.contentOffset.y>0) )
            {
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
                if ([textFieldView isKindOfClass:[UITextView class]] &&
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

                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    [self showLog:[NSString stringWithFormat:@"Adjusting %.2f to %@ ContentOffset",(superScrollView.contentOffset.y-shouldOffsetY),[superScrollView _IQDescription]]];
                    [self showLog:[NSString stringWithFormat:@"Remaining Move: %.2f",move]];

                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);

                } completion:NULL];

                //  Getting next lastView & superScrollView.
                lastView = superScrollView;
                superScrollView = nextScrollView;
            }
            
            //Updating contentInset
            {
                CGRect lastScrollViewRect = [[_lastScrollView superview] convertRect:_lastScrollView.frame toView:keyWindow];

                CGFloat bottom = (kbSize.height-keyboardDistanceFromTextField)-(CGRectGetHeight(keyWindow.frame)-CGRectGetMaxY(lastScrollViewRect));

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                UIEdgeInsets movedInsets = _lastScrollView.contentInset;

                movedInsets.bottom = MAX(_startingContentInsets.bottom, bottom);
                
                [self showLog:[NSString stringWithFormat:@"%@ old ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]];
                
                __weak typeof(self) weakSelf = self;

                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    UIScrollView *strongLastScrollView = strongSelf.lastScrollView;

                    strongLastScrollView.contentInset = movedInsets;
                    
                    UIEdgeInsets newInset = strongLastScrollView.scrollIndicatorInsets;
                    newInset.bottom = movedInsets.bottom;
                    strongLastScrollView.scrollIndicatorInsets = newInset;

                } completion:NULL];

                [self showLog:[NSString stringWithFormat:@"%@ new ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]];
            }
        }
        //Going ahead. No else if.
    }
    
    {
        //Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if ([textFieldView isKindOfClass:[UITextView class]])
        {
            UITextView *textView = (UITextView*)textFieldView;

            CGFloat keyboardYPosition = CGRectGetHeight(keyWindow.frame)-(kbSize.height-keyboardDistanceFromTextField);

            CGRect rootSuperViewFrameInWindow = [rootController.view.superview convertRect:rootController.view.superview.bounds toView:keyWindow];

            CGFloat keyboardOverlapping = CGRectGetMaxY(rootSuperViewFrameInWindow) - keyboardYPosition;

            CGFloat textViewHeight = MIN(CGRectGetHeight(textFieldView.frame), (CGRectGetHeight(rootSuperViewFrameInWindow)-topLayoutGuide-keyboardOverlapping));
            
            if (textFieldView.frame.size.height-textView.contentInset.bottom>textViewHeight)
            {
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    UIView *strongTextFieldView = strongSelf.textFieldView;
                    
                    [self showLog:[NSString stringWithFormat:@"%@ Old UITextView.contentInset : %@",[strongTextFieldView _IQDescription], NSStringFromUIEdgeInsets(textView.contentInset)]];
                    
                    //_isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                    if (strongSelf.isTextViewContentInsetChanged == NO)
                    {
                        strongSelf.startingTextViewContentInsets = textView.contentInset;
                        strongSelf.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets;
                    }
                    
                    UIEdgeInsets newContentInset = textView.contentInset;
                    newContentInset.bottom = strongTextFieldView.frame.size.height-textViewHeight;
                    textView.contentInset = newContentInset;
                    textView.scrollIndicatorInsets = newContentInset;
                    strongSelf.isTextViewContentInsetChanged = YES;
                    
                    [self showLog:[NSString stringWithFormat:@"%@ New UITextView.contentInset : %@",[strongTextFieldView _IQDescription], NSStringFromUIEdgeInsets(textView.contentInset)]];
                    
                } completion:NULL];
            }
        }

        {
            __weak typeof(self) weakSelf = self;

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
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    
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
                    
                    [self showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",[rootController _IQDescription],NSStringFromCGPoint(rootViewOrigin)]];
                } completion:NULL];

                _movedDistance = (_topViewBeginOrigin.y-rootViewOrigin.y);
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
                        
                        __strong typeof(self) strongSelf = weakSelf;
                        
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
                        
                        [self showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",[rootController _IQDescription],NSStringFromCGPoint(rootViewOrigin)]];
                    } completion:NULL];

                    _movedDistance = (_topViewBeginOrigin.y-rootController.view.frame.origin.y);
                }
            }
        }
    }
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

-(void)restorePosition
{
    _hasPendingAdjustRequest = NO;

    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (_rootViewController && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid) == false)
    {
        __weak typeof(self) weakSelf = self;
        
        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong typeof(self) strongSelf = weakSelf;
            UIViewController *strongRootController = strongSelf.rootViewController;
            
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring %@ origin to : %@",[strongRootController _IQDescription],NSStringFromCGPoint(strongSelf.topViewBeginOrigin)]];
                
                //Restoring
                CGRect rect = strongRootController.view.frame;
                rect.origin = strongSelf.topViewBeginOrigin;
                strongRootController.view.frame = rect;

                strongSelf.movedDistance = 0;
                
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
    
    CGSize oldKBSize = _kbSize;
    
    //  Getting UIKeyboardSize.
    CGRect kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGRect screenSize = [[UIScreen mainScreen] bounds];

    //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381)
    CGRect intersectRect = CGRectIntersection(kbFrame, screenSize);

    if (CGRectIsNull(intersectRect))
    {
        _kbSize = CGSizeMake(screenSize.size.width, 0);
    }
    else
    {
        _kbSize = intersectRect.size;
    }
    
	if ([self privateIsEnabled] == NO)	return;
	
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    UIView *textFieldView = _textFieldView;

    if (textFieldView && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [textFieldView parentContainerViewController];
        _rootViewController = rootController;
        _topViewBeginOrigin = rootController.view.frame.origin;

        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",[rootController _IQDescription] ,NSStringFromCGPoint(_topViewBeginOrigin)]];
    }

    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGSizeEqualToSize(_kbSize, oldKBSize))
    {
        //If _textFieldView is inside UIAlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if (_keyboardShowing == YES &&
            textFieldView &&
            [textFieldView isAlertViewTextField] == NO)
        {
            [self optimizedAdjustPosition];
        }
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

/*  UIKeyboardDidShowNotification. */
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if ([self privateIsEnabled] == NO)	return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];
    
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
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
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
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //Restoring the contentOffset of the lastScrollView
    if (_lastScrollView)
    {
        __weak typeof(self) weakSelf = self;

        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.lastScrollView.contentInset = strongSelf.startingContentInsets;
            strongSelf.lastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            
            if (strongSelf.lastScrollView.shouldRestoreScrollViewContentOffset)
            {
                strongSelf.lastScrollView.contentOffset = strongSelf.startingContentOffset;
            }

            [self showLog:[NSString stringWithFormat:@"Restoring %@ contentInset to : %@ and contentOffset to : %@",[strongSelf.lastScrollView _IQDescription],NSStringFromUIEdgeInsets(strongSelf.startingContentInsets),NSStringFromCGPoint(strongSelf.startingContentOffset)]];
            
            // TODO: restore scrollView state
            // This is temporary solution. Have to implement the save and restore scrollView state
            UIScrollView *superscrollView = strongSelf.lastScrollView;
            do
            {
                CGSize contentSize = CGSizeMake(MAX(superscrollView.contentSize.width, CGRectGetWidth(superscrollView.frame)), MAX(superscrollView.contentSize.height, CGRectGetHeight(superscrollView.frame)));
                
                CGFloat minimumY = contentSize.height-CGRectGetHeight(superscrollView.frame);
                
                if (minimumY<superscrollView.contentOffset.y)
                {
                    superscrollView.contentOffset = CGPointMake(superscrollView.contentOffset.x, minimumY);
                    
                    [self showLog:[NSString stringWithFormat:@"Restoring %@ contentOffset to : %@",[superscrollView _IQDescription],NSStringFromCGPoint(superscrollView.contentOffset)]];
                }
            } while ((superscrollView = (UIScrollView*)[superscrollView superviewOfClassType:[UIScrollView class]]));

        } completion:NULL];
    }
    
    [self restorePosition];

    //Reset all values
    _lastScrollView = nil;
    _kbSize = CGSizeZero;
    _startingContentInsets = UIEdgeInsetsZero;
    _startingScrollIndicatorInsets = UIEdgeInsetsZero;
    _startingContentOffset = CGPointZero;

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

/*  UIKeyboardDidHideNotification. So topViewBeginRect can be set to CGRectZero. */
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    _topViewBeginOrigin = kIQCGPointInvalid;

    _kbSize = CGSizeZero;

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

#pragma mark - UITextFieldView Delegate methods
/**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //  Getting object
    _textFieldView = notification.object;
    
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
        if ([textFieldView isKindOfClass:[UITextView class]] &&
            textFieldView.inputAccessoryView == nil)
        {
            __weak typeof(self) weakSelf = self;

            [UIView animateWithDuration:0.00001 delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self addToolbarIfRequired];
            } completion:^(BOOL finished) {

                __strong typeof(self) strongSelf = weakSelf;

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

	if ([self privateIsEnabled] == YES)
    {
        if (CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
        {
            //  keyboard is not showing(At the beginning only).
            UIViewController *rootController = [textFieldView parentContainerViewController];
            _rootViewController = rootController;
            _topViewBeginOrigin = rootController.view.frame.origin;
            
            [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",[rootController _IQDescription], NSStringFromCGPoint(_topViewBeginOrigin)]];
        }
        
        //If textFieldView is inside UIAlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
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
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

/**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    UIView *textFieldView = _textFieldView;

    //Removing gesture recognizer   (Enhancement ID: #14)
    [textFieldView.window removeGestureRecognizer:_resignFirstResponderGesture];
    
//    if ([textFieldView isKindOfClass:[UITextField class]])
//    {
//        [(UITextField*)textFieldView removeTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    }

    // We check if there's a change in original frame or not.
    if(_isTextViewContentInsetChanged == YES &&
       [textFieldView isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView*)textFieldView;

        __weak typeof(self) weakSelf = self;

        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.isTextViewContentInsetChanged = NO;

            [self showLog:[NSString stringWithFormat:@"Restoring %@ textView.contentInset to : %@",[strongSelf.textFieldView _IQDescription],NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];

            //Setting textField to it's initial contentInset
            textView.contentInset = strongSelf.startingTextViewContentInsets;
            textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;

        } completion:NULL];
    }
    
    //Setting object to nil
    _textFieldView = nil;

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

//-(void)editingDidEndOnExit:(UITextField*)textField
//{
//    [self showLog:[NSString stringWithFormat:@"ReturnKey %@",NSStringFromSelector(_cmd)]];
//}

#pragma mark - UIStatusBar Notification methods
/**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //If textViewContentInsetChanged is changed then restore it.
    if (_isTextViewContentInsetChanged == YES &&
        [_textFieldView isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView*)_textFieldView;

        __weak typeof(self) weakSelf = self;

        //Due to orientation callback we need to set it's original position.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.isTextViewContentInsetChanged = NO;

            [self showLog:[NSString stringWithFormat:@"Restoring %@ textView.contentInset to : %@",[strongSelf.textFieldView _IQDescription],NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];
            
            //Setting textField to it's initial contentInset
            textView.contentInset = strongSelf.startingTextViewContentInsets;
            textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;
        } completion:NULL];
    }

    [self restorePosition];

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
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
            
            [self showLog:[NSString stringWithFormat:@"Refuses to Resign first responder: %@",[textFieldView _IQDescription]]];
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
    NSArray *textFields = [self responderViews];

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
    NSArray *textFields = [self responderViews];
    
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
    NSArray *textFields = [self responderViews];
    
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];
    
    //If it is not first textField. then it's previous object becomeFirstResponder.
    if (index != NSNotFound &&
        index > 0)
    {
        UITextField *nextTextField = textFields[index-1];
        
        //  Retaining textFieldView
        UIView *textFieldRetain = _textFieldView;
        
        BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];
        
        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if (isAcceptAsFirstResponder == NO)
        {
            //If next field refuses to become first responder then restoring old textField as first responder.
            [textFieldRetain becomeFirstResponder];
            
            [self showLog:[NSString stringWithFormat:@"Refuses to become first responder: %@",[nextTextField _IQDescription]]];
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
    NSArray *textFields = [self responderViews];
    
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:_textFieldView];
    
    //If it is not last textField. then it's next object becomeFirstResponder.
    if (index != NSNotFound &&
        index < textFields.count-1)
    {
        UITextField *nextTextField = textFields[index+1];
        
        //  Retaining textFieldView
        UIView *textFieldRetain = _textFieldView;
        
        BOOL isAcceptAsFirstResponder = [nextTextField becomeFirstResponder];
        
        //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
        if (isAcceptAsFirstResponder == NO)
        {
            //If next field refuses to become first responder then restoring old textField as first responder.
            [textFieldRetain becomeFirstResponder];
            
            [self showLog:[NSString stringWithFormat:@"Refuses to become first responder: %@",[nextTextField _IQDescription]]];
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
-(NSArray*)responderViews
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
        NSArray *textFields = [textFieldView responderSiblings];
        
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
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];
    
    //    Getting all the sibling textFields.
    NSArray *siblings = [self responderViews];
    
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

            //    If only one object is found, then adding only Done button.
            if ((siblings.count==1 && self.previousNextDisplayMode == IQPreviousNextDisplayModeDefault) || self.previousNextDisplayMode == IQPreviousNextDisplayModeAlwaysHide)
            {
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarDoneBarButtonItemImage)
                {
                    [textField addRightButtonOnKeyboardWithImage:_toolbarDoneBarButtonItemImage target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarDoneBarButtonItemText)
                {
                    [textField addRightButtonOnKeyboardWithText:_toolbarDoneBarButtonItemText target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                else
                {
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    [textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            }
            //If there is multiple siblings of textField
            else if ((siblings.count && self.previousNextDisplayMode == IQPreviousNextDisplayModeDefault) || self.previousNextDisplayMode == IQPreviousNextDisplayModeAlwaysShow)
            {
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarDoneBarButtonItemImage)
                {
                    [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonImage:_toolbarDoneBarButtonItemImage previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarDoneBarButtonItemText)
                {
                    [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonTitle:_toolbarDoneBarButtonItemText previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                else
                {
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowToolbarPlaceholder];
                }
                textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
            }
            
            IQToolbar *toolbar = textField.keyboardToolbar;
            
            //Bar style according to keyboard appearance
            if ([textField respondsToSelector:@selector(keyboardAppearance)])
            {
                switch ([textField keyboardAppearance])
                {
                    case UIKeyboardAppearanceAlert:
                    {
                        toolbar.barStyle = UIBarStyleBlack;
                        [toolbar setTintColor:[UIColor whiteColor]];
                        [toolbar setBarTintColor:nil];
                    }
                        break;
                    default:
                    {
                        toolbar.barStyle = UIBarStyleDefault;
                        toolbar.barTintColor = _toolbarBarTintColor;

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
                            toolbar.tintColor = [UIColor blackColor];
                        }
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
                    if (_placeholderColor &&
                        [_placeholderColor isKindOfClass:[UIColor class]])
                    {
                        [toolbar.titleBarButton setTitleColor:_placeholderColor];
                    }

                    //Setting toolbar button title color.   //  (Enhancement ID: #880)
                    if (_placeholderButtonColor &&
                        [_placeholderButtonColor isKindOfClass:[UIColor class]])
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
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
}

/** Remove any toolbar if it is IQToolbar. */
-(void)removeToolbarIfRequired  //  (Bug ID: #18)
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //    Getting all the sibling textFields.
    NSArray *siblings = [self responderViews];
    
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
    [self showLog:[NSString stringWithFormat:@"****** %@ ended: %g seconds ******",NSStringFromSelector(_cmd),elapsedTime]];
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

        //Handling search bar special case
        {
            UISearchBar *searchBar = currentTextFieldView.searchBar;
            
            if (searchBar)
            {
                invocation = searchBar.keyboardToolbar.previousBarButton.invocation;
            }
        }

        if (isAcceptAsFirstResponder == YES && barButton.invocation)
        {
            if (barButton.invocation.methodSignature.numberOfArguments > 2)
            {
                [barButton.invocation setArgument:&currentTextFieldView atIndex:2];
            }

            [barButton.invocation invoke];
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

        //Handling search bar special case
        {
            UISearchBar *searchBar = currentTextFieldView.searchBar;
            
            if (searchBar)
            {
                invocation = searchBar.keyboardToolbar.nextBarButton.invocation;
            }
        }

        if (isAcceptAsFirstResponder == YES && barButton.invocation)
        {
            if (barButton.invocation.methodSignature.numberOfArguments > 2)
            {
                [barButton.invocation setArgument:&currentTextFieldView atIndex:2];
            }

            [barButton.invocation invoke];
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

    //Handling search bar special case
    {
        UISearchBar *searchBar = currentTextFieldView.searchBar;
        
        if (searchBar)
        {
            invocation = searchBar.keyboardToolbar.doneBarButton.invocation;
        }
    }

    if (isResignedFirstResponder == YES && barButton.invocation)
    {
        if (barButton.invocation.methodSignature.numberOfArguments > 2)
        {
            [barButton.invocation setArgument:&currentTextFieldView atIndex:2];
        }

        [barButton.invocation invoke];
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
    [_registeredClasses addObject:aClass];
    
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
    [_registeredClasses removeObject:aClass];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
}

-(void)showLog:(NSString*)logString
{
    if (_enableDebugging)
    {
        NSLog(@"IQKeyboardManager: %@",logString);
    }
}

@end
