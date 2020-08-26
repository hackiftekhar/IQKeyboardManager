//
//  WebViewController.swift
//  IQKeyboard
//
//  Created by Iftekhar on 23/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    #if swift(>=4.2)
    let activity = UIActivityIndicatorView(style: .gray)
    #else
    let activity = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    #endif

    var webView: WKWebView!
    @IBOutlet var webContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = WKWebViewConfiguration()

        self.webView = WKWebView(frame: webContainerView.bounds, configuration: configuration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webContainerView.addSubview(self.webView)

        let request: URLRequest = URLRequest(url: URL(string: "http://www.google.com")!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60)
        self.webView.load(request)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
    }

    override var shouldAutorotate: Bool {
        return true
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activity.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activity.stopAnimating()
    }
}
