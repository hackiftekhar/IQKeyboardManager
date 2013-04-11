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
@property (nonatomic) UIDeviceOrientation orientation;
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
    self.orientation = [self deviceOrientation];
    
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
     addObserver:self selector:@selector(deviceOrientationDidChange:)
     name:UIDeviceOrientationDidChangeNotification object:nil];

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

#pragma mark - Orientation

- (void)deviceOrientationDidChange:(NSNotification *)notification{
    self.orientation = [self deviceOrientation];
}

- (BOOL)orientationChanged{
    return (self.orientation != [self deviceOrientation]);
}

- (UIDeviceOrientation)deviceOrientation{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if(deviceOrientation == UIDeviceOrientationUnknown){
        switch([[UIApplication sharedApplication] statusBarOrientation]){
            case UIInterfaceOrientationPortrait:
                deviceOrientation = UIDeviceOrientationPortrait;
                break;
            case UIInterfaceOrientationLandscapeLeft: // left and right are different
                deviceOrientation = UIDeviceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationLandscapeRight: // left and right are different
                deviceOrientation = UIDeviceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                break;
        }
    }
    return deviceOrientation;
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
    switch([self deviceOrientation]){
        case UIDeviceOrientationPortrait:{
            newKeyboardEndFrame = keyboardEndFrame;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
            newKeyboardEndFrame.size.width = CGRectGetHeight(keyboardEndFrame);
            newKeyboardEndFrame.size.height = CGRectGetWidth(keyboardEndFrame);
            newKeyboardEndFrame.origin.y = CGRectGetWidth([[UIScreen mainScreen] bounds])-CGRectGetMaxX(keyboardEndFrame);            
            break;
        }
        case UIDeviceOrientationLandscapeRight:{
            newKeyboardEndFrame.size.width = CGRectGetHeight(keyboardEndFrame);
            newKeyboardEndFrame.size.height = CGRectGetWidth(keyboardEndFrame);
            newKeyboardEndFrame.origin.y = CGRectGetMinX(keyboardEndFrame);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:{
            newKeyboardEndFrame = keyboardEndFrame;
            newKeyboardEndFrame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds])-CGRectGetMaxY(keyboardEndFrame);
            break;
        }
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
            NSAssert(NO, @"Should not get here...");
            break;
    }

    // Call the appropriate callback
    if([self orientationChanged]){
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
    if(![self orientationChanged]){
        [self keyboardDidChange:notification show:NO];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification{
    self.keyboardShowing = NO;
}

- (void)keyboardWillShown:(NSNotification *)notification{
    [self keyboardDidChange:notification show:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    self.keyboardShowing = YES;
}

#pragma mark - Animation helper methods

+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve andAnimation:(void(^)())animationBlock{
    NSParameterAssert(animationBlock != nil);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    animationBlock();
    [UIView commitAnimations];
}

+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve animation:(void(^)())animationBlock andCompletion:(void(^)(BOOL finished))completionBlock{
    NSParameterAssert(animationBlock != nil);
    [UIView animateWithDuration:animationDuration delay:0
                        options:animationCurve|UIViewAnimationOptionBeginFromCurrentState
                     animations:animationBlock completion:completionBlock];
}

@end
