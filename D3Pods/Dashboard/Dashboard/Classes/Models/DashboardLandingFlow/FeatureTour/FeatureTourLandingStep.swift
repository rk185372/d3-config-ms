//
//  FeatureTourLandingStep.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 15/10/2021.
//

import Foundation
import ComponentKit
import RxSwift
import Logging

public final class FeatureTourLandingStep: DashboardLandingStep {
    private let factory: FeatureTourViewControllerFactory
    private let featureTourService: FeatureTourService
    private weak var delgate: DashboardLandingStepDelegate?
    private var navControler: UINavigationController!
    private var activeDemo: ActiveDemo?
    private let bag = DisposeBag()
    
    init(factory: FeatureTourViewControllerFactory,
         featureTourService: FeatureTourService) {
        self.factory = factory
        self.featureTourService = featureTourService
    }
    
    public func execute(on controller: UIViewController, withDelegate delegate: DashboardLandingStepDelegate) {
        featureTourService.activeFeaturedDemos().subscribe(onSuccess: { activeDemos in
            guard let activeDemo = activeDemos.filter({ !$0.demoUrl.hasPrefix("desktop-only:") }).first else {
                return
            }
            self.startDemo(activeDemo, on: controller, withDelegate: delegate)
        }, onError: { error in
            log.error("Getting active demos: \(error)")
        })
        .disposed(by: bag)
    }
    
    private func startDemo(_ demo: ActiveDemo, on controller: UIViewController, withDelegate delegate: DashboardLandingStepDelegate) {
        activeDemo = demo
        featureTourService.activityRecords(featureId: demo.id).subscribe(onSuccess: { records in
            guard records.filter({ $0.type == "feature-complete" }).isEmpty else {
                return
            }
            let featureTourVC = self.factory.create(delegate: self)
            self.navControler = UINavigationControllerComponent(rootViewController: featureTourVC)
            self.delgate = delegate
            controller.present(self.navControler, animated: true)
            self.markDemoCompleted()
        }, onError: { error in
            log.error("Getting demo activity records: \(error)")
        })
        .disposed(by: bag)
    }
    
    private func markDemoCompleted() {
        guard let demoId = activeDemo?.id else { return }
        self.featureTourService.createActivityRecord(featureId: demoId)
            .subscribe(onError: { error in
                log.error("Creating demo activity record: \(error)")
            })
            .disposed(by: self.bag)
    }
}

extension FeatureTourLandingStep: FeatureTourViewControllerDelegate {
    public func tourURL() -> URL? {
        guard let demoUrl = activeDemo?.demoUrl else {
            return nil
        }
        let prefix = "mobile-only:"
        return URL(string: demoUrl.hasPrefix(prefix) ? String(demoUrl.dropFirst(prefix.count)) : demoUrl)
    }
    
    public func didCompleteTour() {
        // TODO
    }
    
    public func tourDismissed() {
        NotificationCenter.default.post(.init(name: .featureTourFinished))
        delgate?.stepCompleted()
    }
    
    public func didTapLearnMore() {
        // TODO
    }
}
