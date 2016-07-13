//
//  WebViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class WebViewController: UIViewController , UIWebViewDelegate {
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    @IBOutlet var _webView : UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request : NSURLRequest = NSURLRequest(URL: NSURL(string: "http://www.gmail.com")!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        _webView.loadRequest(request)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activity.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activity.stopAnimating()
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        activity.stopAnimating()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

}

