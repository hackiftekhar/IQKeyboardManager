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
#import "IQUIWindow+Hierarchy.h"
#import "IQNSArray+Sort.h"
#import "IQToolbar.h"
#import "IQBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQUIScrollView+Additions.h"
#import "IQUITextFieldView+Additions.h"
#import "IQUIViewController+Additions.h"
#import "IQPreviousNextView.h"

#import <UIKit/UINavigationBar.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITableViewController.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UITableView.h>
#import <UIKit/UITouch.h>

#import <UIKit/UICollectionView.h>
#import <UIKit/NSLayoutConstraint.h>

NSInteger const kIQDoneButtonToolbarTag             =   -1002;
NSInteger const kIQPreviousNextButtonToolbarTag     =   -1005;

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

/** To save rootViewController.view.frame. */
@property(nonatomic, assign) CGRect     topViewBeginRect;

/** To save rootViewController */
@property(nonatomic, weak) UIViewController *rootViewController;

/** To save topBottomLayoutConstraint original constant */
@property(nonatomic, assign) CGFloat    layoutGuideConstraintInitialConstant;


/*******************************************/

/** TapGesture to resign keyboard on view's touch. */
@property(nonatomic, strong) UITapGestureRecognizer  *tapGesture;

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

/** Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
@property(nonatomic, assign) BOOL  isKeyboardShowing;

/*******************************************/

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *registeredClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledDistanceHandlingClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledDistanceHandlingClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledToolbarClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledToolbarClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *toolbarPreviousNextAllowedClasses;

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledTouchResignedClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledTouchResignedClasses;

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
@synthesize preventShowingBottomBlankSpace      =   _preventShowingBottomBlankSpace;

//Keyboard Appearance handling
@synthesize overrideKeyboardAppearance          =   _overrideKeyboardAppearance;
@synthesize keyboardAppearance                  =   _keyboardAppearance;

//IQToolbar handling
@synthesize enableAutoToolbar                   =   _enableAutoToolbar;
@synthesize toolbarManageBehaviour              =   _toolbarManageBehaviour;

@synthesize shouldToolbarUsesTextFieldTintColor =   _shouldToolbarUsesTextFieldTintColor;
@synthesize toolbarTintColor                    =   _toolbarTintColor;

@synthesize shouldShowTextFieldPlaceholder      =   _shouldShowTextFieldPlaceholder;
@synthesize placeholderFont                     =   _placeholderFont;

//Resign handling
@synthesize shouldResignOnTouchOutside          =   _shouldResignOnTouchOutside;

//Sound handling
@synthesize shouldPlayInputClicks               =   _shouldPlayInputClicks;

//Animation handling
@synthesize layoutIfNeededOnUpdate              =   _layoutIfNeededOnUpdate;

#pragma mark - Initializing functions

/** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
+(void)load
{
    //Enabling IQKeyboardManager.
    [[IQKeyboardManager sharedManager] setEnable:YES];
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

            //  Registering for keyboard notification.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

            strongSelf.registeredClasses = [[NSMutableSet alloc] init];

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

            //  Registering for status bar frame change notification
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
            
            //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
            strongSelf.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            strongSelf.tapGesture.cancelsTouchesInView = NO;
            [strongSelf.tapGesture setDelegate:self];
            strongSelf.tapGesture.enabled = strongSelf.shouldResignOnTouchOutside;

            //Setting it's initial values
            strongSelf.animationDuration = 0.25;
            strongSelf.animationCurve = UIViewAnimationCurveEaseInOut;
			[self setKeyboardDistanceFromTextField:10.0];
            [self setShouldPlayInputClicks:YES];
            [self setShouldResignOnTouchOutside:NO];
            [self setOverrideKeyboardAppearance:NO];
            [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
            [self setEnableAutoToolbar:YES];
            [self setPreventShowingBottomBlankSpace:YES];
            [self setShouldShowTextFieldPlaceholder:YES];
            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            [self setLayoutIfNeededOnUpdate:NO];
            [self setShouldFixInteractivePopGestureRecognizer:YES];
            
            //Initializing disabled classes Set.
            strongSelf.disabledDistanceHandlingClasses = [[NSMutableSet alloc] initWithObjects:[UITableViewController class], nil];
            strongSelf.enabledDistanceHandlingClasses = [[NSMutableSet alloc] init];
            
            strongSelf.disabledToolbarClasses = [[NSMutableSet alloc] init];
            strongSelf.enabledToolbarClasses = [[NSMutableSet alloc] init];
            
            strongSelf.toolbarPreviousNextAllowedClasses = [[NSMutableSet alloc] initWithObjects:[UITableView class],[UICollectionView class],[IQPreviousNextView class], nil];
            
            strongSelf.disabledTouchResignedClasses = [[NSMutableSet alloc] init];
            strongSelf.enabledTouchResignedClasses = [[NSMutableSet alloc] init];

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
    if (enable == YES && _enable == NO)
    {
		//Setting NO to _enable.
		_enable = enable;
        
		//If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
		if (_kbShowNotification)	[self keyboardWillShow:_kbShowNotification];

        [self showLog:IQLocalizedString(@"enabled", nil)];
    }
	//If not disable, desable it.
    else if (enable == NO && _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original frame.
		[self keyboardWillHide:nil];
        
		//Setting NO to _enable.
		_enable = enable;
		
        [self showLog:IQLocalizedString(@"disabled", nil)];
    }
	//If already disabled.
	else if (enable == NO && _enable == NO)
	{
        [self showLog:IQLocalizedString(@"already disabled", nil)];
	}
	//If already enabled.
	else if (enable == YES && _enable == YES)
	{
        [self showLog:IQLocalizedString(@"already enabled", nil)];
	}
}

-(BOOL)privateIsEnabled
{
    BOOL enable = _enable;
    
    UIViewController *textFieldViewController = [_textFieldView viewController];
    
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
    [_tapGesture setEnabled:[self privateShouldResignOnTouchOutside]];
}

-(BOOL)privateShouldResignOnTouchOutside
{
    BOOL shouldResignOnTouchOutside = _shouldResignOnTouchOutside;
    
    UIViewController *textFieldViewController = [_textFieldView viewController];
    
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
    
    UIViewController *textFieldViewController = [_textFieldView viewController];
    
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
        }
    }
    
    return enableAutoToolbar;
}

#pragma mark - Private Methods

/** Getting keyWindow. */
-(UIWindow *)keyWindow
{
    if (_textFieldView.window)
    {
        return _textFieldView.window;
    }
    else
    {
        static UIWindow *_keyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow != nil && _keyWindow != originalKeyWindow)  _keyWindow = originalKeyWindow;
        
        return _keyWindow;
    }
}

