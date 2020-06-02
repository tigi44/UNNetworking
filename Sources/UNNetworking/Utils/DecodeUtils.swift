//
//  DecodeUtils.swift
//  UNNetworking
//
//  Created by tigi on 2020/05/29.
//  Copyright © 2020 nhnpayco. All rights reserved.
//

import Foundation

public class DecodeUtils {
    
    public class func decodeJsonObject<U>(_ jsonObject: Any?) -> U? {
        
        guard let jsonObject = jsonObject else {
            return nil
        }
        
        guard !(jsonObject is NSNull) else {
            return nil
        }
           
        var resultData: U? = nil
           
        do {
               
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
               
            if let resultType = U.self as? Decodable.Type {
                   
                resultData = try resultType.init(jsonData: jsonData) as? U
            } else {
                   
                resultData = nil
            }
        } catch {
               
            resultData = nil
        }
           
        return resultData
    }
    
    public class func decodeJsonObject(_ jsonObject: Any?, dataType: AnyClass) -> Any? {
        
        guard let jsonObject = jsonObject else {
            return nil
        }
               
        guard !(jsonObject is NSNull) else {
            return nil
        }
        
        var resultData: Any? = nil
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            
            if let resultType = dataType as? Decodable.Type {
                
                resultData = try resultType.init(jsonData: jsonData)
            } else {
                
                resultData = nil
            }
        } catch {
            
            resultData = nil
        }
        
        return resultData
    }
}
