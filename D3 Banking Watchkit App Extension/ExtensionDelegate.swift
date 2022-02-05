//
//  ExtensionDelegate.swift
//  D3 Banking Watchkit App Extension
//
//  Created by Branden Smith on 10/9/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Dip
import Localization
import Utilities
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupDependencyContainer()
        
        // Loading consumer localizations by default
        let consumerLocalizationsFile = #fileLiteral(resourceName: "Localizable.json")
        loadL10NFiles(fileUrl: consumerLocalizationsFile)
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(receivedL10nUpdate(_:)),
                    name: .userAccountTypeUpdated,
                    object: nil
        )
    }

    func applicationDidBecomeActive() {
        NotificationCenter.default.post(name: .watchAppDidBecomeActive, object: nil)
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    private func loadL10NFiles(fileUrl: URL) {
        let contents = try! Data(contentsOf: fileUrl)
        let json = try! JSONSerialization.jsonObject(with: contents) as! [String: Any]

        let l10nProvider: L10nProvider = try! DependencyContainer.shared.resolve()
        l10nProvider.loadLocalizations(resources: json, completion: nil)
    }
    
    @objc private func receivedL10nUpdate(_ sender: Notification) {
        guard let lastSignedUserAccountIndex = sender.userInfo as? [String: Int] else { return }
        if lastSignedUserAccountIndex["UserAccount"] == 1 {
            // Business File
            let businessLocalizationFile = #fileLiteral(resourceName: "BusinessLocalizable.json")
            loadL10NFiles(fileUrl: businessLocalizationFile)
        } else {
            // Consumer file
            let consumerLocalizationsFile = #fileLiteral(resourceName: "Localizable.json")
            loadL10NFiles(fileUrl: consumerLocalizationsFile)
        }
        
        NotificationCenter.default.post(
            name: .reloadWatchComponentsNotification,
            object: nil
        )
    }
}
