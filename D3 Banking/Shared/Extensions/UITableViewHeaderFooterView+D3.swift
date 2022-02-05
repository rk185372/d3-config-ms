//
//  UITableViewHeaderFooterView+D3.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/8/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UITableViewHeaderFooterView {
    
    @IBInspectable open override var backgroundColor: UIColor? {
        get {
            return contentView.backgroundColor
        }
        set {
            contentView.backgroundColor = newValue
        }
    }
}
