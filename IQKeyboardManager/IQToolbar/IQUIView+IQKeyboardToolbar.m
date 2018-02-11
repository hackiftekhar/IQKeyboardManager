//
// IQUIView+IQKeyboardToolbar.m
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
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQKeyboardManager.h"

#import <objc/runtime.h>

#import <UIKit/UIImage.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIAccessibility.h>

/*UIKeyboardToolbar Category implementation*/
@implementation UIView (IQToolbarAddition)

-(IQToolbar *)keyboardToolbar
{
    IQToolbar *keyboardToolbar = nil;
    if ([[self inputAccessoryView] isKindOfClass:[IQToolbar class]])
    {
        keyboardToolbar = [self inputAccessoryView];
    }
    else
    {
        keyboardToolbar = objc_getAssociatedObject(self, @selector(keyboardToolbar));
        
        if (keyboardToolbar == nil)
        {
            keyboardToolbar = [[IQToolbar alloc] init];
            
            objc_setAssociatedObject(self, @selector(keyboardToolbar), keyboardToolbar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return keyboardToolbar;
}

-(void)setShouldHideToolbarPlaceholder:(BOOL)shouldHideToolbarPlaceholder
{
    objc_setAssociatedObject(self, @selector(shouldHideToolbarPlaceholder), @(shouldHideToolbarPlaceholder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
}

-(BOOL)shouldHideToolbarPlaceholder
{
    NSNumber *shouldHideToolbarPlaceholder = objc_getAssociatedObject(self, @selector(shouldHideToolbarPlaceholder));
    return [shouldHideToolbarPlaceholder boolValue];
}

-(void)setShouldHidePlaceholderText:(BOOL)shouldHidePlaceholderText
{
    [self setShouldHideToolbarPlaceholder:shouldHidePlaceholderText];
}

-(BOOL)shouldHidePlaceholderText
{
    return [self shouldHideToolbarPlaceholder];
}

-(void)setToolbarPlaceholder:(NSString *)toolbarPlaceholder
{
    objc_setAssociatedObject(self, @selector(toolbarPlaceholder), toolbarPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.keyboardToolbar.titleBarButton.title = self.drawingToolbarPlaceholder;
}

-(NSString *)toolbarPlaceholder
{
    NSString *toolbarPlaceholder = objc_getAssociatedObject(self, @selector(toolbarPlaceholder));
    return toolbarPlaceholder;
}

-(void)setPlaceholderText:(NSString*)placeholderText
{
    [self setToolbarPlaceholder:placeholderText];
}

-(NSString*)placeholderText
{
    return [self toolbarPlaceholder];
}

-(NSString *)drawingToolbarPlaceholder
{
    if (self.shouldHideToolbarPlaceholder)
    {
        return nil;
    }
    else if (self.toolbarPlaceholder.length != 0)
    {
        return self.toolbarPlaceholder;
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

-(NSString*)drawingPlaceholderText
{
    return [self drawingToolbarPlaceholder];
}

#pragma mark - Private helper

+(IQBarButtonItem*)flexibleBarButtonItem
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
    IQToolbar *toolbar = self.keyboardToolbar;
    
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];

    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton.title = nil;
        doneButton.image = image;
        doneButton.target = target;
        doneButton.action = action;
    }
    else
    {
        doneButton = [[IQBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:target action:action];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }
    
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
    [self addRightButtonOnKeyboardWithImage:image target:target action:action titleText:title];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    //  If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for keyboard
    IQToolbar *toolbar = self.keyboardToolbar;

    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
	NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];

    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton.title = text;
        doneButton.image = nil;
        doneButton.target = target;
        doneButton.action = action;
    }
    else
    {
        doneButton =[[IQBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStyleDone target:target action:action];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }

    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
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
    IQToolbar *toolbar = self.keyboardToolbar;

    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
 	
	NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];

    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];

    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }
    else
    {
        doneButton.target = target;
        doneButton.action = action;
    }
    
    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
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
    IQToolbar *toolbar = self.keyboardToolbar;
    
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    //Left button
    IQBarButtonItem *cancelButton = toolbar.previousBarButton;
    if (cancelButton.isSystemItem == NO)
    {
        cancelButton.title = leftTitle;
        cancelButton.image = nil;
        cancelButton.target = target;
        cancelButton.action = leftAction;
    }
    else
    {
        cancelButton = [[IQBarButtonItem alloc] initWithTitle:leftTitle style:UIBarButtonItemStylePlain target:target action:leftAction];
        cancelButton.invocation = toolbar.previousBarButton.invocation;
        cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
        toolbar.previousBarButton = cancelButton;
    }

    [items addObject:cancelButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton.title = rightTitle;
        doneButton.image = nil;
        doneButton.target = target;
        doneButton.action = rightAction;
    }
    else
    {
        doneButton =[[IQBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleDone target:target action:rightAction];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }

    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
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
    IQToolbar *toolbar = self.keyboardToolbar;
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    //Cancel button
    IQBarButtonItem *cancelButton = toolbar.previousBarButton;
    if (cancelButton.isSystemItem == NO)
    {
        cancelButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:target action:cancelAction];
        cancelButton.invocation = toolbar.previousBarButton.invocation;
        cancelButton.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
        toolbar.previousBarButton = cancelButton;
    }
    else
    {
        cancelButton.target = target;
        cancelButton.action = cancelAction;
    }

    [items addObject:cancelButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }
    else
    {
        doneButton.target = target;
        doneButton.action = doneAction;
    }

    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
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
    IQToolbar *toolbar = self.keyboardToolbar;
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
 
	NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
	
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
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
#ifdef __IPHONE_11_0
    if (@available(iOS 9.0, *)) {
#endif
        if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
        {
            imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
            imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
        }
#ifdef __IPHONE_11_0
    }
#endif
    
    //Previous button
    IQBarButtonItem *prev = toolbar.previousBarButton;
    if (prev.isSystemItem == NO)
    {
        prev.title = nil;
        prev.image = imageLeftArrow;
        prev.target = target;
        prev.action = previousAction;
    }
    else
    {
        prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
        prev.invocation = toolbar.previousBarButton.invocation;
        prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
        toolbar.previousBarButton = prev;
    }
    
    [items addObject:prev];

    //Fixed space
    IQBarButtonItem *fixed = toolbar.fixedSpaceBarButton;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
    {
        [fixed setWidth:6];
    }
    else
    {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = toolbar.nextBarButton;
    if (next.isSystemItem == NO)
    {
        next.title = nil;
        next.image = imageRightArrow;
        next.target = target;
        next.action = nextAction;
    }
    else
    {
        next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
        next.invocation = toolbar.nextBarButton.invocation;
        next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
        toolbar.nextBarButton = next;
    }

    [items addObject:next];

    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Done button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton =[[IQBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:doneAction];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }
    else
    {
        doneButton.target = target;
        doneButton.action = doneAction;
    }

    [items addObject:doneButton];
	
    //  Adding button to toolBar.
    [toolbar setItems:items];
	
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
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
    IQToolbar *toolbar = self.keyboardToolbar;
    
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
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
#ifdef __IPHONE_11_0
    if (@available(iOS 9.0, *)) {
#endif
        if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
        {
            imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
            imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
        }
#ifdef __IPHONE_11_0
    }
#endif

    //Previous button
    IQBarButtonItem *prev = toolbar.previousBarButton;
    if (prev.isSystemItem == NO)
    {
        prev.title = nil;
        prev.image = imageLeftArrow;
        prev.target = target;
        prev.action = previousAction;
    }
    else
    {
        prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
        prev.invocation = toolbar.previousBarButton.invocation;
        prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
        toolbar.previousBarButton = prev;
    }

    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed = toolbar.fixedSpaceBarButton;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
    {
        [fixed setWidth:6];
    }
    else
    {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = toolbar.nextBarButton;
    if (next.isSystemItem == NO)
    {
        next.title = nil;
        next.image = imageRightArrow;
        next.target = target;
        next.action = nextAction;
    }
    else
    {
        next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
        next.invocation = toolbar.nextBarButton.invocation;
        next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
        toolbar.nextBarButton = next;
    }

    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton.title = nil;
        doneButton.image = rightButtonImage;
        doneButton.target = target;
        doneButton.action = rightButtonAction;
    }
    else
    {
        doneButton = [[IQBarButtonItem alloc] initWithImage:rightButtonImage style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }

    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonImage:rightButtonImage previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:title];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = self.keyboardToolbar;

    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceAlert: toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    // Get the top level "bundle" which may actually be the framework
    NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
    
    // Check to see if the resource bundle exists inside the top level bundle
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
    
    if (resourcesBundle == nil) {
        resourcesBundle = mainBundle;
    }
    
    UIImage *imageLeftArrow = nil;
    UIImage *imageRightArrow = nil;
    
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
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
#ifdef __IPHONE_11_0
    if (@available(iOS 9.0, *)) {
#endif
        if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
        {
            imageLeftArrow = [imageLeftArrow imageFlippedForRightToLeftLayoutDirection];
            imageRightArrow = [imageRightArrow imageFlippedForRightToLeftLayoutDirection];
        }
#ifdef __IPHONE_11_0
    }
#endif
    
    //Previous button
    IQBarButtonItem *prev = toolbar.previousBarButton;
    if (prev.isSystemItem == NO)
    {
        prev.title = nil;
        prev.image = imageLeftArrow;
        prev.target = target;
        prev.action = previousAction;
    }
    else
    {
        prev = [[IQBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:target action:previousAction];
        prev.invocation = toolbar.previousBarButton.invocation;
        prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
        toolbar.previousBarButton = prev;
    }
    [items addObject:prev];
    
    //Fixed space
    IQBarButtonItem *fixed = toolbar.fixedSpaceBarButton;
            
#ifdef __IPHONE_11_0
    if (@available(iOS 10.0, *))
#else
    if (IQ_IS_IOS10_OR_GREATER)
#endif
    {
        [fixed setWidth:6];
    }
    else
    {
        [fixed setWidth:20];
    }
    [items addObject:fixed];
    
    //Next button
    IQBarButtonItem *next = toolbar.nextBarButton;
    if (next.isSystemItem == NO)
    {
        next.title = nil;
        next.image = imageRightArrow;
        next.target = target;
        next.action = nextAction;
    }
    else
    {
        next = [[IQBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:target action:nextAction];
        next.invocation = toolbar.nextBarButton.invocation;
        next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
        toolbar.nextBarButton = next;
    }
    [items addObject:next];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Title button
    toolbar.titleBarButton.title = self.shouldHideToolbarPlaceholder?nil:titleText;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {}
    else
#endif
    {
        toolbar.titleBarButton.customView.frame = CGRectZero;
    }
    [items addObject:toolbar.titleBarButton];
    
    //Flexible space
    [items addObject:[[self class] flexibleBarButtonItem]];
    
    //Right button
    IQBarButtonItem *doneButton = toolbar.doneBarButton;
    if (doneButton.isSystemItem == NO)
    {
        doneButton.title = rightButtonTitle;
        doneButton.image = nil;
        doneButton.target = target;
        doneButton.action = rightButtonAction;
    }
    else
    {
        doneButton =[[IQBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:target action:rightButtonAction];
        doneButton.invocation = toolbar.doneBarButton.invocation;
        doneButton.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
        toolbar.doneBarButton = doneButton;
    }

    [items addObject:doneButton];
    
    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    NSString *title = nil;
    
    if (shouldShowPlaceholder)
        title = [self drawingToolbarPlaceholder];
    
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:title];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:nil];
}

@end
