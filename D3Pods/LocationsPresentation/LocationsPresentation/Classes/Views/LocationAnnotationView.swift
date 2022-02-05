//
//  LocationAnnotationView.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/27/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import ComponentKit
import Localization
import Locations
import MapKit
import SnapKit
import UIKit

final class LocationAnnotationView: MKMarkerAnnotationView {

    static let reuseIdentifier = "LocationAnnotation"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(withStyleProvider styleProvider: ComponentStyleProvider) {
        let componentStyle: ImageViewStyle = styleProvider["imageCta"]

        markerTintColor = componentStyle.tintColor.color

        if let annotation = annotation as? LocationAnnotation {
            glyphImage = UIImage(
                named: annotation.location.type.imageName,
                in: LocationsPresentationBundle.bundle,
                compatibleWith: nil
            )
            glyphTintColor = .white
        }
    }
}
