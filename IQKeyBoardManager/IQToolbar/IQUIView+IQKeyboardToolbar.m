//
//  UIView+IQToolbar.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
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


#import "IQUIView+IQKeyboardToolbar.h"
#import "IQToolbar.h"
#import "IQTitleBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQBarButtonItem.h"
#import "IQKeyboardManager.h"
#import <UIKit/UIImage.h>
#import <UIKit/UILabel.h>
#import <objc/runtime.h>

/*UIKeyboardToolbar Category implementation*/
@implementation UIView (IQToolbarAddition)

-(void)setShouldHideTitle:(BOOL)shouldHideTitle
{
    objc_setAssociatedObject(self, @selector(shouldHideTitle), [NSNumber numberWithBool:shouldHideTitle], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(placeholder)] && [self.inputAccessoryView respondsToSelector:@selector(setTitle:)])
    {
        UITextField *textField = (UITextField*)self;
        IQToolbar *toolbar = (IQToolbar*)[self inputAccessoryView];
        toolbar.title = textField.placeholder;
    }
}

-(BOOL)shouldHideTitle
{
    NSNumber *shouldHideTitle = objc_getAssociatedObject(self, @selector(shouldHideTitle));
    return [shouldHideTitle boolValue];
}

-(void)setCustomPreviousTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    UIView *selfObject = self;
    [invocation setArgument:&selfObject atIndex:2];
    self.previousInvocation = invocation;
}

-(void)setCustomNextTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    UIView *selfObject = self;
    [invocation setArgument:&selfObject atIndex:2];
    self.nextInvocation = invocation;
}

-(void)setCustomDoneTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    UIView *selfObject = self;
    [invocation setArgument:&selfObject atIndex:2];
    self.doneInvocation = invocation;
}

-(void)setPreviousInvocation:(NSInvocation *)previousInvocation
{
    objc_setAssociatedObject(self, @selector(previousInvocation), previousInvocation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setNextInvocation:(NSInvocation *)nextInvocation
{
    objc_setAssociatedObject(self, @selector(nextInvocation), nextInvocation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setDoneInvocation:(NSInvocation *)doneInvocation
{
    objc_setAssociatedObject(self, @selector(doneInvocation), doneInvocation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInvocation *)previousInvocation
{
    return objc_getAssociatedObject(self, @selector(previousInvocation));
}

-(NSInvocation *)nextInvocation
{
    return objc_getAssociatedObject(self, @selector(nextInvocation));
}

-(NSInvocation *)doneInvocation
{
    return objc_getAssociatedObject(self, @selector(doneInvocation));
}

#pragma mark - Private helper

+(UIBarButtonItem*)flexibleBarButtonItem
{
    static IQBarButtonItem *nilButton = nil;
    
    if (nilButton == nil)
    {
        nilButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    return nilButton;
}

#pragma mark - Toolbar on UIKeyboard

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addRightButtonOnKeyboardWithImage:image target:target action:action titleText:title];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
	NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStyleDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:title];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action
{
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:nil];
}


- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
 	
	NSMutableArray *items = [[NSMutableArray alloc] init];

    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addDoneOnKeyboardWithTarget:target action:action titleText:title];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    [self addDoneOnKeyboardWithTarget:target action:action titleText:nil];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //Left button
    IQBarButtonItem *cancelButton =[[IQBarButtonItem alloc] initWithTitle:leftTitle style:UIBarButtonItemStylePlain target:target action:leftAction];
    [items addObject:cancelButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleDone target:target action:rightAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addLeftRightOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle leftButtonAction:leftAction rightButtonAction:rightAction titleText:title];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction
{
    [self addLeftRightOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle leftButtonAction:leftAction rightButtonAction:rightAction titleText:nil];
}

- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //Cancel button
    IQBarButtonItem *cancelButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:target action:cancelAction];
    [items addObject:cancelButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:title];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction
{
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:nil];
}

- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
 
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
    //        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:target action:previousAction];
    //        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:106 target:target action:nextAction];
    
#ifdef __IPHONE_8_0
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0    //Minimum Target iOS 8+
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    #else   //Minimum Target iOS7+

    UIImage *imageLeftArrow;
    UIImage *imageRightArrow;

    if (IQ_IS_IOS8_OR_GREATER)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    else
    {
        imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
        imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
    }

    #endif
    
#else   //Maximum target iOS 7
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
#endif
    
    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    [items addObject:prev];

    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixed setWidth:20];
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    [items addObject:next];

    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
	[items addObject:doneButton];
	
    //  Adding button to toolBar.
    [toolbar setItems:items];
	
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:title];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:nil];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonImage:(UIImage*)rightButtonImage previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:target action:previousAction];
    //        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:106 target:target action:nextAction];
    
#ifdef __IPHONE_8_0
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0    //Minimum Target iOS 8+
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
#else   //Minimum Target iOS7+
    
    UIImage *imageLeftArrow;
    UIImage *imageRightArrow;
    
    if (IQ_IS_IOS8_OR_GREATER)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    else
    {
        imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
        imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
    }
    
#endif
    
#else   //Maximum target iOS 7
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
#endif
    
    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixed setWidth:20];
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithImage:rightButtonImage style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title;
    
    if (shouldShowPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonImage:rightButtonImage previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:title];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:target action:previousAction];
    //        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:106 target:target action:nextAction];
    
#ifdef __IPHONE_8_0
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0    //Minimum Target iOS 8+
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
#else   //Minimum Target iOS7+
    
    UIImage *imageLeftArrow;
    UIImage *imageRightArrow;
    
    if (IQ_IS_IOS8_OR_GREATER)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    else
    {
        imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
        imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
    }
    
    #endif
    
#else   //Maximum target iOS 7
    UIImage *imageLeftArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowLeft"];
    UIImage *imageRightArrow = [UIImage imageNamed:@"IQKeyboardManager.bundle/IQButtonBarArrowRight"];
#endif
    
    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixed setWidth:20];
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHideTitle?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)showPlaceholder
{
    NSString *title;
    
    if (showPlaceholder && [self respondsToSelector:@selector(placeholder)])    title = [(UITextField*)self placeholder];
    
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:title];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:nil];
}

-(void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled
{
    //  Getting inputAccessoryView.
    IQToolbar *inputAccessoryView = (IQToolbar*)[self inputAccessoryView];
    
    //  If it is IQToolbar and it's items are greater than zero.
    if ([inputAccessoryView isKindOfClass:[IQToolbar class]] && [[inputAccessoryView items] count]>0)
    {
		if ([[inputAccessoryView items] count]>3)
		{
			//  Getting first item from inputAccessoryView.
			IQBarButtonItem *prevButton = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:0];
			IQBarButtonItem *nextButton = (IQBarButtonItem*)[[inputAccessoryView items] objectAtIndex:2];
			
			//  If it is UIBarButtonItem and it's customView is not nil.
			if ([prevButton isKindOfClass:[IQBarButtonItem class]] && [nextButton isKindOfClass:[IQBarButtonItem class]])
			{
                if (prevButton.enabled != isPreviousEnabled)
                    [prevButton setEnabled:isPreviousEnabled];
                if (nextButton.enabled != isNextEnabled)
                    [nextButton setEnabled:isNextEnabled];
			}
		}
    }
}

@end
