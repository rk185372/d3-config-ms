//
//  LocationDetailsAddressCell.swift
//  LocationsPresentation
//
//  Created by Branden Smith on 6/9/20.
//

import ComponentKit
import Foundation
import UIKit

final class LocationDetailsAddressCell: UITableViewCell {
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callImageButton: UIButtonComponent!
    @IBOutlet weak var callButtonsContainerView: UIView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var directionsImageButton: UIButtonComponent!
    @IBOutlet weak var directionsButtonsContainerView: UIView!
}
