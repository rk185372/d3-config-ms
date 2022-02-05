//
//  PagingContentViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/25/19.
//

import Foundation
import ComponentKit
import Localization

final class PagingContentViewController: PagingViewController, ContentViewController, ContentViewDelegate {
    weak var delegate: ContentViewDelegate?
    
    init(viewControllers: [FeatureTourContentViewController], l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(viewControllers: viewControllers, l10nProvider: l10nProvider, componentStyleProvider: componentStyleProvider)
        viewControllers.forEach { $0.delegate = self }
        pagingDelegate = self
    }
    
    @available(*, unavailable)
    override init(viewControllers: [UIViewController], l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(viewControllers: viewControllers, l10nProvider: l10nProvider, componentStyleProvider: componentStyleProvider)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style: PageControlStyle = componentStyleProvider![PageControlStyleKey.pageControlOnFeatureTour]
        pageControl.style(componentStyle: style)
        
        scrollView.bounces = false
        pageControl.accessibilityValue = accessibilityText()
    }
    
    private func accessibilityText() -> String {
        let parameterMap = [
            "pageIndex": pageControl.currentPage + 1,
            "pageCount": viewControllers.count
        ]
        
        return l10nProvider.localize("feature-tour.ios.pageControl.altText", parameterMap: parameterMap)
    }

    func proceedToNextScreen() {
        delegate?.proceedToNextScreen()
    }
    
    func proceedToLogin() {
        delegate?.proceedToLogin()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewControllers.count > 1 else { return }
        pageControl.accessibilityValue = accessibilityText()
        if scrollView.contentOffset.x < view.frame.width * CGFloat((viewControllers.count - 2)) {
            pageControl.alpha = 1
            pageControl.isUserInteractionEnabled = true
        } else {
            pageControl.isUserInteractionEnabled = false
            let positionOffset = (view.frame.width * CGFloat(viewControllers.count - 1)) - scrollView.contentOffset.x
            let transitionAmount = positionOffset / view.frame.width
            pageControl.alpha = transitionAmount
        }
    }
}

extension PagingContentViewController: PagingViewControllerDelegate {
    func didMove(toViewController viewController: UIViewController) {
        setNeedsStatusBarAppearanceUpdate()
    }
}
