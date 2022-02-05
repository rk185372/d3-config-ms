//
//  RDCDepositPresenter.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/30/18.
//

import Foundation
import UITableViewPresentation
import Utilities
import Localization
import RxSwift
import RxCocoa
import ComponentKit

protocol RDCDepositViewDelegate: class {
    func beginLoading()
    func failedToLoadAccounts()
    func noEligibleAccounts()
    func presentCaptureViewController(_ captureVC: UIViewController)
    func presentErrorViewController(_ errorVC: UIViewController)
    func dismissCaptureViewController()
    func checkImagesCaptured()
    func doneEditingAmount()
}

final class RDCDepositViewModel {
    
    private var bag = DisposeBag()
    
    weak var depositViewDelegate: RDCDepositViewDelegate?
    
    private var dataSource: UITableViewPresentableDataSource!
    
    private let rdcCaptureProvider: RDCCaptureProvider
    private let rdcService: RDCService
    private let device: Device
    
    private var depositAccounts: [DepositAccount]?
    
    private var _presenters = BehaviorRelay<[RDCDepositAccountPresenter]>(value: [])
    private var presenters: [RDCDepositAccountPresenter] {
        get { return _presenters.value }
        set { _presenters.accept(newValue) }
    }
    
    var selectedAccount: DepositAccount? {
        get { return _selectedAccount.value }
        set { _selectedAccount.accept(newValue) }
    }
    var depositAmount: Decimal? {
        get { return _depositAmount.value }
        set { _depositAmount.accept(newValue) }
    }
    var checkImages: RDCCaptureImages? {
        get { return _checkImages.value }
        set { _checkImages.accept(newValue) }
    }
    var isDirty: Bool {
        return _isDirty.value
    }
    
    private let _selectedAccount = BehaviorRelay<DepositAccount?>(value: nil)
    private let _depositAmount = BehaviorRelay<Decimal?>(value: nil)
    private let _checkImages = BehaviorRelay<RDCCaptureImages?>(value: nil)
    private let _isDirty = BehaviorRelay(value: false)
    
    let canSubmitDeposit: Driver<Bool>
    
    var listResponse: DepositAccountListResponse?
    
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider

