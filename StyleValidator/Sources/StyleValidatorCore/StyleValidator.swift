//
//  StyleValidator.swift
//  CYaml
//
//  Created by Chris Carranza on 2/26/19.
//

import Foundation
import Files
import PathKit

public enum StyleValidatorError: Error {
    case invalidThemesTemplate
}

public final class StyleValidator {
    private let configuration: Configuration
    private let parserDelegate: ParserDelegate = ParserDelegate()
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func validate() throws {
        Log.info("Validating path: \(configuration.filesPath)")
        
        for path in configuration.filesPath.iterateChildren(options: .skipsHiddenFiles)
            where path.extension == "xib" || path.extension == "storyboard" {
            Log.info(path)
            let parser = XMLParser(contentsOf: path.url)
            parserDelegate.documentUrl = path.url
            parser?.delegate = parserDelegate
            parser?.parse()
        }
        
        let data = try Data(contentsOf: configuration.themesTemplatePath.url)
        
        guard let themeTemplateJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw StyleValidatorError.invalidThemesTemplate
        }
        
        let themeTemplateStyleKeys = Set(themeTemplateJson.keys)
        
        Log.info("")
        Log.info("Themes Template Found")
        
        themeTemplateStyleKeys.forEach { (styleKey) in
            Log.info("Template Style Key: \(styleKey)")
        }
        
        Log.info("")
        Log.info("Parsed Xib Style Keys")
        
        parserDelegate.styleKeys.forEach { (styleKey) in
            Log.info("Style Key: \(styleKey)")
        }
        
        Log.info("")
        
        let unknownStyles = parserDelegate.styleKeys.subtracting(themeTemplateStyleKeys)
        for style in unknownStyles {
            Log.error("Unknown Style: \(style)")
            parserDelegate.styleKeyResults.filter { $0.key == style }.forEach { result in
                Log.error("Located in: \(result.documentUrl)")
            }
        }
    }
}

private struct StyleKeyResult: Hashable {
    let key: String
    let documentUrl: URL
}

private class ParserDelegate: NSObject, XMLParserDelegate {
    
    var documentUrl: URL!
    var styleKeys: Set<String> = []
    var styleKeyResults: [StyleKeyResult] = []
    
    @objc func parser(_ parser: XMLParser,
                      didStartElement elementName: String,
                      namespaceURI: String?,
                      qualifiedName qName: String?,
                      attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "userDefinedRuntimeAttribute",
            let keyPath = attributeDict["keyPath"],
            keyPath == "style",
            let styleKey = attributeDict["value"] {
            styleKeys.insert(styleKey)
            styleKeyResults.append(StyleKeyResult(key: styleKey, documentUrl: documentUrl))
        }
    }
}
