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
}

extension Serializable {
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(self)
        } catch {
            print(error)
            return nil
        }
    }
}

extension Array: Serializable { }

extension Data {
    func deserialize<T: Decodable>(type: T.Type) -> T?  {
        let decoder = JSONDecoder()
        return try? decoder.decode(type.self, from: self)
    }
}


