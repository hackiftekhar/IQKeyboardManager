//
// IQKeyboardReturnKeyHandler.m
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

#import <UIKit/UIKit.h>

#import "IQKeyboardReturnKeyHandler.h"
#import "IQKeyboardManager.h"
#import "IQUIView+Hierarchy.h"
#import "IQNSArray+Sort.h"

NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@interface IQTextFieldViewInfoModal : NSObject

@property(nullable, nonatomic, weak) UIView *textFieldView;
@property(nullable, nonatomic, weak) id<UITextFieldDelegate> textFieldDelegate;
@property(nullable, nonatomic, weak) id<UITextViewDelegate> textViewDelegate;
@property(nonatomic) UIReturnKeyType originalReturnKeyType;

@end

NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@implementation IQTextFieldViewInfoModal

-(instancetype)initWithTextFieldView:(UIView*)textFieldView textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate textViewDelegate:(id<UITextViewDelegate>)textViewDelegate originalReturnKey:(UIReturnKeyType)returnKeyType
{
    self = [super init];
    
    if (self)
    {
        _textFieldView = textFieldView;
        _textFieldDelegate = textFieldDelegate;
        _textViewDelegate = textViewDelegate;
        _originalReturnKeyType = returnKeyType;
    }
    
    return self;
}

@end


NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@interface IQKeyboardReturnKeyHandler ()<UITextFieldDelegate,UITextViewDelegate>

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField;

@end

NS_EXTENSION_UNAVAILABLE_IOS("Unavailable in extension")
@implementation IQKeyboardReturnKeyHandler
{
    NSMutableSet<IQTextFieldViewInfoModal*> *textFieldInfoCache;
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

-(IQTextFieldViewInfoModal*)textFieldViewCachedInfo:(UIView*)textField
{
    for (IQTextFieldViewInfoModal *model in textFieldInfoCache)
        if (model.textFieldView == textField)  return model;

    return nil;
}

#pragma mark - Add/Remove TextFields
-(void)addResponderFromView:(UIView*)view
{
    NSArray<UIView*> *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)  [self addTextFieldView:textField];
}

-(void)removeResponderFromView:(UIView*)view
{
    NSArray<UIView*> *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)  [self removeTextFieldView:textField];
}

-(void)removeTextFieldView:(UIView*)view
{
    IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:view];

    if (model)
    {
        UITextField *textField = (UITextField*)view;

        if ([view respondsToSelector:@selector(setReturnKeyType:)])
        {
            textField.returnKeyType = model.originalReturnKeyType;
        }

        if ([view respondsToSelector:@selector(setDelegate:)])
        {
            textField.delegate = model.textFieldDelegate;
        }
        
        [textFieldInfoCache removeObject:model];
    }
}

-(void)addTextFieldView:(UIView*)view
{
    IQTextFieldViewInfoModal *model = [[IQTextFieldViewInfoModal alloc] initWithTextFieldView:view textFieldDelegate:nil textViewDelegate:nil originalReturnKey:UIReturnKeyDefault];
    
    UITextField *textField = (UITextField*)view;

    if ([view respondsToSelector:@selector(setReturnKeyType:)])
    {
        model.originalReturnKeyType = textField.returnKeyType;
    }

    if ([view respondsToSelector:@selector(setDelegate:)])
    {
        model.textFieldDelegate = textField.delegate;
        [textField setDelegate:self];
    }

    [textFieldInfoCache addObject:model];
}

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
    for (Class consideredClass in [[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses])
    {
        superConsideredView = [textField superviewOfClassType:consideredClass];
        
        if (superConsideredView)
            break;
    }

    NSArray<UIView*> *textFields = nil;

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
        
        if (superConsideredView)
            break;
    }
    
    NSArray<UIView*> *textFields = nil;
    
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [delegate textFieldDidEndEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)])
        [delegate textFieldDidEndEditing:textField reason:reason];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    else
        return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
- (UIMenu *)textField:(UITextField *)textField editMenuForCharactersInRange:(NSRange)range suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions NS_AVAILABLE_IOS(16_0);
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }

    if ([delegate respondsToSelector:@selector(textField:editMenuForCharactersInRange:suggestedActions:)])
        return [delegate textField:textField editMenuForCharactersInRange:range suggestedActions:suggestedActions];
    else
        return nil;
}

