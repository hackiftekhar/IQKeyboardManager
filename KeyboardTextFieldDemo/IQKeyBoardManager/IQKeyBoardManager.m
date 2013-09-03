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


#import "IQKeyBoardManager.h"
#import "IQSegmentedNextPrevious.h"

//Singleton object.
static IQKeyBoardManager *kbManager;

@implementation IQKeyBoardManager

#pragma mark - Initializing
//Call it on our App Delegate.
+(void)installKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kbManager = [[IQKeyBoardManager alloc] init];
    });
}

//Initialize only once
-(id)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            /*Registering for keyboard notification*/
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
            
            /*Registering for textField notification*/
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
            
            /*Registering for textView notification*/
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewdDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
            animationDuration = 0.25;
        });
    }
    return self;
}

#pragma mark - Helper Animation function
//Helper function to manipulate RootViewController's frame with animation.
-(void)setRootViewFrame:(CGRect)frame
{
    [UIView animateWithDuration:animationDuration animations:^{
        [textFieldView.window.rootViewController.view setFrame:frame];
    }];
}

#pragma mark - Device Orientation Supported logic
//Setting rootViewController's frame according to deviceOrientation.
-(void)handleLandscapeRightWithKeyboardNotification:(NSNotification*)aNotification
{
    //Getting UserInfo.
    NSDictionary* info = [aNotification userInfo];
    
    //Getting UIKeyboardSize.
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Adding 10 more height to keyboard.
    kbSize.width += 10;
    
    //Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    //Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [textFieldView.superview convertRect:textFieldView.frame toView:window];
    //Getting RootViewRect.
    CGRect rootViewRect = window.rootViewController.view.frame;
    //Getting Application Frame.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    //Calculate movement which should be scrolled.
    float move = kbSize.width-CGRectGetMinX(textFieldViewRect);
    
    //If textField is showing on screen(i.e. y origin is positive.
    if (CGRectGetMaxX(textFieldViewRect)<=CGRectGetWidth(appFrame))
    {
        //If move is positive, Then Keyboard must be hiding our textField object. 
        if(move >= 0)
        {
            //Adjusting rootView controller frame.
            rootViewRect.origin.x += move;
            [self setRootViewFrame:rootViewRect];
        }
        //Else if our rootViewController frame's y is negative(Disturbed).
        else if(CGRectGetMinX(rootViewRect)>CGRectGetMinX(appFrame))
        {
            //Calculating disturbed distance.
            CGFloat disturbDistance = CGRectGetMinX(appFrame)-CGRectGetMinX(rootViewRect);
            
            //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
            rootViewRect.origin.x += move>disturbDistance?move:disturbDistance;
 
            if (CGRectGetMinX(rootViewRect) == CGRectGetMinX(appFrame))
                [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
            else
                [self setRootViewFrame:rootViewRect];
        }
    }
    //Else if our rootViewController frame's y is negative(Disturbed).
    else if(CGRectGetMinX(rootViewRect)>CGRectGetMinX(appFrame))
    {
        //Calculating disturbed distance.
        CGFloat disturbDistance = CGRectGetMinX(appFrame)-CGRectGetMinX(rootViewRect);
        
        //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
        rootViewRect.origin.x += move>disturbDistance?move:disturbDistance;
        
        if (CGRectGetMinX(rootViewRect) == CGRectGetMinX(appFrame))
            [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
        else
            [self setRootViewFrame:rootViewRect];
    }
}

-(void)handleLandscapeLeftWithKeyboardNotification:(NSNotification*)aNotification
{
    //Getting UserInfo.
    NSDictionary* info = [aNotification userInfo];
    
    //Getting UIKeyboardSize.
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Adding 10 more height to keyboard.
    kbSize.width += 10;
    
    //Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    //Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [textFieldView.superview convertRect:textFieldView.frame toView:window];
    //Getting RootViewRect.
    CGRect rootViewRect = window.rootViewController.view.frame;
    //Getting Application Frame.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    //Calculate movement which should be scrolled.
    float move = CGRectGetMaxX(textFieldViewRect)-(CGRectGetWidth(window.frame)-kbSize.width);
    
    //If textField is showing on screen(i.e. y origin is positive.
    if (CGRectGetMinX(textFieldViewRect)>=CGRectGetMinX(appFrame))
    {
        //If move is positive, Then Keyboard must be hiding our textField object. 
        if(move >= 0)
        {
            //Adjusting rootView controller frame.
            rootViewRect.origin.x -= move;
            [self setRootViewFrame:rootViewRect];
        }
        //Else if our rootViewController frame's y is negative(Disturbed).
        else if(CGRectGetMinX(rootViewRect)<CGRectGetMinX(appFrame))
        {
            //Calculating disturbed distance.
            CGFloat disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(appFrame);
            
            //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
            rootViewRect.origin.x -= move>disturbDistance?move:disturbDistance;
  
            if (CGRectGetMinX(rootViewRect) == CGRectGetMinX(appFrame))
                [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
            else
                [self setRootViewFrame:rootViewRect];
        }
    }
    //Else if our rootViewController frame's y is negative(Disturbed).
    else if(CGRectGetMinX(rootViewRect)<CGRectGetMinX(appFrame))
    {
        //Calculating disturbed distance.
        CGFloat disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(appFrame);
        
        //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
        rootViewRect.origin.x -= move>disturbDistance?move:disturbDistance;
        
        if (CGRectGetMinX(rootViewRect) == CGRectGetMinX(appFrame))
            [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
        else
            [self setRootViewFrame:rootViewRect];
    }
}

-(void)handlePortraitWithKeyboardNotification:(NSNotification*)aNotification
{
    //Getting UserInfo.
    NSDictionary* info = [aNotification userInfo];
    
    //Getting UIKeyboardSize.
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Adding 10 more height to keyboard.
    kbSize.height += 10;
    
    //Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    //Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [textFieldView.superview convertRect:textFieldView.frame toView:window];
    //Getting RootViewRect.
    CGRect rootViewRect = window.rootViewController.view.frame;
    //Getting Application Frame.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    //Calculate movement which should be scrolled.
    float move = CGRectGetMaxY(textFieldViewRect)-(CGRectGetHeight(window.frame)-kbSize.height);
    
    //If textField is showing on screen(i.e. y origin is positive.
    if (CGRectGetMinY(textFieldViewRect)>=CGRectGetMinY(appFrame))
    {
        //If move is positive, Then Keyboard must be hiding our textField object. 
        if(move >= 0)
        {
            //Adjusting rootView controller frame.
            rootViewRect.origin.y -= move;
            [self setRootViewFrame:rootViewRect];
        }
        //Else if our rootViewController frame's y is negative(Disturbed).
        else if(CGRectGetMinY(rootViewRect)<CGRectGetMinY(appFrame))
        {
            //Calculating disturbed distance.
            CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(appFrame);
            
            //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
            rootViewRect.origin.y -= move>disturbDistance?move:disturbDistance;
            
            if (CGRectGetMinY(rootViewRect) == CGRectGetMinY(appFrame))
                [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
            else
                [self setRootViewFrame:rootViewRect];
        }
    }
    //Else if our rootViewController frame's y is negative(Disturbed).
    else if(CGRectGetMinY(rootViewRect)<CGRectGetMinY(appFrame))
    {
        //Calculating disturbed distance.
        CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(appFrame);
        
        //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
        rootViewRect.origin.y -= move>disturbDistance?move:disturbDistance;
        
        if (CGRectGetMinY(rootViewRect) == CGRectGetMinY(appFrame))
            [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
        else
            [self setRootViewFrame:rootViewRect];
    }
}

-(void)handlePortraitUpsideDownWithKeyboardNotification:(NSNotification*)aNotification
{
    //Getting UserInfo.
    NSDictionary* info = [aNotification userInfo];
    
    //Getting UIKeyboardSize.
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Adding 10 more height to keyboard.
    kbSize.height += 10;
    
    //Getting KeyWindow object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    //Converting Rectangle according to window bounds.
    CGRect textFieldViewRect = [textFieldView.superview convertRect:textFieldView.frame toView:window];
    //Getting RootViewRect.
    CGRect rootViewRect = window.rootViewController.view.frame;
    //Getting Application Frame.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    //Calculate movement which should be scrolled.
    float move = kbSize.height-CGRectGetMinY(textFieldViewRect);
    
    //If textField is showing on screen(i.e. y origin is positive.
    if (CGRectGetMaxY(textFieldViewRect)<=CGRectGetHeight(appFrame))
    {
        //If move is positive, Then Keyboard must be hiding our textField object. 
        if(move >= 0)
        {
            //Adjusting rootView controller frame.
            rootViewRect.origin.y += move;
            [self setRootViewFrame:rootViewRect];
        }
        //Else if our rootViewController frame's y is negative(Disturbed).
        else if(CGRectGetMinY(rootViewRect)>CGRectGetMinY(appFrame))
        {
            //Calculating disturbed distance.
            CGFloat disturbDistance = CGRectGetMinY(appFrame)-CGRectGetMinY(rootViewRect);
            
            //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
            rootViewRect.origin.y += move>disturbDistance?move:disturbDistance;
            
            if (CGRectGetMinY(rootViewRect) == CGRectGetMinY(appFrame))
                [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
            else
                [self setRootViewFrame:rootViewRect];
       }
    }
    //Else if our rootViewController frame's y is negative(Disturbed).
    else if(CGRectGetMinY(rootViewRect)>CGRectGetMinY(appFrame))
    {
        //Calculating disturbed distance.
        CGFloat disturbDistance = CGRectGetMinY(appFrame)-CGRectGetMinY(rootViewRect);
        
        //Adding movement or disturbed distance to origin.(Don't be trapped on this calculation)
        rootViewRect.origin.y += move>disturbDistance?move:disturbDistance;
        
        if (CGRectGetMinY(rootViewRect) == CGRectGetMinY(appFrame))
            [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
        else
            [self setRootViewFrame:rootViewRect];
    }
}


#pragma mark - UIKeyboad Delegate methods
// Keyboard Will hide. So setting rootViewController to it's default frame.
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    CGFloat aDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }

    //Setting rootViewController frame to it's original position.
    [self setRootViewFrame:[[UIScreen mainScreen] applicationFrame]];
}

//UIKeyboard Did shown. Adjusting RootViewController's frame according to device orientation.
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    CGFloat aDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    }
    
    switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            [self handleLandscapeLeftWithKeyboardNotification:aNotification];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self handleLandscapeRightWithKeyboardNotification:aNotification];
            break;
        case UIInterfaceOrientationPortrait:
            [self handlePortraitWithKeyboardNotification:aNotification];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self handlePortraitUpsideDownWithKeyboardNotification:aNotification];
            break;
        default:
            break;
    }
}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
}

