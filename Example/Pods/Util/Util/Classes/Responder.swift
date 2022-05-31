//
//  Responder.swift
//  Util
//
//  Created by 方昱恒 on 2021/11/30.
//

import UIKit

public class Responder {
    
    public static var topViewController: UIViewController? {
        getTopViewController()
    }
    
    private static func getTopViewController(base: UIViewController? = UIApplication.shared.windows[0].rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.topViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
    
}
