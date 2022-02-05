//
//  BuildInfoScreenState.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 11/1/19.
//

import Foundation

public final class BuildInfoScreenState {
    public var translatesL10n: Bool
    public var usesLocalExtensions: Bool

    public init(translatesL10n: Bool, usesLocalExtensions: Bool) {
        self.translatesL10n = translatesL10n
        self.usesLocalExtensions = usesLocalExtensions
    }
}
