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
	//Enabling keyboard manager
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:15];
	//Enabling autoToolbar behaviour. If It is set to NO. You have to manually create IQToolbar for keyboard.
	[[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];

	//Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
	[[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];

    //Resign textField if touched outside of UITextField/UITextView.
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    //Giving permission to modify TextView's frame
    [[IQKeyboardManager sharedManager] setCanAdjustTextView:YES];
    
    //Show TextField placeholder texts on autoToolbar
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
    
    return YES;
}

@end