/*  Helper function to manipulate RootViewController's frame with animation. */
-(void)setRootViewFrame:(CGRect)frame
{
    //  Getting topMost ViewController.
    UIViewController *controller = [_textFieldView topMostController];
    if (controller == nil)  controller = [[self keyWindow] topMostController];
    
    //frame size needs to be adjusted on iOS8 due to orientation API changes.
    frame.size = controller.view.frame.size;

    //  If can't get rootViewController then printing warning to user.
    if (controller == nil)
        [self showLog:(IQLocalizedString(@"You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager", nil))];
    
    __weak typeof(self) weakSelf = self;
    
    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{

        __strong typeof(self) strongSelf = weakSelf;

        //  Setting it's new frame
        [controller.view setFrame:frame];
        
        //Animating content if needed (Bug ID: #204)
        if (strongSelf.layoutIfNeededOnUpdate)
        {
            //Animating content (Bug ID: #160)
            [controller.view setNeedsLayout];
            [controller.view layoutIfNeeded];
        }
        
        [self showLog:[NSString stringWithFormat:@"Set %@ frame to : %@",[controller _IQDescription],NSStringFromCGRect(frame)]];
    } completion:NULL];
}

/* Adjusting RootViewController's frame according to interface orientation. */
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
    if (_textFieldView == nil)   return;
    
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //  Boolean to know keyboard is showing/hiding
    _isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *keyWindow = [self keyWindow];
    
    //  Getting RootViewController.  (Bug ID: #1, #4)
    UIViewController *rootController = [_textFieldView topMostController];
    if (rootController == nil)  rootController = [keyWindow topMostController];
    
    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
    //  Getting RootViewRect.
    CGRect rootViewRect = [[rootController view] frame];
    //Getting statusBarFrame

    //Maintain keyboardDistanceFromTextField
    CGFloat specialKeyboardDistanceFromTextField = _textFieldView.keyboardDistanceFromTextField;
    
    if (_textFieldView.isSearchBarTextField)
    {
        UISearchBar *searchBar = (UISearchBar*)[_textFieldView superviewOfClassType:[UISearchBar class]];
        specialKeyboardDistanceFromTextField = searchBar.keyboardDistanceFromTextField;
    }
    
    CGFloat keyboardDistanceFromTextField = (specialKeyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance)?_keyboardDistanceFromTextField:specialKeyboardDistanceFromTextField;
    CGSize kbSize = _kbSize;
    kbSize.height += keyboardDistanceFromTextField;

    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    //  (Bug ID: #250)
    IQLayoutGuidePosition layoutGuidePosition = IQLayoutGuidePositionNone;
    
    NSLayoutConstraint *constraint = [[_textFieldView viewController] IQLayoutGuideConstraint];
    
    //If topLayoutGuide constraint
    if (constraint && (constraint.firstItem == [[_textFieldView viewController] topLayoutGuide] || constraint.secondItem == [[_textFieldView viewController] topLayoutGuide]))
    {
        layoutGuidePosition = IQLayoutGuidePositionTop;
    }
    //If bottomLayoutGuice constraint
    else if (constraint && (constraint.firstItem == [[_textFieldView viewController] bottomLayoutGuide] || constraint.secondItem == [[_textFieldView viewController] bottomLayoutGuide]))
    {
        layoutGuidePosition = IQLayoutGuidePositionBottom;
    }
    
    CGFloat topLayoutGuide = CGRectGetHeight(statusBarFrame);

    CGFloat move = 0;
    //  +Move positive = textField is hidden.
    //  -Move negative = textField is showing.
	
    //  Checking if there is bottomLayoutGuide attached (Bug ID: #250)
    if (layoutGuidePosition == IQLayoutGuidePositionBottom)
    {
        //  Calculating move position.
        move = CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(keyWindow.frame)-kbSize.height);
    }
    else
    {
        //  Calculating move position. Common for both normal and special cases.
        move = MIN(CGRectGetMinY(textFieldViewRect)-(topLayoutGuide+5), CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(keyWindow.frame)-kbSize.height));
    }
	
    [self showLog:[NSString stringWithFormat:@"Need to move: %.2f",move]];

    UIScrollView *superScrollView = nil;
    UIScrollView *superView = (UIScrollView*)[_textFieldView superviewOfClassType:[UIScrollView class]];

    //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
    while (superView)
    {
        if (superView.isScrollEnabled)
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

                [strongSelf.lastScrollView setContentInset:strongSelf.startingContentInsets];
                strongSelf.lastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            } completion:NULL];
            
            if (_lastScrollView.shouldRestoreScrollViewContentOffset)
            {
                [_lastScrollView setContentOffset:_startingContentOffset animated:YES];
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

                [strongSelf.lastScrollView setContentInset:strongSelf.startingContentInsets];
                strongSelf.lastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            } completion:NULL];

            if (_lastScrollView.shouldRestoreScrollViewContentOffset)
            {
                [_lastScrollView setContentOffset:_startingContentOffset animated:YES];
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
            UIView *lastView = _textFieldView;
            UIScrollView *superScrollView = _lastScrollView;

            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView && (move>0?(move > (-superScrollView.contentOffset.y-superScrollView.contentInset.top)):superScrollView.contentOffset.y>0) )
            {
                //Getting lastViewRect.
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y/*-5*/);   //-5 is for good UI.//Commenting -5 (Bug ID: #69)
                
                //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                //[superScrollView superviewOfClassType:[UIScrollView class]] == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                //shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                if ([_textFieldView isKindOfClass:[UITextView class]] && [superScrollView superviewOfClassType:[UIScrollView class]] == nil && (shouldOffsetY >= 0))
                {
                    CGFloat maintainTopLayout = 0;
                    
                    //When uncommenting this, each calculation goes to well, but don't know why scrollView doesn't adjusting it's contentOffset at bottom
//                    if ([_textFieldView.viewController respondsToSelector:@selector(topLayoutGuide)])
//                        maintainTopLayout = [_textFieldView.viewController.topLayoutGuide length];
//                    else
                        maintainTopLayout = CGRectGetMaxY(_textFieldView.viewController.navigationController.navigationBar.frame);

                    maintainTopLayout+= 10; //For good UI
                    
                    //  Converting Rectangle according to window bounds.
                    CGRect currentTextFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
                    
                    //Calculating expected fix distance which needs to be managed from navigation bar
                    CGFloat expectedFixDistance = CGRectGetMinY(currentTextFieldViewRect) - maintainTopLayout;
                    
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
                superScrollView = (UIScrollView*)[lastView superviewOfClassType:[UIScrollView class]];
            }
            
            //Updating contentInset
            {
                CGRect lastScrollViewRect = [[_lastScrollView superview] convertRect:_lastScrollView.frame toView:keyWindow];

                CGFloat bottom = kbSize.height-keyboardDistanceFromTextField-(CGRectGetHeight(keyWindow.frame)-CGRectGetMaxY(lastScrollViewRect));

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                UIEdgeInsets movedInsets = _lastScrollView.contentInset;

                movedInsets.bottom = MAX(_startingContentInsets.bottom, bottom);
                
                [self showLog:[NSString stringWithFormat:@"%@ old ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]];
                
                __weak typeof(self) weakSelf = self;

                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong typeof(self) strongSelf = weakSelf;

                    strongSelf.lastScrollView.contentInset = movedInsets;
                    
                    UIEdgeInsets newInset = strongSelf.lastScrollView.scrollIndicatorInsets;
                    newInset.bottom = movedInsets.bottom;
                    strongSelf.lastScrollView.scrollIndicatorInsets = newInset;

                } completion:NULL];

                [self showLog:[NSString stringWithFormat:@"%@ new ContentInset : %@",[_lastScrollView _IQDescription], NSStringFromUIEdgeInsets(_lastScrollView.contentInset)]];
            }
        }
        //Going ahead. No else if.
    }
    
    if (layoutGuidePosition == IQLayoutGuidePositionTop)
    {
        CGFloat constant = MIN(_layoutGuideConstraintInitialConstant, constraint.constant-move);
        
        __weak typeof(self) weakSelf = self;

        [UIView animateWithDuration:_animationDuration delay:0 options:(7<<16|UIViewAnimationOptionBeginFromCurrentState) animations:^{

            __strong typeof(self) strongSelf = weakSelf;

            constraint.constant = constant;
            [strongSelf.rootViewController.view setNeedsLayout];
            [strongSelf.rootViewController.view layoutIfNeeded];
        } completion:NULL];
    }
    //If bottomLayoutGuice constraint
    else if (layoutGuidePosition == IQLayoutGuidePositionBottom)
    {
        CGFloat constant = MAX(_layoutGuideConstraintInitialConstant, constraint.constant+move);
        
        __weak typeof(self) weakSelf = self;

        [UIView animateWithDuration:_animationDuration delay:0 options:(7<<16|UIViewAnimationOptionBeginFromCurrentState) animations:^{

            __strong typeof(self) strongSelf = weakSelf;

            constraint.constant = constant;
            [strongSelf.rootViewController.view setNeedsLayout];
            [strongSelf.rootViewController.view layoutIfNeeded];
        } completion:NULL];
    }
    //If not constraint
    else
    {
        //Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if ([_textFieldView isKindOfClass:[UITextView class]])
        {
            UITextView *textView = (UITextView*)_textFieldView;

            CGFloat textViewHeight = MIN(CGRectGetHeight(_textFieldView.frame), (CGRectGetHeight(keyWindow.frame)-kbSize.height-(topLayoutGuide)));
            
            if (_textFieldView.frame.size.height-textView.contentInset.bottom>textViewHeight)
            {
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    
                    [self showLog:[NSString stringWithFormat:@"%@ Old UITextView.contentInset : %@",[strongSelf.textFieldView _IQDescription], NSStringFromUIEdgeInsets(textView.contentInset)]];
                    
                    //_isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                    if (_isTextViewContentInsetChanged == NO)
                    {
                        _startingTextViewContentInsets = textView.contentInset;
                        _startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets;
                    }
                    
                    UIEdgeInsets newContentInset = textView.contentInset;
                    newContentInset.bottom = _textFieldView.frame.size.height-textViewHeight;
                    textView.contentInset = newContentInset;
                    textView.scrollIndicatorInsets = newContentInset;
                    strongSelf.isTextViewContentInsetChanged = YES;
                    
                    [self showLog:[NSString stringWithFormat:@"%@ New UITextView.contentInset : %@",[strongSelf.textFieldView _IQDescription], NSStringFromUIEdgeInsets(textView.contentInset)]];
                    
                } completion:NULL];
            }
        }

        //  Special case for iPad modalPresentationStyle.
        if ([rootController modalPresentationStyle] == UIModalPresentationFormSheet ||
            [rootController modalPresentationStyle] == UIModalPresentationPageSheet)
        {
            [self showLog:[NSString stringWithFormat:@"Found Special case for Model Presentation Style: %ld",(long)(rootController.modalPresentationStyle)]];
            
            //  +Positive or zero.
            if (move>=0)
            {
                // We should only manipulate y.
                rootViewRect.origin.y -= move;
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if (_preventShowingBottomBlankSpace == YES)
                {
                    CGFloat minimumY = (CGRectGetHeight(keyWindow.frame)-rootViewRect.size.height-topLayoutGuide)/2-(kbSize.height-keyboardDistanceFromTextField);
                    
                    rootViewRect.origin.y = MAX(rootViewRect.origin.y, minimumY);
                }
                
                [self showLog:@"Moving Upward"];
                //  Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
            //  -Negative
            else
            {
                //  Calculating disturbed distance. Pull Request #3
                CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect);
                
                //  disturbDistance Negative = frame disturbed.
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<0)
                {
                    // We should only manipulate y.
                    rootViewRect.origin.y -= MAX(move, disturbDistance);
                    
                    [self showLog:@"Moving Downward"];
                    //  Setting adjusted rootViewRect
                    [self setRootViewFrame:rootViewRect];
                }
            }
        }
        //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
        else
        {
            //  +Positive or zero.
            if (move>=0)
            {
                rootViewRect.origin.y -= move;
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                if (_preventShowingBottomBlankSpace == YES)
                {
                    rootViewRect.origin.y = MAX(rootViewRect.origin.y, MIN(0, -kbSize.height+keyboardDistanceFromTextField));
                }
                
                [self showLog:@"Moving Upward"];
                //  Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
            //  -Negative
            else
            {
                CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(_topViewBeginRect);
                
                //  disturbDistance Negative = frame disturbed. Pull Request #3
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<0)
                {
                    rootViewRect.origin.y -= MAX(move, disturbDistance);
                    
                    [self showLog:@"Moving Downward"];
                    //  Setting adjusted rootViewRect
                    [self setRootViewFrame:rootViewRect];
                }
            }
        }
    }
    
    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

