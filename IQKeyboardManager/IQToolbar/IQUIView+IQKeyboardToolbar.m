//
//  UIView+IQToolbar.m
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


#import "IQUIView+IQKeyboardToolbar.h"
#import "IQToolbar.h"
#import "IQTitleBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQBarButtonItem.h"
#import "IQKeyboardManager.h"
#import <UIKit/UIImage.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIAccessibility.h>
#import <objc/runtime.h>

/*UIKeyboardToolbar Category implementation*/
@implementation UIView (IQToolbarAddition)

-(void)setShouldHidePlaceholderText:(BOOL)shouldHidePlaceholderText
{
    objc_setAssociatedObject(self, @selector(shouldHidePlaceholderText), @(shouldHidePlaceholderText), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(placeholder)] && [self.inputAccessoryView respondsToSelector:@selector(setTitle:)])
    {
        UITextField *textField = (UITextField*)self;
        IQToolbar *toolbar = (IQToolbar*)[self inputAccessoryView];
        toolbar.title = textField.drawingPlaceholderText;
    }
}

-(BOOL)shouldHidePlaceholderText
{
    NSNumber *shouldHidePlaceholderText = objc_getAssociatedObject(self, @selector(shouldHidePlaceholderText));
    return [shouldHidePlaceholderText boolValue];
}

-(void)setPlaceholderText:(NSString*)placeholderText
{
    objc_setAssociatedObject(self, @selector(placeholderText), placeholderText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([self respondsToSelector:@selector(placeholder)] && [self.inputAccessoryView respondsToSelector:@selector(setTitle:)])
    {
        UITextField *textField = (UITextField*)self;
        IQToolbar *toolbar = (IQToolbar*)[self inputAccessoryView];
        toolbar.title = textField.drawingPlaceholderText;
    }
}

-(NSString*)placeholderText
{
    NSString *placeholderText = objc_getAssociatedObject(self, @selector(placeholderText));
    return placeholderText;
}

-(NSString*)drawingPlaceholderText
{
    if (self.shouldHidePlaceholderText)
    {
        return nil;
    }
    else if (self.placeholderText.length != 0)
    {
        return self.placeholderText;
    }
    else if ([self respondsToSelector:@selector(placeholder)])
    {
        return [(UITextField*)self placeholder];
    }
    else
    {
        return nil;
    }
}

-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
        UIView *selfObject = self;
        [invocation setArgument:&selfObject atIndex:2];
    }
    
    self.titleInvocation = invocation;
}

-(void)setTitleInvocation:(NSInvocation *)titleInvocation
{
    objc_setAssociatedObject(self, @selector(titleInvocation), titleInvocation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([self.inputAccessoryView isKindOfClass:[IQToolbar class]])
    {
        IQToolbar *toolbar = (IQToolbar*)[self inputAccessoryView];
        toolbar.titleInvocation = titleInvocation;
    }
}

-(NSInvocation *)titleInvocation
{
    return objc_getAssociatedObject(self, @selector(titleInvocation));
}


-(void)setCustomPreviousTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
        UIView *selfObject = self;
        [invocation setArgument:&selfObject atIndex:2];
    }
    
    self.previousInvocation = invocation;
}

-(void)setCustomNextTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
        UIView *selfObject = self;
        [invocation setArgument:&selfObject atIndex:2];
    }
    
    self.nextInvocation = invocation;
}

-(void)setCustomDoneTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
        UIView *selfObject = self;
        [invocation setArgument:&selfObject atIndex:2];
    }
    
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
    toolbar.doneImage = image;
    
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
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:target action:action];
    doneButton.accessibilityLabel = @"Toolbar Done Button";
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    toolbar.titleInvocation = self.titleInvocation;
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
    [self addRightButtonOnKeyboardWithImage:image target:target action:action titleText:title];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    toolbar.doneTitle = text;

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
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStyleDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to textFieldPhoneNumber keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
    toolbar.doneTitle = rightTitle;
    
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
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleDone target:target action:rightAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
    if (IQ_IS_IOS10_OR_GREATER)
    {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowUp" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowDown" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    else
    {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }

    //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
    if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
    {
        imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
        imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
    }
    
    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    prev.accessibilityLabel = @"Toolbar Previous Button";
    [items addObject:prev];

    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (IQ_IS_IOS10_OR_GREATER) {
        [fixed setWidth:6];
    } else {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    next.accessibilityLabel = @"Toolbar Next Button";
    [items addObject:next];

    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
	[items addObject:doneButton];
	
    //  Adding button to toolBar.
    [toolbar setItems:items];
	
    //  Setting toolbar to keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
    toolbar.doneImage = rightButtonImage;
    
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
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
    if (IQ_IS_IOS10_OR_GREATER) {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowUp" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowDown" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    } else {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    
    //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
    if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
    {
        imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
        imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
    }

    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    prev.accessibilityLabel = @"Toolbar Previous Button";
    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (IQ_IS_IOS10_OR_GREATER) {
        [fixed setWidth:6];
    } else {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    next.accessibilityLabel = @"Toolbar Next Button";
    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = [[IQBarButtonItem alloc] initWithImage:rightButtonImage style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
    doneButton.accessibilityLabel = @"Toolbar Done Button";
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonImage:rightButtonImage previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:title];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = [[IQToolbar alloc] init];
    toolbar.doneTitle = rightButtonTitle;

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
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
    if (IQ_IS_IOS10_OR_GREATER) {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowUp" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowDown" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    } else {
        imageLeftArrow = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        imageRightArrow = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
    }
    
    //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
    if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
    {
        imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
        imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
    }
    
    //Previous button
    IQBarButtonItem *prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
    prev.accessibilityLabel = @"Toolbar Previous Button";
    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (IQ_IS_IOS10_OR_GREATER) {
        [fixed setWidth:6];
    } else {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
    next.accessibilityLabel = @"Toolbar Next Button";
    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    IQTitleBarButtonItem *title = [[IQTitleBarButtonItem alloc] initWithTitle:self.shouldHidePlaceholderText?nil:titleText];
    [items addObject:title];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton =[[IQBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    toolbar.titleInvocation = self.titleInvocation;
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingPlaceholderText];
    
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
			IQBarButtonItem *prevButton = (IQBarButtonItem*)[inputAccessoryView items][0];
			IQBarButtonItem *nextButton = (IQBarButtonItem*)[inputAccessoryView items][2];
			
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
