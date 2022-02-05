//
//  LocationsViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/19/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Analytics
import ComponentKit
import Foundation
import Localization
import Locations
import Logging
import MapKit
import Perform
import RxRelay
import RxSwift
import SnapKit
import UIKit
import Utilities
import CompanyAttributes

final class LocationsViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var radiusButton: IconButtonComponent!
    @IBOutlet weak var searchScopeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchResultsContainerView: UIView!
    @IBOutlet weak var listViewContainer: UIView!
    @IBOutlet weak var listViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var wrapperView: UIView!
    
    private let bag = DisposeBag()
    private let locationManager: CLLocationManager = CLLocationManager()
    private let distanceRequiredForUpdate: CLLocationDistance = 100.0
    private let lastLocation = BehaviorRelay<CLLocation?>(value: nil)
    private let isVisible = BehaviorRelay(value: false)
    private let defaultScopes: [SearchScope] = [.all, .branch, .atm]

    var selectedLocation: Location?
    var viewModel: LocationsViewModel!
    var styleProvider: ComponentStyleProvider!
    var l10nProvider: L10nProvider!
    var companyAttributesHolder: CompanyAttributesHolder!

    private var searchController: UISearchController!
    private var searchScope = [SearchScope]()

    private var locationsListViewController: LocationsListViewController! {
        return children.first as? LocationsListViewController
    }
    
    private lazy var radiusViewController = StoryboardScene.Locations.searchRadiusPopupViewController.instantiate()
    private lazy var searchResultsController = StoryboardScene.Locations.searchResultsViewController.instantiate()
    private lazy var edgePadding: UIEdgeInsets = {
        return UIEdgeInsets(top: 50,left: 50, bottom: self.containerView.frame.height, right: 50)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchScopeSegmentedControl()
        
        searchBar.placeholder = l10nProvider.localize("launchPage.geolocation.search-placeholder")
        searchBar.delegate = self
        searchBar.accessibilityTraits = .searchField
        searchBar.accessibilityHint = l10nProvider.localize("launchPage.geolocation.search-placeholder")

        radiusButton.iconImage = Asset.downArrow.image
        radiusButton.iconAlignment = .right
        radiusButton.iconSize = CGSize(width: 13, height: 13)
        radiusButton.accessibilityTraits = .button
        radiusButton.accessibilityHint = l10nProvider.localize("location.radiusButton.altText")
        
        mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: LocationAnnotationView.reuseIdentifier)
        wrapperView.accessibilityElements = [mapView as Any]
                
        locationManager.delegate = self
        
        locationsListViewController.connect(viewModel: viewModel, forMapView: mapView)
        locationsListViewController.delegate = self
        locationsListViewController.l10nProvider = l10nProvider
        
        if navigationController?.isBeingPresented == true {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            doneButton.accessibilityTraits = .button
            doneButton.accessibilityHint = l10nProvider.localize("location.doneButton.altText")
            navigationItem.leftBarButtonItem = doneButton
        }

        setUpReactiveWiring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible.accept(true)
        
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        self.mapView.showsUserLocation = (locationAuthStatus == .authorizedAlways || locationAuthStatus == .authorizedWhenInUse)

        locationManager.requestWhenInUseAuthorization()
        
        UIAccessibility.post(notification: .screenChanged, argument: self.navigationItem.backBarButtonItem)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible.accept(false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @objc func doneButtonTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func radiusButtonTapped() {
        if radiusViewController.view.isVisible {
            radiusViewController.slideOut()
        } else {
            radiusViewController.delegate = self
            radiusViewController.popOver(parentViewController: self, l10nProvider: l10nProvider)
        }
    }
    
    private func setupSearchScopeSegmentedControl() {
        var locationsEnabled: Bool {
            return companyAttributesHolder.companyAttributes.value?.value(forKey: "locations.enabled") ?? false
        }
        
        setupSegmentsForScopes(locationsEnabled ? customScopes : defaultScopes)
    }
    
    private var customScopes: [SearchScope] {
        var scopes = [SearchScope]()
        let attributes = companyAttributesHolder.companyAttributes.value
        
        if attributes?.value(forKey: "locations.search.types.all.enabled") ?? true {
            scopes.append(.all)
        }
        
        if attributes?.value(forKey: "locations.search.types.branch.enabled") ?? true {
            scopes.append(.branch)
        }
        
        if attributes?.value(forKey: "locations.search.types.atm.enabled") ?? true {
            scopes.append(.atm)
        }
        
        if scopes.isEmpty {
            scopes.append(.empty)
        }
        
        return scopes
    }
    
    private func setupSegmentsForScopes(_ searchScopes: [SearchScope]) {
        searchScopeSegmentedControl.removeAllSegments()
        searchScopes.forEach { insertSegment(scope: $0) }
        searchScopeSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func insertSegment(scope: SearchScope) {
        searchScopeSegmentedControl.insertSegment(withTitle: l10nProvider.localize(scope.l10nKey),
                                                  at: searchScopeSegmentedControl.numberOfSegments,
                                                  animated: false)
        searchScope.append(scope)
    }
    
    private func setUpReactiveWiring() {
        // Pipe search results into the live results list or map, whichever is visible
        Observable
            .combineLatest(viewModel.locations, searchResultsController.rx.isVisible)
            .subscribe(
                onNext: { [unowned self] (locationsResult, isSearching) in
                    if isSearching {
                        self.searchResultsController.viewModel.locations.accept(locationsResult)
                    } else {
                        if case let LocationsServiceResult.success(locations) = locationsResult {
                            if let address = self.viewModel.searchParams.value.address {
                                getLocation(forAddress: address) { location, _ in
                                    if let location = location {
                                        let radius = self.viewModel.searchParams.value.radius.rawValue
                                        self.zoomTo(radius: radius, location: location.coordinate, animated: false)
                                    }
                                    self.updateMap(locations: locations)
                                }
                            } else {
                                self.updateMap(locations: locations)
                            }
                        }
                    }
                },
                onError: { (error) in
                    log.error("\(error)", context: error)
                }
            ).disposed(by: bag)
        
        // Update the radius button's title when the selected radius changes
        viewModel.searchParams
            .map { $0.radius }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (radius) in
                self.radiusButton.setTitle(radius.description, for: .normal)
                self.radiusButton.accessibilityLabel = self.l10nProvider.localize(
                    "launchPage.geolocation.distance.spinner.contentDescription",
                    parameterMap:
                        ["title": self.l10nProvider.localize("launchPage.geolocation.distance.spinner.label"),
                         "searchRadius": radius
                        ]
                )
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement,
                                     argument: self.radiusButton.titleLabel)
            })
            .disposed(by: bag)

        // Update the search params when the scope or text changes
        Observable
            .combineLatest(searchScopeSegmentedControl.rx.selectedSegmentIndex, searchBar.rx.text)
            .subscribe(onNext: { [unowned self] (scopeIndex, searchText) in
                let scope = self.searchScope[scopeIndex]
                self.viewModel.searchParams.modify { (params) in
                    params.type = scope
                    params.address = searchText
                }
            })
            .disposed(by: bag)
        
        // The first time this view appears, if there is a selected location, segue to details immediately.
        isVisible
            .asObservable()
            .filter { $0 }
            .take(1)
            .ignoreElements()
            .subscribe(onCompleted: { [unowned self] in
                if self.selectedLocation != nil {
                    self.perform(.showLocationDetails, prepare: self.segueToDetailsController)
                }
            })
            .disposed(by: bag)
        
        // The first time we get a location, zoom to it.
        lastLocation.asObservable()
            .skipNil()
            .take(1)
            .subscribe(onNext: { [unowned self] (location) in
                log.debug("Zooming to first location")
                let radius = self.viewModel.searchParams.value.radius.rawValue
                self.zoomTo(radius: radius, location: location.coordinate, animated: true)
            })
            .disposed(by: bag)
        
        // Feed de-jittered location into search params
        lastLocation.asObservable()
            .skipNil()
            .dejitter { [unowned self] in $0.distance(from: $1) >= self.distanceRequiredForUpdate }
            .subscribe(onNext: { [unowned self] (location) in
                self.viewModel.searchParams.modify { (params) in
                    params.coordinate = location.coordinate
                }
            })
            .disposed(by: bag)

        viewModel
            .locations
            .subscribe(onNext: { [unowned self] locationsResult in
                self.locationsListViewController.updateList(withLocations: locationsResult)
            })
            .disposed(by: bag)
    }
    
    private func updateMap(locations: [Location]) {
        mapView.removeAnnotations(mapView.annotations)
        
        if !locations.isEmpty {
            let annotations = locations.map { location in
                return LocationAnnotation(location: location)
            }
            mapView.addAnnotations(annotations)
            mapView.showAnnotations(annotations, edgePadding: edgePadding, animated: true)
        }
    }
    
    private func zoomTo(radius: Miles, location: CLLocationCoordinate2D, animated: Bool) {
        let scalingFactor = abs(cos(2 * .pi * location.latitude / 360))
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: radius / 69, longitudeDelta: radius / (scalingFactor * 69))
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    private func segueToDetailsController(controller: LocationDetailsViewController) {
        controller.location = selectedLocation
        controller.styleProvider = styleProvider
        controller.l10nProvider = l10nProvider
        selectedLocation = nil
    }
    
    fileprivate func select(location: Location) {
        selectedLocation = location
        perform(.showLocationDetails, prepare: segueToDetailsController)
    }
}

