//
//  URLHelper.swift
//  Util
//
//  Created by 方昱恒 on 2021/11/30.
//

import UIKit

public enum URLScheme: String {
    case http       = "http"
    case https      = "https"
    case pangolin     = "pangolin"
}

public class URLHelper {
    
    public static func schemeOfURL(url: String) -> URLScheme? {
        guard let url = URL(string: url) else { return nil }
        guard let scheme = url.scheme else { return nil }
        
        return URLScheme(rawValue: scheme)
    }
    
    public static func queryItemsForURL(url: String) -> [String : String]? {
        guard let urlComponents = URLComponents(string: url) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        
        var res = [String : String]()
        
        for queryItem in queryItems {
            let name = queryItem.name
            let value = queryItem.value
            
            res[name] = value ?? ""
        }
        
        return res
    }
    
}
