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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "IQUIView+IQKeyboardToolbar.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import "IQKeyboardManager.h"


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

+(UIImage*)keyboardLeftImage
{
    static UIImage *keyboardLeftImage = nil;
    
    if (keyboardLeftImage == nil)
    {
        NSString *base64Data = @"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";
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        keyboardLeftImage = [UIImage imageWithData:data scale:3];

        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        keyboardLeftImage = [keyboardLeftImage imageFlippedForRightToLeftLayoutDirection];
    }
    
    return keyboardLeftImage;
}

+(UIImage*)keyboardRightImage
{
    static UIImage *keyboardRightImage = nil;
    
    if (keyboardRightImage == nil)
    {
        NSString *base64Data = @"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";
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        keyboardRightImage = [UIImage imageWithData:data scale:3];

        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        keyboardRightImage = [keyboardRightImage imageFlippedForRightToLeftLayoutDirection];
    }
    
    return keyboardRightImage;
}

+(UIImage*)keyboardUpImage
{
    static UIImage *keyboardUpImage = nil;
    
    if (keyboardUpImage == nil)
    {
        NSString *base64Data = @"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";
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        keyboardUpImage = [UIImage imageWithData:data scale:3];

        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        keyboardUpImage = [keyboardUpImage imageFlippedForRightToLeftLayoutDirection];
    }
    
    return keyboardUpImage;
}

+(UIImage*)keyboardDownImage
{
    static UIImage *keyboardDownImage = nil;
    
    if (keyboardDownImage == nil)
    {
        NSString *base64Data = @"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";
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        keyboardDownImage = [UIImage imageWithData:data scale:3];
        
        //Support for RTL languages like Arabic, Persia etc... (Bug ID: #448)
        keyboardDownImage = [keyboardDownImage imageFlippedForRightToLeftLayoutDirection];
    }
    
    return keyboardDownImage;
}

+(UIImage*)keyboardPreviousImage
{
    if (@available(iOS 10.0, *))
    {
        return [UIImage keyboardUpImage];
    }
    else
    {
        return [UIImage keyboardLeftImage];
    }
}

+(UIImage*)keyboardNextImage
{
    if (@available(iOS 10.0, *))
    {
        return [UIImage keyboardDownImage];
    }
    else
    {
        return [UIImage keyboardRightImage];
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
            prev.accessibilityLabel = previousBarButtonConfiguration.accessibilityLabel;
            prev.accessibilityIdentifier = prev.accessibilityLabel;
            prev.image = previousBarButtonConfiguration.image;
            prev.target = target;
            prev.action = previousBarButtonConfiguration.action;
        }
        else if (previousBarButtonConfiguration.image)
        {
            prev = [[IQBarButtonItem alloc] initWithImage:previousBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = previousBarButtonConfiguration.accessibilityLabel;
            prev.accessibilityIdentifier = prev.accessibilityLabel;
            prev.enabled = toolbar.previousBarButton.enabled;
            prev.tag = toolbar.previousBarButton.tag;
            toolbar.previousBarButton = prev;
        }
        else if (previousBarButtonConfiguration.title)
        {
            prev = [[IQBarButtonItem alloc] initWithTitle:previousBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = previousBarButtonConfiguration.accessibilityLabel;
            prev.accessibilityIdentifier = prev.accessibilityLabel;
            prev.enabled = toolbar.previousBarButton.enabled;
            prev.tag = toolbar.previousBarButton.tag;
            toolbar.previousBarButton = prev;
        }
        else
        {
            prev = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:previousBarButtonConfiguration.barButtonSystemItem target:target action:previousBarButtonConfiguration.action];
            prev.invocation = toolbar.previousBarButton.invocation;
            prev.accessibilityLabel = previousBarButtonConfiguration.accessibilityLabel;
            prev.accessibilityIdentifier = prev.accessibilityLabel;
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
            next.accessibilityLabel = nextBarButtonConfiguration.accessibilityLabel;
            next.accessibilityIdentifier = next.accessibilityLabel;
            next.image = nextBarButtonConfiguration.image;
            next.target = target;
            next.action = nextBarButtonConfiguration.action;
        }
        else if (nextBarButtonConfiguration.image)
        {
            next = [[IQBarButtonItem alloc] initWithImage:nextBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = nextBarButtonConfiguration.accessibilityLabel;
            next.accessibilityIdentifier = next.accessibilityLabel;
            next.enabled = toolbar.nextBarButton.enabled;
            next.tag = toolbar.nextBarButton.tag;
            toolbar.nextBarButton = next;
        }
        else if (nextBarButtonConfiguration.title)
        {
            next = [[IQBarButtonItem alloc] initWithTitle:nextBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = nextBarButtonConfiguration.accessibilityLabel;
            next.accessibilityIdentifier = next.accessibilityLabel;
            next.enabled = toolbar.nextBarButton.enabled;
            next.tag = toolbar.nextBarButton.tag;
            toolbar.nextBarButton = next;
        }
        else
        {
            next = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:nextBarButtonConfiguration.barButtonSystemItem target:target action:nextBarButtonConfiguration.action];
            next.invocation = toolbar.nextBarButton.invocation;
            next.accessibilityLabel = nextBarButtonConfiguration.accessibilityLabel;
            next.accessibilityIdentifier = next.accessibilityLabel;
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
            done.accessibilityLabel = rightBarButtonConfiguration.accessibilityLabel;
            done.accessibilityIdentifier = done.accessibilityLabel;
            done.image = rightBarButtonConfiguration.image;
            done.target = target;
            done.action = rightBarButtonConfiguration.action;
        }
        else if (rightBarButtonConfiguration.image)
        {
            done = [[IQBarButtonItem alloc] initWithImage:rightBarButtonConfiguration.image style:UIBarButtonItemStylePlain target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = rightBarButtonConfiguration.accessibilityLabel;
            done.accessibilityIdentifier = done.accessibilityLabel;
            done.enabled = toolbar.doneBarButton.enabled;
            done.tag = toolbar.doneBarButton.tag;
            toolbar.doneBarButton = done;
        }
        else if (rightBarButtonConfiguration.title)
        {
            done = [[IQBarButtonItem alloc] initWithTitle:rightBarButtonConfiguration.title style:UIBarButtonItemStylePlain target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = rightBarButtonConfiguration.accessibilityLabel;
            done.accessibilityIdentifier = done.accessibilityLabel;
            done.enabled = toolbar.doneBarButton.enabled;
            done.tag = toolbar.doneBarButton.tag;
            toolbar.doneBarButton = done;
        }
        else
        {
            done = [[IQBarButtonItem alloc] initWithBarButtonSystemItem:rightBarButtonConfiguration.barButtonSystemItem target:target action:rightBarButtonConfiguration.action];
            done.invocation = toolbar.doneBarButton.invocation;
            done.accessibilityLabel = rightBarButtonConfiguration.accessibilityLabel;
            done.accessibilityIdentifier = done.accessibilityLabel;
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
