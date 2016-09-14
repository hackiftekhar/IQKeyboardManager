//
//  WebViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit

class WebViewController: UIViewController , UIWebViewDelegate {
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet var _webView : UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request : URLRequest = URLRequest(url: URL(string: "http://www.gmail.com")!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60)
        _webView.loadRequest(request)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activity.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activity.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activity.stopAnimating()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

}

