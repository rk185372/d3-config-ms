//
//  ChallengeTitle.swift
//  Authentication
//
//  Created by Chris Carranza on 7/9/18.
//

import Foundation

struct ChallengeTitle: Decodable, Equatable {
    enum TitleType: String, Decodable {
        case error = "ERROR"
        case footer = "FOOTER"
        case leftAlignedFooter = "LEFT_ALIGNED_FOOTER"
        case info = "INFO"
        case major = "MAJOR_HEADER"
        case minor = "MINOR_HEADER"
        case warning = "WARNING"
        
        var isHeader: Bool {
            return self == .major || self == .minor
        }
        
        var isFooter: Bool {
            return self == .footer || self == .leftAlignedFooter
        }

        var isMessage: Bool {
            return !isHeader && !isFooter
        }
    }
    
    let titleType: TitleType
    let text: String

    enum CodingKeys: String, CodingKey {
        case titleType = "type"
        case text
    }
    
    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleType = try container.decode(TitleType.self, forKey: .titleType)
        text = try container.decode(String.self, forKey: .text)
    }
}
