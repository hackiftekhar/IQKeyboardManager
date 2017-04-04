//
//  IQKeyboardReturnKeyHandler.m
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

#import "IQKeyboardReturnKeyHandler.h"
#import "IQKeyboardManager.h"
#import "IQUIView+Hierarchy.h"
#import "IQNSArray+Sort.h"

#import <Foundation/NSSet.h>

#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIViewController.h>

NSString *const kIQTextField                =   @"kIQTextField";
NSString *const kIQTextFieldDelegate        =   @"kIQTextFieldDelegate";
NSString *const kIQTextFieldReturnKeyType   =   @"kIQTextFieldReturnKeyType";


@interface IQKeyboardReturnKeyHandler ()<UITextFieldDelegate,UITextViewDelegate>

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField;

@end

@implementation IQKeyboardReturnKeyHandler
{
    NSMutableSet *textFieldInfoCache;
}

@synthesize lastTextFieldReturnKeyType = _lastTextFieldReturnKeyType;
@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [self initWithViewController:nil];
    return self;
}

-(instancetype)initWithViewController:(nullable UIViewController*)controller
{
    self = [super init];
    
    if (self)
    {
        textFieldInfoCache = [[NSMutableSet alloc] init];
        
        if (controller.view)
        {
            [self addResponderFromView:controller.view];
        }
    }
    
    return self;
}

-(NSDictionary*)textFieldViewCachedInfo:(UIView*)textField
{
    for (NSDictionary *infoDict in textFieldInfoCache)
        if (infoDict[kIQTextField] == textField)  return infoDict;
    
    return nil;
}

#pragma mark - Add/Remove TextFields
-(void)addResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)  [self addTextFieldView:textField];
}

-(void)removeResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)  [self removeTextFieldView:textField];
}

-(void)removeTextFieldView:(UIView*)view
{
    NSDictionary *dict = [self textFieldViewCachedInfo:view];
    
    if (dict)
    {
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            UITextField *textField = (UITextField*)view;
            textField.returnKeyType = (UIReturnKeyType)[dict[kIQTextFieldReturnKeyType] integerValue];
            textField.delegate = dict[kIQTextFieldDelegate];
        }
        [textFieldInfoCache removeObject:dict];
    }
}

-(void)addTextFieldView:(UIView*)view
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    dict[kIQTextField] = view;
    
    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
    {
        UITextField *textField = (UITextField*)view;
        dict[kIQTextFieldReturnKeyType] = @(textField.returnKeyType);
        if (textField.delegate) dict[kIQTextFieldDelegate] = textField.delegate;
        [textField setDelegate:self];
    }

    [textFieldInfoCache addObject:dict];
}

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
    for (Class consideredClass in [[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses])
    {
        superConsideredView = [textField superviewOfClassType:consideredClass];
        
        if (superConsideredView != nil)
            break;
    }

    NSArray *textFields = nil;

    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds. No sorting for tableView, it's by subView position.
    if (superConsideredView)  //     //   (Enhancement ID: #22)
    {
        textFields = [superConsideredView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [textField responderSiblings];
        
        //Sorting textFields according to behaviour
        switch ([[IQKeyboardManager sharedManager] toolbarManageBehaviour])
        {
                //If needs to sort it by tag
            case IQAutoToolbarByTag:
                textFields = [textFields sortedArrayByTag];
                break;
                
                //If needs to sort it by Position
            case IQAutoToolbarByPosition:
                textFields = [textFields sortedArrayByPosition];
                break;
                
            default:
                break;
        }
    }
    
    //If it's the last textField in responder view, else next
    [(UITextField*)textField setReturnKeyType:(([textFields lastObject] == textField)    ?   self.lastTextFieldReturnKeyType :   UIReturnKeyNext)];
}

#pragma mark - Goto next or Resign.

-(BOOL)goToNextResponderOrResign:(UIView*)textField
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
    for (Class consideredClass in [[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses])
    {
        superConsideredView = [textField superviewOfClassType:consideredClass];
        
        if (superConsideredView != nil)
            break;
    }
    
    NSArray *textFields = nil;
    
    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds. No sorting for tableView, it's by subView position.
    if (superConsideredView)  //     //   (Enhancement ID: #22)
    {
        textFields = [superConsideredView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [textField responderSiblings];
        
        //Sorting textFields according to behaviour
        switch ([[IQKeyboardManager sharedManager] toolbarManageBehaviour])
        {
                //If needs to sort it by tag
            case IQAutoToolbarByTag:
                textFields = [textFields sortedArrayByTag];
                break;
                
                //If needs to sort it by Position
            case IQAutoToolbarByPosition:
                textFields = [textFields sortedArrayByPosition];
                break;
                
            default:
                break;
        }
    }
        
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:textField];
    
    //If it is not last textField. then it's next object becomeFirstResponder.
    if (index != NSNotFound && index < textFields.count-1)
    {
        [textFields[index+1] becomeFirstResponder];
        return NO;
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [delegate textFieldShouldBeginEditing:textField];
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self updateReturnKeyTypeOnTextField:textField];

    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }

    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [delegate textFieldShouldEndEditing:textField];
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [delegate textFieldDidEndEditing:textField];
}

//Xcode8, compile validation
#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)])
        [delegate textFieldDidEndEditing:textField reason:reason];
}

#endif


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    else
        return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [delegate textFieldShouldClear:textField];
    else
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        BOOL shouldReturn = [delegate textFieldShouldReturn:textField];

        if (shouldReturn)
        {
            shouldReturn = [self goToNextResponderOrResign:textField];
        }
        
        return shouldReturn;
    }
    else
    {
        return [self goToNextResponderOrResign:textField];
    }
}


#pragma mark - TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [delegate textViewShouldBeginEditing:textView];
    else
        return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [delegate textViewShouldEndEditing:textView];
    else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateReturnKeyTypeOnTextField:textView];

    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [delegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    BOOL shouldReturn = YES;
    
    if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        shouldReturn = [delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (shouldReturn && [text isEqualToString:@"\n"])
    {
        shouldReturn = [self goToNextResponderOrResign:textView];
    }
    
    return shouldReturn;
}

- (void)textViewDidChange:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChange:)])
        [delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [delegate textViewDidChangeSelection:textView];
}

//Xcode8, compile validation
#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    else
        return YES;
}

#endif

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
#pragma clang diagnostic pop
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kIQTextFieldDelegate];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
#pragma clang diagnostic pop
    else
        return YES;
}

-(void)dealloc
{
    for (NSDictionary *dict in textFieldInfoCache)
    {
        UIView *view  = dict[kIQTextField];
        
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            UITextField *textField = (UITextField*)view;
            textField.returnKeyType  = (UIReturnKeyType)[dict[kIQTextFieldReturnKeyType] integerValue];
            textField.delegate      = dict[kIQTextFieldDelegate];
        }
    }

    [textFieldInfoCache removeAllObjects];
}

@end
