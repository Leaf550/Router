//
//  BaseWebViewUIDelegator.swift
//  Hybrid
//
//  Created by 方昱恒 on 2022/2/30.
//

import UIKit
import WebKit
import Util

class BaseWebViewUIDelegator: NSObject, WKUIDelegate {
    
    /**
     用户点击网页上的链接，需要打开新页面时，将先调用 decidePolicyForNavigationAction 方法，其中的 WKNavigationAction 有两个属性 sourceFrame 和 targetFrame，类型是 WKFrameInfo，WKFrameInfo的mainFrame 属性标记着这个 frame 是在主 frame 里还是新开一个 frame。
     如果 targetFrame 的 mainFrame 属性为 NO，将会新开一个页面，WKWebView 遇到这种情况，将会调用它的 WKUIDelegate 代理中的 createWebViewWithConfiguration方法（就是下面这个），所以如果我们不实现这个协议就会出现点击无反应的情况，因此对于这种情况需要特殊处理，可以采取下边的方法：
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(action)
        
        Responder.topViewController?.present(alert, animated: true, completion: completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let certainAction = UIAlertAction(title: "确定", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            completionHandler(false)
        }
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(certainAction)
        alert.addAction(cancelAction)
        
        Responder.topViewController?.present(alert, animated: true, completion: nil)
    }
    
}
