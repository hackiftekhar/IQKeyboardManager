//
//  KGAppDelegate.m
//  KGKeyboardChangeManagerApp
//
//  Created by David Keegan on 1/16/13.
//  Copyright (c) 2013 David Keegan. All rights reserved.
//

#import "KGKeyboardChangeManagerAppDelegate.h"
#import "KGKeyboardChangeManagerAppViewController.h"

@implementation KGKeyboardChangeManagerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[KGKeyboardChangeManagerAppViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
