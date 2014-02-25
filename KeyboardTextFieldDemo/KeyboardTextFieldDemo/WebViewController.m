//
//  WebViewController.m
//  KeyboardTextFieldDemo

#import "WebViewController.h"

@implementation WebViewController
{
    UIActivityIndicatorView *activity;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gmail.com"]];
    [_webView loadRequest:request];
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activity setHidesWhenStopped:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activity startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activity stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activity stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
