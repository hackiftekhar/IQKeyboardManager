//
// KeyboardManager.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UITableView.h>

NSInteger const kIQDoneButtonToolbarTag             =   -1002;
NSInteger const kIQPreviousNextButtonToolbarTag     =   -1005;

@interface IQKeyboardManager (RemoveCompilerWarning)

//Remove compiler warning
-(void)previousAction:(id)segmentedControl;
-(void)nextAction:(id)segmentedControl;
-(void)doneAction:(IQBarButtonItem*)barButton;

@end

@interface IQKeyboardManager()<UIGestureRecognizerDelegate>


/*!
    @property   keyWindow
 
    @abstract   Save keyWindow object for reuse.
 
    @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.
 */
@property(nonatomic, strong, readonly) UIWindow *keyWindow;

//  Private helper methods
- (void)adjustFrame;
- (void)addToolbarIfRequired;
- (void)removeToolbarIfRequired;

//  Private function to manipulate RootViewController's frame with animation.
- (void)setRootViewFrame:(CGRect)frame;

//  Notification methods
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)textFieldViewDidBeginEditing:(NSNotification*)notification;
- (void)textFieldViewDidEndEditing:(NSNotification*)notification;
- (void)textFieldViewDidChange:(NSNotification*)notification;

- (void)tapRecognized:(UITapGestureRecognizer*)gesture;

@end

@implementation IQKeyboardManager
{
	@package
	/*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    BOOL isKeyboardShowing;
    
	/*! To save rootViewController.view.frame. */
    CGRect topViewBeginRect;
    
	/*! To save keyboard animation duration. */
    CGFloat animationDuration;
    
	/*! To mimic the keyboard animation */
    NSInteger animationCurve;
    
	/*! To save UITextField/UITextView object voa textField/textView notifications. */
    __weak UIView *_textFieldView;
    
    /*! To save keyboard size. */
    CGSize kbSize;
	
    /*! To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
	NSNotification *kbShowNotification;
    
    /*! Variable to save lastScrollView that was scrolled. */
    __weak UIScrollView *lastScrollView;
    
    /*! LastScrollView's initial contentOffset. */
    CGPoint startingContentOffset;
    
    /*! TapGesture to resign keyboard on view's touch. */
    UITapGestureRecognizer *tapGesture;
    
    /*! used with canAdjustTextView boolean. */
    __block CGRect textFieldViewIntialFrame;
    
    /*! used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
    __block BOOL _isTextFieldViewFrameChanged;
}

//KeyWindow
@synthesize keyWindow                           = _keyWindow;

//UIKeyboard handling
@synthesize enable                              =   _enable;
@synthesize keyboardDistanceFromTextField       =   _keyboardDistanceFromTextField;
@synthesize overrideKeyboardAppearance          =   _overrideKeyboardAppearance;
@synthesize keyboardAppearance                  =   _keyboardAppearance;

//IQToolbar handling
@synthesize enableAutoToolbar                   =   _enableAutoToolbar;
@synthesize toolbarManageBehaviour              =   _toolbarManageBehaviour;
@synthesize shouldToolbarUsesTextFieldTintColor =   _shouldToolbarUsesTextFieldTintColor;
@synthesize shouldShowTextFieldPlaceholder      =   _shouldShowTextFieldPlaceholder;
@synthesize placeholderFont                     =   _placeholderFont;

//TextView handling
@synthesize canAdjustTextView                   =   _canAdjustTextView;

//Resign handling
@synthesize shouldResignOnTouchOutside          =   _shouldResignOnTouchOutside;

//Sound handling
@synthesize shouldPlayInputClicks               =   _shouldPlayInputClicks;

//Animation handling
@synthesize shouldAdoptDefaultKeyboardAnimation =   _shouldAdoptDefaultKeyboardAnimation;


#pragma mark - Initializing functions

/*! Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. */
+(void)load
{
    [super load];
    
    //Enabling Keyboard Manager.
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

/*  Singleton Object Initialization. */
-(instancetype)init
{
	if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
			//  Registering for keyboard notification.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

			//  Registering for textField notification.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
			
			//  Registering for textView notification.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
			
            //  Registering for orientation changes notification
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
            
            //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [tapGesture setDelegate:self];
            
            //  Default settings
			[self setKeyboardDistanceFromTextField:10.0];
            animationDuration = 0.25;
            
            //Setting it's initial values
            _enable = NO;
            [self setCanAdjustTextView:NO];
            [self setShouldPlayInputClicks:NO];
            [self setShouldResignOnTouchOutside:NO];
            [self setShouldToolbarUsesTextFieldTintColor:NO];
            [self setOverrideKeyboardAppearance:NO];
            [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
            
            [self setEnableAutoToolbar:YES];
            [self setShouldShowTextFieldPlaceholder:YES];
            [self setShouldAdoptDefaultKeyboardAnimation:YES];
            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            
            _keyWindow = [self keyWindow];
        });
    }
    return self;
}

