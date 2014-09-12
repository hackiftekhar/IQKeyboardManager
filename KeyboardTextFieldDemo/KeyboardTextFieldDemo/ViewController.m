//
//  ViewController.m
//  KeyboardTextFieldDemo

#import "ViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import <Twitter/Twitter.h>

@interface ViewController ()<UIActionSheetDelegate>

@end

@implementation ViewController

- (IBAction)shareClicked:(UIBarButtonItem *)sender
{
    NSString *shareString = @"IQKeyboardManager is really great control for iOS developer to manage keyboard-textField.";
    UIImage *shareImage = [UIImage imageNamed:@"IQKeyboardManagerScreenshot"];
    NSURL *youtubeUrl = [NSURL URLWithString:@"http://youtu.be/6nhLw6hju2A"];
    
    if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_1))
    {
        NSArray *activityItems = [NSArray arrayWithObjects:
                                  youtubeUrl,
                                  shareString,
                                  shareImage,
                                  nil];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        NSArray *excludedActivities = @[UIActivityTypePrint,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypeSaveToCameraRoll];
        controller.excludedActivityTypes = excludedActivities;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        if ([TWTweetComposeViewController canSendTweet])
        {
            // Initialize Tweet Compose View Controller
            TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
            // Settin The Initial Text
            [vc setInitialText:shareString];
            
            [vc addImage:shareImage];
            // Adding a URL
            [vc addURL:youtubeUrl];
            // Setting a Completing Handler
            [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                [self dismissModalViewControllerAnimated:YES];
            }];
            // Display Tweet Compose View Controller Modally
            [self presentViewController:vc animated:YES completion:nil];
        }
        else
        {
            // Show Alert View When The Application Cannot Send Tweets
            NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

