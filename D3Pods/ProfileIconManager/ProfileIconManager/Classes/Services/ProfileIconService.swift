//
//  ProfileIconService.swift
//  ProfileIconManager
//
//  Created by Pablo Pellegrino on 1/26/22.
//

import Foundation
import Network
import UIKit
import RxSwift
import SVGKit

public protocol ProfileIconService {
    func getCurrentIcon() -> Single<UIImage?>
}

public final class ProfileIconServiceItem: ProfileIconService {
    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func getCurrentIcon() -> Single<UIImage?> {
        return client.request(API.ProfileIcon.getCurrent()).map { data in
            return SVGKImage(data: data).uiImage
        }
    }
}
