//
//  CompleteViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/31/19.
//

import UIKit
import Localization
import ComponentKit
import RxSwift
import RxCocoa

final class CompleteViewController: UIViewControllerComponent, ContentViewController {
    
    weak var delegate: ContentViewDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var taglineImageView: UIImageView!
    private let backgroundImage: UIImage
    private let logoImage: UIImage
    private let taglineImage: UIImage
    
    private let appearRelay: PublishRelay<Void> = PublishRelay()
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         backgroundImage: UIImage,
         logoImage: UIImage,
         taglineImage: UIImage) {
        self.backgroundImage = backgroundImage
        self.logoImage = logoImage
        self.taglineImage = taglineImage
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "CompleteViewController",
            bundle: FeatureTourBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = backgroundImage
        logoImageView.image = logoImage
        taglineImageView.image = taglineImage
        
        appearRelay
            .take(1)
            .subscribe(onNext: { _ in
                UIView.animate(withDuration: 4, delay: 0, options: .curveEaseOut, animations: {
                    self.imageView.transform = self.imageView.transform.scaledBy(x: 1.1, y: 1.1)
                }, completion: nil)
            })
            .disposed(by: bag)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appearRelay.accept(())
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        delegate?.proceedToLogin()
    }
}
