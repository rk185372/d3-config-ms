//
//  LaunchItemsResponse.swift
//  Authentication
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 8/3/21.
//

import Foundation
/// Wraps a JSON response that looks like this:
///
/// ```
/// {
///   "navItems": {
///     "NavItem:0": {
///       "item": "Open account",
///       "phone": "888-732-3922",
///       "url": "https://www.tcfbank.com/newaccount"
///     },
///     "NavItem:1": {
///       "item": "Website",
///       "url": "https://tcfbank.com"
///     },
///     "NavItem:2": {
///       "item": "Locations",
///       "url": "nativeGeo"
///     },
///     "NavItem:3": {
///       "item": "Contact us",
///       "url": "https://eeq1my.axshare.com/page_1.html"
///     }
///   }
/// }
/// ```
struct LaunchItemsResponse: Decodable {
    // Because nav items have dynamic dictionary keys instead of just being an array, we must wrap
    // in a custom Decodable type.
    struct NavItems: Decodable {
        struct NavItem: Codable {
            var item: String
            var phone: String?
            var url: String?
        }

        struct NavItemKey: CodingKey {
            var index: Int
            
            init?(stringValue: String) {
                guard let indexString = stringValue.split(separator: ":").last, let index = Int(indexString) else {
                    return nil
                }
                self.index = index
            }
            
            init?(intValue: Int) {
                self.index = intValue
            }
            
            var stringValue: String {
                return "NavItem:\(index)"
            }
            
            var intValue: Int? {
                return index
            }
        }
        
        var navItems: [NavItem]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: NavItemKey.self)
            navItems = try container.allKeys
                .sorted { (lhs, rhs) -> Bool in
                    lhs.index < rhs.index
                }
                .map { (key) in
                    return try container.decode(NavItem.self, forKey: key)
                }
        }
    }

    var navItems: NavItems
}
