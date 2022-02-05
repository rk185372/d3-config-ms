//
//  MessagesService.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation
import Network
import RxSwift

public protocol MessagesService {
    func getAlertsStats() -> Single<AlertsStats>
    func getSecureMessageStats() -> Single<SecureMessageStats>
    func getApprovalsStats() -> Single<ApprovalsStats>
}
