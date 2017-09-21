//
//  Serializable.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation

protocol Serializable : Codable {
    func serialize() -> Data?
//    func deserialize<T: Codable>(data: T) -> T
}

extension Serializable {
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
//    func deserialize<T: Codable>(data: T) -> T {
//        let decoder = JSONDecoder()
//        return try? decoder.decode(T, from: data)
//    }
}
