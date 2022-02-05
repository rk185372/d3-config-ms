//
//  WebComponentModel.swift
//  Web
//
//  Created by Andrew Watt on 7/2/18.
//

import Foundation
import RxSwift
import RxRelay

public class WebComponentModel {
    let navigation: WebComponentNavigation
        
    init(navigation: WebComponentNavigation) {
        self.navigation = navigation
    }
}
