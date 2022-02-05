//
//  TermsOfService.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/4/18.
//

import Foundation

public struct TermsOfService: Codable, Equatable {
    public let service: String
    public let text: String
    
    public init(service: String, text: String) {
        self.service = service
        self.text = text
    }
}
