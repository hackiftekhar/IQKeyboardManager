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
typedef void (^KGKeyboardChangeManagerKeyboardChangedBlock)(BOOL show, CGRect keyboardRect);

@property (nonatomic, readonly, getter=isKeyboardShowing) BOOL keyboardShowing;

+ (KGKeyboardChangeManager *)sharedManager;

// This block is run whenever the orientation of the keyboard changes.
- (id)addObserverForKeyboardOrientationChangedWithBlock:(KGKeyboardChangeManagerKeyboardOrientationBlock)block;

// The setup block is run before the animation block, this block can be used to configure anything that
// will be animated in the animation block. The animation block will be animated along with the keyboard animation.
- (id)addObserverForKeyboardChangedWithSetupBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)setupBlock
                                andAnimationBlock:(KGKeyboardChangeManagerKeyboardChangedBlock)animationBlock;

// Observers should be removed so they are not run when the keyboard changes.
- (void)removeObserverWithKeyboardOrientationIdentifier:(id)identifier;
- (void)removeObserverWithKeyboardChangedIdentifier:(id)identifier;

@end
