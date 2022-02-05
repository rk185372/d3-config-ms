//
//  Configuration.swift
//  NavigationComponentBuilderCore
//
//  Created by Branden Smith on 11/6/19.
//

import Foundation
import PathKit
import Yams

public struct Configuration {
    public enum Error: Swift.Error {
        case yamlPathDoesNotExist
        case navigationPathDoesNotExist
        case templatePathDoesNotExist
        case outputPathDoesNotExist
        case templateNameDoesNotExist
    }

    public let navigationPath: Path
    public let templatePath: Path
    public let outputPath: Path
    public let templateName: String

    public init(configurationPath: Path) throws {
        guard let configDict = try? Yams.load(yaml: configurationPath.read()) as? [String: Any] else {
            throw Error.yamlPathDoesNotExist
        }

        guard let navigationPath = configDict["navigation"] as? String else {
            throw Error.navigationPathDoesNotExist
        }

        guard let templatePath = configDict["templatePath"] as? String else {
            throw Error.templatePathDoesNotExist
        }

        guard let outputPath = configDict["output"] as? String else {
            throw Error.outputPathDoesNotExist
        }

        guard let templateName = configDict["templateName"] as? String else {
            throw Error.templateNameDoesNotExist
        }

        self.navigationPath = Path(navigationPath)
        self.templatePath = Path(templatePath)
        self.outputPath = Path(outputPath)
        self.templateName = templateName
    }
}
