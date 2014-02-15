//
// KeyboardManager.h
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

/*
 
 /---------------------------------------------------------------------------------------------------\
 \---------------------------------------------------------------------------------------------------/
 |                                   iOS NSNotification Mechanism                                    |
 /---------------------------------------------------------------------------------------------------\
 \---------------------------------------------------------------------------------------------------/
 
 1) Begin Editing:-         When TextField begin editing.
 2) End Editing:-           When TextField end editing.
 3) Switch TextField:-      When Keyboard Switch from a TextField to another TextField.
 3) Orientation Change:-    When Device Orientation Change.
 
 
 ----------------------------------------------------------------------------------------------------------------------------------------------
 =============
 UITextField
 =============
 
 Begin Editing                                Begin Editing
 --------------------------------------------           ----------------------------------           ---------------------------------
 |UITextFieldTextDidBeginEditingNotification| --------> | UIKeyboardWillShowNotification | --------> | UIKeyboardDidShowNotification |
 --------------------------------------------           ----------------------------------           ---------------------------------
 ^                  Switch TextField             ^               Switch TextField
 |                                               |
 |                                               |
 | Switch TextField                              | Orientation Change
 |                                               |
 |                                               |
 |                                               |
 --------------------------------------------           ----------------------------------           ---------------------------------
 | UITextFieldTextDidEndEditingNotification | <-------- | UIKeyboardWillHideNotification | --------> | UIKeyboardDidHideNotification |
 --------------------------------------------           ----------------------------------           ---------------------------------
 |                    End Editing                                                             ^
 |                                                                                            |
 |--------------------End Editing-------------------------------------------------------------|
 
 
 ----------------------------------------------------------------------------------------------------------------------------------------------
 =============
 UITextView
 =============
 |-------------------Switch TextView--------------------------------------------------------------|
 | |------------------Begin Editing-------------------------------------------------------------| |
 | |                                                                                            | |
 v |                  Begin Editing                               Switch TextView               v |
 --------------------------------------------           ----------------------------------           ---------------------------------
 | UITextViewTextDidBeginEditingNotification| <-------- | UIKeyboardWillShowNotification | --------> | UIKeyboardDidShowNotification |
 --------------------------------------------           ----------------------------------           ---------------------------------
 ^
 |
 |------------------------Switch TextView--------|
 |                                               | Orientation Change
 |                                               |
 |                                               |
 |                                               |
 --------------------------------------------           ----------------------------------           ---------------------------------
 | UITextViewTextDidEndEditingNotification  | <-------- | UIKeyboardWillHideNotification |           | UIKeyboardDidHideNotification |
 --------------------------------------------           ----------------------------------           ---------------------------------
 |                    End Editing                                                             ^
 |                                                                                            |
 |--------------------End Editing-------------------------------------------------------------|
 
 
 ----------------------------------------------------------------------------------------------------------------------------------------------
 
 /---------------------------------------------------------------------------------------------------\
 \---------------------------------------------------------------------------------------------------/
 */

/* Set IQKEYBOARDMANAGER_DEBUG=1 in preprocessor macros under build settings to enable debugging.*/
#if !IQKEYBOARDMANAGER_DEBUG
#define NSLog(...)
#endif

#import "IQKeyboardManager.h"

@interface IQKeyboardManager()<UIGestureRecognizerDelegate>

/*! save rootViewControlle for reuse. */
@property(nonatomic, strong, readonly) UIViewController *rootViewController;
@property(nonatomic, strong, readonly) UIWindow *keyWindow;

//  Private helper methods
- (void)adjustFrame;
- (void)addToolbarIfRequired;
- (void)removeToolbarIfRequired;

- (void)previousAction:(UISegmentedControl*)segmentedControl;
- (void)nextAction:(UISegmentedControl*)segmentedControl;
- (void)doneAction:(UIBarButtonItem*)barButton;

//  Private function to manipulate RootViewController's frame with animation.
- (void)setRootViewFrame:(CGRect)frame;

