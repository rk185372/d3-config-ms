//
//  CompanyAttributesHolder.swift
//  CompanyAttributes
//
//  Created by Andrew Watt on 9/14/18.
//

import Foundation
import RxRelay

public protocol CompanyAttributesHolder {
    var companyAttributes: BehaviorRelay<CompanyAttributes?> { get }
}
