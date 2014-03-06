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

#import "IQKeyboardManager.h"
#import "UIView+Hierarchy.h"
#import "UIView+IQKeyboardToolbar.h"
#import "UIWindow+Hierarchy.h"
#import "NSArray+Sort.h"
#import "IQToolbar.h"

#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UITableView.h>

@interface IQKeyboardManager (RemoveCompilerWarning)

//Remove compiler warning
-(void)previousAction:(id)segmentedControl;
-(void)nextAction:(id)segmentedControl;
-(void)doneAction:(UIBarButtonItem*)barButton;

@end

@interface IQKeyboardManager()<UIGestureRecognizerDelegate>

/*! save rootViewControlle for reuse. */
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
    
    UIView *_textFieldView;
    
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

@synthesize enable                          = _enable;
@synthesize enableAutoToolbar               = _enableAutoToolbar;
@synthesize keyboardDistanceFromTextField   = _keyboardDistanceFromTextField;
@synthesize toolbarManageBehaviour          = _toolbarManageBehaviour;
@synthesize shouldResignOnTouchOutside      = _shouldResignOnTouchOutside;
@synthesize canAdjustTextView               = _canAdjustTextView;
@synthesize keyWindow                       = _keyWindow;


#pragma mark - Initializing functions

//Override +load method to enable KeyboardManager when class loader load IQKeyboardManager
+(void)load
{
    [super load];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

//  Singleton Object Initialization.
-(id)init
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
            [self setCanAdjustTextView:NO];
            [self setShouldPlayInputClicks:NO];
            [self setShouldResignOnTouchOutside:NO];
            [self setShouldToolbarUsesTextFieldTintColor:NO];

            [self setEnableAutoToolbar:YES];
            [self setShouldShowTextFieldPlaceholder:YES];

            [self setToolbarManageBehaviour:IQAutoToolbarBySubviews];
            
            _keyWindow = [self keyWindow];
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

-(UIWindow *)keyWindow
{
    if (_keyWindow == nil)      _keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    return _keyWindow;
}

#pragma mark - Private Methods
//  Helper function to manipulate RootViewController's frame with animation.
-(void)setRootViewFrame:(CGRect)frame
{
    //  Getting topMost ViewController.
    UIViewController *controller = [[self keyWindow] topMostController];
    
    //  If can't get rootViewController then printing warning to user.
    if (controller == nil)  NSLog(@"You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager");
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        //  Setting it's new frame
        [controller.view setFrame:frame];
    } completion:^(BOOL finished) {
    }];
}

//  UIKeyboard Did show. Adjusting RootViewController's frame according to device orientation.
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.
    if (_textFieldView == nil)   return;
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *window = [self keyWindow];
    //  Getting RootViewController.
    UIViewController *rootController = [[self keyWindow] topMostController];
    
    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:window];
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
    UIScrollView *superScrollView = [_textFieldView superScrollView];
    
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
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (lastScrollView)
        {
            UIView *lastView = _textFieldView;
            UIScrollView *superScrollView = lastScrollView;
            
            while (superScrollView)
            {
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y-5);   //-5 is for good UI.
                
                move -= (shouldOffsetY-superScrollView.contentOffset.y);
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);
                } completion:^(BOOL finished) {
                }];

                //  Getting it's superScrollView.
                lastView = superScrollView;
                superScrollView = [lastView superScrollView];
            }
        }
        //Going ahead. No else if.
    }
    
    //Special case for UITextView(When it's hight is too big to fit on screen).
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
            //Getting problem while using `setContentOffset:animated:`, So I used animation API.
            [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [_textFieldView setFrame:CGRectMake(CGRectGetMinX(_textFieldView.frame),CGRectGetMinY(_textFieldView.frame), CGRectGetWidth(_textFieldView.frame),CGRectGetHeight(_textFieldView.frame)-(initialMove-move))];
            } completion:^(BOOL finished) {
            }];
        }
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
    if (_textFieldView == nil)   return;
    
    //Due to orientation callback we need to set it's original position.
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        _textFieldView.frame = textFieldViewIntialFrame;
    } completion:^(BOOL finished) {

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
	
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        lastScrollView.contentOffset = startingContentOffset;
    } completion:^(BOOL finished) {

    }];
    
    lastScrollView = nil;
    kbSize = CGSizeZero;
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
    textFieldViewIntialFrame = _textFieldView.frame;
    
    //  Getting keyboard animation.