#pragma mark - Public Methods

/*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
- (void)reloadLayoutIfNeeded
{
    if ([self privateIsEnabled] == NO)	return;
    
    if (_textFieldView != nil &&
        _isKeyboardShowing == YES &&
        CGRectEqualToRect(_topViewBeginRect, CGRectZero) == false &&
        [_textFieldView isAlertViewTextField] == NO)
    {
        [self adjustFrame];
    }
}

#pragma mark - UIKeyboad Notification methods
/*  UIKeyboardWillShowNotification. */
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    _kbShowNotification = aNotification;
	
	if ([self privateIsEnabled] == NO)	return;
	
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    if (CGRectEqualToRect(_topViewBeginRect, CGRectZero))    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        _rootViewController = [_textFieldView topMostController];
        if (_rootViewController == nil)  _rootViewController = [[self keyWindow] topMostController];

        _topViewBeginRect = _rootViewController.view.frame;
        
        if (_shouldFixInteractivePopGestureRecognizer && [_rootViewController isKindOfClass:[UINavigationController class]])
        {
            _topViewBeginRect.origin = CGPointMake(0, [self keyWindow].frame.size.height-_rootViewController.view.frame.size.height);
        }

        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning Frame: %@",[_rootViewController _IQDescription] ,NSStringFromCGRect(_topViewBeginRect)]];
    }

    //  Getting keyboard animation.
    _animationCurve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _animationCurve = _animationCurve<<16;

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
 
    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGSizeEqualToSize(_kbSize, oldKBSize))
    {
        //If _textFieldView is inside UIAlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if (_textFieldView != nil  && [_textFieldView isAlertViewTextField] == NO)
        {
            [self adjustFrame];
        }
    }

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

