//
//  String+JSON.swift
//  Web
//
//  Created by Andrew Watt on 10/10/18.
//

import Foundation

extension String {
    init(jsonData: Data) throws {
        guard let string = String(data: jsonData, encoding: .utf8) else {
            throw WebError.json
        }
        self = string
    }
}
