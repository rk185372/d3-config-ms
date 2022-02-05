//
//  MKMapView+D3.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/24/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import MapKit

typealias Miles = Double

extension MKMapView {
    
    /// Sets the visible region so that the map displays the specified annotations with padding.
    ///
    /// - Parameters:
    ///   - annotations: The annotations that you want to be visible in the map.
    ///   - insets: The amount of additional space (measured in screen points) to make visible around the specified rectangle.
    ///   - animated: true if you want the map requion change to be animated, or false if you want the map to display the new
    ///               region immediately without animations.
    public final func showAnnotations(_ annotations: [MKAnnotation], edgePadding insets: UIEdgeInsets, animated: Bool) {
        var zoomRect = MKMapRect.null
        
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
            if zoomRect.isNull {
                zoomRect = pointRect
            } else {
                zoomRect = zoomRect.union(pointRect)
            }
        }
        
        // NOTE: If passing in only a single annotation the pad rect will be empty, this can produce unexpected results when specifying
        // an inset value. For now i'm adding an arbitrary size to the rect. This should be looked at and further.
        if zoomRect.isNull {
            zoomRect = MKMapRect(origin: zoomRect.origin, size: MKMapSize(width: 1, height: 100))
        }
        
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: animated)
    }
    
    func zoomTo(radius: Miles, location: CLLocationCoordinate2D, animated: Bool) {
        let scalingFactor = abs(cos(2 * .pi * location.latitude / 360))
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: radius / 69, longitudeDelta: radius / (scalingFactor * 69))
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        setRegion(region, animated: animated)
    }
}
