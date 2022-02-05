//
//  FileHelper.swift
//  D3 BankingUITests
//
//  Created by Branden Smith on 2/7/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation

final class FileHelper {
    static func stringContents(of filename: String, withType type: String, in directory: String) -> String {
        let manager = FileManager()
        let bundle = Bundle(for: FileHelper.self)
        let qualifiedPath = bundle.path(
            forResource: filename,
            ofType: type,
            inDirectory: directory,
            forLocalization: nil
        )!
        let contents = manager.contents(atPath: qualifiedPath)!

        return (type != "jpg")
            ? String(data: contents, encoding: .utf8)!
            : contents.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}
