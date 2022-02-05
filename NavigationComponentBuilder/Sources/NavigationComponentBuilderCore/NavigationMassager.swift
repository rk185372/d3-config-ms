//
//  NavigationMassager.swift
//  NavigationComponentBuilderCore
//
//  Created by Branden Smith on 11/7/19.
//

import Foundation

final class NavigationMassager {
    enum Key: String {
        case name
        case web
        case title
        case position
        case subitems
        case subsection
        case subsections

        func callAsFunction() -> String {
            return self.rawValue
        }
    }

    static func massage(json: [String: Any]) -> [[String: Any]] {
        let topLevelObjects: [[String: Any]] = flattenObject(from: json, forKey: Key.name())
        var transformedTopLevelObject: [[String: Any]] = []

        topLevelObjects.forEach({ object in
            var newObject = object
            var flattenedSubitems: [[String: Any]] = []

            // Parse subitem objects
            if let webObj = newObject[Key.web()] as? [String: Any],
               let subItemsObject = webObj[Key.subitems()] as? [String: Any] {
                flattenedSubitems = flattenObject(from: subItemsObject, forKey: Key.name()).sorted(by: position)
                newObject[Key.web()] = copyDict(webObj, replacingKey: Key.subitems(), with: flattenedSubitems)
            }
            // Parse subSection objects
            if let webObj = newObject[Key.web()] as? [String: Any],
               let subSectionsObject = webObj[Key.subsections()] as? [String: Any] {
                let flattenedSubSections = flattenSubSections(from: subSectionsObject, with: flattenedSubitems).sorted(by: position)
                newObject[Key.web()] = copyDict(webObj, replacingKey: Key.subsections(), with: flattenedSubSections)
            }

            transformedTopLevelObject.append(newObject)
        })

        return transformedTopLevelObject.sorted(by: position)
    }

    private static func flattenObject(from json: [String: Any], forKey jsonKey: String) -> [[String: Any]] {
        return json.compactMap { (key, value) in
            guard var object = value as? [String: Any] else { return nil }
            object[jsonKey] = key

            return object
        }
        .filter({ dict in dict["enabled"] as? Bool ?? true })
    }

    private static func flattenSubSections(from json: [String: Any], with subitems: [[String: Any]]) -> [[String: Any]] {
        return json.compactMap { (key, value) in
            guard let value = value as? String else { return nil }
            var result: [String: Any] = [:]
            result[Key.title()] = value
            result[Key.position()] = Int(key)

            // Match subitems based on the subSection value
            let subItemsForSection: [[String: Any]] = subitems.filter({ subItem in
                guard let number = subItem[Key.subsection()] as? Int else { return false }
                return number == Int(key)
            })
            .sorted(by: position)
            result[Key.subitems()] = subItemsForSection

            return result
        }
    }

    private static func copyDict(_ dict: [String: Any], replacingKey replacementKey: String, with object: Any) -> [String: Any] {
        dict.reduce(into: [:], { (result, keyValueTuple) in
            guard keyValueTuple.key == replacementKey else {
                result[keyValueTuple.key] = keyValueTuple.value
                return
            }

            result[replacementKey] = object
        })
    }

    private static let position: ([String: Any], [String: Any]) -> Bool = { (left, right) in
        guard let leftPosition = left[Key.position()] as? Int else { return false }
        guard let rightPosition = right[Key.position()] as? Int else { return false }

        return leftPosition < rightPosition
    }
}
