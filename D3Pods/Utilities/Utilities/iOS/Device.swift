//
//  Device.swift
//  Utilities
//
//  Created by Andrew Watt on 7/6/18.
//

import Foundation

public struct Device: Encodable {
    public static func current(application: Application, carrier: String?, uuid: D3UUID) -> Device {
        let platformVersion = UIDevice.current.systemVersion
        let displayableNickName = UIDevice.current.name
            .removing(charactersInSet: .controlCharacters)
            .replacingRightSingleQuote()
        
        var language: String {
            guard let languageString = Locale.preferredLanguages.first else { return "" }
            
            return languageString
        }
        
        var screenResolution: CGSize {
            let width = UIScreen.main.bounds.width * UIScreen.main.scale
            let height = UIScreen.main.bounds.height * UIScreen.main.scale
            
            return CGSize(width: width, height: height)
        }

        return Device(
            appVersion: application.appVersion,
            carrier: carrier,
            displayableNickName: displayableNickName,
            platformVersion: platformVersion,
            uuid: uuid.uuidString,
            language: language,
            screenResolution: screenResolution
        )
    }

    public var appVersion: String
    public var carrier: String?
    public var cordovaVersion = "0.0"
    public var deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "tablet" : "mobile"
    public var displayableNickName: String
    public var manufacturer = "Apple"
    public var model = UIDevice.current.model
    public var os = "iOS"
    public var platform = "iOS"
    public var platformVersion: String
    public var uuid: String
    public var language = "eng"
    public var screenResolution: CGSize
    
    public init(
        appVersion: String,
        carrier: String?,
        displayableNickName: String,
        platformVersion: String,
        uuid: String,
        language: String,
        screenResolution: CGSize) {
        self.appVersion = appVersion
        self.carrier = carrier
        self.displayableNickName = displayableNickName
        self.platformVersion = platformVersion
        self.uuid = uuid
        self.language = language
        self.screenResolution = screenResolution
    }
    
    public func dictionary() -> [String: Any] {
        // NB: it would be nice to use the Encodable protocol to generate this,
        // if there was a DictionaryEncoder.
        let values = [
            "appVersion": appVersion,
            "carrier": carrier,
            "cordovaVersion": cordovaVersion,
            "deviceType": deviceType,
            "nickName": displayableNickName,
            "manufacturer": manufacturer,
            "model": model,
            "os": os,
            "platform": platform,
            "platformVersion": platformVersion,
            "uuid": uuid
        ]

        return values.reduce(into: [:], { (result, element) in
            if let value = element.value {
                result[element.key] = value
            }
        })
    }
    
    public var description: String {
        let carrier = self.carrier ?? ""
        
        return "\(os)"
            + "\(platform)"
            + "\(model)"
            + "\(deviceType)"
            + "\(carrier)"
            + "\(manufacturer)"
            + "\(uuid)"
            + "\(language)"
            + "\(screenResolution)"
    }
}