/*  Automatically called from the `+(void)load` method. */
+ (instancetype)sharedManager
{
	//Singleton instance
	static IQKeyboardManager *kbManager;
	
	//Dispatching it once.
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
		//  Initializing keyboard manger.
        kbManager = [[self alloc] init];
    });
	
	//Returning kbManager.
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
		if (kbShowNotification)	[self keyboardWillShow:kbShowNotification];

#if IQKEYBOARDMANAGER_DEBUG
        NSLog(@"%@",IQLocalizedString(@"IQKeyboardManager enabled", nil));
#endif
    }
	//If not disable, desable it.
    else if (enable == NO && _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original frame.
		[self keyboardWillHide:nil];
        
		//Setting NO to _enable.
		_enable = enable;
		
#if IQKEYBOARDMANAGER_DEBUG
        NSLog(@"%@",IQLocalizedString(@"IQKeyboardManager disabled", nil));
#endif
    }
	//If already disabled.
	else if (enable == NO && _enable == NO)
	{
#if IQKEYBOARDMANAGER_DEBUG
        NSLog(@"%@",IQLocalizedString(@"IQKeyboardManager already disabled", nil));
#endif
	}
	//If already enabled.
	else if (enable == YES && _enable == YES)
	{
#if IQKEYBOARDMANAGER_DEBUG
        NSLog(@"%@",IQLocalizedString(@"IQKeyboardManager already enabled", nil));
#endif
	}
}

//Is enabled
-(BOOL)isEnabled
{
	return _enable;
}

//	Setting keyboard distance from text field.
-(void)setKeyboardDistanceFromTextField:(CGFloat)keyboardDistanceFromTextField
{
    //Can't be less than zero. Minimum is zero.
	_keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);
}

/*! Getting keyWindow. */
-(UIWindow *)keyWindow
{
    /*  (Bug ID: #23, #25, #73)   */
    UIWindow *_originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
    if (_originalKeyWindow != nil && _keyWindow != _originalKeyWindow)  _keyWindow = _originalKeyWindow;
    
    //Return KeyWindow
    return _keyWindow;
}

#pragma mark - Private Methods
/*  Helper function to manipulate RootViewController's frame with animation. */
-(void)setRootViewFrame:(CGRect)frame
{
    //  Getting topMost ViewController.
    UIViewController *controller = [[self keyWindow] topMostController];
    
    //frame size needs to be adjusted on iOS8 due to orientation structure changes.
    if (IQ_IS_IOS8_OR_GREATER)
    {
        frame.size = controller.view.size;
    }

    //  If can't get rootViewController then printing warning to user.
    if (controller == nil)  NSLog(@"%@",IQLocalizedString(@"You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager", nil));
    
    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        //  Setting it's new frame
        [controller.view setFrame:frame];
    } completion:NULL];
}

/* Adjusting RootViewController's frame according to device orientation. */
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
    if (_textFieldView == nil)   return;
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *window = [self keyWindow];
    
    //  Getting RootViewController.  (Bug ID: #1, #4)
    UIViewController *rootController = [[self keyWindow] topMostController];
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
    UIInterfaceOrientation interfaceOrientation = IQ_IS_IOS8_OR_GREATER ? UIInterfaceOrientationPortrait : [rootController interfaceOrientation];
