//
//  JSBridge.swift
//  Hybrid
//
//  Created by 方昱恒 on 2021/12/5.
//

import WebKit

public protocol JSBridgeModel: Codable { }

public protocol JSBridge: AnyObject {
    
    var name: String { get }
    
    func handleScriptMessage(_ message: WKScriptMessage)
    
}

public extension JSBridge {
    
    func decodeModel<M: Codable>(json: Any, byType: M.Type) -> M? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        
        guard let model = try? JSONDecoder().decode(M.self, from: data) else {
            return nil
        }
        
        return model
    }
    
}

extension JSBridge {
    var scriptMessageHandler: CYScriptMessageHandler {
        get {
            CYScriptMessageHandler(jsb: self)
        }
    }
}

class CYScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var jsb: JSBridge?
    
    init(jsb: JSBridge) {
        self.jsb = jsb
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let jsb = jsb else { return }
        
        guard message.name == jsb.name else { return }
        
        jsb.handleScriptMessage(message)
    }
    
}
