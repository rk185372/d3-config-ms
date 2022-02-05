//
//  ChallengeButtonDialog.swift
//  Authentication
//
//  Created by Jose Torres on 3/15/21.
//

import Foundation

enum ChallengeButtonDialogType: String, Decodable {
    case businessLoginHelpDialog
    case businessTooltipDialog
}

struct ChallengeButtonDialog: Decodable {
    let type: ChallengeButtonDialogType
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case type
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ChallengeButtonDialogType.self, forKey: .type)
        url = try? container.decodeIfPresent(URL.self, forKey: .url) ?? nil
    }
}
