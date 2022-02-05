//
//  LocationAnnotation.swift
//  Locations
//
//  Created by Andrew Watt on 8/1/18.
//

import Foundation
import MapKit

public final class LocationAnnotation: NSObject, MKAnnotation {
    public let location: Location
    
    public init(location: Location) {
        self.location = location
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    public var title: String? {
        return location.name
    }
}
