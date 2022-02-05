//
//  RDCCaptureImages.m
//  Pods
//
//  Created by Chris Carranza on 7/11/17.
//
//

import Foundation

public struct RDCCaptureImages: Equatable {
    
    var encodedFrontImage: String
    var encodedBackImage: String
    var encodedOrigFrontImage: String?
    var encodedOrigBackImage: String?
    
    private static func base64Encode(data: Data) -> String {
        return data.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

extension RDCCaptureImages {
    
    init(front: Data, back: Data) {
        self.init(
            encodedFront: RDCCaptureImages.base64Encode(data: front),
            encodedBack: RDCCaptureImages.base64Encode(data: back),
            origFront: nil,
            origBack: nil
        )
    }
    
    init(encodedFront: String, encodedBack: String) {
        self.init(
            encodedFront: encodedFront,
            encodedBack: encodedBack,
            origFront: nil,
            origBack: nil
        )
    }
    
    init(front: Data, back: Data, origFront: Data?, origBack: Data?) {
        self.init(
            encodedFront: RDCCaptureImages.base64Encode(data: front),
            encodedBack: RDCCaptureImages.base64Encode(data: back),
            origFront: origFront,
            origBack: origBack
        )
    }
    
    init(encodedFront: String, encodedBack: String, origFront: Data?, origBack: Data?) {
        self.encodedFrontImage = encodedFront
        self.encodedBackImage = encodedBack
        if let origFront = origFront {
            self.encodedOrigFrontImage = RDCCaptureImages.base64Encode(data: origFront)
        }
        if let origBack = origBack {
            self.encodedOrigBackImage = RDCCaptureImages.base64Encode(data: origBack)
        }
    }
    
}
