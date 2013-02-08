//
//  KGKeyboardChangeManager.m
//  KGKeyboardChangeManagerApp
//
//  Created by David Keegan on 1/16/13.
//  Copyright (c) 2013 David Keegan. All rights reserved.
//

#import "KGKeyboardChangeManager.h"

@interface KGKeyboardChangeManager()
@property (strong, atomic) NSMutableDictionary *changeCallbacks;
@property (strong, atomic) NSMutableDictionary *orientationCallbacks;
@property (nonatomic, readwrite, getter=isKeyboardShowing) BOOL keyboardShowing;
@property (nonatomic) BOOL orientationChange, didBecomeActive;
@end

@implementation KGKeyboardChangeManager

+ (KGKeyboardChangeManager *)sharedManager{
    static dispatch_once_t onceToken;
    static KGKeyboardChangeManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init{
    if(!(self = [super init])){
        return nil;
    }

    self.changeCallbacks = [NSMutableDictionary dictionary];
    self.orientationCallbacks = [NSMutableDictionary dictionary];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShown:)
     name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardDidHide:)
     name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationDidChange:)
     name:UIDeviceOrientationDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(didBecomeActive:)
     name:UIApplicationDidBecomeActiveNotification object:nil];

    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observers

- (id)addObserverForKeyboardOrientationChangedWithBlock:(void(^)(CGRect keyboardRect))block{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    if(block){
        self.orientationCallbacks[identifier] = block;
    }
    return identifier;
}

- (id)addObserverForKeyboardChangedWithBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)block{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    if(block){
        self.changeCallbacks[identifier] = block;
    }
    return identifier;
}

- (void)removeObserverWithIdentifier:(id)identifier{
    if(identifier){
        [self.orientationCallbacks removeObjectForKey:identifier];
        [self.changeCallbacks removeObjectForKey:identifier];
    }
}

- (void)didBecomeActive:(NSNotification *)notification{
    self.didBecomeActive = YES;
}

#pragma mark - Orientation

- (void)orientationDidChange:(NSNotification *)notification{
    if(self.isKeyboardShowing){
        self.orientationChange = YES;
    }

    // This code is here to undo orientationDidChange setting
    // orientationChange = YES when the app is returning to active.
    // If this is not done the code will think it is responding to an orientaion change
    if(self.didBecomeActive){
        self.orientationChange = NO;
        self.didBecomeActive = NO;
    }
}

#pragma mark - Keyboard

- (void)keyboardDidChange:(NSNotification *)notification show:(BOOL)show{
    CGRect keyboardEndFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    // The keyboard frame is in portrait space
    CGRect newKeyboardEndFrame = CGRectZero;    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(interfaceOrientation == UIInterfaceOrientationPortrait){
        newKeyboardEndFrame = keyboardEndFrame;
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        newKeyboardEndFrame.origin.y = CGRectGetMinX(keyboardEndFrame);
        newKeyboardEndFrame.size.width = CGRectGetHeight(keyboardEndFrame);
        newKeyboardEndFrame.size.height = CGRectGetWidth(keyboardEndFrame);
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        newKeyboardEndFrame.size.width = CGRectGetHeight(keyboardEndFrame);
        newKeyboardEndFrame.size.height = CGRectGetWidth(keyboardEndFrame);
        newKeyboardEndFrame.origin.y = CGRectGetWidth([[UIScreen mainScreen] bounds])-CGRectGetHeight(newKeyboardEndFrame);
    }else if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        newKeyboardEndFrame = keyboardEndFrame;
        newKeyboardEndFrame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds])-CGRectGetHeight(newKeyboardEndFrame);
    }

    // Call the appropriate callback
    if(self.orientationChange){
        [self.orientationCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, KGKeyboardChangeManagerKeyboardOrientationBlock block, BOOL *stop){
            if(block){
                block(newKeyboardEndFrame);
            }
        }];
    }else{
        [self.changeCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, KGKeyboardChangeManagerKeyboardChangedBlock block, BOOL *stop){
            if(block){
                block(show, newKeyboardEndFrame, animationDuration, animationCurve);
            }
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [self keyboardDidChange:notification show:NO];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    self.keyboardShowing = NO;
}

- (void)keyboardWillShown:(NSNotification *)notification{
    [self keyboardDidChange:notification show:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    self.keyboardShowing = YES;
    self.orientationChange = NO;
}

#pragma mark - Animation helper methods

+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve andAnimation:(void(^)())animationBlock{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    if(animationBlock){
        animationBlock();
    }
    [UIView commitAnimations];
}

+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve animation:(void(^)())animationBlock andCompletion:(void(^)(BOOL finished))completionBlock{
    [UIView animateWithDuration:animationDuration delay:0
                        options:animationCurve|UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock completion:completionBlock];
}

@end
