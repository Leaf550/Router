//
//  Router.swift
//  Router
//
//  Created by 方昱恒 on 2022/2/28.
//

import UIKit
import WebKit
import Util
import Hybrid

// URL Query参数类型
public typealias RouterURLQueryType = [String : String]

// 路由跳转时传递的参数
public typealias RouterRequestUserInfo = Any

// 路由注册回调。参数：URL Query参数；返回值：UI界面
public typealias RouterInitializerType = (RouterURLQueryType?, RouterRequestUserInfo?) -> UIViewController?

// 路由拦截器类型，每当路由器打开一个URL，都会首先执行一下拦截器。
// 参数：URL；返回值：是否拦截当前路由跳转，如返回`continue`，则继续跳转。
public typealias RouterInterceptorType = (String) -> RouterIntercepteResult

// 路由完成回调。参数：状态码。
public typealias RouterOpenCompletion = (RouterStatus) -> Void

public enum RouterIntercepteResult {
    case `continue`         // 不拦截跳转
    case intercept          // 拦截跳转
}

// 自定义路由打开动画样式
public enum RouterAnimationStyle {
    case push               // 默认导航控制器push动画
    case present            // 默认模态视图动画
    case presentFullScreen  // 全屏模态视图动画
    case customPush         // 自定义导航控制器push动画
    case customPresent      // 自定义模态视图动画
}

// 路由状态码
public enum RouterStatus {
    case ok                 // 页面正常打开
    case notFound           // 页面未注册
    case unknownScheme      // 不支持的URL协议头
    case badRequest         // URL语法错误
    case intercepted        // 被拦截器拦截
}

// 路由注册入口
public class RouterEntrance {
    
    public var initializer: RouterInitializerType              // 页面构造器
    public var animated: Bool = true                           // 是否开启动画
    public var animationStyle: RouterAnimationStyle = .push    // 跳转类型，默认压入导航栈
    
    public init(initializer: @escaping RouterInitializerType) {
        self.initializer = initializer
    }
    
}

public class Router {
    
    private static var routeMap = [String : RouterEntrance]()
    private static var interceptor: RouterInterceptorType = { _ in .continue }
    
    // 注册路由
    public static func register(url: String, with entrance: RouterEntrance) {
        routeMap[url] = entrance
    }
    
    // 注销路由
    public static func deregister(url: String) {
        routeMap.removeValue(forKey: url)
    }
    
    // 添加拦截器
    public static func addInterceptor(_ interceptor: @escaping RouterInterceptorType) {
        let currentInterceptor = self.interceptor
        self.interceptor = { url in
            let shouldIntercept1 = currentInterceptor(url)
            let shouldIntercept2 = interceptor(url)
            // 保证所有拦截器都可以正常执行
            let result: RouterIntercepteResult = (shouldIntercept1 == .intercept || shouldIntercept2 == .intercept) ? .intercept : .continue
            
            return result
        }
    }
    
    // 用Router打开URL
    public static func open(url: String,
                            userInfo: RouterRequestUserInfo?,
                            completion: @escaping RouterOpenCompletion = { _ in }) {
        guard interceptor(url) == .continue else {
            completion(.intercepted)
            return
        }
        
        guard let urlScheme = URLHelper.schemeOfURL(url: url) else {
            completion(.unknownScheme)
            return
        }
        
        switch urlScheme {
            case .http, .https:
                openWebPage(url: url, userInfo: userInfo, completion: completion)
            case .pangolin:
                openNativePage(url: url, userInfo: userInfo, completion: completion)
        }
    }
    
    // 用Router获取对应URL的页面
    public static func viewController(forURL url: String, userInfo: RouterRequestUserInfo?) -> UIViewController? {
        guard interceptor(url) == .continue else {
            return nil
        }
        
        return viewControllerWithoutIntercepter(forURL: url, userInfo: userInfo)
    }
    
    private static func urlWithoutQuery(url: String) -> String {
        String(url.split(separator: Character("?")).first ?? "")
    }
    
    private static func viewControllerWithoutIntercepter(forURL url: String, userInfo: RouterRequestUserInfo?) -> UIViewController? {
        guard let entrance = routeMap[urlWithoutQuery(url: url)] else {
            return nil
        }
        
        let urlQueries = URLHelper.queryItemsForURL(url: url)
        let targetVC = entrance.initializer(urlQueries, userInfo)
        
        return targetVC
    }
    
    private static func openWebPage(url: String,
                                    userInfo: RouterRequestUserInfo?,
                                    completion: @escaping RouterOpenCompletion) {
        guard let _ = URL(string: url) else {
            completion(.badRequest)
            return
        }
        
        guard let _ = routeMap[urlWithoutQuery(url: url)] else {
            let vc = WebViewController(url: url)
            if let navController = Responder.topViewController?.navigationController {
                navController.pushViewController(vc, animated: true)
            } else {
                Responder.topViewController?.present(vc, animated: true, completion: nil)
            }
            
            completion(.ok)
            return
        }
        
        // 若http、https协议头URL被注册为了native页面，则打开注册的native页面。
        openNativePage(url: url, userInfo: userInfo, completion: completion)
    }
    
    private static func openNativePage(url: String,
                                       userInfo: RouterRequestUserInfo?,
                                       completion: @escaping RouterOpenCompletion) {
        guard let _ = URL(string: url) else {
            completion(.badRequest)
            return
        }
        
        guard let entrance = routeMap[urlWithoutQuery(url: url)] else {
            completion(.notFound)
            return
        }
        
        guard let targetVC = viewControllerWithoutIntercepter(forURL: url, userInfo: userInfo) else { return }
        
        let animated = entrance.animated
        let animationStyle = entrance.animationStyle
        
        switch animationStyle {
            case .push:
                Responder.topViewController?.navigationController?.pushViewController(targetVC, animated: animated)
            case .present:
                Responder.topViewController?.present(targetVC, animated: animated, completion: nil)
            case .presentFullScreen:
                targetVC.modalPresentationStyle = .fullScreen
                Responder.topViewController?.present(targetVC, animated: animated, completion: nil)
            case .customPush:
                // TODO: 自定义转场动画，暂不支持，后期补充
                Responder.topViewController?.navigationController?.pushViewController(targetVC, animated: animated)
            case .customPresent:
                // TODO: 自定义转场动画，暂不支持，后期补充
                Responder.topViewController?.navigationController?.pushViewController(targetVC, animated: animated)
        }
        
        completion(.ok)
    }
}
