//
//  CodableExtension.swift
//  UNNetworking
//
//  Created by tigi on 2020/05/29.
//  Copyright © 2020 nhnpayco. All rights reserved.
//

import Foundation


//MARK: Extension - Decodable


internal extension Decodable {
    
    init(jsonData: Data) throws {
        
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}
