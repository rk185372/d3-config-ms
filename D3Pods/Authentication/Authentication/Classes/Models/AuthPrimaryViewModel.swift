//
//  PrimaryViewModel.swift
//  Authentication
//
//  Created by Andrew Watt on 8/14/18.
//

import Foundation
import Navigation
import RxSwift

final class AuthPrimaryViewModel {
    let snapshotToken: String?

    init(snapshotToken: String?) {
        self.snapshotToken = snapshotToken
    }
}
