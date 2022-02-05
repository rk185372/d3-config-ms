//
//  API+MFAEnrollment.swift
//  Authentication
//
//  Created by Ignacio Mariani on 01/12/2021.
//

import Foundation
import Network
import Wrap

extension API {
    enum MFAEnrollment {
        static func disclosure() -> Endpoint<MFAEnrollmentResponse> {
            return Endpoint(method: .get, path: "v4/content/legal/disclosures/MFA_ENROLL")
        }
    }
}
