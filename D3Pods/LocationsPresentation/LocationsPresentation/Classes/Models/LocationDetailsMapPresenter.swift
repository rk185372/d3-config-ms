//
//  LocationDetailsMapPresenter.swift
//  LocationsPresentation
//
//  Created by Branden Smith on 6/10/20.
//

import Foundation
import Locations
import UITableViewPresentation

struct LocationDetailsMapPresenter: UITableViewPresentable {
    private let location: Location
    private let height: CGFloat
    
    init(location: Location, height: CGFloat = 100.0) {
        self.location = location
        self.height = height
    }
    
    func configure(cell: LocationDetailsMapCell, at indexPath: IndexPath) {
        cell.heightConstraint.constant = height
        cell.mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: LocationAnnotationView.reuseIdentifier)
        cell.mapView.removeAnnotations(cell.mapView.annotations)
        
        let annotation = LocationAnnotation(location: location)
        cell.mapView.addAnnotation(annotation)
        cell.mapView.showAnnotations([annotation], animated: false)
    }
}

extension LocationDetailsMapPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: LocationsPresentationBundle.bundle)
    }
}
