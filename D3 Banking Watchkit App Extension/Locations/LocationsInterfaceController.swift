//
//  LocationsInterfaceController.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/23/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import CoreLocation
import Dip
import Foundation
import Localization
import Locations
import Logging
import RxSwift
import Utilities
import WatchKit

class LocationsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var loadingImage: WKInterfaceImage!
    @IBOutlet var loadingGroup: WKInterfaceGroup!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var locationsTable: WKInterfaceTable!

    @IBOutlet var zipSearchGroup: WKInterfaceGroup!

    @IBOutlet var enterZipLabel: WKInterfaceLabel!
    @IBOutlet var zipDigit1: WKInterfacePicker!
    @IBOutlet var zipDigit2: WKInterfacePicker!
    @IBOutlet var zipDigit3: WKInterfacePicker!
    @IBOutlet var zipDigit4: WKInterfacePicker!
    @IBOutlet var zipDigit5: WKInterfacePicker!

    @IBOutlet var search: WKInterfaceButton!
    @IBOutlet var loadMoreButton: WKInterfaceButton!
    @IBOutlet var noLocationsLabel: WKInterfaceLabel!

    @IBOutlet var networkErrorGroup: WKInterfaceGroup!
    @IBOutlet var networkErrorTitleLabel: WKInterfaceLabel!
    @IBOutlet var networkErrorDescriptionLabel: WKInterfaceLabel!

    let loadMoreButtonText = "Load More"
    let loadMoreButtonLoadingText = "Loading"

    var locationManager = CLLocationManager()
    var locationArray: [Location] = []
    var zipCodeArray: [Int]
    var displayCountLimit: Int
    var currentDisplayCount: Int

    private let bag = DisposeBag()
    private var l10nProvider: L10nProvider!
    private var viewModel: WatchLocationsViewModel!


    override init() {
        zipCodeArray = [Int](repeating: 0, count: 5)
        displayCountLimit = 25
        currentDisplayCount = 0
        l10nProvider = try! DependencyContainer.shared.resolve()

        viewModel = WatchLocationsViewModel(
            service: try! DependencyContainer.shared.resolve(),
            searchParams: nil
        )

        super.init()
    }

    override func awake(withContext context: Any?) {
        setupLocationManager()
        setupZipCodeSearch()

        setTitle(l10nProvider.localize("watch.locations.title"))
        loadingLabel.setText(l10nProvider.localize("watch.locations.loading"))
        enterZipLabel.setText(l10nProvider.localize("watch.locations.zip.label"))
        noLocationsLabel.setText(l10nProvider.localize("watch.locations.none"))
        networkErrorTitleLabel.setText(l10nProvider.localize("watch.locations.networkError.title"))
        networkErrorDescriptionLabel.setText(l10nProvider.localize("watch.locations.networkError.description"))

        viewModel.locations
            .subscribe(onNext: { [unowned self] response in
                self.updateView(for: response)
            })
            .disposed(by: bag)
    }

    private func updateView(for response: LocationsResponse) {
        switch response {
        case .none:
            updateViewForNone()
        case .success(let locations):
            updateViewForLocations(locations)
        case .failure:
            updateViewForNetworkError()
        }
    }

    private func updateViewForNone() {
        D3Spinner().startSpinner(self.loadingImage)
        self.loadingGroup.setHidden(false)
        self.networkErrorGroup.setHidden(true)
        self.noLocationsLabel.setHidden(true)
        self.locationsTable.setHidden(true)
        self.loadMoreButton.setHidden(true)
        self.zipSearchGroup.setHidden(true)
    }

    private func updateViewForLocations(_ locations: [Location]) {
        D3Spinner().stopSpinner(self.loadingImage)
        self.locationArray = locations
        self.currentDisplayCount = 0

        self.loadingGroup.setHidden(true)
        self.networkErrorGroup.setHidden(true)
        self.noLocationsLabel.setHidden(true)
        self.locationsTable.setHidden(true)
        self.loadMoreButton.setHidden(true)
        self.zipSearchGroup.setHidden(true)

        self.displayNextGroupOfLocations()
    }

    private func updateViewForNetworkError() {
        D3Spinner().stopSpinner(self.loadingImage)
        self.networkErrorGroup.setHidden(false)
        self.loadingGroup.setHidden(true)
        self.noLocationsLabel.setHidden(true)
        self.locationsTable.setHidden(true)
        self.loadMoreButton.setHidden(true)
        self.zipSearchGroup.setHidden(true)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500 // meters
        locationManager.requestLocation()
    }

    private func setupZipCodeSearch() {
        let pickerItems: [WKPickerItem] = (0...9).map {
            let pickerItem = WKPickerItem()
            pickerItem.title = "\($0)"
            pickerItem.caption = "\($0)"
            return pickerItem
        }

        zipDigit1.setItems(pickerItems)
        zipDigit2.setItems(pickerItems)
        zipDigit3.setItems(pickerItems)
        zipDigit4.setItems(pickerItems)
        zipDigit5.setItems(pickerItems)

        zipSearchGroup.setHidden(true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        guard let errCode = CLError.Code(rawValue: error._code) else { return }

        switch errCode {
        case .denied, .locationUnknown:
            zipSearchGroup.setHidden(false)
            loadingGroup.setHidden(true)
            D3Spinner().stopSpinner(self.loadingImage)

        default: break
        }

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else { return }

        if viewModel.searchParams.value != nil {
            viewModel.searchParams.modify(modifier: { params in
                params?.coordinate = mostRecentLocation.coordinate
            })
        } else {
            viewModel.searchParams.accept(
                LocationSearchParams(coordinate: mostRecentLocation.coordinate, radius: .threeMiles, address: nil, type: .all)
            )
        }
    }

    @IBAction func zipDigit1Changed(_ value: Int) {
        zipCodeArray[0] = value
    }

    @IBAction func zipDigit2Changed(_ value: Int) {
        zipCodeArray[1] = value
    }

    @IBAction func zipDigit3Changed(_ value: Int) {
        zipCodeArray[2] = value
    }

    @IBAction func zipDigit4Changed(_ value: Int) {
        zipCodeArray[3] = value
    }

    @IBAction func zipDigit5Changed(_ value: Int) {
        zipCodeArray[4] = value
    }


    @IBAction func searchButtonPressed() {
        zipSearchGroup.setHidden(true)
        loadingGroup.setHidden(false)

        D3Spinner().startSpinner(self.loadingImage)

        let address = zipCodeArray.reduce("", { $0 + "\($1)" })

        if viewModel.searchParams.value != nil {
            viewModel.searchParams.modify { params in
                 params?.address = address
            }
        } else {
            viewModel.searchParams.accept(
                LocationSearchParams(address: address)
            )
        }
    }

    @IBAction func loadMoreLocations() {
        self.loadMoreButton.setTitle(self.loadMoreButtonLoadingText)
        self.loadMoreButton.setEnabled(false)
        DispatchQueue.main.async {
            self.displayNextGroupOfLocations()
        }
    }

    func displayNextGroupOfLocations() {
        D3Spinner().startSpinner(loadingImage)
        locationsTable.setHidden(false)

        guard !locationArray.isEmpty else {
            loadingGroup.setHidden(true)
            D3Spinner().stopSpinner(loadingImage)
            noLocationsLabel.setHidden(false)
            return
        }

        let endOfGroup = (displayCountLimit + currentDisplayCount) > locationArray.count ? locationArray.count : displayCountLimit + currentDisplayCount
        let subLocationArray = locationArray[0...max(endOfGroup - 1, 0)]

        subLocationArray.enumerated().forEach { (index, location) in
            if index > currentDisplayCount - 1 {
                locationsTable.insertRows(at: IndexSet(integer: index), withRowType: "LocationRow")
            }

            guard let row = locationsTable.rowController(at: index) as? LocationRowController else { return }

            row.nameLabel.setText(location.name)
            row.addressLabel.setText(location.address.street)
            row.locationTypeImage.setImageNamed(location.type == .atm ? "locationsAtm" : "locationsBank")

            if let hours = location.todaysSchedule {
                row.hoursLabel.setHidden(false)
                row.hoursLabel.setText(hours)
            } else {
                row.hoursLabel.setHidden(true)
            }

            if let distance = location.distance {
                row.distanceLabel.setHidden(false)
                row.distanceLabel.setText(distance)
            } else {
                row.distanceLabel.setHidden(true)
            }

            loadMoreButton.setTitle(loadMoreButtonText)
            loadMoreButton.setEnabled(true)
            loadMoreButton.setHidden(endOfGroup == locationArray.count)
            currentDisplayCount = index
        }

        loadingGroup.setHidden(true)
        D3Spinner().stopSpinner(loadingImage)
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return locationArray[rowIndex]
    }
}
