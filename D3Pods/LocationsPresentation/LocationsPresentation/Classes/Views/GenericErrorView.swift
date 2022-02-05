//
//  GenericErrorView.swift
//  LocationsPresentation
//
//  Created by Pablo Pellegrino on 12/30/21.
//

import ComponentKit
import Foundation
import UIKit

final class GenericErrorView: UIView {
    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabelComponent!
    
    func configure(withTitle title: String?, description: String?, image: UIImage?) {
        titleLabel.text = title
        descriptionLabel.text = description
        imageView.image = image
    }
}
