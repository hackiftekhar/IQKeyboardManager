//
//  IQKeyboardReturnKeyHandler.m
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-14 Iftekhar Qurashi.
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

#import "IQUIView+Hierarchy.h"
#import "IQNSArray+Sort.h"

#import <Foundation/NSSet.h>

#import <UIKit/UIViewController.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITableView.h>

NSString *const kIQTextField                =   @"kIQTextField";
NSString *const kIQTextFieldDelegate        =   @"kIQTextFieldDelegate";
NSString *const kIQTextFieldReturnKeyType   =   @"kIQTextFieldReturnKeyType";


@interface IQKeyboardReturnKeyHandler ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation IQKeyboardReturnKeyHandler
{
    NSMutableSet *textFieldInfoCache;
}

-(id)initWithViewController:(UIViewController*)controller
{
    self = [super init];
    
    if (self)
    {
        textFieldInfoCache = [[NSMutableSet alloc] init];
        [self addResponderFromView:controller.view];
    }
    
    return self;
}

-(NSDictionary*)textFieldCachedInfo:(UITextField*)textField
{
    for (NSDictionary *infoDict in textFieldInfoCache)
        if ([infoDict objectForKey:kIQTextField] == textField)  return infoDict;
    
    return nil;
}

#pragma mark - Add/Remove TextFields
-(void)addResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UITextField *textField in textFields)  [self addTextFieldView:textField];
}

-(void)removeResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UITextField *textField in textFields)  [self removeTextFieldView:textField];
}

-(void)removeTextFieldView:(UITextField*)textField
{
    NSDictionary *dict = [self textFieldCachedInfo:textField];
    
    if (dict)
    {
        textField.keyboardType = [[dict objectForKey:kIQTextFieldReturnKeyType] integerValue];
        textField.delegate = [dict objectForKey:kIQTextFieldDelegate];
        [textFieldInfoCache removeObject:textField];
    }
}

-(void)addTextFieldView:(UITextField*)textField
{
    NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc] init];
    
    [dictInfo setObject:textField forKey:kIQTextField];
    [dictInfo setObject:[NSNumber numberWithInteger:[textField returnKeyType]] forKey:kIQTextFieldReturnKeyType];
    if (textField.delegate) [dictInfo setObject:textField.delegate forKey:kIQTextFieldDelegate];
    
    //Adding return key as Next
    {
        UITableView *tableView = [textField superTableView];
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds, Otherwise fetching all the siblings.
        NSArray *textFields = (tableView)   ?   [tableView deepResponderViews]  :   [textField responderSiblings];
        
        //If needs to sort it by tag
        if (_toolbarManageBehaviour == IQAutoToolbarByTag)  textFields = [textFields sortedArrayByTag];
        
        //If it's the last textField in responder view, else next
        textField.returnKeyType = ([textFields lastObject] == textField)    ?   self.lastTextFieldReturnKeyType :   UIReturnKeyNext;
    }
    
    [textField setDelegate:self];
    [textFieldInfoCache addObject:dictInfo];
}

#pragma mark - Overriding lastTextFieldReturnKeyType
-(void)setLastTextFieldReturnKeyType:(UIReturnKeyType)lastTextFieldReturnKeyType
{
    _lastTextFieldReturnKeyType = lastTextFieldReturnKeyType;
    
    for (NSDictionary *infoDict in textFieldInfoCache)
    {
        UITextField *textField = [infoDict objectForKey:kIQTextField];

        UITableView *tableView = [textField superTableView];
        
        //If there is a tableView in view's hierarchy, then fetching all it's subview that responds, Otherwise fetching all the siblings.
        NSArray *textFields = (tableView)   ?   [tableView deepResponderViews]  :   [textField responderSiblings];
        
        //If needs to sort it by tag
        if (_toolbarManageBehaviour == IQAutoToolbarByTag)  textFields = [textFields sortedArrayByTag];
        
        //If it's the last textField in responder view, else next
        textField.returnKeyType = ([textFields lastObject] == textField)    ?   self.lastTextFieldReturnKeyType :   UIReturnKeyNext;
    }
}

#pragma mark - Goto next or Resign.

-(void)goToNextResponderOrResign:(UIView*)textField
{
    UITableView *tableView = [textField superTableView];
    
    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds, Otherwise fetching all the siblings.
    NSArray *textFields = (tableView)   ?   [tableView deepResponderViews]  :   [textField responderSiblings];
    
    //If needs to sort it by tag
    if (_toolbarManageBehaviour == IQAutoToolbarByTag)  textFields = [textFields sortedArrayByTag];
    
    if ([textFields containsObject:textField])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:textField];
        
        //If it is not last textField. then it's next object becomeFirstResponder.
        (index < textFields.count-1) ?   [[textFields objectAtIndex:index+1] becomeFirstResponder]  :   [textField resignFirstResponder];
    }
}

#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goToNextResponderOrResign:textField];
    
    return YES;
}

#pragma mark - TextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self goToNextResponderOrResign:textView];

        return NO;
    }
    
    return YES;
}

-(void)dealloc
{
    for (NSDictionary *dict in textFieldInfoCache)
    {
        UITextField *textField  = [dict objectForKey:kIQTextField];
        textField.keyboardType  = [[dict objectForKey:kIQTextFieldReturnKeyType] integerValue];
        textField.delegate      = [dict objectForKey:kIQTextFieldDelegate];
    }

    [textFieldInfoCache removeAllObjects];
}

@end