//  Notification methods
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)textFieldViewDidBeginEditing:(NSNotification*)notification;
- (void)textFieldViewDidEndEditing:(NSNotification*)notification;
- (void)textFieldViewDidChange:(NSNotification*)notification;

- (void)tapRecognized:(UITapGestureRecognizer*)gesture;

//To remove compiler warning
- (void)barTintColor;

@end

@implementation IQKeyboardManager
{
	@package
	/*! Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
    BOOL isKeyboardShowing;
    
	/*! To save rootViewController.view.frame. */
    CGRect topViewBeginRect;
    
	/*! TextField or TextView object. */
    UIView *textFieldView;
    
	/*! To save keyboard animation duration. */
    CGFloat animationDuration;
    
    /*! To save keyboard size */
    CGSize kbSize;
	
    /*! To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
	NSNotification *kbShowNotification;
    
    /*! Variable to save lastScrollView that was scrolled. */
    UIScrollView *lastScrollView;
    
    /*! LastScrollView's initial contentOffset. */
    CGPoint startingContentOffset;
    
    /*! TapGesture to resign keyboard on view's touch*/
    UITapGestureRecognizer *tapGesture;
    
    /*! used with canAdjustTextView boolean*/
    CGRect textFieldViewIntialFrame;
}

//Remove compiler warning
- (void)barTintColor
{
    
}


@synthesize enable                          = _enable;
@synthesize enableAutoToolbar               = _enableAutoToolbar;
@synthesize keyboardDistanceFromTextField   = _keyboardDistanceFromTextField;
@synthesize toolbarManageBehaviour          = _toolbarManageBehaviour;
@synthesize shouldResignOnTouchOutside      = _shouldResignOnTouchOutside;
@synthesize canAdjustTextView               = _canAdjustTextView;
@synthesize rootViewController              = _rootViewController;
@synthesize keyWindow                       = _keyWindow;


#pragma mark - Initializing functions

//  Singleton Object Initialization.
-(id)initUniqueInstance
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
			
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [tapGesture setDelegate:self];
            
            //  Default settings
			[self setKeyboardDistanceFromTextField:10.0];
            animationDuration = 0.25;
            
            _enable = NO;
            [self setShouldResignOnTouchOutside:NO];
            [self setEnableAutoToolbar:NO];
            [self setCanAdjustTextView:NO];
            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            _keyWindow = [self keyWindow];
            _rootViewController = [self rootViewController];
        });
    }
    return self;
}

//  Call it on your AppDelegate to initialize keyboardManager
+ (IQKeyboardManager*)sharedManager
{
	//Singleton instance
	static IQKeyboardManager *kbManager;
	
	//Dispatching it once.
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
		//  Initializing keyboard manger.
        kbManager = [[IQKeyboardManager alloc] initUniqueInstance];
    });
	
	//Returning kbManager.
	return kbManager;
}

#pragma mark - Dealloc
-(void)dealloc
{
    //  Disable the keyboard manager.
	[self setEnable:NO];
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
		
        NSLog(@"Keyboard Manager enabled");
    }
	//If not disable, desable it.
    else if (enable == NO && _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original frame.
		[self keyboardWillHide:nil];
		
		//Setting NO to _enable.
		_enable = enable;
		
        NSLog(@"Keyboard Manager disabled");
    }
	//If already disabled.
	else if (enable == NO && _enable == NO)
	{
		NSLog(@"Keyboard Manger already disabled");
	}
	//If already enabled.
	else if (enable == YES && _enable == YES)
	{
        NSLog(@"Keyboard Manager already enabled");
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
	_keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);
}

-(UIViewController *)rootViewController
{
    if (_rootViewController == nil)     _rootViewController = [[self keyWindow] rootViewController];
    
    return _rootViewController;
}

-(UIWindow *)keyWindow
{
    if (_keyWindow == nil)      _keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    return _keyWindow;
}

#pragma mark - Helper Class Methods