#pragma GCC diagnostic pop

    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:window];
    //  Getting RootViewRect.
    CGRect rootViewRect = [[rootController view] frame];
    //Getting statusBarFrame
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    CGFloat move = 0;
    //  Move positive = textField is hidden.
    //  Move negative = textField is showing.
	
    //  Calculating move position. Common for both normal and special cases.
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            move = MIN(CGRectGetMinX(textFieldViewRect)-(CGRectGetWidth(statusBarFrame)+5), CGRectGetMaxX(textFieldViewRect)-(window.width-kbSize.width));
            break;
        case UIInterfaceOrientationLandscapeRight:
            move = MIN(window.width-CGRectGetMaxX(textFieldViewRect)-(CGRectGetWidth(statusBarFrame)+5), kbSize.width-CGRectGetMinX(textFieldViewRect));
            break;
        case UIInterfaceOrientationPortrait:
            move = MIN(CGRectGetMinY(textFieldViewRect)-(CGRectGetHeight(statusBarFrame)+5), CGRectGetMaxY(textFieldViewRect)-(window.height-kbSize.height));
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            move = MIN(window.height-CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(statusBarFrame)+5), kbSize.height-CGRectGetMinY(textFieldViewRect));
            break;
        default:
            break;
    }
	
    //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
    UIScrollView *superScrollView = [_textFieldView superScrollView];
    
    //If there was a lastScrollView.    //  (Bug ID: #34)
    if (lastScrollView)
    {
        //If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if (superScrollView == nil)
        {
            [lastScrollView setContentOffset:startingContentOffset animated:YES];
            lastScrollView = nil;
            startingContentOffset = CGPointZero;
        }
        //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
        else if (superScrollView != lastScrollView)
        {
            [lastScrollView setContentOffset:startingContentOffset animated:YES];
            lastScrollView = superScrollView;
            startingContentOffset = superScrollView.contentOffset;
        }
        //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        lastScrollView = superScrollView;
        startingContentOffset = superScrollView.contentOffset;
    }
    
    //  Special case for ScrollView.
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (lastScrollView)
        {
            //Saving
            UIView *lastView = _textFieldView;
            UIScrollView *superScrollView = lastScrollView;
            
            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView)
            {
                //Getting lastViewRect.
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y/*-5*/);   //-5 is for good UI.//Commenting -5 (Bug ID: #69)
                
                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                move -= (shouldOffsetY-superScrollView.contentOffset.y);
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);
                } completion:NULL];

                //  Getting next lastView & superScrollView.
                lastView = superScrollView;
                superScrollView = [lastView superScrollView];
            }
        }
        //Going ahead. No else if.
    }
    
    //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen).
    //If we have permission to adjust the textView, then let's do it on behalf of user.  (Enhancement ID: #15)
    //Added _isTextFieldViewFrameChanged. (Bug ID: #92)
    if (_canAdjustTextView && [_textFieldView isKindOfClass:[UITextView class]] && _isTextFieldViewFrameChanged == NO)
    {
        CGFloat textViewHeight = _textFieldView.height;
        
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                textViewHeight = MIN(textViewHeight, (window.width-kbSize.width-(CGRectGetWidth(statusBarFrame)+5)));
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                textViewHeight = MIN(textViewHeight, (window.height-kbSize.height-(CGRectGetHeight(statusBarFrame)+5)));
                break;
            default:
                break;
        }
        
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _textFieldView.height = textViewHeight;
            _isTextFieldViewFrameChanged = YES;
        } completion:NULL];
    }
    
    //  Special case for iPad modalPresentationStyle.
    if ([[[self keyWindow] topMostController] modalPresentationStyle] == UIModalPresentationFormSheet ||
        [[[self keyWindow] topMostController] modalPresentationStyle] == UIModalPresentationPageSheet)
    {
        //  Positive or zero.
        if (move>=0)
        {
            // We should only manipulate y.
            rootViewRect.origin.y -= move;
            [self setRootViewFrame:rootViewRect];
        }
        //  Negative
        else
        {
            //  Calculating disturbed distance. Pull Request #3
            CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(topViewBeginRect);
			
            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if(disturbDistance<0)
            {
                // We should only manipulate y.
                rootViewRect.origin.y -= MAX(move, disturbDistance);
                [self setRootViewFrame:rootViewRect];
            }
        }
    }
    //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
    else
    {
        //  Positive or zero.
        if (move>=0)
        {
            switch (interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= move;  break;
                case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += move;  break;
                case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= move;  break;
                case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += move;  break;
                default:    break;
            }
			
            //  Setting adjusted rootViewRect
            [self setRootViewFrame:rootViewRect];
        }
        //  Negative
        else
        {
            CGFloat disturbDistance = 0;
            
            switch (interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                    disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(topViewBeginRect);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    disturbDistance = CGRectGetMinX(topViewBeginRect)-CGRectGetMinX(rootViewRect);
                    break;
                case UIInterfaceOrientationPortrait:
                    disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(topViewBeginRect);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    disturbDistance = CGRectGetMinY(topViewBeginRect)-CGRectGetMinY(rootViewRect);
                    break;
                default:
                    break;
            }

            //  disturbDistance Negative = frame disturbed. Pull Request #3
            //  disturbDistance positive = frame not disturbed.
            if(disturbDistance<0)
            {
                switch (interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += MAX(move, disturbDistance);  break;
                    default:    break;
                }
                
                //  Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
        }
    }
}

