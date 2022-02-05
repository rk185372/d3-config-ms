//
//  BiometricsAutoPromptManagerFactory.swift
//  Biometrics
//
//  Created by Chris Carranza on 10/9/18.
//

import Foundation

public final class BiometricsAutoPromptManagerFactory {
    
    private let biometricsHelper: BiometricsHelper
    
    init(biometricsHelper: BiometricsHelper) {
        self.biometricsHelper = biometricsHelper
    }
    
    public func create(suppressPrompt: Bool) -> BiometricsAutoPromptManager {
        return BiometricsAutoPromptManager(
            biometricsHelper: biometricsHelper,
            suppressPrompt: suppressPrompt
        )
    }
}
