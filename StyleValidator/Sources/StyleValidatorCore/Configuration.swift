//
//  Configuration.swift
//  StyleValidatorCore
//
//  Created by Chris Carranza on 12/20/18.
//

import Foundation
import PathKit
import Yams

public struct Configuration {
    public enum Error: Swift.Error {
        case invalidFormat(message: String)
        case invalidConfiguration(message: String)
    }
    
    let filesPath: Path
    let themesTemplatePath: Path
    
    public init(path: Path) throws {
        guard let dict = try Yams.load(yaml: path.read()) as? [String: Any] else {
            throw Error.invalidFormat(message: "Could not parse config file")
        }
        
        guard let filesPath = dict["filesPath"] as? String else {
            throw Error.invalidConfiguration(message: "Files path not defined")
        }
        guard let themesTemplatePath = dict["themesTemplatePath"] as? String else {
            throw Error.invalidConfiguration(message: "Themes Template Json file not defined")
        }
        
        self.filesPath = Path(filesPath)
        self.themesTemplatePath = Path(themesTemplatePath)
    }
}
