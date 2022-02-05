//
//  Endpoint+Decodable.swift
//  Accounts
//
//  Created by Chris Carranza on 1/4/18.
//

import Foundation
import Utilities

extension Endpoint where Response: Swift.Decodable {
    public convenience init(method: Method = .get, path: Path, parameters: (() -> ParameterType)? = nil) {
        self.init(method: method, path: path, parameters: parameters) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Endpoint.customDateDecoding)
            return try decoder.decode(Response.self, from: $0)
        }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Parameters?) {
        self.init(method: method, path: path, parameters: parameters) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Endpoint.customDateDecoding)
            return try decoder.decode(Response.self, from: $0)
        }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Data?) {
        self.init(method: method, path: path, parameters: parameters) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Endpoint.customDateDecoding)
            return try decoder.decode(Response.self, from: $0)
        }
    }

    public convenience init(method: Method = .get, path: Path, headers: Headers? = nil, parameters: Parameters? = nil) {
        self.init(method: method, path: path, headers: headers, parameters: parameters) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Endpoint.customDateDecoding)
            return try decoder.decode(Response.self, from: $0)
        }
    }
    
    public convenience init(_ configuration: Configuration) {
        self.init(configuration) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Endpoint.customDateDecoding)
            return try decoder.decode(Response.self, from: $0)
        }
    }

    private static func customDateDecoding(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let date = dateString.asDate()

        if date == nil {
            throw DecodingError
                .dataCorruptedError(
                    in: container,
                    debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        return date!
    }
}
