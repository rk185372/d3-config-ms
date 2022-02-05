//
//  StartupHolder.swift
//  AppInitialization
//
//  Created by Andrew Watt on 9/14/18.
//

import Foundation
import Utilities
import CompanyAttributes
import RxSwift
import RxRelay

/// Holder wrapper for Startup and CompanyAttributes
public final class StartupHolder: CompanyAttributesHolder {
    private let holder = Holder<Decoded<Startup, String>>()
    
    public var decodedStartup: Decoded<Startup, String>? {
        get {
            return holder.value
        }
        set {
            if let new = newValue {
                companyAttributes.accept(new.value.companyAttributes)
            }

            holder.value = newValue
        }
    }

    public var startup: Startup? {
        return decodedStartup?.value
    }
    
    public var companyAttributes: BehaviorRelay<CompanyAttributes?> = BehaviorRelay(value: nil)
    
    public var startupJSON: String? {
        return decodedStartup?.source
    }

    public init() { }
}
