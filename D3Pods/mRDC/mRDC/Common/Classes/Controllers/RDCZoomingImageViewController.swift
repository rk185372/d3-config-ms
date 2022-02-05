//
//  RDCSuccessViewController.swift
//  mRDC
//
//  Created by Chris Pflepsen on 9/5/18
//

import Foundation
import UIKit
import ComponentKit
import Localization

final class RDCZoomingImageViewController: UIViewControllerComponent {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageViewComponent!
    
    private let image: UIImage
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         image: UIImage) {
        
        self.image = image
        
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: RDCBundle.bundle
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        imageView.image = image
        
        view.backgroundColor = .black
    }
    
    func resetZoom() {
        scrollView.setZoomScale(1.0, animated: false)
    }
}

extension RDCZoomingImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
