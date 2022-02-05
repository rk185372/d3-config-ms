//
//  JSONHelper.swift
//  D3 Banking
//
//  Created by Chris Carranza on 8/8/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation

final class JSONHelper {
    static func jsonResource(atPath path: String, inBundle bundle: Bundle = Bundle(for: BundleToken.self)) throws -> Any {
        let data = try Data(contentsOf: URL(fileURLWithPath: path, relativeTo: bundle.bundleURL), options: .alwaysMapped)
        
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}

private final class BundleToken {}
