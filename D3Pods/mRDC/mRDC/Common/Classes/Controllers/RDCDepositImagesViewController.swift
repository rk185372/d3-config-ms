//
//  RDCDepositImagesViewController.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/3/18.
//

import Foundation
import ComponentKit
import Localization
import SnapKit

final class RDCDepositImagesViewController: UIViewControllerComponent {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var stackView: UIStackView!
    
    private let kBackCheckPage = 1
    private let imageData: [RDCImageData]
    private let rdcZoomingImageViewControllerFactory: RDCZoomingImageViewControllerFactory
    private let backCheckPressed: Bool
    private var frontImageVC: RDCZoomingImageViewController?
    private var backImageVC: RDCZoomingImageViewController?
    
    private var needsZoomReset = false
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         imageData: [RDCImageData],
         rdcZoomingImageViewControllerFactory: RDCZoomingImageViewControllerFactory,
         backCheckPressed: Bool) {
        
        self.imageData = imageData
        self.rdcZoomingImageViewControllerFactory = rdcZoomingImageViewControllerFactory
        self.backCheckPressed = backCheckPressed

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if backCheckPressed {
            scrollToBackCheck()
        }
    }

    private func setupViews() {
        view.backgroundColor = .black
        pageControl.addTarget(self, action: #selector(pageViewValueChanged), for: .valueChanged)
        setupScrollView()
    }
    
    private func setupScrollView() {
        guard let frontImage = imageData.first(where: {$0.itemImageAngle == .front})?.image(),
        let backImage = imageData.first(where: {$0.itemImageAngle == .back})?.image() else {
            return
        }
        
        let rotatedFrontImage = frontImage.rotate(radians: Float.pi / 2)
        let rotatedBackImage = backImage.rotate(radians: Float.pi / 2)

        frontImageVC = rdcZoomingImageViewControllerFactory.create(image: rotatedFrontImage ?? UIImage()) as? RDCZoomingImageViewController
        backImageVC = rdcZoomingImageViewControllerFactory.create(image: rotatedBackImage ?? UIImage()) as? RDCZoomingImageViewController
        
        guard let frontVC = frontImageVC,
            let backVC = backImageVC else {
                return
        }
        
        addChild(frontVC)
        stackView.addArrangedSubview(frontVC.view)
        frontVC.didMove(toParent: self)

        addChild(backVC)
        stackView.addArrangedSubview(backVC.view)
        backVC.didMove(toParent: self)
        
        frontVC.view.snp.makeConstraints { (make) in
            make.height.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        backVC.view.snp.makeConstraints { (make) in
            make.height.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    @objc private func pageViewValueChanged() {
        let offset = view.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: offset, y: scrollView.contentOffset.y), animated: true)
    }
    
    private func scrollToBackCheck() {
        pageControl.currentPage = kBackCheckPage
        scrollView.setContentOffset(CGPoint(x: view.bounds.width, y: scrollView.contentOffset.y), animated: true)
    }
}

extension RDCDepositImagesViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let oldPage = pageControl.currentPage
        pageControl.currentPage = targetContentOffset.pointee.x == 0 ? 0 : 1
        
        needsZoomReset = oldPage != pageControl.currentPage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard needsZoomReset else {
            return
        }
        
        frontImageVC?.resetZoom()
        backImageVC?.resetZoom()
        
        needsZoomReset = false
    }
}
