//
//  MFAEnrollmentService.swift
//  Authentication
//
//  Created by Ignacio Mariani on 01/12/2021.
//

import Foundation
import RxSwift

public protocol MFAEnrollmentService: AnyObject {
    func disclosure() -> Single<MFAEnrollmentResponse>
}

public protocol MFAEnrollmentServiceFactory {
    func create() -> MFAEnrollmentService
}
