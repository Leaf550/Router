//
//  BaseWebViewDelegator.swift
//  Hybrid
//
//  Created by 方昱恒 on 2022/2/30.
//

import UIKit
import WebKit
import Util

class BaseWebViewNavigationDelegator: NSObject, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // 禁止不支持的 URL 协议头跳转
        guard let urlScheme = URLScheme(rawValue: url.scheme ?? "") else {
            decisionHandler(.cancel)
            return
        }
        
        switch urlScheme {
            case .http, .https:
                decisionHandler(.allow)
            case .pangolin:
                decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 网页内容开始加载到web view的时候调用。
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // 如果第1个代理回调 webView(_:decidePolicyFor:decisionHandler:) 允许加载 WebView，并且调用 webView(_:didStartProvisionalNavigation:) 后，会来到这里。
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 网页开始接受网络内容的时候调用，也就是网络内容开始要往网页中加载时调用。
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 网页加载失败
    }
    
}
