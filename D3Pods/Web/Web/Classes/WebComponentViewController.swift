//
//  WebComponentViewController.swift
//  Web
//
//  Created by Andrew Watt on 6/29/18.
//

import ComponentKit
import Localization
import Logging
import Permissions
import RxSwift
import RxRelay
import Session
import UIKit
import UITableViewPresentation
import Utilities
import Analytics

final class WebComponentViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableView!

    private var dataSource: UITableViewPresentableDataSource!

    private let permissionsManager: PermissionsManager
    private let model: WebComponentModel
    private let webViewControllerFactory: WebViewControllerFactory

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         webViewControllerFactory: WebViewControllerFactory,
         permissionsManager: PermissionsManager,
         model: WebComponentModel,
         userSession: UserSession,
         badgePathToCountObservableDictionary: [String: Observable<Int>] = [:]) {
        self.permissionsManager = permissionsManager
        self.model = model
        self.webViewControllerFactory = webViewControllerFactory

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "\(type(of: self))",
            bundle: WebBundle.bundle
        )

        userSession
            .rx
            .session
            .skip(1)
            .filter({ [unowned self] _ in self.isViewLoaded })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.loadNavigation()
            })
            .disposed(by: bag)
        
        for observable in userSession.rx.userProfiles {
            observable
                .distinctUntilChanged()
                .skip(1)
                .skipNil()
                .filter { [unowned self] _ in self.isViewLoaded }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (_) in
                    self.loadNavigation()
                })
                .disposed(by: self.bag)
        }
        
        userSession.rx.selectedProfileIndex
            .distinctUntilChanged()
            .skip(1)
            .skipNil()
            .filter { [unowned self] _ in self.isViewLoaded }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                self.loadNavigation()
            })
            .disposed(by: bag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNavigation()
    }

    private func loadNavigation() {
        dataSource = UITableViewPresentableDataSource(tableView: tableView)
        dataSource.delegate = self

        update(navigation: model.navigation)
    }

    private func update(navigation: WebComponentNavigation) {
        func getRows(from items: [WebComponentNavigation.Item]) -> [ComponentRow] {
            let rows = items.compactMap { (item) -> ComponentRow? in
                guard permissionsManager.isAccessible(feature: item.feature) else { return nil }
                let name = self.l10nProvider.localize(item.title)
                let componentPath = WebComponentPath(path: item.path, showsUserProfile: navigation.showsUserProfile)
                let row = ComponentRow(
                    name: name,
                    image: item.image,
                    componentPath: componentPath,
                    componentStyleProvider: componentStyleProvider
                )
                return row
            }
            return rows
        }

        self.title = self.l10nProvider.localize(navigation.title)

        guard !navigation.sections.isEmpty else {
            let rows = getRows(from: navigation.items)
            self.dataSource.tableViewModel = UITableViewModel(rows: rows)
            return
        }

        let sections = navigation.sections.compactMap({ (section) -> UITableViewSection in
            let header = TableSectionHeader(title: l10nProvider.localize(section.title))
            let rows = getRows(from: section.items)
            return UITableViewSection(
                rows: rows,
                header: .presentable(AnyUITableViewHeaderFooterPresentable(header)),
                footer: .none
            )
        })
        .filter { !$0.isEmpty }
        
        if sections.count == 1 {
            self.dataSource.tableViewModel = UITableViewModel(rows: sections[0].rows)
            return
        }
        
        self.dataSource.tableViewModel = UITableViewModel(sections: sections)
    }
}

extension WebComponentViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let row = presentable.base as? ComponentRow {
            do {
                let viewController = try webViewControllerFactory.create(componentPath: row.componentPath, isRootComponent: false)
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                log.error("Error createing web view controller: \(error)", context: error)
            }
        }
    }
}

extension WebComponentViewController: TrackableScreen {
    var screenName: String {
        return "WebViewNavList\(model.navigation.path)"
    }
}

final class ComponentRow: UITableViewPresentable, Equatable {
    let name: String
    let image: UIImage?
    let componentPath: WebComponentPath
    let componentStyleProvider: ComponentStyleProvider
    
    init(name: String, image: UIImage?, componentPath: WebComponentPath, componentStyleProvider: ComponentStyleProvider) {
        self.name = name
        self.image = image
        self.componentPath = componentPath
        self.componentStyleProvider = componentStyleProvider
    }
    
    func configure(cell: WebComponentCell, at indexPath: IndexPath) {
        cell.stackedMenuView.titleLabel.text = name
        cell.stackedMenuView.titleLabel.accessibilityTraits = .button
        cell.stackedMenuView.imageView.image = image

        let componentStyle: StackedMenuViewStyle = componentStyleProvider["stackedMenuOnDefault"]
        componentStyle.style(component: cell.stackedMenuView)
    }
    
    static func == (lhs: ComponentRow, rhs: ComponentRow) -> Bool {
        guard lhs.name == rhs.name else { return false }
        guard lhs.image == rhs.image else { return false }
        guard lhs.componentPath == rhs.componentPath else { return false }
        
        return true
    }
}

extension ComponentRow: UITableViewNibRegistrable {
    var nib: UINib {
        return WebBundle.nib(name: cellReuseIdentifier)
    }
}
