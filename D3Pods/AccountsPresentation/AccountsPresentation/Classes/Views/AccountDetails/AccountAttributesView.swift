//
//  AccountAttributesView.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/4/18.
//

import Foundation
import UIKit
import ComponentKit

protocol AccountAttributesView {
    var attributeLabel: UILabelComponent! { get }
    var valueLabel: UILabelComponent! { get }
}
