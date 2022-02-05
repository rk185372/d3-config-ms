//
//  SelectionBox.swift
//  ComponentKit
//
//  Created by Branden Smith on 1/21/19.
//

import Dip
import DependencyContainerExtension
import Foundation
import UIKit

public final class SelectionBox: UIView {
    @IBOutlet public weak var titleLabel: UILabelComponent!
    @IBOutlet public weak var valueView: UIViewComponent!
    @IBOutlet public weak var valueLabel: UILabelComponent!
    @IBOutlet public weak var pickerView: UIPickerView!
}
