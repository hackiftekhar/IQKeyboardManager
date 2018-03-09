//
//  YYTextViewController.m
//  Demo
//
//  Created by IEMacBook01 on 21/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import "YYTextViewController.h"

@import IQKeyboardManager;
@import YYText;

@interface YYTextViewController ()<YYTextViewDelegate>

@end

@implementation YYTextViewController
{
    IBOutlet YYTextView *textView;
}

-(void)dealloc
{
    textView = nil;
}

+(void)initialize
{
    [super initialize];
    
    [[IQKeyboardManager sharedManager] registerTextFieldViewClass:[YYTextView class] didBeginEditingNotificationName:YYTextViewTextDidBeginEditingNotification didEndEditingNotificationName:YYTextViewTextDidEndEditingNotification];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    textView.placeholderText=@"This is placeholder text of YYTextView";
}

- (void)textViewDidBeginEditing:(YYTextView *)tv
{
    [tv reloadInputViews];
}

@end
