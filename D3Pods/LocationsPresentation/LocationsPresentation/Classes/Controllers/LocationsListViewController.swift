//
//  LocationsListViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/20/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Localization
import Locations
import MapKit
import RxSwift
import UIKit
import UITableViewPresentation

protocol LocationsListViewControllerDelegate: class {
    func locationSelected(location: Location, for locationsListViewController: LocationsListViewController)
    func panRecognizerDidPan(_ sender: UIPanGestureRecognizer, inListViewController viewController: LocationsListViewController)
}

final class LocationsListViewController: UIViewController {
    weak var delegate: LocationsListViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerDividerView: UIView!

    private let bag = DisposeBag()

    var l10nProvider: L10nProvider!

    private var presentableDataSource: UITableViewPresentableDataSource!
    private var viewModel: LocationsViewModel?
    private var mapView: MKMapView?
    private var currentLocations: [Location] = []

    private let noLocationsView: NoLocationsView = {
        return LocationsPresentationBundle
            .bundle
            .loadNibNamed("NoLocationsView", owner: self, options: nil)?
            .first as! NoLocationsView
    }()
    
    private let errorView: GenericErrorView = {
        return LocationsPresentationBundle
            .bundle
            .loadNibNamed("GenericErrorView", owner: self, options: nil)?
            .first as! GenericErrorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        presentableDataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)

        headerView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(panRecognizerDidPan(_:)))
        )
    }

    func selected(location: Location) {
        guard let index = currentLocations.firstIndex(of: location) else { return }

        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)

        if tableView.bounds.contains(tableView.rectForRow(at: indexPath)) {
            UIView.animate(withDuration: 0.4, animations: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
        }

        tableView
            .rx
            .didEndScrollingAnimation
            .subscribe(onNext: { [unowned self] in
                DispatchQueue.main.async {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
            .disposed(by: bag)
    }
    
    func connect(viewModel: LocationsViewModel, forMapView mapView: MKMapView) {
        self.viewModel = viewModel
        self.mapView = mapView
    }

    func updateList(withLocations locationsResult: LocationsServiceResult) {
        guard let mapView = mapView else { return }

        errorView.removeFromSuperview()
        noLocationsView.removeFromSuperview()

        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
        let supplementaryViewFrame = CGRect(
            origin: .zero,
            size: CGSize(
                width: tableView.bounds.width,
                height: tableView.bounds.height - tabBarHeight
            )
        )
        
        if case let LocationsServiceResult.failure(error) = locationsResult,
           ((error as NSError?)?.code ?? 0) < 0 {
            showErrorView(for: .networkError, withFrame: supplementaryViewFrame)
            return
        }
        
        guard case let LocationsServiceResult.success(locations) = locationsResult else {
            showErrorView(for: .generalError, withFrame: supplementaryViewFrame)
            return
        }

        let visibleLocations = mapView
            .annotations(in: mapView.visibleMapRect)
            .compactMap({ ($0 as? LocationAnnotation)?.location })

        currentLocations = locations.filter({ visibleLocations.contains($0) })

        let presentables = currentLocations.map { location in
            return LocationPresenter(location: location, l10nProvider: l10nProvider, delegate: self)
        }

        if presentables.isEmpty {
            noLocationsView.frame = supplementaryViewFrame
            tableView.addSubview(noLocationsView)
        }

        self.presentableDataSource.tableViewModel = UITableViewModel(
            // We use the .blank footer here to get rid of the cell separators when rows is empty.
            sections: [UITableViewSection(rows: presentables, header: .none, footer: .blank)]
        )
    }

    @objc private func panRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        delegate?.panRecognizerDidPan(sender, inListViewController: self)
    }
}

extension LocationsListViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let viewModel = viewModel else { return }
        guard case let LocationsServiceResult.success(locations) = viewModel.locations.value else { return }

        let location = locations[indexPath.row]

        delegate?.locationSelected(location: location, for: self)
    }
}

extension LocationsListViewController: LocationPresenterDelegate {
    func presenter(_ presenter: LocationPresenter, shouldPromptUserWithAlert alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

private extension LocationsListViewController {
    enum ErrorType {
        case generalError, networkError
    }
    
    func showErrorView(for type: ErrorType, withFrame frame: CGRect) {
        
        switch type {
        case .networkError:
            errorView.configure(withTitle: l10nProvider.localize("launchPage.geolocation.networkError.title"),
                                description: l10nProvider.localize("launchPage.geolocation.networkError.description"),
                                image: LocationsPresentationBundle.image(named: "networkErrorIcon"))
        default:
            errorView.configure(withTitle: l10nProvider.localize("app.error.generic.title"),
                                description: l10nProvider.localize("launchPage.geolocation.genericError.description"),
                                image: LocationsPresentationBundle.image(named: "errorIcon"))
        }
        
        errorView.frame = frame
        tableView.addSubview(errorView)

        self.presentableDataSource.tableViewModel = UITableViewModel(
            sections: [
                UITableViewSection(rows: [AnyUITableViewPresentable](), header: .none, footer: .blank)
            ]
        )
    }
}
