//
//  L10nService.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 8/29/19.
//

import Foundation
import Network
import RxSwift

public protocol L10nService {
    func getL10n() -> Single<Data>
}

final class L10nServiceItem: L10nService {
    private let client: ClientProtocol

    init(client: ClientProtocol) {
        self.client = client
    }

    func getL10n() -> Single<Data> {
        return client.request(API.L10n.getL10n())
    }
}
