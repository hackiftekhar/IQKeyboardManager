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
#import <UIKit/UIScreen.h>
#import <UIKit/UIAccessibility.h>

@implementation IQBarButtonItemConfiguration

-(instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)barButtonSystemItem action:(SEL)action
{
    self = [super init];
    if (self) {
        _barButtonSystemItem = barButtonSystemItem;
        _action = action;
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)image action:(SEL)action
{
    self = [super init];
    if (self) {
        _image = image;
        _action = action;
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self) {
        _title = title;
        _action = action;
    }
    return self;
}

@end

@implementation UIImage (IQKeyboardToolbarNextPreviousImage)

+(UIImage*)keyboardPreviousiOS9Image
{
    static UIImage *keyboardPreviousiOS9Image = nil;
    
    if (keyboardPreviousiOS9Image == nil)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        keyboardPreviousiOS9Image = [UIImage imageNamed:@"IQButtonBarArrowLeft" inBundle:resourcesBundle compatibleWithTraitCollection:nil];;
        
        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        if (@available(iOS 9.0, *)) {
            if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            {
                keyboardPreviousiOS9Image = [keyboardPreviousiOS9Image imageFlippedForRightToLeftLayoutDirection];
            }
        }
    }
    
    return keyboardPreviousiOS9Image;
}

+(UIImage*)keyboardNextiOS9Image
{
    static UIImage *keyboardNextiOS9Image = nil;
    
    if (keyboardNextiOS9Image == nil)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        keyboardNextiOS9Image = [UIImage imageNamed:@"IQButtonBarArrowRight" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        
        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        if (@available(iOS 9.0, *)) {
            if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            {
                keyboardNextiOS9Image = [keyboardNextiOS9Image imageFlippedForRightToLeftLayoutDirection];
            }
        }
    }
    
    return keyboardNextiOS9Image;
}

+(UIImage*)keyboardPreviousiOS10Image
{
    static UIImage *keyboardPreviousiOS10Image = nil;
    
    if (keyboardPreviousiOS10Image == nil)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        keyboardPreviousiOS10Image = [UIImage imageNamed:@"IQButtonBarArrowUp" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        
        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        if (@available(iOS 9.0, *)) {
            if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            {
                keyboardPreviousiOS10Image = [keyboardPreviousiOS10Image imageFlippedForRightToLeftLayoutDirection];
            }
        }
    }
    
    return keyboardPreviousiOS10Image;
}

+(UIImage*)keyboardNextiOS10Image
{
    static UIImage *keyboardNextiOS10Image = nil;
    
    if (keyboardNextiOS10Image == nil)
    {
        // Get the top level "bundle" which may actually be the framework
        NSBundle *mainBundle = [NSBundle bundleForClass:[IQKeyboardManager class]];
        
        // Check to see if the resource bundle exists inside the top level bundle
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"IQKeyboardManager" ofType:@"bundle"]];
        
        if (resourcesBundle == nil) {
            resourcesBundle = mainBundle;
        }
        
        keyboardNextiOS10Image = [UIImage imageNamed:@"IQButtonBarArrowDown" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        
        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        if (@available(iOS 9.0, *)) {
            if ([UIImage instancesRespondToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)])
            {
                keyboardNextiOS10Image = [keyboardNextiOS10Image imageFlippedForRightToLeftLayoutDirection];
            }
        }
    }
    
    return keyboardNextiOS10Image;
}

+(UIImage*)keyboardPreviousImage
{
    if (@available(iOS 10.0, *))
    {
        return [UIImage keyboardPreviousiOS10Image];
    }
    else
    {
        return [UIImage keyboardPreviousiOS9Image];
    }
}

+(UIImage*)keyboardNextImage
{
    if (@available(iOS 10.0, *))
    {
        return [UIImage keyboardNextiOS10Image];
    }
    else
    {
        return [UIImage keyboardNextiOS9Image];
    }
}

@end


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
            CGRect frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44);

            keyboardToolbar = [[IQToolbar alloc] initWithFrame:frame];
            
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

#pragma mark - Common