/*  UIKeyboardDidShowNotification. */
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if ([self privateIsEnabled] == NO)	return;
    
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];
    
    //  Getting topMost ViewController.
    UIViewController *controller = [_textFieldView topMostController];
    if (controller == nil)  controller = [[self keyWindow] topMostController];

    //If _textFieldView viewController is presented as formSheet, then adjustFrame again because iOS internally update formSheet frame on keyboardShown. (Bug ID: #37, #74, #76)
    if (_textFieldView != nil && controller.modalPresentationStyle == UIModalPresentationFormSheet && [_textFieldView isAlertViewTextField] == NO)
    {
        [self adjustFrame];
    }
    
    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

/*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //If it's not a fake notification generated by [self setEnable:NO].
    if (aNotification != nil)	_kbShowNotification = nil;
    
    //If not enabled then do nothing.
    if ([self privateIsEnabled] == NO)	return;
    
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //  Boolean to know keyboard is showing/hiding
    _isKeyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        _animationDuration = aDuration;
    }
    
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
    
    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (!CGRectEqualToRect(_topViewBeginRect, CGRectZero) && _rootViewController)
    {
        //frame size needs to be adjusted on iOS8 due to orientation API changes.
        _topViewBeginRect.size = _rootViewController.view.frame.size;
        
        __weak typeof(self) weakSelf = self;

        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{

            __strong typeof(self) strongSelf = weakSelf;

            NSLayoutConstraint *constraint = [[strongSelf.textFieldView viewController] IQLayoutGuideConstraint];
            
            //If done LayoutGuide tweak
            if (constraint &&
                ((constraint.firstItem == [[strongSelf.textFieldView viewController] topLayoutGuide] || constraint.secondItem == [[strongSelf.textFieldView viewController] topLayoutGuide]) ||
                 (constraint.firstItem == [[strongSelf.textFieldView viewController] bottomLayoutGuide] || constraint.secondItem == [[strongSelf.textFieldView viewController] bottomLayoutGuide])))
            {
                constraint.constant = strongSelf.layoutGuideConstraintInitialConstant;
                [strongSelf.rootViewController.view setNeedsLayout];
                [strongSelf.rootViewController.view layoutIfNeeded];
            }
            else
            {
                [self showLog:[NSString stringWithFormat:@"Restoring %@ frame to : %@",[strongSelf.rootViewController _IQDescription],NSStringFromCGRect(strongSelf.topViewBeginRect)]];
                //  Setting it's new frame
                [strongSelf.rootViewController.view setFrame:strongSelf.topViewBeginRect];
                
                //Animating content if needed (Bug ID: #204)
                if (strongSelf.layoutIfNeededOnUpdate)
                {
                    //Animating content (Bug ID: #160)
                    [strongSelf.rootViewController.view setNeedsLayout];
                    [strongSelf.rootViewController.view layoutIfNeeded];
                }
            }

        } completion:NULL];
        _rootViewController = nil;
    }

    //Reset all values
    _lastScrollView = nil;
    _kbSize = CGSizeZero;
    _startingContentInsets = UIEdgeInsetsZero;
    _startingScrollIndicatorInsets = UIEdgeInsetsZero;
    _startingContentOffset = CGPointZero;
//    topViewBeginRect = CGRectZero;    //Commented due to #82

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

/*  UIKeyboardDidHideNotification. So topViewBeginRect can be set to CGRectZero. */
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    _topViewBeginRect = CGRectZero;

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

