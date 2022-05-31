//
//  WebViewController.swift
//  Hybrid
//
//  Created by 方昱恒 on 2022/2/30.
//

import UIKit
import WebKit

public class WebViewController: UIViewController {
    
    var url: String
    
    public lazy var webView: WKWebView = {
        let view = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)
        view.allowsBackForwardNavigationGestures = true
        view.allowsLinkPreview = true
        view.uiDelegate = uiDelegator
        view.navigationDelegate = navigationDelegator
        
        return view
    }()
    
    private var bridges = [String : JSBridge]()
    
    private var uiDelegator = BaseWebViewUIDelegator()
    private var navigationDelegator = BaseWebViewNavigationDelegator()
    
    private var userContentController: WKUserContentController = {
        WKUserContentController()
    }()
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        return configuration
    }()
    
    public init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        registerGlobalJSB()
        setupSubViews()
    }
    
    private func registerGlobalJSB() {
        let manager = GlobalJSBridgeManager.shared
        for jsb in manager.bridges.values {
            registerJSB(jsb)
        }
    }
    
    private func setupSubViews() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(webView)
        if let uRL = URL(string: url) {
            webView.load(URLRequest(url: uRL))
        }
    }
    
    deinit {
        for bridgeName in bridges.keys {
            deregisterJSB(forName: bridgeName)
        }
    }
    
}

public extension WebViewController {
    
    func registerJSB(_ jsb: JSBridge) {
        let jsbName = jsb.name
        if bridges[jsbName] != nil {
            fatalError("不能重复注册JSBridge：“\(jsbName)”！")
        } else {
            bridges[jsbName] = jsb
            userContentController.add(jsb.scriptMessageHandler, name: jsb.name)
        }
    }
    
    func deregisterJSB(forName name: String) {
        if bridges[name] == nil {
            fatalError("不能移除为注册的JSBridge：“\(name)”！")
        } else {
            bridges.removeValue(forKey: name)
            userContentController.removeScriptMessageHandler(forName: name)
        }
    }
    
    func isJSBRegistered(forName name: String) -> Bool {
        bridges[name] != nil
    }
    
    func runJSFunction(_ function: String, completionHandler: ((Any?, Error?) -> Void)?) {
        self.webView.runJSFunction(function, completionHandler: completionHandler)
    }
    
}

public extension WKWebView {
    func runJSFunction(_ function: String, completionHandler: ((Any?, Error?) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            self?.evaluateJavaScript(function, completionHandler: completionHandler)
        }
    }
}
