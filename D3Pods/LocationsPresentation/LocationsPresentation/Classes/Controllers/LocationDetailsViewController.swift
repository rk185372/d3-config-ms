//
//  LocationDetailsViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/25/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Analytics
import ComponentKit
import Foundation
import Localization
import Locations
import MapKit
import UIKit
import UITableViewPresentation

final class LocationDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var location: Location!
    var analyticsTracker: AnalyticsTracker!
    var styleProvider: ComponentStyleProvider!
    var l10nProvider: L10nProvider!
    
    private var dataSource: UITableViewPresentableDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = location.name
        
        setupDetailsView()
    }
    
    private func setupDetailsView() {
        var rows: [AnyUITableViewPresentable] = [
            AnyUITableViewPresentable(LocationDetailsMapPresenter(location: location, height: self.tableView.bounds.height * (2.0 / 3.0))),
            AnyUITableViewPresentable(LocationDetailsAddressPresenter(location: location, l10nProvider: l10nProvider, delegate: self))
        ]
        
        if !location.hours.isEmpty {
            rows.append(
                AnyUITableViewPresentable(
                    LocationDetailsPropertyPresenter(
                        propertyName: l10nProvider.localize("launchPage.geolocation.hours"),
                        value: location.hours.joined(separator: "\n")
                    )
                )
            )
        }
        
        if let extraProperties = location.properties {
            rows += extraProperties.map({
                AnyUITableViewPresentable(
                    LocationDetailsPropertyPresenter(propertyName: $0.name, value: $0.value)
                )
            })
        }
        
        dataSource = UITableViewPresentableDataSource(tableView: tableView)
        dataSource.tableViewModel = UITableViewModel(rows: rows)
    }
}

extension LocationDetailsViewController: LocationDetailsAddressPresenterDelegate {
    func directionsTapped(_ sender: UIButton) {
        analyticsTracker.trackEvent(AnalyticsEvent(category: "Locations/Detail", action: .click, name: "NavigateToLocation"))
        location.navigationInMaps()
    }
    
    func callTapped(_ sender: UIButton, forURL url: URL) {
        analyticsTracker.trackEvent(AnalyticsEvent(category: "Locations/Detail", action: .click, name: "CallLocation"))
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension LocationDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LocationAnnotation else { return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: LocationAnnotationView.reuseIdentifier, for: annotation)

        if let annotationView = view as? LocationAnnotationView {
            annotationView.configure(withStyleProvider: styleProvider)
        }

        return view
    }
}

extension LocationDetailsViewController: TrackableScreen {
    var screenName: String {
        return "Locations/Detail"
    }
}
