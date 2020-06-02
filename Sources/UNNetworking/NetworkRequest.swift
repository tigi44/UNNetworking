//
//  NetworkRequest.swift
//  UNSE
//
//  Created by tigi on 09/09/2019.
//  Copyright © 2019 nhnpayco. All rights reserved.
//

import Foundation


//MARK: - Enum


public enum HttpMethod: String {
    case GET, POST, PUT, DELETE
}

public enum ContentType: String {
    case NONE = ""
    case APPLICATION_JSON = "application/json"
    case APPLICATION_OCTETSTREAM = "application/octet-stream"
}


//MARK: - NetworkRequest


public protocol NetworkURLRequest {
    
    var urlPath: String { get }
    var method: HttpMethod { get }
    var contentType: ContentType { get }
    var headers: Dictionary<String, String>? { get }
    var params: Dictionary<String, Any>? { get }
    var bodyBinary: Data? { get set }
    
    init(urlPath: String, method: HttpMethod, contentType: ContentType)
    
    func alphaHost() -> String
    func betaHost() -> String
    func realHost() -> String
    func cachePolicy() -> URLRequest.CachePolicy
    func timeoutInterval() -> TimeInterval
    
    func request() -> URLRequest?
}

open class NetworkRequest: NetworkURLRequest {


    //MARK: - request variable
    
    
    public var urlPath: String
    public var method: HttpMethod
    public var contentType: ContentType
    public var headers: Dictionary<String, String>?
    public var params: Dictionary<String, Any>?
    public var bodyBinary: Data?
    
    
    //MARK: - response variable
    
    
    public var networkResponse: NetworkResponse?
    
    
    //MARK: - init
    
    
    public required init(urlPath: String, method: HttpMethod, contentType: ContentType) {
        
        self.urlPath = urlPath
        self.method = method
        self.contentType = contentType
    }
    
    public convenience init(urlPath: String, method: HttpMethod, contentType: ContentType, params: Dictionary<String, Any>?) {
        
        self.init(urlPath: urlPath, method: method, contentType: contentType)
        
        self.params = params
    }
    
    public convenience init(urlPath: String, method: HttpMethod, contentType: ContentType, headers: Dictionary<String, String>?, params: Dictionary<String, Any>?) {
        
        self.init(urlPath: urlPath, method: method, contentType: contentType, params: params)
        
        self.headers = headers
    }
    
    
    //MARK: - public
    
    
    public func request() -> URLRequest? {
        
        return self.makeRequest()
    }
    
    
    //MARK: - NetworkRequestProtocol Override
    
    
    open func alphaHost() -> String {
        return ""
    }
    open func betaHost() -> String {
        return ""
    }
    open func realHost() -> String {
        return ""
    }
    open func cachePolicy() -> URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    open func timeoutInterval() -> TimeInterval {
        return 5.0
    }
}


//MARK: - Extension : NetworkRequest


extension NetworkRequest {
    
    
    //MARK: - Public Funtions
    
    
    public func addHeaders(_ aHeaders: [String: String]) {
        
        if let headers = headers {
            
            self.headers = headers.merging(aHeaders) { (_, new) in new }
        } else {
            
            self.headers = aHeaders
        }
    }
    
    public func addParams(_ aParams: [String: Any]) {
        
        if let params = params {
            
            self.params = params.merging(aParams) { (_, new) in new }
        } else {
            
            self.params = aParams
        }
    }
}

//MARK: - Extension : NetworkRequest Private

internal extension NetworkRequest {
    
    private func host() -> String {
        
        #if REAL
            return self.realHost()
        #elseif BETA
            return self.betaHost()
        #else
            return self.alphaHost()
        #endif
    }
    
    private func checkUrlPrefix(urlPath: String) -> String {
        
        var result: String = ""
        
        if urlPath.hasPrefix("/") {
            result = urlPath
        } else {
            if urlPath.contains("://") {
                result = urlPath
            } else {
                result = "/" + urlPath
            }
        }
        
        return result
    }
    
    private func url() -> String {
        urlPath = checkUrlPrefix(urlPath: self.urlPath)
        return self.host() + urlPath
    }
    
    private func makeRequestQuery() -> URLRequest? {
        
        guard var components = URLComponents(string: url()) else {
            return nil
        }
        
        var request: URLRequest
        var queryItems: [URLQueryItem] = []
        
        if let params = self.params {
            
            for param in params {
                
                let key: String = param.key
                let value: String = String(describing: param.value)
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            components.queryItems = queryItems
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
        
        request = URLRequest(url: components.url!)
        
        return request
    }
    
    private func makeRequestBody() -> URLRequest? {
        
        guard let url = URL(string: url()) else {
            return nil
        }
        
        var request: URLRequest = URLRequest(url: url)
        var paramsData: Data?   = nil
        
        switch self.contentType {
        case .APPLICATION_JSON:
            if let params = self.params {
                paramsData = try? JSONSerialization.data(withJSONObject: params, options: [])
            }
        case .APPLICATION_OCTETSTREAM:
            paramsData = self.bodyBinary
        default:
            paramsData = nil
        }
        
        request.httpBody = paramsData
        
        return request
    }
    
    private final func makeRequest() -> URLRequest? {
        
        var request: URLRequest?
        
        switch self.method {
        case .GET:
            request = self.makeRequestQuery()
        case .POST, .PUT, .DELETE:
            request = self.makeRequestBody()
        }
        
        request?.httpMethod = self.method.rawValue
        request?.cachePolicy = self.cachePolicy()
        request?.timeoutInterval = self.timeoutInterval()
        
        if (contentType != .NONE) {
            request?.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        if let headers = headers {
            
            for (key, value) in headers {
                request?.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
