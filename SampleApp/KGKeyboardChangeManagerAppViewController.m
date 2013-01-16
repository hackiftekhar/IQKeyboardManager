//
//  KGKeyboardChangeManagerAppViewController.m
//  KGKeyboardChangeManagerApp
//
//  Created by David Keegan on 1/16/13.
//  Copyright (c) 2013 David Keegan. All rights reserved.
//

#import "KGKeyboardChangeManagerAppViewController.h"
#import "KGKeyboardChangeManager.h"

@interface KGKeyboardChangeManagerAppViewController()
@property (weak, nonatomic) UIView *keyboardFrameView;
@property (strong, nonatomic) id keyboardChangeIdentifier;
@property (strong, nonatomic) id keyboardOrientationIdentifier;
@end

@implementation KGKeyboardChangeManagerAppViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    UIView *appFrameView = [[UIView alloc] initWithFrame:self.view.bounds];
    appFrameView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    appFrameView.backgroundColor = [UIColor redColor];
    [self.view addSubview:appFrameView];

    UIView *keyboardFrameView = self.keyboardFrameView =
    [[UIView alloc] initWithFrame:CGRectZero];
    keyboardFrameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:keyboardFrameView];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 32)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    [self.view addSubview:textField];
    [textField becomeFirstResponder];

    UIButton *resignButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [resignButton addTarget:textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    [resignButton setTitle:@"Resign" forState:UIControlStateNormal];
    resignButton.frame = CGRectMake(220, 10, 56, 32);
    [self.view addSubview:resignButton];

    [self setupKeyboardObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)setupKeyboardObservers{
    self.keyboardChangeIdentifier =
    [[KGKeyboardChangeManager sharedManager] addObserverForKeyboardChangedWithSetupBlock:^(BOOL show, CGRect keyboardRect){
        CGRect keyboardFrameViewRect = self.keyboardFrameView.frame;
        keyboardFrameViewRect.size.width = CGRectGetWidth(keyboardRect);
        if(show){
            keyboardFrameViewRect.size.height = 0;
            keyboardFrameViewRect.origin.y = CGRectGetHeight(self.view.bounds);
        }else{
            keyboardFrameViewRect.size.height = CGRectGetHeight(keyboardRect);
            keyboardFrameViewRect.origin.y = CGRectGetHeight(self.view.bounds)-CGRectGetHeight(keyboardFrameViewRect);
        }
        keyboardFrameViewRect.origin.y -= 2; // poke the view up 2 pts so we can see it above the keyboard
        self.keyboardFrameView.frame = keyboardFrameViewRect;
    } andAnimationBlock:^(BOOL show, CGRect keyboardRect){
        CGRect keyboardFrameViewRect = self.keyboardFrameView.frame;
        if(show){
            keyboardFrameViewRect.size.height = CGRectGetHeight(keyboardRect);
            keyboardFrameViewRect.origin.y = CGRectGetHeight(self.view.bounds)-CGRectGetHeight(keyboardFrameViewRect);
        }else{
            keyboardFrameViewRect.size.height = 0;
            keyboardFrameViewRect.origin.y = CGRectGetHeight(self.view.bounds);
        }
        keyboardFrameViewRect.origin.y -= 2; // poke the view up 2 pts so we can see it above the keyboard
        self.keyboardFrameView.frame = keyboardFrameViewRect;
    }];

    self.keyboardOrientationIdentifier =
    [[KGKeyboardChangeManager sharedManager] addObserverForKeyboardOrientationChangedWithBlock:^(CGRect keyboardRect){
        CGRect keyboardFrameViewRect = self.keyboardFrameView.frame;
        keyboardFrameViewRect.size.width = CGRectGetWidth(keyboardRect);
        keyboardFrameViewRect.size.height = CGRectGetHeight(keyboardRect);
        keyboardFrameViewRect.origin.y = CGRectGetHeight(self.view.bounds)-CGRectGetHeight(keyboardFrameViewRect);
        keyboardFrameViewRect.origin.y -= 2; // poke the view up 2 pts so we can see it above the keyboard        
        self.keyboardFrameView.frame = keyboardFrameViewRect;
    }];
}

- (void)dealloc{
    [[KGKeyboardChangeManager sharedManager]
     removeObserverWithKeyboardChangedIdentifier:self.keyboardChangeIdentifier];
    [[KGKeyboardChangeManager sharedManager]
     removeObserverWithKeyboardOrientationIdentifier:self.keyboardOrientationIdentifier];
}

@end
