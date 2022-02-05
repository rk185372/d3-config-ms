//
//  QRCodeUtils.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 20/12/2021.
//

import Foundation

public class QRCodeUtils {
    
    public init() {}
    
    public func generateQRCode(from data: Data) -> UIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    public func generateQRCode(from string: String) -> UIImage? {
        if let data = string.data(using: String.Encoding.ascii) {
            return generateQRCode(from: data)
        }
        return nil
    }
    
    public func string(fromQRCodeImage image: UIImage) -> String {
            var qrAsString = ""
            guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                            context: nil,
                                            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
                let ciImage = CIImage(image: image),
                let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
                    return qrAsString
            }

            for feature in features {
                guard let indeedMessageString = feature.messageString else {
                    continue
                }
                qrAsString += indeedMessageString
            }

            return qrAsString
        }
}
