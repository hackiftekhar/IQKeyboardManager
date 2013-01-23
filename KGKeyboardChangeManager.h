//
//  KGKeyboardChangeManager.h
//  KGKeyboardChangeManagerApp
//
//  Created by David Keegan on 1/16/13.
//  Copyright (c) 2013 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGKeyboardChangeManager : NSObject

typedef void (^KGKeyboardChangeManagerKeyboardOrientationBlock)(CGRect keyboardRect);
typedef void (^KGKeyboardChangeManagerKeyboardChangedBlock)
(BOOL show, CGRect keyboardRect, NSTimeInterval animationDuration, UIViewAnimationCurve animationCurve);

@property (nonatomic, readonly, getter=isKeyboardShowing) BOOL keyboardShowing;

+ (KGKeyboardChangeManager *)sharedManager;

// This block is run whenever the orientation of the keyboard changes.
- (id)addObserverForKeyboardOrientationChangedWithBlock:(KGKeyboardChangeManagerKeyboardOrientationBlock)block;

// This block is run whenever the keyboard is shown or hidden.
- (id)addObserverForKeyboardChangedWithBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)block;

// Observers should be removed so they are not run when the keyboard changes.
- (void)removeObserverWithIdentifier:(id)identifier;

// Animation helper methods
+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration
                 animationCurve:(UIViewAnimationCurve)animationCurve
                   andAnimation:(void(^)())animationBlock;

+ (void)animateWithWithDuration:(NSTimeInterval)animationDuration
                 animationCurve:(UIViewAnimationCurve)animationCurve
                      animation:(void(^)())animationBlock
                  andCompletion:(void(^)(BOOL finished))completionBlock;

@end
