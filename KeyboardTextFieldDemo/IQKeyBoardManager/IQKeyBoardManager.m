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

// Singleton object.
static IQKeyBoardManager *kbManager;

@interface IQKeyBoardManager()

// Properties to maintain keyboar
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;
@property(nonatomic, assign) BOOL isEnabled;

-(void)adjustFrameWithDuration:(CGFloat)aDuration;
-(void)commonDidBeginEditing;

-(void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;
-(void)textFieldDidBeginEditing:(NSNotification*)notification;
-(void)textViewdDidEndEditing:(NSNotification*)notification;

@end

@implementation IQKeyBoardManager
@synthesize keyboardDistanceFromTextField;
@synthesize isEnabled;

#pragma mark - Initializing
// Call it on our App Delegate.
+(void)installKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Initializing keyboard manger.
        kbManager = [[IQKeyBoardManager alloc] init];
        
        // Enabling keyboard manager.
        [IQKeyBoardManager enableKeyboardManger];
    });
}

+(void)setTextFieldDistanceFromKeyboard:(CGFloat)distance
{
    // Setting keyboard distance.
    kbManager.keyboardDistanceFromTextField = MAX(distance, 0);
}

+(void)enableKeyboardManger
{
    // registering for notifications if it is not enable already.
    if (kbManager.isEnabled == NO)
    {
        kbManager.isEnabled = YES;
        /*Registering for keyboard notification*/
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        /*Registering for textField notification*/
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        
        /*Registering for textView notification*/
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(textViewdDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
        NSLog(@"Keyboard Manager enabled");
    }
    else
    {
        NSLog(@"Keyboard Manager already enabled");
    }
}

+(void)disableKeyboardManager
{
    // Unregister for all notifications if it is enabled.
    if (kbManager.isEnabled == YES)
    {
        kbManager.isEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:kbManager];
        NSLog(@"Keyboard Manager disabled");
    }
    else
    {
        NSLog(@"Keyboard Manger already disabled");
    }
}

+(BOOL)isEnabled
{
    // keyboard manger is enabled or not.
    return kbManager.isEnabled;
}

// Initialize only once
-(id)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            // Default settings
            keyboardDistanceFromTextField = 10.0;
            isEnabled = NO;
            animationDuration = 0.25;
        });
    }
    return self;
}

// Function to get topMost ViewController object.
+ (UIViewController*) topMostController
{
    // Getting rootViewController
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    // Getting topMost ViewController
    while (topController.presentedViewController)
        topController = topController.presentedViewController;

    // Returning topMost ViewController
    return topController;
}


#pragma mark - Helper Animation function
// Helper function to manipulate RootViewController's frame with animation.
-(void)setRootViewFrame:(CGRect)frame
{
    // Getting topMost ViewController.
    UIViewController *controller = [IQKeyBoardManager topMostController];
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        // Setting it's new frame
        [controller.view setFrame:frame];
    }];
}

#pragma mark - UIKeyboad Delegate methods
//  Keyboard Will hide. So setting rootViewController to it's default frame.
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (textFieldView == nil)
    {
        return;
    }
    
    // Boolean to know keyboard is showing/hiding
    isKeyboardShowing = NO;
    
    // Getting keyboard animation duration
    CGFloat aDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        // Setitng keyboard animation duration
        animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }

    // Setting rootViewController frame to it's original position.
    [self setRootViewFrame:topViewBeginRect];
}

// UIKeyboard Will show
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    // Getting keyboard animation duration
    CGFloat duration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // Getting UIKeyboardSize.
    kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Adding Keyboard distance from textField.
    switch ([IQKeyBoardManager topMostController].interfaceOrientation)
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

    [self adjustFrameWithDuration:duration];
}

