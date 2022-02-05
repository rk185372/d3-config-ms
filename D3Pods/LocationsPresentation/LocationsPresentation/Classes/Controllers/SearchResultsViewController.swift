//
//  SearchResultsViewController.swift
//  Locations
//
//  Created by Andrew Watt on 7/25/18.
//

import Locations
import RxRelay
import RxKeyboard
import RxSwift
import SnapKit
import UIKit
import UITableViewPresentation
import Utilities

final class SearchResultsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = SearchResultsViewModel()
    
    weak var delegate: SearchResultsViewControllerDelegate?

    private let animationDuration: TimeInterval = 0.2
    fileprivate let isVisible = BehaviorRelay(value: false)
    private let bag = DisposeBag()

    private var dataSource: UITableViewPresentableDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = UITableViewPresentableDataSource(tableView: tableView)
        dataSource.delegate = self
        viewModel.locations.asDriver()
            .drive(onNext: { [unowned self] (locationsResult) in
                let model: UITableViewModel

                switch locationsResult {
                case .success(let locations):
                    let results = locations.map(SearchResult.init(location:))
                    model = UITableViewModel(rows: results)
                case .failure:
                    model = UITableViewModel(rows: [AnyUITableViewPresentable]())
                }

                self.dataSource.tableViewModel = model
            })
            .disposed(by: bag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [unowned self] (height) in
                self.tableView.contentInset.bottom = height
                self.tableView.scrollIndicatorInsets.bottom = height
            })
            .disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible.accept(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible.accept(false)
    }

    func slide(intoParentViewController parent: UIViewController, insideView: UIView) {
        guard self.parent == nil else { return }

        parent.addChild(self)
        
        let endFrame = insideView.bounds
        let startFrame = endFrame.offsetBy(dx: 0, dy: -endFrame.height)

        view.frame = startFrame
        insideView.addSubview(view)
        insideView.isUserInteractionEnabled = true
        
        UIView.animate(
            withDuration: animationDuration,
            animations: { [weak self] in
                self?.view.frame = endFrame
            },
            completion: { [weak self] (_) in
                self?.view.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                self?.didMove(toParent: parent)
            }
        )
    }

    func slideOut() {
        guard self.parent != nil else { return }

        view.superview?.isUserInteractionEnabled = false

        willMove(toParent: nil)
        let endFrame = view.frame.offsetBy(dx: 0, dy: view.bounds.height)

        UIView.animate(
            withDuration: animationDuration,
            animations: { [weak self] in
                self?.view.frame = endFrame
            },
            completion: { [weak self] (_) in
                self?.view.removeFromSuperview()
                self?.removeFromParent()
            }
        )
    }
}

extension SearchResultsViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard case let LocationsServiceResult.success(locations) = viewModel.locations.value else { return }

        let location = locations[indexPath.row]
        
        delegate?.searchResultsViewController(self, selectedResult: location)
    }
}

protocol SearchResultsViewControllerDelegate: class {
    func searchResultsViewController(_: SearchResultsViewController, selectedResult: Location)
}

final class SearchResultsViewModel {
    let locations = BehaviorRelay<LocationsServiceResult>(value: .success([]))
}

struct SearchResult: UITableViewPresentable {
    let cellReuseIdentifier = "ResultCell"
    
    var location: Location
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? SearchResultCell {
            cell.locationNameLabel.text = location.name
        }
    }
}

extension Reactive where Base == SearchResultsViewController {
    var isVisible: Observable<Bool> {
        return base.isVisible.asObservable()
    }
}
