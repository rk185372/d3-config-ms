//
//  Codable+.swift
//  Pods
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation

enum EncodeError: Error {
    case invalidConversion
}

extension Encodable {
    public func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
    
    public func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Any {
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    public func dictEncode(with encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let raw: Any = try encode()
        
        guard let dict = raw as? [String: Any] else {
            throw EncodeError.invalidConversion
        }
        
        return dict
    }
}