#pragma mark - UIKeyboad Notification methods
/*  UIKeyboardWillShowNotification. */
-(void)keyboardWillShow:(NSNotification*)aNotification
{
	kbShowNotification = aNotification;
	
	if (_enable == NO)	return;
	
    //Due to orientation callback we need to resave it's original frame.    //  (Bug ID: #46)
    //Added _isTextFieldViewFrameChanged check. Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed. (Bug ID: #92)
    if (_isTextFieldViewFrameChanged == NO)
    {
        textFieldViewIntialFrame = _textFieldView.frame;
    }
    
    if (_shouldAdoptDefaultKeyboardAnimation)
    {
        //  Getting keyboard animation.
        animationCurve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
        animationCurve = animationCurve<<16;
    }
    else
    {
        animationCurve = 0;
    }

    //  Getting keyboard animation duration
    CGFloat duration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    animationDuration = duration;
    
    CGSize oldKBSize = kbSize;
    
    //  Getting UIKeyboardSize.
    kbSize = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
    UIInterfaceOrientation interfaceOrientation = IQ_IS_IOS8_OR_GREATER ? UIInterfaceOrientationPortrait : [[[self keyWindow] topMostController] interfaceOrientation];
#pragma GCC diagnostic pop
    
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            kbSize.width += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationLandscapeRight:
            kbSize.width += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortrait:
            kbSize.height += _keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            kbSize.height += _keyboardDistanceFromTextField;
            break;
        default:
            break;
    }
    
    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGSizeEqualToSize(kbSize, oldKBSize))
    {
        //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if (_textFieldView != nil && [[_textFieldView viewController] isKindOfClass:[UITableViewController class]] == NO && [_textFieldView isAlertViewTextField] == NO)
        {
            [self adjustFrame];
        }
    }
}

