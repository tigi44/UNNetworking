//
//  NetworkResponse.swift
//  UNSE
//
//  Created by tigi on 09/09/2019.
//  Copyright © 2019 nhnpayco. All rights reserved.
//

import Foundation


//MARK: -  NetworkResponse

public protocol NetworkURLResponse {
    var urlResponse: URLResponse? { get set }
}

public protocol NetworkResponseDataParser {
    var responseDataType: AnyClass? { get set }
    func parseResponseData(_ data: Data?, success: ((Any?) -> Void)?) throws
    func handleResponseObject(_ responseObject: Any?, success: ((Any?) -> Void)?) throws
}

open class NetworkResponse: NetworkURLResponse, NetworkResponseDataParser {
    
    public var responseDataType: AnyClass?
    public var urlResponse: URLResponse?
    
    public init() {}
    
    open func parseResponseData(_ data: Data?, success: ((Any?) -> Void)?) throws {
        
        if let httpResponse = urlResponse as? HTTPURLResponse, let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
            
            if contentType.contains(ContentType.APPLICATION_JSON.rawValue) {
                
                try parseJsonResponseData(data, success: success)
            } else {
                
                try parseObjectResponseData(data, success: success)
            }
        } else {
            
            try parseObjectResponseData(data, success: success)
        }
    }
    
    open func handleResponseObject(_ responseObject: Any?, success: ((Any?) -> Void)?) throws {
        
        if let success = success {
            
            var resultData: Any?
            
            if let responseDataType = responseDataType, responseDataType is Decodable.Type {
                if let responseJsonObject = responseObject as? Dictionary<String, Any> {
                    resultData = DecodeUtils.decodeJsonObject(responseJsonObject, dataType: responseDataType)
                } else {
                    resultData = nil
                }
            } else {
                resultData = responseObject
            }
            
            success(resultData)
        }
    }
}


//MARK: - Extension : NetworkResponse


extension NetworkResponse {
    
    
    //MARK: - parse
    
    
    public final func parseJsonResponseData(_ data: Data?, success: ((Any?) -> Void)?) throws {
        
        if let data = data {
            
            if let reponseJsonObject = jsonResponseSerializer(data) {
                
                try handleResponseObject(reponseJsonObject, success: success)
            } else {
                
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error : the Response has No JsonObject"])
            }
        } else {
            
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error : the Response has No Data"])
        }
    }
    
    public final func parseObjectResponseData(_ data: Data?, success: ((Any?) -> Void)?) throws {
        
        if let data = data {
            
            if let reponseJsonObject = jsonResponseSerializer(data) {
                
                try handleResponseObject(reponseJsonObject, success: success)
            } else {
                
                try parseStringResponseData(data, success: success)
            }
        } else {
            
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error : the Response has No Data"])
        }
    }
    
    public final func parseStringResponseData(_ data: Data?, success: ((Any?) -> Void)?) throws {
        
        if let data = data {
            
            let responseStringObject = String(data: data, encoding: .utf8)
            try handleResponseObject(responseStringObject, success: success)
        } else {
            
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error : the Response has No Data"])
        }
    }
}

internal extension NetworkResponse {
    private final func jsonResponseSerializer(_ data: Data) -> Any? {
        
        var result: Any?
        
        do {
            if let dataString = String(data: data, encoding: .utf8) {
                
                var stringData: Data?
                var string = dataString
                string = string.trimmingCharacters(in: .whitespacesAndNewlines)
                string = string.trimmingCharacters(in: .illegalCharacters)
                string = string.replacingOccurrences(of: "\n", with: "\\n")
                string = string.replacingOccurrences(of: "\r", with: "\\r")
                string = string.replacingOccurrences(of: "\t", with: "\\t")
                
                stringData = string.data(using: .utf8)
                result = try JSONSerialization.jsonObject(with: stringData!, options: [])
            }
        } catch {
            
            result = nil
        }
        
        return result
    }
}

