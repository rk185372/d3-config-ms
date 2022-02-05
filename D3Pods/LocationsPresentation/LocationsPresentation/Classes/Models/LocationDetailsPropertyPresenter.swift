//
//  LocationDetailsPropertyPresenter.swift
//  LocationsPresentation
//
//  Created by Branden Smith on 6/10/20.
//

import Foundation
import UITableViewPresentation

struct LocationDetailsPropertyPresenter: UITableViewPresentable {

    private let name: String
    private let value: String
    
    init(propertyName: String, value: String) {
        self.name = propertyName
        self.value = value
    }
    
    func configure(cell: LocationDetailsPropertyCell, at indexPath: IndexPath) {
        cell.nameLabel.text = name
        cell.valueLabel.text = value
    }
}

extension LocationDetailsPropertyPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: LocationsPresentationBundle.bundle)
    }
}
