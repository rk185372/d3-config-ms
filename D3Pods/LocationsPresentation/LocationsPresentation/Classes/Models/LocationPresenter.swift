//
//  LocationPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/20/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Contacts
import Foundation
import Localization
import Locations
import UITableViewPresentation

protocol LocationPresenterDelegate: class {
    func presenter(_ presenter: LocationPresenter, shouldPromptUserWithAlert alert: UIAlertController)
}

final class LocationPresenter: UITableViewPresentable {
    let location: Location

    private let l10nProvider: L10nProvider
    private weak var delegate: LocationPresenterDelegate?
    
    init(location: Location, l10nProvider: L10nProvider, delegate: LocationPresenterDelegate) {
        self.location = location
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }

    func configure(cell: LocationCell, at indexPath: IndexPath) {
        cell.nameLabel.text = location.name
        cell.subtitleLabel.text = location.address.formattedString

        if PhoneFormatter.phoneNumberFormatter(phone: location.phoneNumber) != nil {
            cell.callImageButton.isHidden = false
            cell.callButton.isHidden = false

            cell.callImageButton.setImage(UIImage(named: "PhoneIcon"), for: .normal)
            cell.callImageButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.callImageButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
            cell.callImageButton.isExclusiveTouch = true

            cell.callButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
            cell.callImageButton.isExclusiveTouch = true
        } else {
            cell.callImageButton.isHidden = true
            cell.callButton.isHidden = true
        }

        cell.directionsImageButton.setImage(UIImage(named: "DirectionsIcon"), for: .normal)
        cell.directionsImageButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.directionsImageButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)
        cell.directionsImageButton.isExclusiveTouch = true

        cell.directionsButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)
        cell.directionsButton.isExclusiveTouch = true
        
        if #available(iOS 13, *) {
            cell.callImageButton.isAccessibilityElement = true
            cell.callImageButton.accessibilityLabel = l10nProvider.localize(
                "launchPage.geolocation.cell.customAction.call.altText",
                parameterMap: ["location": location.name])
            
            cell.directionsImageButton.isAccessibilityElement = true
            cell.directionsImageButton.accessibilityLabel = l10nProvider.localize(
                "launchPage.geolocation.cell.customAction.directions.altText",
                parameterMap: ["location": location.name]
            )
        } else {
            cell.accessibilityCustomActions = customActions(
                withCallButtonTitle: l10nProvider.localize(
                    "launchPage.geolocation.cell.customAction.call.altText",
                    parameterMap: ["location": location.name]
                ),
                andDirectionsButtonTitle: l10nProvider.localize(
                    "launchPage.geolocation.cell.customAction.directions.altText",
                    parameterMap: ["location": location.name]
                )
            )
        }
    }
    
    @objc func callTapped() {
        guard let url = PhoneFormatter.phoneNumberFormatter(phone: location.phoneNumber) else {
                let alert = UIAlertController(
                    title: l10nProvider.localize("app.error.generic.title"),
                    message: l10nProvider.localize("launchPage.geolocation.error.call-failed"),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "app.alert.btn.ok", style: .cancel, handler: nil))

                delegate?.presenter(self, shouldPromptUserWithAlert: alert)

                return
        }

        UIApplication.shared.open(url)
    }
    
    @objc func directionsTapped() {
        location.navigationInMaps()
    }

    private func customActions(withCallButtonTitle callTitle: String,
                               andDirectionsButtonTitle directionsTitle: String) -> [UIAccessibilityCustomAction] {
        return [
            UIAccessibilityCustomAction(name: callTitle, target: self, selector: #selector(callTapped)),
            UIAccessibilityCustomAction(name: directionsTitle, target: self, selector: #selector(directionsTapped))
        ]
    }
}

extension LocationPresenter: Equatable {
    static func == (lhs: LocationPresenter, rhs: LocationPresenter) -> Bool {
        return lhs.location == rhs.location
    }
}

extension LocationPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return LocationsPresentationBundle.nib(name: cellReuseIdentifier)
    }
}
