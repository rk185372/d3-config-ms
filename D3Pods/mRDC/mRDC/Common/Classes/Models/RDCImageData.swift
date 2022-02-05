//
//  RDCImageData.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/3/18.
//

import Foundation

public struct RDCImageData: Codable, Equatable {
    
    public enum ImageAngle: String, Codable {
        case front = "FRONT"
        case back = "BACK"
    }
    
    let transactionId: Int
    let sequenceNumber: Int
    let itemImageType: String
    let itemImageAngle: ImageAngle
    let bytes: String
}

extension RDCImageData {
    func image() -> UIImage? {
        guard let imageData = Data(base64Encoded: bytes) else {
                return nil
        }
        
        return UIImage(data: imageData)
    }
}
