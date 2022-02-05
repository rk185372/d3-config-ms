//
//  ContactsModule.swift
//  D3Contacts
//
//  Created by Branden Smith on 10/14/19.
//

import DependencyContainerExtension
import Dip
import Foundation

public final class ContactsModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register {
            ContactsHelper()
        }
    }
}