extension LocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location {
            lastLocation.accept(location)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LocationAnnotation else {
            return nil
        }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: LocationAnnotationView.reuseIdentifier, for: annotation)

        if let annotationView = view as? LocationAnnotationView {
            annotationView.configure(withStyleProvider: styleProvider)
        }
        
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let location = (view.annotation as? LocationAnnotation)?.location else { return }

        locationsListViewController.selected(location: location)
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.locationsListViewController.updateList(withLocations: viewModel.locations.value)
    }
}

extension LocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default: break
        }
    }
}

extension LocationsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResultsController.delegate = self
        searchResultsController.slide(intoParentViewController: self, insideView: searchResultsContainerView)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
        searchResultsController.slideOut()
    }
}

extension LocationsViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_: SearchResultsViewController, selectedResult location: Location) {
        select(location: location)
    }
}

extension LocationsViewController: SearchRadiusPopupViewControllerDelegate {
    func searchRadiusPopupViewController(_ viewController: SearchRadiusPopupViewController, selectedRadius radius: SearchRadius) {
        viewModel.searchParams.modify { (params) in
            params.radius = radius
        }
    }
}

extension Segue {
    static var showLocationDetails: Segue<LocationDetailsViewController> {
        return .init(segue: StoryboardSegue.Locations.locationDetails)
    }
}

