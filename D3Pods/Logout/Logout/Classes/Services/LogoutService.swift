//
//  LogoutService.swift
//  Logout
//
//  Created by Chris Carranza on 9/13/18.
//

import Foundation
import RxSwift

public protocol LogoutService {
    func logout() -> Completable
}
