//
//  Dialog.swift
//  Authentication
//
//  Created by Branden Smith on 7/18/18.
//

import Foundation

public struct Dialog: Decodable {
    let title: String?
    let message: String
    let cancel: String
    let confirm: String
}
