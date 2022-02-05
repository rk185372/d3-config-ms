//
//  WebViewExtension.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation

/// Usually, this would be a struct however, because there is some swizzling
/// going on in the WebViewExtensionsCache for the BuildInfoScreen. This needs
/// to be available to Objective-C therefore, it must be a class that inherits from
/// NSObject.
@objc public class WebViewExtension: NSObject, Codable {
    let id: Int
    let path: String
    let extensionId: Int
    let sourceAssetId: String
    let assetType: String
    let disabled: Bool
    let assetVersion: String?
    let async: Bool?
    let loadOrder: Int?

    init(id: Int, path: String, extensionId: Int, sourceAssetId: String,
         assetType: String, disabled: Bool, assetVersion: String?, async: Bool?, loadOrder: Int?) {
        self.id = id
        self.path = path
        self.extensionId = extensionId
        self.sourceAssetId = sourceAssetId
        self.assetType = assetType
        self.disabled = disabled
        self.assetVersion = assetVersion
        self.async = async
        self.loadOrder = loadOrder
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? WebViewExtension else { return false }

        // NOTE: We aren't using the id as part of this comparison because the id's can change
        // as clients update them or if they move to different environments. The server team
        // introduced sourceAssetId as a fix and they will ensure that value doesn't change.
        return self.path == rhs.path
            && self.extensionId == rhs.extensionId
            && self.sourceAssetId == rhs.sourceAssetId      
            && self.assetType == rhs.assetType
            && self.disabled == rhs.disabled
            && self.assetVersion == rhs.assetVersion
            && self.async == rhs.async
            && self.loadOrder == rhs.loadOrder
    }
}
