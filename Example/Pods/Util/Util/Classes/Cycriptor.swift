//
//  Cycriptor.swift
//  Util
//
//  Created by 方昱恒 on 2022/2/28.
//

import Foundation

public class Cycriptor {
    
    public static func base64Decode(encoded: String) -> [AnyHashable : Any]? {
        var encoded = encoded
        var remainder = 4 - (encoded.count % 4)
        while remainder > 0 {
            encoded.append("=")
            remainder -= 1
        }
        
        guard let data = Data(base64Encoded: encoded) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [AnyHashable : Any]
    }

}
