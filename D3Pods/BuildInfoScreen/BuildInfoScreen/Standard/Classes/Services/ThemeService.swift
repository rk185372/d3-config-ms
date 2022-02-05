//
//  ThemeService.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 8/19/19.
//

import Foundation
import Network
import RxSwift

public protocol ThemeService {
    func getTheme() -> Single<Data>
}

final class ThemeServiceItem: ThemeService {
    private let client: ClientProtocol

    init(client: ClientProtocol) {
        self.client = client
    }

    func getTheme() -> Single<Data> {
        return client.request(API.Theme.getTheme())
    }
}
