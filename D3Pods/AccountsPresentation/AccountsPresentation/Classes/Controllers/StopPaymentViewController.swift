//
//  StopPaymentViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/6/18.
//

import D3Accounts
import Foundation
import UIKit
import ScrollableSegmentedControl
import UITableViewPresentation
import ComponentKit
import Localization
import Analytics

final class StopPaymentViewController: UIViewControllerComponent {

    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var segmentedControl: ScrollableSegmentedControl!
    @IBOutlet weak var segmentedControlContainerView: UIView!
    @IBOutlet weak var segmentedControlContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDividerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomDividerViewHeightConstraint: NSLayoutConstraint!

    private let account: Account
    private let stoppedPayment: StoppedPayment
    private let serviceItem: AccountsService
    private let stopSinglePaymentViewControllerFactory: StopSinglePaymentViewControllerFactory
    private let stopRangeOfPaymentsViewControllerFactory: StopRangeOfPaymentsViewControllerFactory

    private var dataSource: UITableViewPresentableDataSource!
    private var pageViewController: UIPageViewController!
    private var previousNavigationBarShadowImage: UIImage?
    private var pages: [UIViewController] = []

    // TODO: These two things will apparently be controlled by company
    // attributes in the future so we will need to use those when they
    // are available.
    private var hasSinglePayment: Bool = true
    private var hasRangeOfPayments: Bool = true

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         account: Account,
         serviceItem: AccountsService,
         stopSinglePaymentViewControllerFactory: StopSinglePaymentViewControllerFactory,
         stopRangeOfPaymentsViewControllerFactory: StopRangeOfPaymentsViewControllerFactory) {
        self.account = account
        self.serviceItem = serviceItem
        self.stoppedPayment = StoppedPayment()
        self.stopSinglePaymentViewControllerFactory = stopSinglePaymentViewControllerFactory
        self.stopRangeOfPaymentsViewControllerFactory = stopRangeOfPaymentsViewControllerFactory
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: (type(of: self))),
            bundle: AccountsPresentationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        previousNavigationBarShadowImage = navigationController?.navigationBar.shadowImage
        title = "Stop Payment"
        navigationStyleItem.hideShadowImage()

        // We want the divider views above and below the segmented control
        // to be one pixel tall.
        topDividerViewHeightConstraint.setConstantToPixelWidth()
        bottomDividerViewHeightConstraint.setConstantToPixelWidth()

        setupSegmentedControl()
        setupPageViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We are adding our own custom close button as the right bar button item of the navigation item.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "CloseIcon", in: AccountsPresentationBundle.bundle, compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTouched(_:))
        )

        // Set the back button item to a custom item so that it does not show a title on the
        // next view controller pushed onto the stack.
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: navigationController,
            action: nil
        )
    }

    private func setupSegmentedControl() {
        segmentedControl.insertSegment(withTitle: "Single", at: 0)
        segmentedControl.insertSegment(withTitle: "Range", at: 1)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.segmentStyle = .textOnly
        segmentedControl.underlineSelected = true
        segmentedControl.tintColor = .white
        segmentedControl.segmentContentColor = .white
        segmentedControl.selectedSegmentContentColor = .white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        // Now that the segmented control is set up. If we only have stop single
        // payment or stop range of payments, we want to hide the segmented control.
        if !hasSinglePayment || !hasRangeOfPayments {
            segmentedControlContainerViewHeightConstraint.constant = 0.0
            segmentedControlContainerView.isHidden = true
        } else {
            segmentedControlContainerView.isHidden = false
            segmentedControlContainerViewHeightConstraint.constant = 50.0
        }
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        pageViewController.dataSource = self
        pageViewController.delegate = self

        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.makeMatch(view: pageContainerView)

        if hasSinglePayment {
            pages.append(
                stopSinglePaymentViewControllerFactory.create(stoppedPayment: stoppedPayment,
                                                              account: account,
                                                              delegate: self)
            )
        }

        if hasRangeOfPayments {
            pages.append(
                stopRangeOfPaymentsViewControllerFactory.create(stoppedRange: StoppedRange(),
                                                                account: account,
                                                                delegate: self)
            )
        }

        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }

    private func updateNavBarShadowImage(basedOn scrollView: UIScrollView) {
        // We only want to show and hide the navigation bar shadow image if there
        // is only one view controller in pages. This means that the segmented control
        // is hidden so it is appropriate to show the shadow image. If there are
        // two controllers, the table view will scroll under the segmented control.
        if pages.count == 1 {
            // We are using -20 here because that is the top offset of table view
            // in the stop single payment and stop range of payments view controller.
            if scrollView.contentOffset.y == -20.0 {
                navigationStyleItem.hideShadowImage()
            } else {
                navigationStyleItem.showShadowImage()
            }
        }
    }

    private func stoppedPaymentHistoryButtonTouched(_ sender: UIButton) {
        navigationController?.pushViewController(
            StoppedPaymentHistoryViewController(account: account, serviceItem: serviceItem),
            animated: true
        )
    }

    @objc private func segmentedControlChanged(_ sender: ScrollableSegmentedControl) {
        let direction = (sender.selectedSegmentIndex == 0)
            ? UIPageViewController.NavigationDirection.reverse
            : UIPageViewController.NavigationDirection.forward

        pageViewController.setViewControllers([pages[sender.selectedSegmentIndex]], direction: direction, animated: true, completion: nil)
    }

    @objc private func cancelButtonTouched(_ sender: UIBarButtonItem) {
        parent?.dismiss(animated: true, completion: nil)
    }
}

