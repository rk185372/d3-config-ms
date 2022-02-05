//
//  LocationDetailsMapCell.swift
//  LocationsPresentation
//
//  Created by Branden Smith on 6/10/20.
//

import Foundation
import MapKit
import UIKit

final class LocationDetailsMapCell: UITableViewCell {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}
