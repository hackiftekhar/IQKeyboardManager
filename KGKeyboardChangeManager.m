//
//  KGKeyboardChangeManager.m
//  KGKeyboardChangeManagerApp
//
//  Created by David Keegan on 1/16/13.
//  Copyright (c) 2013 David Keegan. All rights reserved.
//

#import "KGKeyboardChangeManager.h"

NSString *const kChangeSetupBlockKey = @"KGKeyboardChangeManagerChangeSetupBlockKey";
NSString *const kChangeAnimationBlockKey = @"KGKeyboardChangeManagerChangeAnimationBlockKey";

@interface KGKeyboardChangeManager()
@property (strong, atomic) NSMutableDictionary *changeCallbacks;
@property (strong, atomic) NSMutableDictionary *orientationCallbacks;
@property (nonatomic, readwrite, getter=isKeyboardShowing) BOOL keyboardShowing;
@property (nonatomic) BOOL orientationChange;
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

- (id)addObserverForKeyboardChangedWithSetupBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)setupBlock andAnimationBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)animationBlock{
    NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    NSMutableDictionary *callbacks = [NSMutableDictionary dictionary];
    if(setupBlock){
        callbacks[kChangeSetupBlockKey] = setupBlock;
    }
    if(animationBlock){
        callbacks[kChangeAnimationBlockKey] = animationBlock;
    }
    if([callbacks count]){
        self.changeCallbacks[identifier] = [NSDictionary dictionaryWithDictionary:callbacks];
    }
    return identifier;
}

- (void)removeObserverWithKeyboardOrientationIdentifier:(id)identifier{
    [self.orientationCallbacks removeObjectForKey:identifier];
}

- (void)removeObserverWithKeyboardChangedIdentifier:(id)identifier{
    [self.changeCallbacks removeObjectForKey:identifier];
}

#pragma mark - Orientation

- (void)orientationDidChange:(NSNotification *)notification{
    if(self.isKeyboardShowing){
        self.orientationChange = YES;
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
        [self.changeCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop){
            KGKeyboardChangeManagerKeyboardChangedBlock setupBlock = obj[kChangeSetupBlockKey];
            if(setupBlock){
                setupBlock(show, newKeyboardEndFrame);
            }
        }];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];

        [self.changeCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop){
            KGKeyboardChangeManagerKeyboardChangedBlock animationBlock = obj[kChangeAnimationBlockKey];
            if(animationBlock){
                animationBlock(show, newKeyboardEndFrame);
            }
        }];

        [UIView commitAnimations];
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

@end