+ (UITableView*)superTableView:(UIView*)view
{
    UIView *superview = view.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UITableView class]])
        {
            return (UITableView*)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

+(UIScrollView*)superScrollView:(UIView*)view
{
    UIView *superview = view.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UIScrollView class]])
        {
            return (UIScrollView*)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

//  Function to get topMost ViewController object.
+ (UIViewController*) topMostController
{
    UIViewController *topController = [[IQKeyboardManager sharedManager] rootViewController];
    
    //  Getting topMost ViewController
    while ([topController presentedViewController])	topController = [topController presentedViewController];
	
    //  Returning topMost ViewController
    return topController;
}

+(UIViewController*)currentViewController;
{
    UIViewController *currentViewController = [IQKeyboardManager topMostController];
    
    while ([currentViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)currentViewController topViewController])
        currentViewController = [(UINavigationController*)currentViewController topViewController];
    
    return currentViewController;
}

#pragma mark - Private Methods
//  Helper function to manipulate RootViewController's frame with animation.
-(void)setRootViewFrame:(CGRect)frame
{
    //  Getting topMost ViewController.
    UIViewController *controller = [IQKeyboardManager topMostController];
    
    //  If can't get rootViewController then printing warning to user.
    if (controller == nil)  NSLog(@"You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager");
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //  Setting it's new frame
        [controller.view setFrame:frame];
    } completion:^(BOOL finished) {
    }];
}

