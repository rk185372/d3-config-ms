//
//  Helpers.swift
//  Utilities-iOS
//
//  Created by Branden Smith on 1/7/19.
//

import Foundation

public class Helpers {
    public static func handleAcronyms(in arr: [String]) -> [String] {
        var newArr = [String]()
        var current = ""

        for elmt in arr {
            if elmt.count <= 1 {
                current += elmt
            } else {
                if !current.isEmpty {
                    newArr.append(current)
                    current = ""
                    newArr.append(elmt)
                } else {
                    newArr.append(elmt)
                }
            }
        }

        if !current.isEmpty {
            newArr.append(current)
        }

        return newArr
    }
}