/*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //If it's not a fake notification generated by [self setEnable:NO].
    if (aNotification != nil)	kbShowNotification = nil;
    
    //If not enabled then do nothing.
    if (_enable == NO)	return;
    
    //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        //  Setitng keyboard animation duration
        animationDuration = aDuration;
    }
    
    //Restoring the contentOffset of the lastScrollView
    if (lastScrollView)
    {
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            lastScrollView.contentOffset = startingContentOffset;
            
            // TODO: This is temporary solution. Have to implement the save and restore scrollView state
            UIScrollView *superscrollView = lastScrollView;
            while ((superscrollView = [superscrollView superScrollView]))
            {
                CGSize contentSize = CGSizeMake(MAX(superscrollView.contentSize.width, superscrollView.width), MAX(superscrollView.contentSize.height, superscrollView.height));
                
                CGFloat minimumY = contentSize.height-superscrollView.height;
                
                if (minimumY<superscrollView.contentOffset.y)
                {
                    superscrollView.contentOffset = CGPointMake(superscrollView.contentOffset.x, minimumY);
                }
            }
        } completion:NULL];
    }
    
    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (!CGRectEqualToRect(topViewBeginRect, CGRectZero))
    {
        [self setRootViewFrame:topViewBeginRect];
    }

    //Reset all values
    lastScrollView = nil;
    kbSize = CGSizeZero;
    startingContentOffset = CGPointZero;
//    topViewBeginRect = CGRectZero;    //Committed due to #82
}

#pragma mark - UITextFieldView Delegate methods
/*!  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    //  Getting object
    _textFieldView = notification.object;
    
    if (_overrideKeyboardAppearance == YES) [(UITextField*)_textFieldView setKeyboardAppearance:_keyboardAppearance];
    
    // Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed.
    //Added _isTextFieldViewFrameChanged check. (Bug ID: #92)
    if (_isTextFieldViewFrameChanged == NO)
    {
        textFieldViewIntialFrame = _textFieldView.frame;
    }
    
	//If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
	if (_enableAutoToolbar)
    {
        //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
        if ([_textFieldView isKindOfClass:[UITextView class]] && _textFieldView.inputAccessoryView == nil)
        {
            UIView *view = _textFieldView;
            
            [UIView animateWithDuration:0.00001 delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self addToolbarIfRequired];
            } completion:^(BOOL finished) {
                [view resignFirstResponder];
                [view becomeFirstResponder];
            }];
        }
        else
        {
            [self addToolbarIfRequired];
        }
    }
    
	if (_enable == NO)	return;
	
    [_textFieldView.window addGestureRecognizer:tapGesture];    //   (Enhancement ID: #14)
    
    if (isKeyboardShowing == NO)    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [[self keyWindow] topMostController];
        topViewBeginRect = rootController.view.frame;
    }
    
    //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37, #74, #76)
    //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
    if (_textFieldView != nil && [[_textFieldView viewController] isKindOfClass:[UITableViewController class]] == NO && [_textFieldView isAlertViewTextField] == NO)
    {
        //  keyboard is already showing. adjust frame.
        [self adjustFrame];
    }
}

/*!  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    [_textFieldView.window removeGestureRecognizer:tapGesture]; // (Enhancement ID: #14)
    
    // We check if there's a change in original frame or not.
    if(_isTextFieldViewFrameChanged == YES)
    {
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _isTextFieldViewFrameChanged = NO;

            _textFieldView.frame = textFieldViewIntialFrame;
        } completion:NULL];
    }
    
    //Setting object to nil
    _textFieldView = nil;
}

/* UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
-(void)textFieldViewDidChange:(NSNotification*)notification //  (Bug ID: #18)
{
    UITextView *textView = (UITextView *)notification.object;
    
    CGRect line = [textView caretRectForPosition: textView.selectedTextRange.start];
    CGFloat overflow = CGRectGetMaxY(line) - (textView.contentOffset.y + CGRectGetHeight(textView.bounds) - textView.contentInset.bottom - textView.contentInset.top);
    
    if ( overflow > 0 )
    {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            [textView setContentOffset:offset];
        } completion:NULL];
    }
}

#pragma mark - UIInterfaceOrientation Change notification methods
/*!  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
    if (_isTextFieldViewFrameChanged == YES)
    {
        //Due to orientation callback we need to set it's original position.
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            _textFieldView.frame = textFieldViewIntialFrame;
            _isTextFieldViewFrameChanged = NO;
        } completion:NULL];
    }
}

#pragma mark AutoResign methods
/*! Enabling/disable gesture on touching. */
-(void)setShouldResignOnTouchOutside:(BOOL)shouldResignOnTouchOutside
{
    _shouldResignOnTouchOutside = shouldResignOnTouchOutside;
    [tapGesture setEnabled:_shouldResignOnTouchOutside];    // (Enhancement ID: #14)
}

/*! Resigning on tap gesture. */
- (void)tapRecognized:(UITapGestureRecognizer*)gesture  // (Enhancement ID: #14)
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [gesture.view endEditing:YES];
    }
}

/*! Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

/*! Resigning textField. */
- (void)resignFirstResponder
{
	[_textFieldView resignFirstResponder];
}

#pragma mark AutoToolbar methods

/*! return YES. If autoToolbar is enabled. */
-(BOOL)isEnableAutoToolbar
{
	return _enableAutoToolbar;
}