//  UIKeyboard Did show. Adjusting RootViewController's frame according to device orientation.
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.
    if (textFieldView == nil)   return;
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *window = [self keyWindow];
    //  Getting RootViewController.
    UIViewController *rootController = [IQKeyboardManager topMostController];
    
    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[textFieldView superview] convertRect:textFieldView.frame toView:window];
    //  Getting RootViewRect.
    CGRect rootViewRect = [[rootController view] frame];
    
    CGFloat move = 0;
    //  Move positive = textField is hidden.
    //  Move negative = textField is showing.
	
    //  Calculating move position. Common for both normal and special cases.
    switch ([rootController interfaceOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            move = CGRectGetMaxX(textFieldViewRect)-(CGRectGetWidth(window.frame)-kbSize.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
            move = kbSize.width-CGRectGetMinX(textFieldViewRect);
            break;
        case UIInterfaceOrientationPortrait:
            move = CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(window.frame)-kbSize.height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            move = kbSize.height-CGRectGetMinY(textFieldViewRect);
            break;
        default:
            break;
    }
	
    //  Getting it's superScrollView.
    UIScrollView *superScrollView = [IQKeyboardManager superScrollView:textFieldView];
    
    //If there was a lastScrollView.
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
        if (superScrollView != lastScrollView)
        {
            [lastScrollView setContentOffset:startingContentOffset animated:YES];
            lastScrollView = superScrollView;
            startingContentOffset = superScrollView.contentOffset;
        }
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        lastScrollView = superScrollView;
        startingContentOffset = superScrollView.contentOffset;
    }
    
    //  Special case for ScrollView.
    //  If we found lastScrollView then setting it's contentOffset to show textField.
    if (lastScrollView)
    {
        UIView *lastView = textFieldView;
        UIScrollView *superScrollView = lastScrollView;
        
        while (superScrollView)
        {
            CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
            
            CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
            shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y-5);   //-5 is for good UI.
            
            move -= (shouldOffsetY-superScrollView.contentOffset.y);

            //Getting problem while using `setContentOffset:animated:`, So I used animation API.
            [UIView animateWithDuration:animationDuration animations:^{
                superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);
            }];
            
            //  Getting it's superScrollView.
            lastView = superScrollView;
            superScrollView = [IQKeyboardManager superScrollView:lastView];
        }
    }
    //Going ahead. No else if.
    
    
    //Special case for UITextView(When it's hight is too big to fit on screen.
    {
        CGFloat initialMove = move;
        
        CGFloat adjustment = 5;
        switch ([rootController interfaceOrientation])
        {
            case UIInterfaceOrientationLandscapeLeft:
                adjustment += [[UIApplication sharedApplication] statusBarFrame].size.width;
                move = MIN(CGRectGetMinX(textFieldViewRect)-adjustment, move);
                break;
            case UIInterfaceOrientationLandscapeRight:
                adjustment += [[UIApplication sharedApplication] statusBarFrame].size.width;
                move = MIN(CGRectGetWidth(window.frame)-CGRectGetMaxX(textFieldViewRect)-adjustment, move);
                break;
            case UIInterfaceOrientationPortrait:
                adjustment += [[UIApplication sharedApplication] statusBarFrame].size.height;
                move = MIN(CGRectGetMinY(textFieldViewRect)-adjustment, move);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                adjustment += [[UIApplication sharedApplication] statusBarFrame].size.height;
                move = MIN(CGRectGetHeight(window.frame)-CGRectGetMaxY(textFieldViewRect)-adjustment, move);
                break;
            default:
                break;
        }
        
        
        if (_canAdjustTextView)
        {
            [UIView animateWithDuration:animationDuration animations:^{
                [textFieldView setFrame:CGRectMake(CGRectGetMinX(textFieldView.frame),CGRectGetMinY(textFieldView.frame), CGRectGetWidth(textFieldView.frame),CGRectGetHeight(textFieldView.frame)-(initialMove-move))];
            }];
        }
    }
    
    
    //  Special case for iPad modalPresentationStyle.
    if ([[IQKeyboardManager topMostController] modalPresentationStyle] == UIModalPresentationFormSheet ||
        [[IQKeyboardManager topMostController] modalPresentationStyle] == UIModalPresentationPageSheet)
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
            //  Calculating disturbed distance
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
    else
    {
        //  Positive or zero.
        if (move>=0)
        {
            //  adjusting rootViewRect
            switch (rootController.interfaceOrientation)
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
            CGFloat disturbDistance;
            
            //  Calculating disturbed distance
			switch (rootController.interfaceOrientation)
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
            
            //  disturbDistance Negative = frame disturbed.
            //  disturbDistance positive = frame not disturbed.
            if(disturbDistance<0)
            {
                //  adjusting rootViewRect
                switch (rootController.interfaceOrientation)
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
//  Keyboard Will hide. So setting rootViewController to it's default frame.
- (void)keyboardWillHide:(NSNotification*)aNotification
{
	//If it's not a fake notification generated by [self setEnable:NO].
	if (aNotification != nil)	kbShowNotification = nil;
	
	if (_enable == NO)	return;
	
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.
    if (textFieldView == nil)   return;
    
    //Due to orientation callback we need to set it's original position.
    [UIView animateWithDuration:animationDuration animations:^{
        textFieldView.frame = textFieldViewIntialFrame;
    }];
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        //  Setitng keyboard animation duration
        animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
	
    
    [UIView animateWithDuration:0.25 animations:^{
        lastScrollView.contentOffset = startingContentOffset;
    }];
    
    lastScrollView = nil;
    startingContentOffset = CGPointZero;
    //  Setting rootViewController frame to it's original position.
    [self setRootViewFrame:topViewBeginRect];
}

//  UIKeyboard Will show
-(void)keyboardWillShow:(NSNotification*)aNotification
{
	kbShowNotification = aNotification;
	
	if (_enable == NO)	return;
	
    //Due to orientation callback we need to resave it's original frame.
    textFieldViewIntialFrame = textFieldView.frame;
    
    //  Getting keyboard animation duration
    CGFloat duration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    animationDuration = duration;
    
    //  Getting UIKeyboardSize.
    kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Adding Keyboard distance from textField.
    switch ([[IQKeyboardManager topMostController] interfaceOrientation])
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
	
    [self adjustFrame];
}

#pragma mark - UITextFieldView Delegate methods
//  Removing fetched object.
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    [textFieldView.window removeGestureRecognizer:tapGesture];
    
    [UIView animateWithDuration:animationDuration animations:^{
        textFieldView.frame = textFieldViewIntialFrame;
    }];
    
    //Setting object to nil
    textFieldView = nil;
}

//  Fetching UITextFieldView object from notification.
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    //  Getting object
    textFieldView = notification.object;
    textFieldViewIntialFrame = textFieldView.frame;
    
	//If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
	if (_enableAutoToolbar)
    {
        //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
        if ([textFieldView isKindOfClass:[UITextView class]] && textFieldView.inputAccessoryView == nil)
        {
            UIView *view = textFieldView;
            
            //Resigning becoming first responder with some delay.
            [UIView animateWithDuration:0.00001 animations:^{
                [self addToolbarIfRequired];
                
            }completion:^(BOOL finished) {
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
	
    [textFieldView.window addGestureRecognizer:tapGesture];
    
    if (isKeyboardShowing == NO)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [IQKeyboardManager topMostController];
        topViewBeginRect = rootController.view.frame;
    }
    
    //  keyboard is already showing. adjust frame.
    [self adjustFrame];
}

// Bug fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string
-(void)textFieldViewDidChange:(NSNotification*)notification
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
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}


#pragma mark AutoResign methods


-(void)setShouldResignOnTouchOutside:(BOOL)shouldResignOnTouchOutside
{
    _shouldResignOnTouchOutside = shouldResignOnTouchOutside;
    [tapGesture setEnabled:_shouldResignOnTouchOutside];
}

- (void)tapRecognized:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [gesture.view endEditing:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

//Resigning textField.
- (void)resignFirstResponder
{
	[textFieldView resignFirstResponder];
}

#pragma mark AutoToolbar methods

//return YES. If autoToolbar is enabled.
-(BOOL)isEnableAutoToolbar
{
	return _enableAutoToolbar;
}

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


+(NSArray*)deepResponderViews:(UIView*)view
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    
    NSLog(@"%@",view.subviews);
    
    //subviews are returning in opposite order. So I sorted it according the frames 'y'.
    NSArray *subViews = [view.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
        
        if (obj1.frame.origin.y < obj2.frame.origin.y)	return NSOrderedAscending;
        
        else if (obj1.frame.origin.y > obj2.frame.origin.y)	return NSOrderedDescending;
        
        else	return NSOrderedSame;
    }];
    
    
    for (UITextField *textField in subViews)
    {
        if (([textField isKindOfClass:[UITextField class]] || [textField isKindOfClass:[UITextView class]]) && textField.userInteractionEnabled && textField.enabled)
        {
            [textFields addObject:textField];
        }
        else if (textField.subviews.count)
        {
            [textFields addObjectsFromArray:[IQKeyboardManager deepResponderViews:textField]];
        }
    }
    
    return textFields;
}

//	Get all UITextField/UITextView siblings of textFieldView.
-(NSArray*)responderViews
{
    UITableView *tableView = [IQKeyboardManager superTableView:textFieldView];
    
    NSArray *textFields;
    
    if (tableView)
    {
        textFields = [IQKeyboardManager deepResponderViews:tableView];
    }
    else
    {
        //	Getting all siblings
        NSArray *siblings = textFieldView.superview.subviews;
        
        //Array of (UITextField/UITextView's).
        NSMutableArray *tempTextFields = [[NSMutableArray alloc] init];
        
        for (UITextField *textField in siblings)
            if (([textField isKindOfClass:[UITextField class]] || [textField isKindOfClass:[UITextView class]]) && textField.userInteractionEnabled && textField.enabled)
                [tempTextFields addObject:textField];
        
        textFields = tempTextFields;
    }
    
    
    //If autoToolbar behaviour is bySubviews, then returning it.
    if (_toolbarManageBehaviour == IQAutoToolbarBySubviews)
    {
        return textFields;
    }
    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
    else if (_toolbarManageBehaviour == IQAutoToolbarByTag)
    {
        return [textFields sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            if ([(UIView*)obj1 tag] < [(UIView*)obj2 tag])	return NSOrderedAscending;
            
            else if ([(UIView*)obj1 tag] > [(UIView*)obj2 tag])	return NSOrderedDescending;
            
            else	return NSOrderedSame;
        }];
    }
    else
        return nil;
}

-(void)addToolbarIfRequired
{
	//	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
	
	//	If only one object is found, then adding only Done button.
	if (siblings.count==1)
	{
		if (![[siblings objectAtIndex:0] inputAccessoryView])
		{
			[[siblings objectAtIndex:0] addDoneOnKeyboardWithTarget:self action:@selector(doneAction:)];
		}
	}
	else
	{
		//	If more than 1 textField is found. then adding previous/next/done buttons on it.
		for (UITextField *textField in siblings)
		{
			if (![textField inputAccessoryView])
			{
				[textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:)];
			}
            
            //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.
            //	If firstTextField, then previous should not be enabled.
            if ([siblings objectAtIndex:0] == textField)
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


-(void)removeToolbarIfRequired
{
    //	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
    
    for (UITextField *textField in siblings)
    {
        if ([textField inputAccessoryView].tag == NSIntegerMin)
        {
            [textField setInputAccessoryView:nil];
        }
    }
}

//	Previous button action.
-(void)previousAction:(UISegmentedControl*)segmentedControl
{
	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
	//Getting index of current textField.
	NSUInteger index = [textFields indexOfObject:textFieldView];
	
	//If it is not first textField. then it's previous object becomeFirstResponder.
	if (index > 0)	[[textFields objectAtIndex:index-1] becomeFirstResponder];
}

//	Next button action.
-(void)nextAction:(UISegmentedControl*)segmentedControl
{
	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
	//Getting index of current textField.
	NSUInteger index = [textFields indexOfObject:textFieldView];
	
	//If it is not last textField. then it's next object becomeFirstResponder.
	if (index < textFields.count-1)	[[textFields objectAtIndex:index+1] becomeFirstResponder];
}

//	Done button action. Resigning current textField.
-(void)doneAction:(UIBarButtonItem*)barButton
{
    [self resignFirstResponder];
}

@end


/*UIKeyboardToolbar Category implementation*/
@implementation UIView (IQKeyboardToolbar)

#pragma mark - Toolbar on UIKeyboard
-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setTag:NSIntegerMin];
    [toolbar sizeToFit];
	
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    
	//iOS 7 check.
	if ([[UIToolbar class] instancesRespondToSelector:@selector(barTintColor)])
	{
		[doneButton setTintColor:[UIColor blackColor]];
	}
	else
	{
		[toolbar setBarStyle:UIBarStyleBlackTranslucent];
	}
	
    //  Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: nilButton,doneButton, nil]];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setTag:NSIntegerMin];
    [toolbar sizeToFit];
    
    //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:cancelAction];
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    
	//iOS 7 check.
	if ([[UIToolbar class] instancesRespondToSelector:@selector(barTintColor)])
	{
		[doneButton setTintColor:[UIColor blackColor]];
	}
	else
	{
		[toolbar setBarStyle:UIBarStyleBlackTranslucent];
	}
	
    //  Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects:cancelButton,nilButton,doneButton, nil]];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setTag:NSIntegerMin];
    [toolbar sizeToFit];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	//  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
	
	//iOS 7 check.
	if ([[UIToolbar class] instancesRespondToSelector:@selector(barTintColor)])
	{
		UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IQButtonBarArrowLeft"] style:UIBarButtonItemStylePlain target:target action:previousAction];
		[prev setTintColor:[UIColor blackColor]];
		UIBarButtonItem *fixed =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		[fixed setWidth:23];
		UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IQButtonBarArrowRight"] style:UIBarButtonItemStylePlain target:target action:nextAction];
		[next setTintColor:[UIColor blackColor]];
		[items addObject:prev];
		[items addObject:fixed];
		[items addObject:next];
		
		[doneButton setTintColor:[UIColor blackColor]];
	}
	else
	{
		[toolbar setBarStyle:UIBarStyleBlackTranslucent];
		//  Create a next/previous button to switch between TextFieldViews.
		IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousAction:previousAction nextAction:nextAction];
		UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segControl];
		[items addObject:segButton];
	}
	
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	[items addObject:nilButton];
	[items addObject:doneButton];
	
    //  Adding button to toolBar.
    [toolbar setItems:items animated:YES];
	
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled
{
    //  Getting inputAccessoryView.
    UIToolbar *inputAccessoryView = (UIToolbar*)[self inputAccessoryView];
    
    //  If it is UIToolbar and it's items are greater than zero.
    if ([inputAccessoryView isKindOfClass:[UIToolbar class]] && [[inputAccessoryView items] count]>0)
    {
		//	iOS 7 check.
		if ([[UIToolbar class] instancesRespondToSelector:@selector(barTintColor)] && [[inputAccessoryView items] count]>3)
		{
			//  Getting first item from inputAccessoryView.
			UIBarButtonItem *prevButton = (UIBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
			UIBarButtonItem *nextButton = (UIBarButtonItem*)[[inputAccessoryView items] objectAtIndex:2];
			
			//  If it is UIBarButtonItem and it's customView is not nil.
			if ([prevButton isKindOfClass:[UIBarButtonItem class]] && [nextButton isKindOfClass:[UIBarButtonItem class]])
			{
				[prevButton setEnabled:isPreviousEnabled];
				[nextButton setEnabled:isNextEnabled];
			}
		}
		else
		{
			//  Getting first item from inputAccessoryView.
			UIBarButtonItem *barButtonItem = (UIBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
			
			//  If it is UIBarButtonItem and it's customView is not nil.
			if ([barButtonItem isKindOfClass:[UIBarButtonItem class]] && [barButtonItem customView] != nil)
			{
				//  Getting it's customView.
				IQSegmentedNextPrevious *segmentedControl = (IQSegmentedNextPrevious*)[barButtonItem customView];
				
				//  If its customView is IQSegmentedNextPrevious and has 2 segments
				if ([segmentedControl isKindOfClass:[IQSegmentedNextPrevious class]] && [segmentedControl numberOfSegments]==2)
				{
					//  Setting it's first segment enable/disable.
					[segmentedControl setEnabled:isPreviousEnabled forSegmentAtIndex:0];
					
					//  Setting it's second segment enable/disable.
					[segmentedControl setEnabled:isNextEnabled forSegmentAtIndex:1];
				}
			}
		}
    }
}

@end


@interface IQSegmentedNextPrevious ()

//  UISegmentedControl selector for value change.
- (void)segmentedControlHandler:(IQSegmentedNextPrevious*)sender;

@end


@implementation IQSegmentedNextPrevious

//  Initialize method
-(id)initWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction
{
    //  Creating it with two items, Previous/Next.
    self = [super initWithItems:[NSArray arrayWithObjects:@"Previous",@"Next",nil]];
    
    if (self)
    {
        [self setSegmentedControlStyle:UISegmentedControlStyleBar];
		[self setMomentary:YES];
		[self setTintColor:[UIColor blackColor]];
		//  Adding self as it's valueChange selector.
        [self addTarget:self action:@selector(segmentedControlHandler:) forControlEvents:UIControlEventValueChanged];
        
        //  Setting target and selectors.
        buttonTarget = target;
        previousSelector = previousAction;
        nextSelector = nextAction;
    }
    return self;
}

//  Value has changed
- (void)segmentedControlHandler:(IQSegmentedNextPrevious*)sender
{
    //  Switching to selected segmenteIndex.
    switch ([sender selectedSegmentIndex])
    {
            //  Previous selected.
        case 0:
        {
            //  Invoking selector.
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[buttonTarget class] instanceMethodSignatureForSelector:previousSelector]];
            invocation.target = buttonTarget;
            invocation.selector = previousSelector;
            [invocation invoke];
        }
            break;
            //  Next selected.
        case 1:
        {
            //  Invoking selector.
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[buttonTarget class] instanceMethodSignatureForSelector:nextSelector]];
            invocation.target = buttonTarget;
            invocation.selector = nextSelector;
            [invocation invoke];
        }
        default:
            break;
    }
}

@end
