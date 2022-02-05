//
//  LocationsMapInterfaceController.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/23/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Dip
import Foundation
import Localization
import Locations
import WatchKit

class LocationsMapInterfaceController: WKInterfaceController {
    @IBOutlet var mapView: WKInterfaceMap!
    @IBOutlet var locationName: WKInterfaceLabel!
    @IBOutlet var locationAddress: WKInterfaceLabel!
    @IBOutlet var locationHours: WKInterfaceLabel!
    @IBOutlet var callButton: WKInterfaceButton!

    var locationAnnotation: Location!
    var l10nProvider: L10nProvider!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        l10nProvider = try! DependencyContainer.shared.resolve()
        callButton.setTitle(l10nProvider.localize("watch.locations.call.label"))

        guard let annotation = context as? Location else { return }

        locationAnnotation = annotation
        locationName.setText(locationAnnotation.name)
        locationAddress.setText(locationAnnotation.address.street)
        locationHours.setText(locationAnnotation.todaysSchedule)

        let location = locationAnnotation.coordinate

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)

        let height = WKInterfaceDevice.current().screenBounds.size.height
        let heightValues: (base: CGFloat, padding: CGFloat) = height == 195 ? (74, 42) : (50, 34)

        var baseHeight: CGFloat = heightValues.base

        if locationAnnotation.phoneNumber != nil {
            callButton.setHidden(false)
            baseHeight = baseHeight + heightValues.padding
        } else {
            callButton.setHidden(true)
        }

        if locationAnnotation.todaysSchedule != nil {
            baseHeight += 15
        }

        mapView.setHeight(baseHeight)
        mapView.addAnnotation(location, with: .red)
        mapView.setRegion(region)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func callButtonPressed() {
        guard let phoneNumber = locationAnnotation.phoneNumber else { return }
        guard let tel = URL(string: "tel:\(phoneNumber)") else { return }
        WKExtension.shared().openSystemURL(tel)
    }
}

