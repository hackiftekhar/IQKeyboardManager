//
//  AppDelegate.m
//
//  Created by Mohd Iftekhar Qurashi on 01/07/13.


#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = @"完成";
    [IQKeyboardManager sharedManager].toolbarBackgroundColor = [UIColor blueColor];
    return YES;
}

@end
