//
//  RDCServiceProtocol.h
//  Pods
//
//  Created by Chris Carranza on 7/11/17.
//
//

import Foundation

public typealias RDCCaptureCompletionHandler = (RDCCaptureImages?) -> Void

public enum RDCCaptureType {
    case front, back, both
}

public enum RDCCaptureSide {
    case front
    case back
}

public protocol RDCServiceProtocol {
    func setCaptureCompletion(completion: @escaping RDCCaptureCompletionHandler)
}
