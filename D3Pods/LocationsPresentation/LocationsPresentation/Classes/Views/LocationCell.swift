//
//  LocationCell.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/20/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UIKit

final class LocationCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callImageButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var directionsImageButton: UIButton!

    // We are overriding this method so that the background color of the
    // call and directions buttons will not change colors when the cell is
    // selected.
    override func setSelected(_ selected: Bool, animated: Bool) {
        let originalCallButtonBackgroundColor = callButton.backgroundColor
        let originalDirectionsButtonBackgroundColor = directionsButton.backgroundColor

        super.setSelected(selected, animated: animated)

        callButton.backgroundColor = originalCallButtonBackgroundColor
        directionsButton.backgroundColor = originalDirectionsButtonBackgroundColor
    }
}
