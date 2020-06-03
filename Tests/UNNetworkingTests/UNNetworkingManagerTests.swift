//
//  UNNetworkingManagerTests.swift
//  UNNetworkingTests
//
//  Created by tigi on 2020/06/03.
//

import XCTest
@testable import UNNetworking

class UNNetworkingManagerTests: XCTestCase {
    
    class Teams: Codable {
        class Team: Codable {
            let isNBAFranchise: Bool
            let city: String
            let fullName: String
        }
        class Standard: Codable {
            let standard: [Team]
        }
        let league: Standard
    }
    
    var networkingRequest: NetworkRequest!
    
    override func setUpWithError() throws {
        let networkingResponse: NetworkResponse = NetworkResponse()
        networkingResponse.responseDataType = Teams.self
        
        networkingRequest = NetworkRequest(urlPath: "https://data.nba.net/prod/v1/2019/teams.json",
                                           method: .GET,
                                           contentType: .APPLICATION_JSON,
                                           headers: nil,
                                           params: nil)
        networkingRequest.timeoutInterval = 10.0
        networkingRequest.cachePolicy     = .reloadIgnoringLocalAndRemoteCacheData
        networkingRequest.networkResponse = networkingResponse
    }

    func testJson() throws {
        let expectation = XCTestExpectation(description: "Receive a response")
        
        NetworkManager.shared.sendRequest(networkingRequest,
                                          success: { data in
                                            XCTAssertNotNil(data)
                                            XCTAssertTrue(data is Teams)
                                            XCTAssertNotNil((data as! Teams).league.standard[0].city)
                                            
                                            expectation.fulfill()
        },
                                          fail: { error in
                                            XCTFail("Fail test : \(error.localizedDescription)")
                                            
                                            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: networkingRequest.timeoutInterval)
    }
    
    func testString() throws {
        networkingRequest.urlPath = "https://apple.com"
        networkingRequest.networkResponse?.responseDataType = nil
        
        let expectation = XCTestExpectation(description: "Receive a response")
        
        NetworkManager.shared.sendRequest(networkingRequest,
                                          success: { data in
                                            XCTAssertNotNil(data)
                                            XCTAssertTrue(data is String)
                                            
                                            expectation.fulfill()
        },
                                          fail: { error in
                                            XCTFail("Fail test : \(error.localizedDescription)")
                                            
                                            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: networkingRequest.timeoutInterval)
    }
}
