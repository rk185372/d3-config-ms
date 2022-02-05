//
//  OOBService.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/29/20.
//

import Foundation
import RxSwift
import Session

public protocol OOBService {
    func putOutOfBandDestinations(userProfile: UserProfile) -> Single<Void>
}
