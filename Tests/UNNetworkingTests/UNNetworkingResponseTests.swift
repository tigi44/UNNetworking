//
//  UNNetworkingResponseTests.swift
//  UNNetworkingTests
//
//  Created by tigi on 2020/06/01.
//  Copyright © 2020 nhnpayco. All rights reserved.
//

import XCTest
@testable import UNNetworking

class UNNetworkingResponseTests: XCTestCase {

    class ResponseDataHeader: Codable {
        let code: Int
        let isSuccess: Bool
    }
    class ResponseDataResult: Codable {
        let data1: String
        let data2: [String]
    }
    class ResponseData: Codable {
        let header: ResponseDataHeader
        let result: ResponseDataResult
        
        func isEqual(with jsonObject: Dictionary<String, Any>) ->Bool {
            
            if let data = try? JSONEncoder().encode(self), let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                
                return NSDictionary(dictionary: dictionary).isEqual(to: jsonObject)
            } else {
                return false
            }
        }
    }
    
    var httpResponse: HTTPURLResponse!
    var networkResponse: NetworkResponse!
    var responseDataJson: Dictionary<String, Any> = [:]
    var responseDataString: String = ""

    override func setUpWithError() throws {
        httpResponse = HTTPURLResponse(url: URL(string: "UNNetworking://testParseResponseData")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": ContentType.APPLICATION_JSON.rawValue])!
        
        networkResponse = NetworkResponse()
        networkResponse.urlResponse = httpResponse
        
        responseDataJson    = ["header": ["code" : 0, "isSuccess": true], "result": ["data1": "value1", "data2": ["value2-1", "value2-2"]]]
        responseDataString  = "Success Response!"
    }

    // MARK: test
    func testParseResponseData() throws {
        
        networkResponse.responseDataType = ResponseData.self
        let responseData                 = try? JSONSerialization.data(withJSONObject: responseDataJson, options: [])
        try networkResponse.parseResponseData(responseData, success: testResponseDataSuccess)
    }
    
    func testHandleResponseObject() throws {
        
        networkResponse.responseDataType = ResponseData.self
        try networkResponse.decodeResponseObject(responseDataJson, success: testResponseDataSuccess)
    }
    
    func testParseJsonResponseData() throws {
        
        networkResponse.responseDataType = ResponseData.self
        let responseJsonData             = try? JSONSerialization.data(withJSONObject: responseDataJson, options: [])
        try networkResponse.parseJsonResponseData(responseJsonData, success: testResponseDataSuccess)
        
        
        networkResponse.responseDataType = nil
        let responseStringData: Data = responseDataString.data(using: .utf8)!
        do {
            try networkResponse.parseJsonResponseData(responseStringData) { parsedObject in XCTFail("Fail Test") }
        } catch {
            XCTAssert(true)
        }
    }
    
    func testParseObjectResponseData() throws {

        networkResponse.responseDataType = ResponseData.self
        let responseData                 = try? JSONSerialization.data(withJSONObject: responseDataJson, options: [])
        try networkResponse.parseObjectResponseData(responseData, success: testResponseDataSuccess)
        
        
        networkResponse.responseDataType = nil
        let responseStringData: Data     = responseDataString.data(using: .utf8)!
        try networkResponse.parseObjectResponseData(responseStringData, success: testStringSuccess)
    }
    
    func testParseStringResponseData() throws {

        networkResponse.responseDataType = nil
        let responseStringData: Data     = responseDataString.data(using: .utf8)!
        try networkResponse.parseObjectResponseData(responseStringData, success: testStringSuccess)
    }
    
    // MARK: private test
    private func testResponseDataSuccess(_ parsedObject: Any?){
        if let parsedObject: ResponseData = parsedObject as? ResponseData {
            XCTAssertTrue(parsedObject.isEqual(with: self.responseDataJson), "Fail Test : Not match")
        } else {
            XCTFail("Fail Test : no parsedObject as ResponseData")
        }
    }
    
    private func testStringSuccess(_ parsedObject: Any?){
        if let parsedString = parsedObject as? String {
            XCTAssertTrue(parsedString == self.responseDataString, "Fail Test : Not match")
        } else {
            XCTFail("Fail Test : no parsedObject as String")
        }
    }
}