- (void)addKeyboardToolbarWithTarget:(id)target titleText:(NSString*)titleText rightBarButtonConfiguration:(IQBarButtonItemConfiguration*)rightBarButtonConfiguration previousBarButtonConfiguration:(IQBarButtonItemConfiguration*)previousBarButtonConfiguration nextBarButtonConfiguration:(IQBarButtonItemConfiguration*)nextBarButtonConfiguration
{
    //If can't set InputAccessoryView. Then return
    if (![self respondsToSelector:@selector(setInputAccessoryView:)])    return;
    
    //  Creating a toolBar for phoneNumber keyboard
    IQToolbar *toolbar = self.keyboardToolbar;
    
    NSMutableArray<UIBarButtonItem*> *items = [[NSMutableArray alloc] init];
    
    if(previousBarButtonConfiguration)
    {
        IQBarButtonItem *prev = toolbar.previousBarButton;
        
        if (prev.isSystemItem == NO && (previousBarButtonConfiguration.image || previousBarButtonConfiguration.title))
        {
            prev.title = previousBarButtonConfiguration.title;
            prev.image = previousBarButtonConfiguration.image;
            prev.target = target;
            prev.action = previousBarButtonConfiguration.action;
        }
        else if (previousBarButtonConfiguration.image)
        {
            prev = [[IQBarButtonItem alloc] initWithImage:previousBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
            prev.enabled = toolbar.previousBarButton.enabled;
            prev.tag = toolbar.previousBarButton.tag;
            toolbar.previousBarButton = prev;
        }
        else if (previousBarButtonConfiguration.title)
        {
            prev = [[IQBarButtonItem alloc] initWithTitle:previousBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
            prev.enabled = toolbar.previousBarButton.enabled;
            prev.tag = toolbar.previousBarButton.tag;
            toolbar.previousBarButton = prev;
        }
        else
        {
            prev = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:previousBarButtonConfiguration.barButtonSystemItem target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = toolbar.previousBarButton.accessibilityLabel;
            prev.enabled = toolbar.previousBarButton.enabled;
            prev.tag = toolbar.previousBarButton.tag;
            toolbar.previousBarButton = prev;
        }
        
        [items addObject:prev];
    }
    
    if (previousBarButtonConfiguration != nil && nextBarButtonConfiguration != nil)
    {
        [items addObject:toolbar.fixedSpaceBarButton];
    }

    if(nextBarButtonConfiguration)
    {
        IQBarButtonItem *next = toolbar.nextBarButton;
        
        if (next.isSystemItem == NO && (nextBarButtonConfiguration.image || nextBarButtonConfiguration.title))
        {
            next.title = nextBarButtonConfiguration.title;
            next.image = nextBarButtonConfiguration.image;
            next.target = target;
            next.action = nextBarButtonConfiguration.action;
        }
        else if (nextBarButtonConfiguration.image)
        {
            next = [[IQBarButtonItem alloc] initWithImage:nextBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
            next.enabled = toolbar.nextBarButton.enabled;
            next.tag = toolbar.nextBarButton.tag;
            toolbar.nextBarButton = next;
        }
        else if (nextBarButtonConfiguration.title)
        {
            next = [[IQBarButtonItem alloc] initWithTitle:nextBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
            next.enabled = toolbar.nextBarButton.enabled;
            next.tag = toolbar.nextBarButton.tag;
            toolbar.nextBarButton = next;
        }
        else
        {
            next = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:nextBarButtonConfiguration.barButtonSystemItem target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = toolbar.nextBarButton.accessibilityLabel;
            next.enabled = toolbar.nextBarButton.enabled;
            next.tag = toolbar.nextBarButton.tag;
            toolbar.nextBarButton = next;
        }
        
        [items addObject:next];
    }
    
    //Title
    {
        //Flexible space
        [items addObject:[[self class] flexibleBarButtonItem]];
        
        //Title button
        toolbar.titleBarButton.title = titleText;
        if (@available(iOS 11.0, *)) {}
        else
        {
            toolbar.titleBarButton.customView.frame = CGRectZero;
        }
        [items addObject:toolbar.titleBarButton];
        
        //Flexible space
        [items addObject:[[self class] flexibleBarButtonItem]];
    }
    
    if(rightBarButtonConfiguration)
    {
        IQBarButtonItem *done = toolbar.doneBarButton;
        
        if (done.isSystemItem == NO && (rightBarButtonConfiguration.image || rightBarButtonConfiguration.title))
        {
            done.title = rightBarButtonConfiguration.title;
            done.image = rightBarButtonConfiguration.image;
            done.target = target;
            done.action = rightBarButtonConfiguration.action;
        }
        else if (rightBarButtonConfiguration.image)
        {
            done = [[IQBarButtonItem alloc] initWithImage:rightBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
            done.enabled = toolbar.doneBarButton.enabled;
            done.tag = toolbar.doneBarButton.tag;
            toolbar.doneBarButton = done;
        }
        else if (rightBarButtonConfiguration.title)
        {
            done = [[IQBarButtonItem alloc] initWithTitle:rightBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
            done.enabled = toolbar.doneBarButton.enabled;
            done.tag = toolbar.doneBarButton.tag;
            toolbar.doneBarButton = done;
        }
        else
        {
            done = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:rightBarButtonConfiguration.barButtonSystemItem target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = toolbar.doneBarButton.accessibilityLabel;
            done.enabled = toolbar.doneBarButton.enabled;
            done.tag = toolbar.doneBarButton.tag;
            toolbar.doneBarButton = done;
        }
        
        [items addObject:done];
    }

    //  Adding button to toolBar.
    [toolbar setItems:items];
    
    //  Setting toolbar to keyboard.
    [(UITextField*)self setInputAccessoryView:toolbar];

    
    if ([self respondsToSelector:@selector(keyboardAppearance)])
    {
        switch ([(UITextField*)self keyboardAppearance])
        {
            case UIKeyboardAppearanceDark:  toolbar.barStyle = UIBarStyleBlack;     break;
            default:                        toolbar.barStyle = UIBarStyleDefault;   break;
        }
    }
}

#pragma mark - Right

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action
{
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:nil];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addRightButtonOnKeyboardWithText:text target:target action:action titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addRightButtonOnKeyboardWithText:(NSString*)text target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:text action:action];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:nil nextBarButtonConfiguration:nil];
}


- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action
{
    [self addRightButtonOnKeyboardWithImage:image target:target action:action titleText:nil];
}

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addRightButtonOnKeyboardWithImage:image target:target action:action titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addRightButtonOnKeyboardWithImage:(UIImage*)image target:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:image action:action];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:nil nextBarButtonConfiguration:nil];
}


