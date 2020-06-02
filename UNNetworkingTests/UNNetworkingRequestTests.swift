//
//  UNNetworkingRequestTests.swift
//  UNNetworkingTests
//
//  Created by tigi on 2020/06/01.
//  Copyright © 2020 nhnpayco. All rights reserved.
//

import XCTest
@testable import UNNetworking

class UNNetworkingRequestTests: XCTestCase {

    let urlString = "http://www.apple.com"
    let method = HttpMethod.GET
    let contentType = ContentType.APPLICATION_JSON
    let headers: Dictionary<String, String> = ["headersKey": "headersValue"]
    let params: Dictionary<String, Any> = ["paramsKey": "paramsValue"]
    
    var networkRequest: NetworkRequest!
    
    override func setUpWithError() throws {
        networkRequest = NetworkRequest(urlPath: urlString,
                                        method: method,
                                        contentType: contentType,
                                        headers: headers,
                                        params: params)
        
        if contentType == .APPLICATION_OCTETSTREAM {
            networkRequest.bodyBinary = "anydata".data(using: .utf8)
        }
    }

    func testInit() throws {
        XCTAssert(networkRequest.urlPath == urlString, "Fail test : \(networkRequest.urlPath)")
        XCTAssert(networkRequest.method == method, "Fail test : \(networkRequest.method)")
        XCTAssert(networkRequest.contentType == contentType, "Fail test : \(networkRequest.contentType)")
        XCTAssert(networkRequest.headers == headers, "Fail test : \(String(describing: networkRequest.headers))")
        XCTAssert(networkRequest.params!["paramsKey"] as! String == params["paramsKey"] as! String, "Fail test : \(networkRequest.params!["paramsKey"] ?? "")")
    }
    
    func testAddHeaders() throws {
        let additionalHeaders: Dictionary<String, String> = ["headersKey2": "headersValue2"]
        let mergedHeaders = self.headers.merging(additionalHeaders) { (_, new) in new }
        
        networkRequest.addHeaders(additionalHeaders)
        
        XCTAssert(networkRequest.headers == mergedHeaders, "Fail test : \(String(describing: networkRequest.headers))")
    }
    
    func testAddParams() throws {
        let additionalParams: Dictionary<String, Any> = ["paramsKey2": "paramsKey2"]
        
        networkRequest.addParams(additionalParams)
        
        XCTAssert(networkRequest.params!["paramsKey"] as! String == params["paramsKey"] as! String, "Fail test : \(networkRequest.params!["paramsKey"] ?? "")")
        XCTAssert(networkRequest.params!["paramsKey2"] as! String == additionalParams["paramsKey2"] as! String, "Fail test : \(networkRequest.params!["paramsKey2"] ?? "")")
    }
    
    func testMakeURLRequest() throws {
        guard let urlRequest: URLRequest = networkRequest.request() else {
            XCTFail("Fail test : makeRequest")
            return
        }
        
        XCTAssert(urlString.contains(urlRequest.url!.host!), "Fail test : request url \(String(describing: urlRequest.url))")
        XCTAssert(urlRequest.httpMethod == method.rawValue, "Fail test : \(String(describing: urlRequest.httpMethod))")
        XCTAssert(urlRequest.value(forHTTPHeaderField: "Content-Type") == contentType.rawValue, "Fail test : \(String(describing: urlRequest.value(forHTTPHeaderField: "Content-Type")))")
        
        switch method {
        case .GET:
            let query = "paramsKey=paramsValue"
            let urlQuery = urlRequest.url?.query
            XCTAssert(query == urlQuery, "Fail test : \(String(describing: urlQuery))")
            break
        default:
            let httpBody = urlRequest.httpBody
            
            switch contentType {
            case .APPLICATION_JSON, .APPLICATION_OCTETSTREAM:
                XCTAssert(httpBody != nil, "Fail test : \(String(describing: httpBody))")
                break
            default:
                XCTAssert(httpBody == nil, "Fail test : \(String(describing: httpBody))")
                break
            }
        }
    }
}
