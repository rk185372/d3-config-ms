//
//  L10n.swift
//  Pods
//
//  Created by Chris Carranza on 1/9/17.
//
//

import Foundation
import i18next
import Logging
import Utilities

public protocol L10nProvider {
    
    /// Loads localization resources to be displayed
    ///
    /// - Parameter resources: A dictionary of key value pairs for localization.
    /// - Parameter completion: A closure executed upon completion containing an optional error
    func loadLocalizations(resources: [String: Any], completion: ((Error?) -> Void)? )
    
    /// Translates a given key to its string representation.
    ///
    /// - Returns: Localized representation
    func localize(_ key: String) -> String
    
    /// Translates a given key to its string representation and optionally
    /// populates any named parameters of the string using the `prameterMap`.
    ///
    /// For example:
    ///
    /// Your localized string may have the form:
    ///
    /// `"foo" = "foo from the year: __year__ in the month: __month__";`
    ///
    /// You would then pass a `parameterMap` object with:
    ///
    /// `["year": 2017, "month": 6]`
    ///
    /// and this function will return:
    /// `"foo from the year: 2017 in the month: 6"`
    ///
    /// - Parameters:
    ///   - key: A key in which to find a localized representation.
    ///   - parameterMap: A mapping of the parameters with the key being the placeholder in the string and the value being the
    ///                   value to replace the placeholder.
    ///
    /// - Returns: Localized representation
    func localize(_ key: String, parameterMap: [AnyHashable: Any]?) -> String
}

public final class L10n: L10nProvider {
    private let i18Next: I18Next = I18Next()
    
    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedL10nUpdate(_:)),
            name: .updatedL10nNotification,
            object: nil
        )
    }
    
    public func loadLocalizations(resources: [String: Any], completion: ((Error?) -> Void)? ) {
        let options = I18NextOptions()
        
        let translation: [String: Any] = ["translation": resources]
        let dev: [String: Any] = ["dev": translation]
        
        options.resourcesStore = dev
        options.keySeparator = "::"
        options.namespaceSeparator = ":::"
        
        i18Next.load(options: options.asDictionary(), completion: completion)
    }
    
    public func localize(_ key: String) -> String {
        return localize(key, parameterMap: nil)
    }

    /// Localizes key.
    /// - Parameter key: The key whose translation is needed
    /// - Parameter parameterMap: A Dictionary of substitution paramters to insert into the translation.
    /// # Note
    ///     This method is dynamic so that it can be swizzled when necessary. Changing this method
    ///     to be non-dynamic will cause any swizzling to fail. Before changing, ensure that the
    ///     selector: #selector(localize(_:parameterMap:)) is not being used anywhere inside of the app or any
    ///     of the pods that are dependent on the Localization pod.
    @objc public dynamic func localize(_ key: String, parameterMap: [AnyHashable: Any]?) -> String {
        guard i18Next.exists(key),
            let result = (parameterMap != nil) ? i18Next.t(key, variables: parameterMap!) : i18Next.t(key) else {
                log.warning("Localization error: Unhandled key: \(key)")
                
                return key
        }
        
        return result
    }

    @objc private func receivedL10nUpdate(_ sender: Notification) {
        guard let newL10n = sender.userInfo as? [String: Any] else { return }

        self.loadLocalizations(resources: newL10n, completion: { error in
            guard error == nil else {
                log.debug("Error updating l10n \(error!)")
                return
            }

            NotificationCenter.default.post(name: .reloadComponentsNotification, object: nil)
        })
    }
}