// UIKeyboard Did show. Adjusting RootViewController's frame according to device orientation.
-(void)adjustFrameWithDuration:(CGFloat)aDuration
{
    if (textFieldView == nil)
    {
        return;
    }
    
    // Boolean to know keyboard is showing/hiding
    isKeyboardShowing = YES;
    
    if (aDuration!= 0.0f)
    {
        // Setitng keyboard animation duration
        animationDuration = aDuration;
    }
    
    // Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    // Getting RootViewController's view.
    UIViewController *rootController = [IQKeyBoardManager topMostController];
    
    // Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [textFieldView.superview convertRect:textFieldView.frame toView:window];
    // Getting RootViewRect.
    CGRect rootViewRect = rootController.view.frame;
    
    CGFloat move;
    // Move positive = textField is hidden.
    // Move negative = textField is showing.

    // Calculating move position. Common for both normal and special cases.
    switch (rootController.interfaceOrientation)
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

    // Special case.
    if ([[IQKeyBoardManager topMostController] modalPresentationStyle] == UIModalPresentationFormSheet ||
        [[IQKeyBoardManager topMostController] modalPresentationStyle] == UIModalPresentationPageSheet)
    {
        // Positive or zero.
        if (move>=0)
        {
            // We should only manipulate y.
            rootViewRect.origin.y -= move;  
            [self setRootViewFrame:rootViewRect];
        }
        // Negative
        else
        {
            // Calculating disturbed distance
            CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(topViewBeginRect);

            // Move Negative = frame disturbed.
            // Move positive or frame not disturbed.
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
        // Positive or zero.
        if (move>=0)
        {
            // adjusting rootViewRect
            switch (rootController.interfaceOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= move;  break;
                case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += move;  break;
                case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= move;  break;
                case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += move;  break;
                default:    break;
            }

            // Setting adjusted rootViewRect
            [self setRootViewFrame:rootViewRect];
        }
        // Negative
        else
        {
            CGFloat disturbDistance;
            
            // Calculating disturbed distance
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
            
            // Move Negative = frame disturbed.
            // Move positive or frame not disturbed.
            if(disturbDistance<0)
            {
                // adjusting rootViewRect
                switch (rootController.interfaceOrientation)
                {
                    case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= MAX(move, disturbDistance);  break;
                    case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += MAX(move, disturbDistance);  break;
                    default:    break;
                }
                
                // Setting adjusted rootViewRect
                [self setRootViewFrame:rootViewRect];
            }
        }
    }    
}

#pragma mark - UITextField Delegate methods
// Fetching UITextField object from notification.
-(void)textFieldDidBeginEditing:(NSNotification*)notification
{
    textFieldView = notification.object;
    [self commonDidBeginEditing];
}

// Removing fetched object.
-(void)textFieldDidEndEditing:(NSNotification*)notification
{
    textFieldView = nil;
}

#pragma mark - UITextView Delegate methods
// Fetching UITextView object from notification.
-(void)textViewDidBeginEditing:(NSNotification*)notification
{
    textFieldView = notification.object;
    [self commonDidBeginEditing];
}

// Removing fetched object.
-(void)textViewdDidEndEditing:(NSNotification*)notification
{
    textFieldView = nil;
}

// Common code to perform on begin editing
-(void)commonDidBeginEditing
{
    if (isKeyboardShowing)
    {
        // keyboard is already showing. adjust frame.
        [self adjustFrameWithDuration:0];
    }
    else
    {
        // keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [IQKeyBoardManager topMostController];
        topViewBeginRect = rootController.view.frame;

        // keyboard is not showing. adjust frame.
        [self adjustFrameWithDuration:animationDuration];
    }
}

@end


/*Additional Function*/
@implementation UIView (ToolbarOnKeyboard)

#pragma mark - Toolbar on UIKeyboard
-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    // Creating a toolBar for phoneNumber keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    // Create a button to show on phoneNumber keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    
    // Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: nilButton,doneButton, nil]];
    
    if ([self respondsToSelector:@selector(setInputAccessoryView:)])
    {
        // Setting toolbar to textFieldPhoneNumber keyboard.
        [(UITextField*)self setInputAccessoryView:toolbar];
    }
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    // Creating a toolBar for phoneNumber keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    // Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // Create a button to show on phoneNumber keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    
    IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousSelector:previousAction nextSelector:nextAction];

    UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    
    // Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: segButton,nilButton,doneButton, nil]];
    
    if ([self respondsToSelector:@selector(setInputAccessoryView:)])
    {
        // Setting toolbar to textFieldPhoneNumber keyboard.
        [(UITextField*)self setInputAccessoryView:toolbar];
    }
}

-(void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled
{
    UIToolbar *inputView = (UIToolbar*)[self inputAccessoryView];
    
    if ([inputView isKindOfClass:[UIToolbar class]] && [[inputView items] count]>0)
    {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem*)[[inputView items] objectAtIndex:0];
        
        if ([barButtonItem isKindOfClass:[UIBarButtonItem class]] && [barButtonItem customView] != nil)
        {
            UISegmentedControl *segmentedControl = (UISegmentedControl*)[barButtonItem customView];
            
            if ([segmentedControl isKindOfClass:[UISegmentedControl class]] && [segmentedControl numberOfSegments]>1)
            {
                [segmentedControl setEnabled:isPreviousEnabled forSegmentAtIndex:0];

                [segmentedControl setEnabled:isNextEnabled forSegmentAtIndex:1];
            }
        }
    }
}


@end


@interface IQSegmentedNextPrevious ()

- (void)segmentedControlHandler:(IQSegmentedNextPrevious*)sender;

@end


@implementation IQSegmentedNextPrevious

-(id)initWithTarget:(id)target previousSelector:(SEL)pSelector nextSelector:(SEL)nSelector
{
    self = [super initWithItems:[NSArray arrayWithObjects:@"Previous",@"Next",nil]];
    
    if (self)
    {
#ifndef __IPHONE_7_0
        [self setSegmentedControlStyle:UISegmentedControlStyleBar];
#endif
        
        [self setMomentary:YES];
        [self addTarget:self action:@selector(segmentedControlHandler:) forControlEvents:UIControlEventValueChanged];
        
        buttonTarget = target;
        previousSelector = pSelector;
        nextSelector = nSelector;
    }
    return self;
}

- (void)segmentedControlHandler:(IQSegmentedNextPrevious*)sender
{
    switch ([sender selectedSegmentIndex])
    {
        case 0:
        {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[buttonTarget class] instanceMethodSignatureForSelector:previousSelector]];
            invocation.target = buttonTarget;
            invocation.selector = previousSelector;
            [invocation invoke];
        }
            break;
        case 1:
        {
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
