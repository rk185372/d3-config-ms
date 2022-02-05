//
//  ServerTrustPackage.swift
//  Network
//
//  Created by Chris Carranza on 2/5/18.
//

import Foundation

public struct ServerTrustPackage {
    let domain: String
    let hashes: Set<Data>
    let hashingAlgorithms: [Int]
    
    public init(domain: String, hashes: Set<Data>, hashingAlgorithms: [Int]) {
        self.domain = domain
        self.hashes = hashes
        self.hashingAlgorithms = hashingAlgorithms
    }
}