extension StopPaymentViewController: TrackableScreen {
    var screenName: String {
        return "Stop Payments"
    }
}

extension StopPaymentViewController: UIPageViewControllerDataSource {
    // TODO: There is an abstraction around the page view data source in the main project
    // for authentication. At some point, we want to break that into its own pod and see
    // how we can use that for these methods.
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // If there is only one view controller (this could be single payment or range of payments)
        // we return nil. Otherwise, both single and range should be there so if we are on single,
        // the view controller before that is nil. If we are not on single we must be on range. The
        // view controller before range is stop single payment.
        if pages.count == 1 {
            return nil
        } else if viewController is StopSinglePaymentViewController {
            return nil
        } else {
            return pages[0]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // If there is only one view controller (this could be single payment or range of payments)
        // we return nil. Otherwise, there are two view controllers (both stop single payment and
        // stop range of payments). In this case if the current view controller is stop range
        // of payments, the next view controller is nil. If it is not stop range, then it
        // must be stop single payment. In this case the next view controller is second
        // item in the pages array.
        if pages.count == 1 {
            return nil
        } else if viewController is StopRangeOfPaymentsViewController {
            return nil
        } else {
            return pages[1]
        }
    }
}

extension StopPaymentViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
            if completed && previousViewControllers.first! is StopSinglePaymentViewController {
                segmentedControl.selectedSegmentIndex = 1
            } else if completed {
                segmentedControl.selectedSegmentIndex = 0
            }
    }
}

extension StopPaymentViewController: StopSinglePaymentViewControllerDelegate {
    func singlePaymentScrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavBarShadowImage(basedOn: scrollView)
    }

    func singlePaymentPresentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    func singlePaymentHistoryButtonTouched(_ sender: UIButton) {
        stoppedPaymentHistoryButtonTouched(sender)
    }
}

extension StopPaymentViewController: StopRangeOfPaymentsViewControllerDelegate {
    func rangeOfPaymentsScrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavBarShadowImage(basedOn: scrollView)
    }

    func rangeOfPaymentsPresentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    func rangeOfPaymentsHistoryButtonTouched(_ sender: UIButton) {
        stoppedPaymentHistoryButtonTouched(sender)
    }
}
