//
//  NetworkManager.swift
//  UNSE
//
//  Created by tigi on 25/07/2019.
//  Copyright © 2019 nhnpayco. All rights reserved.
//

import Foundation


//MARK: Enum - NetworkError


public enum NetworkError: LocalizedError {
    
    case NetworkError_CLIENT(_ message: String)
    case NetworkError_CLIENT_NOT_CONNECTED_TO_INTERNET(_ message: String)
    case NetworkError_SERVER(_ message: String)
    case NetworkError_SERVER_500(_ message: String)
    case NetworkError_SERVICE(_ message: String)
    case NetworkError_SERVICE_SERVER_MESSAGE(_ message: String)
    
    public var message: String {
        switch self {
        case let .NetworkError_CLIENT(message), let .NetworkError_CLIENT_NOT_CONNECTED_TO_INTERNET(message), let .NetworkError_SERVER(message), let .NetworkError_SERVER_500(message), let .NetworkError_SERVICE(message), let .NetworkError_SERVICE_SERVER_MESSAGE(message):
            return message
        }
    }
    
    public var failureReason: String {
        switch self {
        case .NetworkError_CLIENT_NOT_CONNECTED_TO_INTERNET(_):
            return "CLIENT_NOT_CONNECTED_TO_INTERNET"
        case .NetworkError_CLIENT(_):
            return "CLIENT_ERROR"
        case .NetworkError_SERVER(_):
            return "SERVER_ERROR"
        case .NetworkError_SERVER_500(_):
            return "SERVER_ERROR_500"
        case .NetworkError_SERVICE(_):
            return "SERVICE_ERROR"
        case .NetworkError_SERVICE_SERVER_MESSAGE(_):
            return "SERVER_ERROR_MESSAGE"
        }
    }
}


//MARK: Class - NetworkManager


protocol SendToNetwork {
    func sendRequest(_ networkRequest: NetworkRequest, success: ((Any?) -> Void)?, fail: ((Error) -> Void)?)
}

open class NetworkManager: SendToNetwork {
    
    public static let shared = NetworkManager()
    private init() {}
}


//MARK: - extension NetworkManager


extension NetworkManager {
    
    public func sendRequest(_ networkRequest: NetworkRequest, success: ((Any?) -> Void)?, fail: ((Error) -> Void)?) {
        guard let urlRequest: URLRequest = networkRequest.request() else {
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in

            DispatchQueue.main.async {

                if let error = error {

                    self.handleClientError(error, networkRequest: networkRequest, response: response, data: data, fail: fail)
                    return
                }

                guard let httpURLResponse = response as? HTTPURLResponse, (200..<300).contains(httpURLResponse.statusCode) else {

                    self.handleErrorHTTPURLResponse(response, networkRequest: networkRequest, data: data, fail: fail)
                    return
                }


                do {

                    if let networkResponse = networkRequest.networkResponse {

                        networkResponse.urlResponse = response
                        try networkResponse.parseResponseData(data, success: success)
                    } else {

                        if let success = success {

                            success(nil)
                        }
                    }
                } catch {

                    self.handleServiceError(error, networkRequest: networkRequest, response: response, data: data, fail: fail)
                }
            }
        })

        task.resume()
    }
}
    
internal extension NetworkManager {
    
    func handleErrorHTTPURLResponse(_ response: URLResponse?, networkRequest: NetworkRequest, data: Data?, fail: ((Error) ->Void)?) {

        guard let httpURLResponse = response as? HTTPURLResponse else {
            
            handleNetworkError(.NetworkError_SERVER("Error : No Response"), networkRequest: networkRequest, response: response, data: data, fail: fail)
            return
        }
        
        var networkError: NetworkError!
        let statusCode   = httpURLResponse.statusCode
        let dataString   = String(data: data!, encoding: .utf8) ?? "Error : HTTPURLResponse No data"
        let errorMessage = "StatusCode : \(statusCode), Data : \(dataString)"
        
        switch statusCode {
        case 500..<600:
            networkError = .NetworkError_SERVER_500(errorMessage)
        default:
            networkError = .NetworkError_SERVER(errorMessage)
        }
        
        handleNetworkError(networkError, networkRequest: networkRequest, response: httpURLResponse, data: data, fail: fail)
    }
    
    func handleClientError(_ error: Error, networkRequest: NetworkRequest, response: URLResponse?, data: Data?, fail: ((Error) ->Void)?) {
        
        var networkError: NetworkError!
        
        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
            
            networkError = .NetworkError_CLIENT_NOT_CONNECTED_TO_INTERNET(nsError.localizedDescription)
        } else {
            
            networkError = .NetworkError_CLIENT(error.localizedDescription)
        }
        
        handleNetworkError(networkError, networkRequest: networkRequest, response: response, data: data, fail: fail)
    }
    
    func handleServiceError(_ error: Error, networkRequest: NetworkRequest, response: URLResponse?, data: Data?, fail: ((Error) ->Void)?) {
        
        var networkError: NetworkError!
        
        if let error = error as? NetworkError {
            
            networkError = error
        } else {
            
            networkError = .NetworkError_SERVICE(error.localizedDescription)
        }
        
        handleNetworkError(networkError, networkRequest: networkRequest, response: response, data: data, fail: fail)
    }
    
    func handleNetworkError(_ error: NetworkError, networkRequest: NetworkRequest, response: URLResponse?, data: Data?, fail: ((Error) ->Void)?) {
        if let fail = fail {
            fail(error)
        }
    }
}