- (void)textField:(UITextField *)textField willPresentEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator NS_AVAILABLE_IOS(16_0);
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }

    if ([delegate respondsToSelector:@selector(textField:willPresentEditMenuWithAnimator:)])
        [delegate textField:textField willPresentEditMenuWithAnimator:animator];
}

- (void)textField:(UITextField *)textField willDismissEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator NS_AVAILABLE_IOS(16_0);
{
    id<UITextFieldDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
    }

    if ([delegate respondsToSelector:@selector(textField:willDismissEditMenuWithAnimator:)])
        [delegate textField:textField willDismissEditMenuWithAnimator:animator];
}
#endif

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textField];
        delegate = model.textFieldDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [delegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
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
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChange:)])
        [delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [delegate textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];

    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
-(UIMenu *)textView:(UITextView *)textView editMenuForTextInRange:(NSRange)range suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions  NS_AVAILABLE_IOS(16_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:editMenuForTextInRange:suggestedActions:)])
        return [delegate textView:textView editMenuForTextInRange:range suggestedActions:suggestedActions];
    else
        return nil;
}

- (void)textView:(UITextView *)textView willPresentEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator  NS_AVAILABLE_IOS(16_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:willPresentEditMenuWithAnimator:)])
        [delegate textView:textView willPresentEditMenuWithAnimator:animator];
}

- (void)textView:(UITextView *)textView willDismissEditMenuWithAnimator:(id<UIEditMenuInteractionAnimating>)animator  NS_AVAILABLE_IOS(16_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:willDismissEditMenuWithAnimator:)])
        [delegate textView:textView willDismissEditMenuWithAnimator:animator];
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 170000

- (nullable UIAction *)textView:(UITextView *)textView primaryActionForTextItem:(UITextItem *)textItem defaultAction:(UIAction *)defaultAction NS_AVAILABLE_IOS(17_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:primaryActionForTextItem:defaultAction:)])
        return [delegate textView:textView primaryActionForTextItem:textItem defaultAction:defaultAction];
    else
        return nil;
}

- (nullable UITextItemMenuConfiguration *)textView:(UITextView *)textView menuConfigurationForTextItem:(UITextItem *)textItem defaultMenu:(UIMenu *)defaultMenu NS_AVAILABLE_IOS(17_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:menuConfigurationForTextItem:defaultMenu:)])
        return [delegate textView:textView menuConfigurationForTextItem:textItem defaultMenu:defaultMenu];
    else
        return nil;
}

- (void)textView:(UITextView *)textView textItemMenuWillDisplayForTextItem:(UITextItem *)textItem animator:(id<UIContextMenuInteractionAnimating>)animator NS_AVAILABLE_IOS(17_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:textItemMenuWillDisplayForTextItem:animator:)])
        [delegate textView:textView textItemMenuWillDisplayForTextItem:textItem animator:animator];
}

- (void)textView:(UITextView *)textView textItemMenuWillEndForTextItem:(UITextItem *)textItem animator:(id<UIContextMenuInteractionAnimating>)animator NS_AVAILABLE_IOS(17_0);
{
    id<UITextViewDelegate> delegate = self.delegate;

    if (delegate == nil)
    {
        IQTextFieldViewInfoModal *model = [self textFieldViewCachedInfo:textView];
        delegate = model.textViewDelegate;
    }

    if ([delegate respondsToSelector:@selector(textView:textItemMenuWillEndForTextItem:animator:)])
        [delegate textView:textView textItemMenuWillEndForTextItem:textItem animator:animator];
}

#endif

-(void)dealloc
{
    for (IQTextFieldViewInfoModal *model in textFieldInfoCache)
    {
        UITextField *textField = (UITextField*)model.textFieldView;

        if ([textField respondsToSelector:@selector(setReturnKeyType:)])
        {
            textField.returnKeyType = model.originalReturnKeyType;
        }

        if ([textField respondsToSelector:@selector(setDelegate:)])
        {
            textField.delegate = model.textFieldDelegate;
        }
    }

    [textFieldInfoCache removeAllObjects];
}

@end
