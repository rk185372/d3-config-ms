//
//  RestServer.swift
//  AppConfiguration
//
//  Created by Chris Carranza on 2/20/18.
//

import Foundation

public struct RestServer: Codable {
    public struct SSLCertificate: Codable {
        public let hashes: [String]
        public let algorithms: [String]
        
        public init(hashes: [String], algorithms: [String]) {
            self.hashes = hashes
            self.algorithms = algorithms
        }
        
        public var hashSet: Set<Data> {
            return Set(hashes.map { Data(base64Encoded: $0)! })
        }
        
        public var algorithmIntegers: [Int] {
            return algorithms.map {
                switch $0 {
                case "2048": return 0
                case "4096": return 1
                case "256r1": return 2
                case "384r1": return 3
                default: fatalError("Unknown algorithm type: \($0)")
                }
            }
        }
    }
    
    public let url: URL
    public let sslCertificates: [SSLCertificate]
    
    public init(url: URL, sslCertificates: [SSLCertificate] = []) {
        self.url = url
        self.sslCertificates = sslCertificates
    }
}
