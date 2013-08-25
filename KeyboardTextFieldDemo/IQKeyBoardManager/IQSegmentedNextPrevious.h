//
//  KeyboardNextPrevious.h
//  DKKeyboardView
//
//  Created by Mohd Iftekhar Qurashi on 06/06/13.
//  Copyright (c) 2013 Denis Kutlubaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQSegmentedNextPrevious : UISegmentedControl
{
    id buttonTarget;
    SEL previousSelector;
    SEL nextSelector;
}
-(id)initWithTarget:(id)target previousSelector:(SEL)pSelector nextSelector:(SEL)nSelector;

@end