#pragma mark - UITextFieldView Delegate methods
/**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //  Getting object
    _textFieldView = notification.object;
    
    if (_overrideKeyboardAppearance == YES)
    {
        UITextField *textField = (UITextField*)_textFieldView;
        
        //If keyboard appearance is not like the provided appearance
        if (textField.keyboardAppearance != _keyboardAppearance)
        {
            //Setting textField keyboard appearance and reloading inputViews.
            textField.keyboardAppearance = _keyboardAppearance;
            [textField reloadInputViews];
        }
    }
    
	//If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
	if ([self privateIsEnableAutoToolbar])
    {
        [self showLog:@"adding UIToolbars if required"];

        //UITextView special case. Keyboard Notification is firing before textView notification so we need to reload it's inputViews.
        if ([_textFieldView isKindOfClass:[UITextView class]] && _textFieldView.inputAccessoryView == nil)
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
    
	if ([self privateIsEnabled] == NO)
    {
        [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
        return;
    }
    
    //Adding Geture recognizer to window    (Enhancement ID: #14)
    [_textFieldView.window addGestureRecognizer:_tapGesture];
    
    if (_isKeyboardShowing == NO)    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect and _layoutGuideConstraintInitialConstant.
        _layoutGuideConstraintInitialConstant = [[[_textFieldView viewController] IQLayoutGuideConstraint] constant];
        
        _rootViewController = [_textFieldView topMostController];
        if (_rootViewController == nil)  _rootViewController = [[self keyWindow] topMostController];
        
        _topViewBeginRect = _rootViewController.view.frame;

        if (_shouldFixInteractivePopGestureRecognizer && [_rootViewController isKindOfClass:[UINavigationController class]])
        {
            _topViewBeginRect.origin = CGPointMake(0, [self keyWindow].frame.size.height-_rootViewController.view.frame.size.height);
        }

        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning Frame: %@",[_rootViewController _IQDescription], NSStringFromCGRect(_topViewBeginRect)]];
    }
    
    //If _textFieldView is inside UIAlertView then do nothing. (Bug ID: #37, #74, #76)
    //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
    if (_textFieldView != nil  && [_textFieldView isAlertViewTextField] == NO)
    {
        //  keyboard is already showing. adjust frame.
        [self adjustFrame];
    }

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

/**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //Removing gesture recognizer   (Enhancement ID: #14)
    [_textFieldView.window removeGestureRecognizer:_tapGesture];
    
    // We check if there's a change in original frame or not.
    if(_isTextViewContentInsetChanged == YES && [_textFieldView isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView*)_textFieldView;

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

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

#pragma mark - UIInterfaceOrientation Change notification methods
/**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    //If textViewContentInsetChanged is changed then restore it.
    if (_isTextViewContentInsetChanged == YES && [_textFieldView isKindOfClass:[UITextView class]])
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

    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
}

#pragma mark - Status Bar Frame change Notifications

/**  UIApplicationDidChangeStatusBarFrameNotification. Need to refresh view position and update _topViewBeginRect. (Bug ID: #446)*/
- (void)didChangeStatusBarFrame:(NSNotification*)aNotification
{
    if ([self privateIsEnabled] == NO)	return;
    
    [self showLog:[NSString stringWithFormat:@"****** %@ started ******",NSStringFromSelector(_cmd)]];

    if (_rootViewController && !CGRectEqualToRect(_topViewBeginRect, _rootViewController.view.frame))
    {
        _topViewBeginRect = _rootViewController.view.frame;
        
        if (_shouldFixInteractivePopGestureRecognizer && [_rootViewController isKindOfClass:[UINavigationController class]])
        {
            _topViewBeginRect.origin = CGPointMake(0, [self keyWindow].frame.size.height-_rootViewController.view.frame.size.height);
        }
        
        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning Frame: %@",[_rootViewController _IQDescription] ,NSStringFromCGRect(_topViewBeginRect)]];
    }
    
    //If _textFieldView is inside UIAlertView then do nothing. (Bug ID: #37, #74, #76)
    //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is UIAlertView textField then do not affect anything (Bug ID: #70).
    if (_textFieldView != nil  && [_textFieldView isAlertViewTextField] == NO)
    {
        [self adjustFrame];
    }
    
    [self showLog:[NSString stringWithFormat:@"****** %@ ended ******",NSStringFromSelector(_cmd)]];
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
    return ([[touch view] isKindOfClass:[UIControl class]] || [[touch view] isKindOfClass:[UINavigationBar class]]) ? NO : YES;
}

