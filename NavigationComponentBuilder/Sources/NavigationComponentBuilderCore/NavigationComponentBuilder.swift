//
//  NavigationComponentBuilder.swift
//  NavigationComponentBuilderCore
//
//  Created by Branden Smith on 11/6/19.
//

import Files
import Foundation
import PathKit
import Stencil

public class NavigationComponentBuilder {
    public enum Error: Swift.Error {
        case failedToReadNavigationJSON
        case failedToParseNavigationJSON
        case failedToLoadStencil
        case templatePathIsNotADirectory

        public var localizedDescription: String {
            switch self {
            case .failedToReadNavigationJSON:
                return "Failed to read navigation json"
            case .failedToParseNavigationJSON:
                return "Failed to parse navigation json"
            case .failedToLoadStencil:
                return "Failed to load the template stencil"
            case .templatePathIsNotADirectory:
                return "The given template path is not a directory"
            }
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func build() throws {
        guard let navigationData = try? configuration.navigationPath.read().data(using: .utf8) else {
            throw Error.failedToReadNavigationJSON
        }

        guard let json = try? JSONSerialization.jsonObject(with: navigationData, options: []) as? [String: Any] else {
            throw Error.failedToParseNavigationJSON
        }

        guard configuration.templatePath.isDirectory else {
            throw Error.templatePathIsNotADirectory
        }
        
        let environment = Environment(
            loader: FileSystemLoader(paths: [configuration.templatePath])
        )

        do {
            let rendered = try environment.renderTemplate(
                name: configuration.templateName,
                context: ["navItems": getNavItems(fromJSON: json)]
            )

            try configuration.outputPath.write(rendered)
        }
    }

    private func getNavItems(fromJSON json: [String: Any]) -> [Navigation] {
        let arrayOfNavItems = NavigationMassager.massage(json: json)

        return arrayOfNavItems.compactMap({ item in
            guard let itemData = try? JSONSerialization.data(withJSONObject: item, options: []) else { return nil }
            guard let decoded = try? JSONDecoder().decode(Navigation.self, from: itemData) else { return nil }

            return decoded
        })
    }
}
