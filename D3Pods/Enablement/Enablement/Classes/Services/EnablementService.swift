//
//  EnablementService.swift
//  Enablement
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network
import RxSwift

public protocol EnablementService {
    func enableSnapshot(deviceId: Int) -> Single<EnableResponse>
}
