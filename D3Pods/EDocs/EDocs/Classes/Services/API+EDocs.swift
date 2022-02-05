//
//  API+EDocs.swift
//  EDocs
//
//  Created by Chris Carranza on 4/12/18.
//

import Foundation
import Network

extension API {
    enum EDocs {

        static func updateEDocPreferences(request: UpdateDeliverySettings) -> Endpoint<Data> {
            return Endpoint(
                method: .put,
                path: "v4/edocs/preferences",
                parameters: request.toDictionary()
            )
        }

        static func declineEDocs(for type: EDocsDocumentType) -> Endpoint<Void> {
            return Endpoint(method: .put, path: "v4/edocs/prompted/\(type.rawValue)")
        }
    }
}
