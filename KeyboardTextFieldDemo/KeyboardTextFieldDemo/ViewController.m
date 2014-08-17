//
//  ViewController.m
//  KeyboardTextFieldDemo

#import "ViewController.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import <Twitter/Twitter.h>
#import "IQFeedbackView.h"

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

- (IBAction)moreAction:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"More Controls" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"IQPhotoEditor", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        IQFeedbackView *feedbackView = [[IQFeedbackView alloc] initWithTitle:@"IQPhotoEditor" message:@"'IQPhotoEditor' is a lightweight photo editing framework which can be integrated very easily in any project within minutes. Present `IQPhotoEditorController` with `UIViewController+IQPhotoEditor` category method to provide to the user a powerful, beautiful & user friendly photo editing interface. Check it out here:- https://github.com/IQPhotoEditor/IQPhotoEditor" image:nil cancelButtonTitle:@"Cancel" doneButtonTitle:@"Open"];
        [feedbackView setImage:[UIImage imageNamed:@"IQPhotoEditor"]];
        [feedbackView setCanEditImage:NO];
        [feedbackView setCanEditText:NO];
        [feedbackView showInViewController:self.navigationController completionHandler:^(BOOL isCancel, NSString *message, UIImage *image)
        {
            [feedbackView dismiss];
            
            if (isCancel == NO)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/IQPhotoEditor/IQPhotoEditor"]];
            }
        }];
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

