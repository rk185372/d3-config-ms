//
//  QRInfoBuilders.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 21/12/2021.
//

import Foundation
import Localization

public struct ZelleQRDataModel {
    public let name: String
    public let token: String
    
    public init(name: String, token: String) {
        self.name = name
        self.token = token
    }
}

public final class ZelleQRInfoBuilder: ProfileQRCodeInfoBuilder {
    
    private let userProfileQRTokens: [String]
    private let l10nProvider: L10nProvider
    
    private let prefix = "https://enroll.zellepay.com/qr-codes/?data=s/#"
    
    public init(userProfileQRTokens: [String], l10nProvider: L10nProvider) {
        self.userProfileQRTokens = userProfileQRTokens
        self.l10nProvider = l10nProvider
    }
    
    public func isValid(_ info: String) -> ProfileQRCodeInfoValidatorError? {
        guard info.starts(with: prefix),
              let data = Data(base64Encoded: info.replacingOccurrences(of: prefix, with: "")) else {
                  return .invalid(title: l10nProvider.localize("qr.scan.error.zelle.invalidQR.title"),
                                  description: l10nProvider.localize("qr.scan.error.zelle.invalidQR.description"))
              }
        let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]
        let token = json?["token"] as? String ?? ""
        guard !userProfileQRTokens.contains(token) else {
            return .invalid(title: l10nProvider.localize("qr.scan.error.zelle.invalidAccount.title"),
                            description: l10nProvider.localize("qr.scan.error.zelle.invalidAccount.description"))
        }
        return nil
    }
    
    public func buildInfo(from model: ZelleQRDataModel) -> String? {
        let json = [
            "name": model.name,
            "token": model.token,
            "type": "payment"
        ]
        guard let data = (try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed))?.base64EncodedData(),
              let sufix = String(data: data, encoding: .utf8) else {
                  return nil
              }
        return "\(prefix)\(sufix)"
    }
    
    public func decodeInfo(_ info: String) -> ZelleQRDataModel? {
        guard let data = Data(base64Encoded: info.replacingOccurrences(of: prefix, with: "")) else {
            return nil
        }
        let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]
        guard let name = json?["name"] as? String, let token = json?["token"] as? String else {
            return nil
        }
        return ZelleQRDataModel(name: name, token: token)
    }
}
