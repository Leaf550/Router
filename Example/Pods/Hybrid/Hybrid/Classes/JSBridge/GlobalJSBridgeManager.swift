//
//  GlobalJSBridgeManager.swift
//  Hybrid
//
//  Created by 方昱恒 on 2021/12/6.
//

import UIKit

public class GlobalJSBridgeManager {
    
    public static var shared = GlobalJSBridgeManager()
    
    var bridges = [String : JSBridge]()
    
    public func registerGlobalJSB(_ jsb: JSBridge) {
        let jsbName = jsb.name
        if bridges[jsbName] != nil {
            fatalError("不能重复注册JSBridge：“\(jsbName)”！")
        } else {
            bridges[jsbName] = jsb
        }
    }
    
    public func deregisterGlobalJSB(forName name: String) {
        if bridges[name] == nil {
            fatalError("不能移除为注册的JSBridge：“\(name)”！")
        } else {
            bridges.removeValue(forKey: name)
        }
    }
    
    public func isJSBRegistered(forName name: String) -> Bool {
        bridges[name] != nil
    }
    
}