//    animationCurve = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//    animationCurve = animationCurve<<16;

    //  Getting keyboard animation duration
    CGFloat duration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    animationDuration = duration;
    
    CGSize oldKBSize = kbSize;
    
    //  Getting UIKeyboardSize.
    kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Adding Keyboard distance from textField.
    switch ([[[self keyWindow] topMostController] interfaceOrientation])
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
    
    if (!CGSizeEqualToSize(kbSize, oldKBSize))
    {
        [self adjustFrame];
    }
}

#pragma mark - UITextFieldView Delegate methods
//  Removing fetched object.
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    [_textFieldView.window removeGestureRecognizer:tapGesture];
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        _textFieldView.frame = textFieldViewIntialFrame;
    } completion:^(BOOL finished) {
    }];
    
    //Setting object to nil
    _textFieldView = nil;
}

//  Fetching UITextFieldView object from notification.
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    //  Getting object
    _textFieldView = notification.object;
    textFieldViewIntialFrame = _textFieldView.frame;
    
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
	
    [_textFieldView.window addGestureRecognizer:tapGesture];
    
    if (isKeyboardShowing == NO)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [[self keyWindow] topMostController];
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
        [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            [textView setContentOffset:offset];
        } completion:^(BOOL finished) {

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
	[_textFieldView resignFirstResponder];
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

//	Get all UITextField/UITextView siblings of textFieldView.
-(NSArray*)responderViews
{
    UITableView *tableView = [_textFieldView superTableView];
    
    NSArray *textFields;
    
    if (tableView)
    {
        textFields = [tableView deepResponderViews];
    }
    else
    {
        textFields = [_textFieldView responderSiblings];
    }

    //If autoToolbar behaviour is bySubviews, then returning it.
    if (_toolbarManageBehaviour == IQAutoToolbarBySubviews)
    {
        return textFields;
    }
    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
    else if (_toolbarManageBehaviour == IQAutoToolbarByTag)
    {
        return [textFields sortedArrayByTag];
    }
    else
        return nil;
}

#pragma mark previous/next/done functionality
//	Previous button action.
-(void)previousAction:(id)segmentedControl
{
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not first textField. then it's previous object becomeFirstResponder.
        if (index > 0)	[[textFields objectAtIndex:index-1] becomeFirstResponder];
    }
}

//	Next button action.
-(void)nextAction:(id)segmentedControl
{
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

	//Getting all responder view's.
	NSArray *textFields = [self responderViews];
	
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not last textField. then it's next object becomeFirstResponder.
        if (index < textFields.count-1)	[[textFields objectAtIndex:index+1] becomeFirstResponder];
    }
}

//	Done button action. Resigning current textField.
-(void)doneAction:(UIBarButtonItem*)barButton
{
    if (_shouldPlayInputClicks)
    {
        [[UIDevice currentDevice] playInputClick];
    }

    [self resignFirstResponder];
}

-(void)addToolbarIfRequired
{
	//	Getting all the sibling textFields.
	NSArray *siblings = [self responderViews];
	
	//	If only one object is found, then adding only Done button.
	if (siblings.count==1)
	{
        UIView *textField = [siblings objectAtIndex:0];
		if (![textField inputAccessoryView])
		{
			[textField addDoneOnKeyboardWithTarget:self action:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];

            //Setting toolbar tintColor
            if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                [textField.inputAccessoryView setTintColor:[textField tintColor]];
        }
	}
	else if(siblings.count)
	{
		//	If more than 1 textField is found. then adding previous/next/done buttons on it.
		for (UITextField *textField in siblings)
		{
			if (![textField inputAccessoryView])
			{
				[textField addPreviousNextDoneOnKeyboardWithTarget:self previousAction:@selector(previousAction:) nextAction:@selector(nextAction:) doneAction:@selector(doneAction:) shouldShowPlaceholder:_shouldShowTextFieldPlaceholder];

                //Setting toolbar tintColor
                if (_shouldToolbarUsesTextFieldTintColor && [textField respondsToSelector:@selector(tintColor)])
                    [textField.inputAccessoryView setTintColor:[textField tintColor]];
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
        if ([[textField inputAccessoryView] isKindOfClass:[IQToolbar class]])
        {
            [textField setInputAccessoryView:nil];
        }
    }
}

@end