    private let tableViewStyle: TableViewStyle
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcService: RDCService,
         device: Device,
         rdcCaptureProvider: RDCCaptureProvider) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcService = rdcService
        self.device = device
        self.rdcCaptureProvider = rdcCaptureProvider
        
        tableViewStyle = componentStyleProvider[TableViewStyleKey.tableViewOnDefault]
        
        canSubmitDeposit = Observable
            .combineLatest(_selectedAccount, _checkImages, _depositAmount)
            .map { observables -> Bool in
                return observables.0 != nil
                    && observables.1 != nil
                    && observables.2 != nil
                    && observables.2! > 0.0
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        Observable
            .combineLatest(_selectedAccount, _checkImages, _depositAmount)
            .map { observables -> Bool in
                return observables.0 != nil
                    || observables.1 != nil
                    || observables.2 ?? 0.0 > 0.0
            }
            .distinctUntilChanged()
            .bind(to: _isDirty)
            .disposed(by: bag)

        _checkImages
            .filter({ captureImages in captureImages != nil })
            .subscribe(onNext: { [weak self] _ in
                self?.depositViewDelegate?.checkImagesCaptured()
            })
            .disposed(by: bag)
    }
    
    func configureDataSource(tableView: UITableView) {
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)
    }
    
    @objc public func getAccounts() {
        //Clear any existing data
        clearSavedData()
        //show loading spinner
        depositViewDelegate?.beginLoading()
        self.dataSource.tableViewModel = .shimmeringDataModel

        //fetch accounts
        getDepositAccounts()
    }
    
    private func clearSavedData() {
        depositAccounts = nil
        
        selectedAccount = nil
        depositAmount = nil
        checkImages = nil
    }
    
    private func getDepositAccounts() {
        rdcService
            .getDepositAccounts(withUuid: device.uuid)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .success(let response):
                    self.listResponse = response
                    
                    guard !response.userAccounts.isEmpty else {
                        self.depositViewDelegate?.noEligibleAccounts()
                        return
                    }
                    self.depositAccounts = response.userAccounts
                    self.presenters = RDCDepositAccountPresenterFactory(l10nProvider: self.l10nProvider)
                        .create(depositAccounts: response.userAccounts)
                    for presenter in self.presenters {
                        presenter.delegate = self
                    }
                    self.updateTableView()
                case .error:
                    let rows: [AnyUITableViewPresentable] = []
                    self.dataSource.tableViewModel = UITableViewModel(
                        sections: [UITableViewSection(rows: rows, header: .none, footer: .blank)]
                    )
                    
                    self.depositViewDelegate?.failedToLoadAccounts()
                }
            })
            .disposed(by: bag)
    }
    
    private func updateTableView() {
        
        guard !presenters.isEmpty else {
            return
        }
        
        let clickListener: ((RDCCheckImagePresenter.PressedButtonType) -> Void) = { [weak self] (type) in
            switch type {
            case .captureCheck:
                self?.captureCheckImage(captureType: .frontAndBack)
            case .captureCheckFront:
                self?.captureCheckImage(captureType: .front)
            case .captureCheckBack:
                self?.captureCheckImage(captureType: .back)
            }
        }
        
        let textListener: ((Decimal) -> Void) = { [weak self] (amount) in
            self?.depositAmount = amount
        }
        
        let doneListener: (() -> Void) = { [weak self] in
            self?.depositViewDelegate?.doneEditingAmount()
        }
        
        //Build Cells
        let checkImage = [
            RDCCheckImagePresenter(
                l10nProvider: self.l10nProvider,
                componentStyleProvider: componentStyleProvider,
                depositAmount: self.depositAmount,
                images: self.checkImages,
                clickListener: clickListener,
                textListener: textListener,
                doneListener: doneListener
            )
        ]
        
        let accountsSectionHeader = RDCSectionHeaderPresenter(
            title: l10nProvider.localize("deposit.account.placeholder"),
            accessibilityLabel: "\(l10nProvider.localize("deposit.account.placeholder")) - Required",
            backgroundColor: tableViewStyle.backgroundColor?.color,
            separatorColor: tableViewStyle.separatorColor.color
        )
        
        var sections: [UITableViewSection]
        
        if let currentAccount = self.selectedAccount,
            currentAccount.hasLimits() {
            let accountInfo = RDCAccountLimitInformationCellPresenter(
                l10nProvider: l10nProvider,
                depositAccount: currentAccount
            )
            
            sections = [
                UITableViewSection(rows: checkImage),
                UITableViewSection(rows: presenters, header: .presentable(AnyUITableViewHeaderFooterPresentable(accountsSectionHeader))),
                UITableViewSection(rows: [accountInfo], footer: .blank)
            ]
        } else {
            sections = [
                UITableViewSection(rows: checkImage),
                UITableViewSection(
                    rows: presenters,
                    header: .presentable(AnyUITableViewHeaderFooterPresentable(accountsSectionHeader)),
                    footer: .blank
                )
            ]
        }
        
        dataSource.tableViewModel = UITableViewModel(sections: sections)
    }
    
    private func captureCheckImage(captureType: RDCCaptureProvider.RDCCaptureProviderCaptureType) {
        func performRealCapture() {
            //Attempt to capture the images
            rdcCaptureProvider.captureViewController( completionHandler: { [weak self] (captureResult) in

                switch captureResult {
                case .success(let viewController):
                    viewController.setCaptureCompletion(completion: { (images) in
                        self?.depositViewDelegate?.dismissCaptureViewController()

                        guard let images = images else {
                            return
                        }

                        switch captureType {
                        case .frontAndBack:
                            self?.checkImages = images
                        case .front:
                            self?.checkImages = RDCCaptureImages(encodedFront: images.encodedFrontImage,
                                                                 encodedBack: self?.checkImages?.encodedBackImage ?? "")
                        case .back:
                            self?.checkImages = RDCCaptureImages(encodedFront: self?.checkImages?.encodedFrontImage ?? "",
                                                                 encodedBack: images.encodedBackImage)
                        }
                        
                        self?.updateTableView()
                    })

                    self?.depositViewDelegate?.presentCaptureViewController(viewController)
                case .error(let viewController):
                    self?.depositViewDelegate?.presentErrorViewController(viewController)
                }
            }, captureType: captureType)
        }

        #if DEBUG
        if let testImage = ProcessInfo.processInfo.environment["rdcTestImage"], !testImage.isEmpty {
            self.checkImages = RDCCaptureImages(encodedFront: testImage, encodedBack: testImage)
            self.updateTableView()
        } else {
            performRealCapture()
        }
        #else
        performRealCapture()
        #endif
    }
    
    fileprivate func selectPresenter(presenter: RDCDepositAccountPresenter) {
        presenters.forEach {
            $0.isSelected = $0 == presenter
        }
        
        selectedAccount = presenters.first(where: { $0.isSelected })?.depositAccount
    }
}

extension RDCDepositViewModel: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        guard let presentable = presentable.base as? RDCDepositAccountPresenter else { return }
        
        selectPresenter(presenter: presentable)
        updateTableView()
    }
}

extension RDCDepositViewModel: RDCDepositAccountPresenterDelegate {
    func didSelectPresenter(presenter: RDCDepositAccountPresenter) {
        selectPresenter(presenter: presenter)
        updateTableView()
    }
}