extension LocationsViewController: LocationsListViewControllerDelegate {
    func locationSelected(location: Location, for locationsListViewController: LocationsListViewController) {
        select(location: location)
    }

    func panRecognizerDidPan(_ sender: UIPanGestureRecognizer, inListViewController viewController: LocationsListViewController) {
        let velocity = sender.velocity(in: self.view)
        self.view.layoutIfNeeded()

        let (tabBarHeight, tabBarIsTranslucent) = getTabBarHeightAndTranslucentValueIfOneExists(viewController: self)

        // If the tab bar is translucent we need to include its height since the content will go behind it
        // this will allow the top of the drawer to remain above the tab bar. If it is not translucent
        // the offset will be from the top of the tab bar so don't want to account for the tab bar's height.
        let tabBarHeightOffset = (tabBarIsTranslucent) ? tabBarHeight + 44.0 : 44.0

        let drawerOffset: CGFloat = (tabBarHeight > 0)
            ? tabBarHeightOffset
            : 64.0

        // When the velocity of y is greater than zero, the user is pulling down.
        if velocity.y > 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.listViewContainerBottomConstraint.constant = -(self.listViewContainer.frame.height - drawerOffset)
                viewController.tableView.alpha = 0.0
                viewController.headerDividerView.alpha = 0.0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.listViewContainerBottomConstraint.constant = 0
                viewController.tableView.alpha = 1.0
                viewController.headerDividerView.alpha = 1.0
                self.view.layoutIfNeeded()
            })
        }
    }

    private func getTabBarHeightAndTranslucentValueIfOneExists(viewController: UIViewController) -> (CGFloat, Bool) {
        guard let tabBarController = getTabBarController(viewController: viewController) else { return (0.0, false) }

        return (tabBarController.tabBar.frame.height, tabBarController.tabBar.isTranslucent)
    }

    private func getTabBarController(viewController: UIViewController) -> UITabBarController? {
        guard let parent = viewController.parent else { return nil }

        if parent is UITabBarController {
            return (parent as! UITabBarController)
        }

        return getTabBarController(viewController: parent)
    }
}

extension LocationsViewController: TrackableScreen {
    var screenName: String {
        return "Locations"
    }
}

private extension LocationsViewController {
    func getLocation(forAddress address: String, onCompletion: @escaping (CLLocation?, Error?) -> Void) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            onCompletion(placemarks?.first?.location, error)
        })
    }
}
