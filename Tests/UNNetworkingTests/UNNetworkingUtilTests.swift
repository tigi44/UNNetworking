//
//  UNNetworkingUtilTests.swift
//  UNNetworkingTests
//
//  Created by tigi on 2020/06/03.
//

import XCTest
@testable import UNNetworking

class UNNetworkingUtilTests: XCTestCase {

    class ResponseDataHeader: Codable {
        let code: Int
        let isSuccess: Bool
    }
    
    let responseDataJson: Dictionary<String, Any> = ["code": 0, "isSuccess": true]
    
    func testDecodeUtilsDecodeJsonObject() throws {
        guard let responseData: ResponseDataHeader = DecodeUtils.decodeJsonObject(responseDataJson) else {
            XCTFail("Fail Test : Decode to ResponseDataHeader")
            return
        }
                
        XCTAssert(responseData.code == responseDataJson["code"] as! Int && responseData.isSuccess == responseDataJson["isSuccess"] as! Bool, "Fail Test : No match")
    }
    
    func testDecodeUtilsDecodeJsonObjectV2() throws {
        guard let responseData = DecodeUtils.decodeJsonObject(responseDataJson, dataType: ResponseDataHeader.self) as? ResponseDataHeader else {
            XCTFail("Fail Test : Decode to ResponseDataHeader")
            return
        }
        
        XCTAssert(responseData.code == responseDataJson["code"] as! Int && responseData.isSuccess == responseDataJson["isSuccess"] as! Bool, "Fail Test : No match")
    }

}
