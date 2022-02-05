//
//  LocationDetailsAddressPresenter.swift
//  LocationsPresentation
//
//  Created by Branden Smith on 6/10/20.
//

import Foundation
import Localization
import Locations
import UITableViewPresentation

protocol LocationDetailsAddressPresenterDelegate: class {
    func directionsTapped(_ sender: UIButton)
    func callTapped(_ sender: UIButton, forURL url: URL)
}

final class LocationDetailsAddressPresenter: UITableViewPresentable {
    private let location: Location
    private let l10nProvider: L10nProvider
    
    private weak var delegate: LocationDetailsAddressPresenterDelegate?
    
    init(location: Location, l10nProvider: L10nProvider, delegate: LocationDetailsAddressPresenterDelegate? = nil) {
        self.location = location
        self.l10nProvider = l10nProvider
        self.delegate = delegate
    }
    
    func configure(cell: LocationDetailsAddressCell, at indexPath: IndexPath) {
        cell.locationTitleLabel.text = location.name
        cell.locationAddressLabel.text = location.address.formattedString
        
        cell.callButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.callButton.addTarget(self, action: #selector(callButtonTapped(_:)), for: .touchUpInside)
        
        cell.callImageButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.callImageButton.addTarget(self, action: #selector(callButtonTapped(_:)), for: .touchUpInside)
        
        cell.directionsButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.directionsButton.addTarget(self, action: #selector(directionsButtonTapped(_:)), for: .allEvents)
        
        cell.directionsImageButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.directionsImageButton.addTarget(self, action: #selector(directionsButtonTapped(_:)), for: .allEvents)
        
        cell.callButtonsContainerView.accessibilityLabel = l10nProvider.localize("launchPage.geolocation.button.call")
        cell.directionsButtonsContainerView.accessibilityLabel = l10nProvider.localize("launchPage.geolocation.button.directions")
        
        if PhoneFormatter.phoneNumberFormatter(phone: location.phoneNumber) != nil {
            cell.callImageButton.setImage(UIImage(named: "PhoneIcon"), for: .normal)
            cell.callButtonsContainerView.isHidden = false
        } else {
            cell.callButtonsContainerView.isHidden = true
        }

        cell.directionsImageButton.setImage(UIImage(named: "DirectionsIcon"), for: .normal)
    }
    
    @objc private func callButtonTapped(_ sender: UIButton) {
        guard let url = PhoneFormatter.phoneNumberFormatter(phone: location.phoneNumber) else { return }
        
        delegate?.callTapped(sender, forURL: url)
    }
    
    @objc private func directionsButtonTapped(_ sender: UIButton) {
        delegate?.directionsTapped(sender)
    }
}

extension LocationDetailsAddressPresenter: Equatable {
    static func ==(_ lhs: LocationDetailsAddressPresenter, _ rhs: LocationDetailsAddressPresenter) -> Bool {
        return lhs.location == rhs.location
    }
}

extension LocationDetailsAddressPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: LocationsPresentationBundle.bundle)
    }
}