-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action
{
    [self addDoneOnKeyboardWithTarget:target action:action titleText:nil];
}

-(void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addDoneOnKeyboardWithTarget:target action:action titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addDoneOnKeyboardWithTarget:(id)target action:(SEL)action titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone action:action];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:nil nextBarButtonConfiguration:nil];
}


- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction
{
    [self addLeftRightOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle leftButtonAction:leftAction rightButtonAction:rightAction titleText:nil];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addLeftRightOnKeyboardWithTarget:target leftButtonTitle:leftTitle rightButtonTitle:rightTitle leftButtonAction:leftAction rightButtonAction:rightAction titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addLeftRightOnKeyboardWithTarget:(id)target leftButtonTitle:(NSString*)leftTitle rightButtonTitle:(NSString*)rightTitle leftButtonAction:(SEL)leftAction rightButtonAction:(SEL)rightAction titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *leftConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:leftTitle action:leftAction];
    
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:rightTitle action:rightAction];

    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:leftConfiguration nextBarButtonConfiguration:nil];
}


-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction
{
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:nil];
}

-(void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addCancelDoneOnKeyboardWithTarget:target cancelAction:cancelAction doneAction:doneAction titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addCancelDoneOnKeyboardWithTarget:(id)target cancelAction:(SEL)cancelAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *leftConfiguration = [[IQBarButtonItemConfiguration alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel action:cancelAction];
    
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone action:doneAction];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:leftConfiguration nextBarButtonConfiguration:nil];
}


-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:nil];
}

-(void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addPreviousNextDoneOnKeyboardWithTarget:target previousAction:previousAction nextAction:nextAction doneAction:doneAction titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addPreviousNextDoneOnKeyboardWithTarget:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *previousConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardPreviousImage] action:previousAction];
    
    IQBarButtonItemConfiguration *nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardNextImage] action:nextAction];
    
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone action:doneAction];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:previousConfiguration nextBarButtonConfiguration:nextConfiguration];
}


- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonImage:rightButtonImage previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:nil];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonImage:rightButtonImage previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonImage:(UIImage*)rightButtonImage previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *previousConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardPreviousImage] action:previousAction];
    
    IQBarButtonItemConfiguration *nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardNextImage] action:nextAction];
    
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:rightButtonImage action:rightButtonAction];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:previousConfiguration nextBarButtonConfiguration:nextConfiguration];
}


- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:nil];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder
{
    [self addPreviousNextRightOnKeyboardWithTarget:target rightButtonTitle:rightButtonTitle previousAction:previousAction nextAction:nextAction rightButtonAction:rightButtonAction titleText:(shouldShowPlaceholder?[self drawingToolbarPlaceholder]:nil)];
}

- (void)addPreviousNextRightOnKeyboardWithTarget:(id)target rightButtonTitle:(NSString*)rightButtonTitle previousAction:(SEL)previousAction nextAction:(SEL)nextAction rightButtonAction:(SEL)rightButtonAction titleText:(NSString*)titleText
{
    IQBarButtonItemConfiguration *previousConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardPreviousImage] action:previousAction];
    
    IQBarButtonItemConfiguration *nextConfiguration = [[IQBarButtonItemConfiguration alloc] initWithImage:[UIImage keyboardNextImage] action:nextAction];
    
    IQBarButtonItemConfiguration *rightConfiguration = [[IQBarButtonItemConfiguration alloc] initWithTitle:rightButtonTitle action:rightButtonAction];
    
    [self addKeyboardToolbarWithTarget:target titleText:titleText rightBarButtonConfiguration:rightConfiguration previousBarButtonConfiguration:previousConfiguration nextBarButtonConfiguration:nextConfiguration];
}


@end
