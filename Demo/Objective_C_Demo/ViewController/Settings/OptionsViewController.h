//
//  OptionsViewController.h
//  IQKeyboard
//
//  Created by Iftekhar on 27/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsViewController;

@protocol OptionsViewControllerDelegate <NSObject>

-(void)optionsViewController:(OptionsViewController*)controller didSelectIndex:(NSInteger)index;

@end

@interface OptionsViewController : UITableViewController

@property(nonatomic, assign) id<OptionsViewControllerDelegate> delegate;
@property(nonatomic, strong) NSArray *options;
@property(nonatomic, assign) NSInteger selectedIndex;

@end
