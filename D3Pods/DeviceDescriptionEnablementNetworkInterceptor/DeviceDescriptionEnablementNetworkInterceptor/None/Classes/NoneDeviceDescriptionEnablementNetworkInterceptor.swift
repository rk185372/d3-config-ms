//
//  NoneDeviceDescriptionEnablementNetworkInterceptor
//  EnablementNetworkInterceptor
//
//  Created by David McRae on 8/28/19.
//

import Foundation
import EnablementNetworkInterceptorApi
import RxSwift

final class NoneDeviceDescriptionEnablementNetworkInterceptor: EnablementNetworkInterceptor {
    init() {}
    
    func headers() -> Single<[String: String]?> {
        return Single.just(nil)
    }
}
