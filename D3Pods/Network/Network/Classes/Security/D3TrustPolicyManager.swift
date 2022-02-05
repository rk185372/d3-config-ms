//
//  D3TrustPolicyManager.swift
//  Network
//
//  Created by Chris Carranza on 2/5/18.
//

import Foundation
import Alamofire

public final class D3TrustPolicyManager: ServerTrustPolicyManager {
    private let hashCache: TSKSPKIHashCache = TSKSPKIHashCache(identifier: kTSKSPKISharedHashCacheIdentifier)!
    
    public init(serverTrustPackages: [ServerTrustPackage]) {
        var trustPolicies: [String: ServerTrustPolicy] = [:]
        for trustPackage in serverTrustPackages {
            trustPolicies[trustPackage.domain] = ServerTrustPolicy.customEvaluation(
                D3TrustPolicyManager.pinWithHashedKeys(trustPackage.hashes, trustPackage.hashingAlgorithms, hashCache)
            )
        }
        super.init(policies: trustPolicies)
    }
    
    private static func pinWithHashedKeys(_ knownPins: Set<Data>,
                                          _ hashingAlgorithms: [Int],
                                          _ hashCache: TSKSPKIHashCache) -> ((_ serverTrust: SecTrust, _ host: String) -> Bool) {
        
        let pinningClosure: (_ serverTrust: SecTrust, _ host: String) -> Bool = { (trust, hostName) in
            let sslPolicy = SecPolicyCreateSSL(true, hostName as CFString)
            SecTrustSetPolicies(trust, sslPolicy)
            
            guard self.trustIsValid(trust) else {
                print("Error evaluating trust")
                return false
            }
            
            let chainLength = SecTrustGetCertificateCount(trust)
            
            for i in 0..<chainLength {
                guard let cert = SecTrustGetCertificateAtIndex(trust, i) else {
                    print("Couldn't create a certificate in the chain")
                    return false
                }
                
                for algo in hashingAlgorithms {
                    guard let subjectPublicKeyInfoHash = hashCache.hashSubjectPublicKeyInfo(
                        from: cert,
                        publicKeyAlgorithm: TSKPublicKeyAlgorithm(rawValue: algo)!) else {
                            print("Error - could not generate the SPKI hash for \(hostName)")
                            return false
                    }
                    
                    if knownPins.contains(subjectPublicKeyInfoHash) {
                        return true
                    }
                }
            }
            
            print("Error: SSL Pin not found for \(hostName)")
            
            return false
        }
        
        return pinningClosure
    }
    
    private static func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false
        
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)
        
        if status == errSecSuccess {
            let unspecified = SecTrustResultType.unspecified
            let proceed = SecTrustResultType.proceed
            
            isValid = result == unspecified || result == proceed
        }
        
        return isValid
    }
}
