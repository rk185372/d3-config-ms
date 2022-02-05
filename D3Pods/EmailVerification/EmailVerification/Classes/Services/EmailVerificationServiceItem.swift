//
//  EmailVerificationServiceItem.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import Foundation
import Network
import RxSwift

public final class EmailVerificationServiceItem: EmailVerificationService {

    private let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }

    public func postPrimaryEmail(email: String) -> Single<Void> {
        let data = try! JSONSerialization.data(withJSONObject: ["emailAddress": email], options: [])
        return client.request(API.EmailVerification.postPrimaryEmail(email: data))
    }
    
    public func cleanEmailVerify() -> Single<Void> {
        return client.request(API.EmailVerification.cleanEmailVerify())
    }
}
