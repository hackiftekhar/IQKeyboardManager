//
//  keyBoardManager.m
//
// Copyright (c) 2013 Iftekhar Qurashi.
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


#import "IQKeyBoardManager.h"

//  Singleton object.
static IQKeyboardManager *kbManager;

@interface IQKeyboardManager()

//  Properties to maintain keyboard
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;
@property(nonatomic, assign) BOOL isEnabled;

//  Private helper methods
- (void)adjustFrame;

//  Notification methods
- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
- (void)textFieldViewDidBeginEditing:(NSNotification*)notification;
- (void)textFieldViewDidEndEditing:(NSNotification*)notification;

@end

@implementation IQKeyboardManager
@synthesize keyboardDistanceFromTextField;
@synthesize isEnabled;

#pragma mark - Initializing


//  Singleton Object Initialization.
-(id)initUniqueInstance
{
	if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            //  Default settings
            keyboardDistanceFromTextField = 10.0;
            isEnabled = NO;
            animationDuration = 0.25;
        });
    }
    return self;
}

//  Call it on your AppDelegate to initialize keyboardManager
+(void)installKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //  Initializing keyboard manger.
        kbManager = [[IQKeyboardManager alloc] initUniqueInstance];
        
        //  Enabling keyboard manager.
        [IQKeyboardManager enableKeyboardManger];
    });
}

//  To set keyboard distance from textField. can't be less than zero. Default is 10.0.
+(void)setTextFieldDistanceFromKeyboard:(CGFloat)distance
{
    //  Setting keyboard distance.
    kbManager.keyboardDistanceFromTextField = MAX(distance, 0);
}

//  Enable the keyboard manager. Default is enabled.
+(void)enableKeyboardManger
{
    //  Registering for notifications if it is not enable already.
    if (kbManager.isEnabled == NO)
    {
        kbManager.isEnabled = YES;
        //  Registering for keyboard notification.
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        //  Registering for textField notification.
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        
        //  Registering for textView notification.
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
        NSLog(@"Keyboard Manager enabled");
    }
    else
    {
        NSLog(@"Keyboard Manager already enabled");
    }
}

//  Disable the keyboard manager. Default is enabled.
+(void)disableKeyboardManager
{
    //  Unregister for all notifications if it is enabled.
    if ([kbManager isEnabled] == YES)
    {
        //Sending a fake notification for keyboardWillHide to retain view's original frame.
        [kbManager keyboardWillHide:nil];
        
        kbManager.isEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:kbManager];
        NSLog(@"Keyboard Manager disabled");
    }
    else
    {
        NSLog(@"Keyboard Manger already disabled");
    }
}

//  Return YES if keyboard manager is enabled, otherwise NO.
+(BOOL)isEnabled
{
    //  keyboard manger is enabled or not.
    return [kbManager isEnabled];
}

//  Function to get topMost ViewController object.
+ (UIViewController*) topMostController
{
    //  Getting rootViewController
    UIViewController *topController = [[[UIApplication sharedApplication] keyWindow] rootViewController];

    //  Getting topMost ViewController
    while ([topController presentedViewController])
        topController = [topController presentedViewController];

    //  Returning topMost ViewController
    return topController;
}


#pragma mark - Helper Animation function
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

#pragma mark - UIKeyboad Notification methods
//  Keyboard Will hide. So setting rootViewController to it's default frame.
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.
    if (textFieldView == nil)   return;
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        //  Setitng keyboard animation duration
        animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }

    //  Setting rootViewController frame to it's original position.
    [self setRootViewFrame:topViewBeginRect];
}

//  UIKeyboard Will show
-(void)keyboardWillShow:(NSNotification*)aNotification
{
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
            kbSize.width += keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationLandscapeRight:
            kbSize.width += keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortrait:
            kbSize.height += keyboardDistanceFromTextField;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            kbSize.height += keyboardDistanceFromTextField;
            break;
        default:
            break;
    }

    [self adjustFrame];
}

//  UIKeyboard Did show. Adjusting RootViewController's frame according to device orientation.
-(void)adjustFrame
{
    //  We are unable to get textField object while keyboard showing on UIWebView's textField.
    if (textFieldView == nil)   return;
    
    //  Boolean to know keyboard is showing/hiding
    isKeyboardShowing = YES;
    
    //  Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //  Getting RootViewController.
    UIViewController *rootController = [IQKeyboardManager topMostController];
    
    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [[textFieldView superview] convertRect:textFieldView.frame toView:window];
    //  Getting RootViewRect.
    CGRect rootViewRect = [[rootController view] frame];
    
    CGFloat move;
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

#pragma mark - UITextFieldView Delegate methods
//  Removing fetched object.
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    //Setting object to nil
    textFieldView = nil;
}

//  Fetching UITextFieldView object from notification.
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    //  Getting object
    textFieldView = notification.object;
    
    if (isKeyboardShowing == NO)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [IQKeyboardManager topMostController];
        topViewBeginRect = rootController.view.frame;
    }
    
    //  keyboard is already showing. adjust frame.
    [self adjustFrame];
}

-(void)dealloc
{
    //  Desable the keyboard manager.
    [IQKeyboardManager disableKeyboardManager];
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
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
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
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    //  Create a cancel button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:cancelAction];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
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
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    //  Create a next/previous button to switch between TextFieldViews.
    IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousAction:previousAction nextAction:nextAction];
    UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //  Create a done button to show on keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    
    //  Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: segButton,nilButton,doneButton, nil]];

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
        //  Getting first item from inputAccessoryView.
        UIBarButtonItem *barButtonItem = (UIBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
        
        //  If it is UIBarButtonItem and it's customView is not nil.
        if ([barButtonItem isKindOfClass:[UIBarButtonItem class]] && [barButtonItem customView] != nil)
        {
            //  Getting it's customView.
            UISegmentedControl *segmentedControl = (IQSegmentedNextPrevious*)[barButtonItem customView];
            
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
#ifndef __IPHONE_7_0
        [self setSegmentedControlStyle:UISegmentedControlStyleBar];
#endif
        
        [self setMomentary:YES];
        
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
