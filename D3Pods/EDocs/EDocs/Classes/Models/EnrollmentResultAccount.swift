//
//  EnrollmentResultAccount.swift
//  EDocs
//
//  Created by Andrew Watt on 8/24/18.
//

import Foundation

struct EnrollmentResultAccount: Equatable {
    enum Status: Equatable {
        case success
        case failure(message: String)
        
        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure(let leftMessage), .failure(let rightMessage)):
                return leftMessage == rightMessage
            default:
                return false
            }
        }
    }
    
    var accountNumber: String
    var accountName: String
    var status: Status
}