#pragma mark - UITextField Delegate methods
//Fetching UITextField object from notification.
-(void)textFieldDidBeginEditing:(NSNotification*)notification
{
    textFieldView = notification.object;
}

//Removing fetched object.
-(void)textFieldDidEndEditing:(NSNotification*)notification
{
    textFieldView = nil;
}

#pragma mark - UITextView Delegate methods
//Fetching UITextView object from notification.
-(void)textViewDidBeginEditing:(NSNotification*)notification
{
    textFieldView = notification.object;
}

//Removing fetched object.
-(void)textViewdDidEndEditing:(NSNotification*)notification
{
    textFieldView = nil;
}

@end





/*Additional Function*/
@implementation UITextField(ToolbarOnKeyboard)

#pragma mark - Toolbar on UIKeyboard
-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    //Creating a toolBar for phoneNumber keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    //Create a button to show on phoneNumber keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    
    //Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: nilButton,doneButton, nil]];
    
    //Setting toolbar to textFieldPhoneNumber keyboard.
    [self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    //Creating a toolBar for phoneNumber keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];

   //Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //Create a button to show on phoneNumber keyboard to resign it. Adding a selector to resign it.
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];

    IQSegmentedNextPrevious *segControl = [[IQSegmentedNextPrevious alloc] initWithTarget:target previousSelector:previousAction nextSelector:nextAction];
//
    UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segControl];

    //Adding button to toolBar.
    [toolbar setItems:[NSArray arrayWithObjects: segButton,nilButton,doneButton, nil]];
//    [toolbar setItems:[NSArray arrayWithObjects: previousButton,nextButton,nilButton,doneButton, nil]];
    
    //Setting toolbar to textFieldPhoneNumber keyboard.
    [self setInputAccessoryView:toolbar];
}

@end
