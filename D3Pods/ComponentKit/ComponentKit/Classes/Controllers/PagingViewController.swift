//
//  PagingViewController.swift
//  ComponentKit
//
//  Created by Chris Carranza on 1/14/19.
//

import UIKit
import Localization

public protocol PagingViewControllerDelegate: class {
    func didMove(toViewController viewController: UIViewController)
}

open class PagingViewController: UIViewControllerComponent {
    
    @IBOutlet public weak var scrollView: UIScrollView!
    @IBOutlet public weak var pageControl: UIPageControlComponent!
    
    public weak var pagingDelegate: PagingViewControllerDelegate?
    
    public let viewControllers: [UIViewController]
    public private(set) var currentViewController: UIViewController?
    
    open override var childForNavigationStyle: UIViewControllerComponent? {
        return currentViewController as? UIViewControllerComponent
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return currentViewController
    }
    
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    public init(viewControllers: [UIViewController], l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        self.viewControllers = viewControllers
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "PagingViewController",
            bundle: ComponentKitBundle.bundle
        )
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        
        pageControl.numberOfPages = viewControllers.count
        pageControl.currentPage = 0
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustScrollViewContents()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // This keeps your current page consistent across device rotations
        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
        
        coordinator.animate(alongsideTransition: { _ in
            self.scrollView.contentOffset = CGPoint(x: currentPage * self.scrollView.frame.size.width, y: 0)
        }, completion: nil)
    }
    
    private func setupPages() {
        scrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(viewControllers.count),
            height: view.frame.height
        )
        
        for viewController in viewControllers {
            addViewController(viewController: viewController)
        }
        
        if let viewController = viewControllers.first {
            viewController.viewDidAppear(false)
            currentViewController = viewController
        }
        
        adjustScrollViewContents()
    }
    
    private func addViewController(viewController: UIViewController) {
        addChild(viewController)
        viewController.view.frame = CGRect(
            x: self.view.frame.width * CGFloat(scrollView.subviews.count),
            y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height
        )
        viewController.didMove(toParent: self)
        scrollView.addSubview(viewController.view)
    }
    
    private func adjustScrollViewContents() {
        scrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(viewControllers.count),
            height: view.frame.height
        )
        
        for (index, view) in scrollView.subviews.enumerated() {
            view.frame = CGRect(
                x: self.view.frame.width * CGFloat(index),
                y: 0,
                width: self.view.frame.width,
                height: self.view.frame.height
            )
        }
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let offset = CGPoint(
            x: view.frame.width * CGFloat(currentPage),
            y: 0
        )
        
        scrollView.setContentOffset(offset, animated: true)
    }
}

extension PagingViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
        pageControl.currentPage = pageIndex
        
        let viewController = viewControllers[pageIndex]
        
        currentViewController = viewController
        viewController.viewDidAppear(true)
        pagingDelegate?.didMove(toViewController: viewController)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