/*! Enable/disable autotoolbar. Adding and removing toolbar if required. */
-(void)setEnableAutoToolbar:(BOOL)enableAutoToolbar
{
    _enableAutoToolbar = enableAutoToolbar;
    
    if (_enableAutoToolbar == YES)
    {
        [self addToolbarIfRequired];
    }
    else
    {
        [self removeToolbarIfRequired];
    }
}

/*!	Get all UITextField/UITextView siblings of textFieldView. */
-(NSArray*)responderViews
{
    UITableView *tableView = [_textFieldView superTableView];
    
    NSArray *textFields;
    
    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds.
    if (tableView)  //     //   (Enhancement ID: #22)
    {
        textFields = [tableView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [_textFieldView responderSiblings];
    }

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
    }
}

#pragma mark previous/next/done functionality
/*!	previousAction. */
-(void)previousAction:(id)segmentedControl
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not first textField. then it's previous object becomeFirstResponder.
        if (index > 0)	[textFields[index-1] becomeFirstResponder];
    }
}

/*!	nextAction. */
-(void)nextAction:(id)segmentedControl
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not last textField. then it's next object becomeFirstResponder.
        if (index < textFields.count-1)	[textFields[index+1] becomeFirstResponder];
    }
}

/*!	doneAction. Resigning current textField. */
-(void)doneAction:(IQBarButtonItem*)barButton
{
    //If user wants to play input Click sound.
    if (_shouldPlayInputClicks)
    {
        //Play Input Click Sound.
        [[UIDevice currentDevice] playInputClick];
    }

    //Resign textFieldView.
    [self resignFirstResponder];
}

/*! Add toolbar if it is required to add on textFields and it's siblings. */
-(void)addToolbarIfRequired
{
	//	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
	
	//	If only one object is found, then adding only Done button.
	if (siblings.count==1)
	{
        UIView *textField = [siblings firstObject];
        
        //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
		if (![textField inputAccessoryView] || ([[textField inputAccessoryView] tag] == kIQPreviousNextButtonToolbarTag))
		{
            //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
			[textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
            textField.inputAccessoryView.tag = kIQDoneButtonToolbarTag; //  (Bug ID: #78)
            
            //Setting toolbar tintColor //  (Enhancement ID: #30)
            if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                [textField.inputAccessoryView setTintColor:[textField tintColor]];
            
            //Setting toolbar title font.   //  (Enhancement ID: #30)
            if (_shouldShowTextFieldPlaceholder && _placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                [(IQToolbar*)[textField inputAccessoryView] setTitleFont:_placeholderFont];
        }
	}
	else if(siblings.count)
	{
		//	If more than 1 textField is found. then adding previous/next/done buttons on it.
		for (UITextField *textField in siblings)
		{
            //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
			if (![textField inputAccessoryView] || [[textField inputAccessoryView] tag] == kIQDoneButtonToolbarTag)
			{
                //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
				[textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];
                textField.inputAccessoryView.tag = kIQPreviousNextButtonToolbarTag; //  (Bug ID: #78)
                
                //Setting toolbar tintColor //  (Enhancement ID: #30)
                if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                    [textField.inputAccessoryView setTintColor:[textField tintColor]];
                
                //Setting toolbar title font.   //  (Enhancement ID: #30)
                if (_shouldShowTextFieldPlaceholder && _placeholderFont && [_placeholderFont isKindOfClass:[UIFont class]])
                    [(IQToolbar*)[textField inputAccessoryView] setTitleFont:_placeholderFont];
  			}
            
            //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
            if (textField.inputAccessoryView.tag == kIQPreviousNextButtonToolbarTag)
            {
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

/*! Remove any toolbar if it is IQToolbar. */
-(void)removeToolbarIfRequired  //  (Bug ID: #18)
{
    //	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
    
    for (UITextField *textField in siblings)
    {
        UIView *toolbar = [textField inputAccessoryView];

        //  (Bug ID: #78)
        if ([toolbar isKindOfClass:[IQToolbar class]] && (toolbar.tag == kIQDoneButtonToolbarTag || toolbar.tag == kIQPreviousNextButtonToolbarTag))
        {
            [textField setInputAccessoryView:nil];
        }
    }
}

@end
