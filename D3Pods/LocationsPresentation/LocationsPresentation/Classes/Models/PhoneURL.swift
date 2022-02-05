//
//  PhoneFormatter.swift
//  LocationsPresentation
//
//  Created by Richard Crichlow on 7/7/20.
//

import Foundation

class PhoneFormatter {
    static func phoneNumberFormatter(phone: String?) -> URL? {
        guard let phone = phone?.removing(charactersInSet: CharacterSet.whitespaces), !phone.isEmpty else { return nil }
        guard let url = URL(string: "tel:\(phone)") else { return nil }
        guard UIApplication.shared.canOpenURL(url) else { return nil }

        return url
    }
}
