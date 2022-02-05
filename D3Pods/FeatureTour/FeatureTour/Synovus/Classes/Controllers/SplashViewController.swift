//
//  SplashViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import UIKit
import ComponentKit
import Localization
import RxSwift
import RxCocoa

final class SplashViewController: UIViewControllerComponent, ContentViewController {
    
    private let transitionDelay: TimeInterval = 3
    
    weak var delegate: ContentViewDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textImageView: UIImageView!
    private let backgroundImage: UIImage
    private let textImage: UIImage
    
    init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider, backgroundImage: UIImage, textImage: UIImage) {
        self.backgroundImage = backgroundImage
        self.textImage = textImage
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "SplashViewController",
            bundle: FeatureTourBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = backgroundImage
        textImageView.image = textImage
        
        UIView.animate(withDuration: 4, delay: 0, options: .curveLinear, animations: {
            self.imageView.transform = self.imageView.transform.scaledBy(x: 1.1, y: 1.1)
        }, completion: nil)

        Observable<Int>
            .timer(transitionDelay, scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [unowned self] _ in
                self.delegate?.proceedToNextScreen()
            })
            .disposed(by: bag)
    }
}
