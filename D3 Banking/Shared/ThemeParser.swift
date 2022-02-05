//
//  ThemeParser.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/8/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import ComponentKit
import RxSwift
import RxRelay
import Web
import Network

final class ThemeParser {
    private let loader: ThemeLoader
    private let webLoader: WebThemeLoader
    private let styleProvider: ComponentStyleProvider
    private var configurationSettings: ConfigurationSettings?
    private let bag = DisposeBag()
    var theme: [String: Any]?

    var themeColors: ThemeColors
    
    init(loader: ThemeLoader, styleProvider: ComponentStyleProvider,
         webLoader: WebThemeLoader, configurationSettings: ConfigurationSettings?
    ) {
        self.loader = loader
        self.styleProvider = styleProvider
        self.webLoader = webLoader
        self.themeColors = ThemeColors()
        self.configurationSettings = configurationSettings

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTheme(notification:)),
            name: .updatedThemeNotification,
            object: nil
        )
    }
    
    func parse() {
        // We use a dispatch group to block the thread until
        // loading has finished. Missing themes will crash
        // the app if they aren't loaded when accessed.
        
        let group = DispatchGroup()
        group.enter()
        
        loader
            .loadTheme()
            .subscribe { [unowned self] event in
                switch event {
                case .success(let json):
                    self.theme = json
                    self.loadStyleProvider(json: json)
                    self.loadThemeColors(json: json)
                case .error(let error):
                    fatalError("Error Getting Theme: \(error)")
                }
                group.leave()
            }
            .disposed(by: self.bag)
        group.wait()
        
        // create a new dispatch group for Web Theme for waiting.
        let webGroup = DispatchGroup()
        webGroup.enter()
        webLoader
            .loadWebTheme()
            .subscribe { [unowned self] event in
                switch event {
                case .success(let jsonData):
                    self.loadWebStyleProvider(json: jsonData)
                case .error(let error):
                    fatalError("Error Getting Theme: \(error)")
                }
                webGroup.leave()
            }
            .disposed(by: self.bag)
        webGroup.wait()
    }
    
    @objc public func updateTheme(notification: NSNotification) {
        let json = notification.userInfo as! [String: Any]
        self.theme = json
        self.loadStyleProvider(json: json)
        self.loadThemeColors(json: json)
        NotificationCenter.default.post(name: .reloadComponentsNotification, object: nil)
    }
    
    private func loadStyleProvider(json: [String: Any]) {
        let styleDeserializer = StylesDeserializer(styleParsers: parsers, json: json)
        try! styleDeserializer.deserialize().forEach { (key, value) in
            self.styleProvider.load(style: value, forIdentifier: key)
        }
    }

    private func loadThemeColors(json: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            themeColors = try JSONDecoder().decode(ThemeColors.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func loadWebStyleProvider(json: Data) {
        let configurationSettings = try? JSONDecoder().decode(ConfigurationSettings.self, from: json)
        self.configurationSettings?.config = configurationSettings?.config
    }
}