/** Resigning textField. */
- (BOOL)resignFirstResponder
{
    if (_textFieldView)
    {
        //  Retaining textFieldView
        UIView *textFieldRetain = _textFieldView;
        
        //Resigning first responder
        BOOL isResignFirstResponder = [_textFieldView resignFirstResponder];
        
        //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
        if (isResignFirstResponder == NO)
        {
            //If it refuses to resign then becoming it first responder again for getting notifications callback.
            [textFieldRetain becomeFirstResponder];
            
            [self showLog:[NSString stringWithFormat:@"Refuses to Resign first responder: %@",[_textFieldView _IQDescription]]];
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
    if (index != NSNotFound && index > 0)
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
    if (index != NSNotFound && index < textFields.count-1)
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
    if (index != NSNotFound && index > 0)
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
    if (index != NSNotFound && index < textFields.count-1)
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

/**	Get all UITextField/UITextView siblings of textFieldView. */
-(NSArray*)responderViews
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
    for (Class consideredClass in _toolbarPreviousNextAllowedClasses)
    {
        superConsideredView = [_textFieldView superviewOfClassType:consideredClass];
        
        if (superConsideredView != nil)
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
        NSArray *textFields = [_textFieldView responderSiblings];
        
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
    //	Getting all the sibling textFields.
    NSArray *siblings = [self responderViews];
    
    //	If only one object is found, then adding only Done button.
    if (siblings.count==1 || self.shouldHidePreviousNext)
    {
        UITextField *textField = (UITextField*)_textFieldView;
        
        //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
        //setInputAccessoryView: check   (Bug ID: #307)
        if ([textField respondsToSelector:@selector(setInputAccessoryView:)])
        {
            if ((![textField inputAccessoryView] || ([[textField inputAccessoryView] tag] == kIQPreviousNextButtonToolbarTag)))
            {
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarDoneBarButtonItemImage)
                {
                    [textField addRightButtonOnKeyboardWithImage:_toolbarDoneBarButtonItemImage target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarDoneBarButtonItemText)
                {
                    [textField addRightButtonOnKeyboardWithText:_toolbarDoneBarButtonItemText target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                }
                else
                {
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    [textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                }
                textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            }
            else if ([[textField inputAccessoryView] isKindOfClass:[IQToolbar class]] && ([[textField inputAccessoryView] tag] == kIQDoneButtonToolbarTag))
            {
                IQToolbar *toolbar = (IQToolbar*)[textField inputAccessoryView];
                
                //Supporting Custom Done button image (Enhancement ID: #366)
                if (_toolbarDoneBarButtonItemImage)
                {
                    if ([toolbar.doneImage isEqual:_toolbarDoneBarButtonItemImage] == NO)
                    {
                        [textField addRightButtonOnKeyboardWithImage:_toolbarDoneBarButtonItemImage target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                }
                //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                else if (_toolbarDoneBarButtonItemText &&
                         [toolbar.doneTitle isEqualToString:_toolbarDoneBarButtonItemText] == NO)
                {
                    if ([toolbar.doneTitle isEqualToString:_toolbarDoneBarButtonItemText] == NO)
                    {
                        [textField addRightButtonOnKeyboardWithText:_toolbarDoneBarButtonItemText target:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                }
                else if ((_toolbarDoneBarButtonItemText == nil && toolbar.doneTitle) ||
                         (_toolbarDoneBarButtonItemImage == nil && toolbar.doneImage))
                {
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    [textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                }
                textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            }
        }
        
        if ([textField.inputAccessoryView isKindOfClass:[IQToolbar class]] && textField.inputAccessoryView.tag == kIQDoneButtonToolbarTag)
        {
            IQToolbar *toolbar = (IQToolbar*)[textField inputAccessoryView];
            
            //Bar style according to keyboard appearance
            if ([textField respondsToSelector:@selector(keyboardAppearance)])
            {
                switch ([(UITextField*)textField keyboardAppearance])
                {
                    case UIKeyboardAppearanceAlert:
                    {
                        toolbar.barStyle = UIBarStyleBlack;
                        [toolbar setTintColor:[UIColor whiteColor]];
                    }
                        break;
                    default:
                    {
                        toolbar.barStyle = UIBarStyleDefault;
                        
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
            }
            
            //If need to show placeholder
            if (_shouldShowTextFieldPlaceholder && textField.shouldHidePlaceholderText == NO)
            {
                //Updating placeholder     //(Bug ID: #148, #272)
                if (toolbar.title == nil || [toolbar.title isEqualToString:textField.drawingPlaceholderText] == NO)
                    [toolbar setTitle:textField.drawingPlaceholderText];
                
                //Setting toolbar title font.   //  (Enhancement ID: #30)
                if (_placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                    [toolbar setTitleFont:_placeholderFont];
            }
            else
            {
                //Updating placeholder     //(Bug ID: #272)
                [toolbar setTitle:nil];
            }
        }
    }
    else if(siblings.count)
    {
        //	If more than 1 textField is found. then adding previous/next/done buttons on it.
        for (UITextField *textField in siblings)
        {
            //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
            //setInputAccessoryView: check   (Bug ID: #307)
            if ([textField respondsToSelector:@selector(setInputAccessoryView:)])
            {
                if ((![textField inputAccessoryView] || [[textField inputAccessoryView] tag] == kIQDoneButtonToolbarTag))
                {
                    //Supporting Custom Done button image (Enhancement ID: #366)
                    if (_toolbarDoneBarButtonItemImage)
                    {
                        [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonImage:_toolbarDoneBarButtonItemImage previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                    //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                    else if (_toolbarDoneBarButtonItemText)
                    {
                        [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonTitle:_toolbarDoneBarButtonItemText previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                    else
                    {
                        //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                    textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
                }
                else if ([[textField inputAccessoryView] isKindOfClass:[IQToolbar class]]  && ([[textField inputAccessoryView] tag] == kIQPreviousNextButtonToolbarTag))
                {
                    IQToolbar *toolbar = (IQToolbar*)[textField inputAccessoryView];
                
                    //Supporting Custom Done button image (Enhancement ID: #366)
                    if (_toolbarDoneBarButtonItemImage)
                    {
                        if ([toolbar.doneImage isEqual:_toolbarDoneBarButtonItemImage] == NO)
                        {
                            [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonImage:_toolbarDoneBarButtonItemImage previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                        }
                    }
                    //Supporting Custom Done button text (Enhancement ID: #209, #411, Bug ID: #376)
                    else if (_toolbarDoneBarButtonItemText)
                    {
                        if ([toolbar.doneTitle isEqualToString:_toolbarDoneBarButtonItemText] == NO)
                        {
                            [textField addPreviousNextRightOnKeyboardWithTarget:self rightButtonTitle:_toolbarDoneBarButtonItemText previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) rightButtonAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                        }
                    }
                    else if ((_toolbarDoneBarButtonItemText == nil && toolbar.doneTitle) ||
                             (_toolbarDoneBarButtonItemImage == nil && toolbar.doneImage))
                    {
                        //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                        [textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                    }
                    textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
                }
            }
            
            if ([textField.inputAccessoryView isKindOfClass:[IQToolbar class]] && textField.inputAccessoryView.tag == kIQPreviousNextButtonToolbarTag)
            {
                IQToolbar *toolbar = (IQToolbar*)[textField inputAccessoryView];
                
                //Bar style according to keyboard appearance
                if ([textField respondsToSelector:@selector(keyboardAppearance)])
                {
                    switch ([(UITextField*)textField keyboardAppearance])
                    {
                        case UIKeyboardAppearanceAlert:
                        {
                            toolbar.barStyle = UIBarStyleBlack;
                            [toolbar setTintColor:[UIColor whiteColor]];
                        }
                            break;
                        default:
                        {
                            toolbar.barStyle = UIBarStyleDefault;
                            
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
                }
                
                //If need to show placeholder
                if (_shouldShowTextFieldPlaceholder && textField.shouldHidePlaceholderText == NO)
                {
                    //Updating placeholder     //(Bug ID: #148, #272)
                    if (toolbar.title == nil || [toolbar.title isEqualToString:textField.drawingPlaceholderText] == NO)
                            [toolbar setTitle:textField.drawingPlaceholderText];
                    
                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if (_placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                        [toolbar setTitleFont:_placeholderFont];
                }
                else
                {
                    //Updating placeholder     //(Bug ID: #272)
                    [toolbar setTitle:nil];
                }

                //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                //	If firstTextField, then previous should not be enabled.
                if (siblings[0] == textField)
                {
                    [textField setEnablePrevious:NO next:YES];
                }
                //	If lastTextField then next should not be enaled.
                else if ([siblings lastObject] == textField)
                {
                    [textField setEnablePrevious:YES next:NO];
                }
                else
                {
                    [textField setEnablePrevious:YES next:YES];
                }
            }
        }
    }
}

/** Remove any toolbar if it is IQToolbar. */
-(void)removeToolbarIfRequired  //  (Bug ID: #18)
{
    //	Getting all the sibling textFields.
    NSArray *siblings = [self responderViews];
    
    for (UITextField *textField in siblings)
    {
        UIView *toolbar = [textField inputAccessoryView];
        
        //  (Bug ID: #78)
        //setInputAccessoryView: check   (Bug ID: #307)
        if ([textField respondsToSelector:@selector(setInputAccessoryView:)] && ([toolbar isKindOfClass:[IQToolbar class]] && (toolbar.tag == kIQDoneButtonToolbarTag || toolbar.tag == kIQPreviousNextButtonToolbarTag)))
        {
            textField.inputAccessoryView = nil;
        }
    }
}

/**	reloadInputViews to reload toolbar buttons enable/disable state on the fly Enhancement ID #434. */
- (void)reloadInputViews
{
    //	Getting all the sibling textFields.
    NSArray *siblings = [self responderViews];
    
    for (UITextField *textField in siblings)
    {
        //	If firstTextField, then previous should not be enabled.
        if (siblings[0] == textField)
        {
            if (siblings.count == 1)
            {
                [textField setEnablePrevious:NO next:NO];
            }
            else
            {
                [textField setEnablePrevious:NO next:YES];
            }
        }
        //	If lastTextField then next should not be enaled.
        else if ([siblings lastObject] == textField)
        {
            [textField setEnablePrevious:YES next:NO];
        }
        else
        {
            [textField setEnablePrevious:YES next:YES];
        }
    }
}

#pragma mark previous/next/done functionality
/**	previousAction. */
-(void)previousAction:(id)segmentedControl
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    if ([self canGoPrevious])
    {
        UIView *textFieldRetain = _textFieldView;

        BOOL isAcceptAsFirstResponder = [self goPrevious];
        
        if (isAcceptAsFirstResponder == YES && textFieldRetain.previousInvocation)
        {
            [textFieldRetain.previousInvocation invoke];
        }
    }
}

/**	nextAction. */
-(void)nextAction:(id)segmentedControl
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    if ([self canGoNext])
    {
        UIView *textFieldRetain = _textFieldView;

        BOOL isAcceptAsFirstResponder = [self goNext];
        
        if (isAcceptAsFirstResponder == YES && textFieldRetain.nextInvocation)
        {
            [textFieldRetain.nextInvocation invoke];
        }
    }
}

/**	doneAction. Resigning current textField. */
-(void)doneAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound. Then Play Input Click Sound.
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    UIView *textFieldRetain = _textFieldView;

    BOOL isResignedFirstResponder = [self resignFirstResponder];
    
    if (isResignedFirstResponder == YES && textFieldRetain.doneInvocation)
    {
        [textFieldRetain.doneInvocation invoke];
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

-(void)showLog:(NSString*)logString
{
    if (_enableDebugging)
    {
        NSLog(@"IQKeyboardManager: %@",logString);
    }
}

@end


@implementation IQKeyboardManager(IQKeyboardManagerDeprecated)

@end
