//
//  ButtonPresenterFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import ComponentKit
import Foundation
import PresenterKit

final class ButtonPresenterFactory {
    private let componentStyleProvider: ComponentStyleProvider
    
    init(styleProvider: ComponentStyleProvider) {
        componentStyleProvider = styleProvider
    }
    
    func createButton(buttonTitle: String,
                      style: ButtonStyleKey,
                      clickListener: ((UIButton) -> Void)? = nil) -> ButtonPresenter {
        return ButtonPresenter(buttonTitle: buttonTitle, style: style, clickListener: clickListener)
    }
}
