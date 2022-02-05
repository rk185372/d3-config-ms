//
//  ProfileIconComponent.swift
//  ComponentKit
//
//  Created by Branden Smith on 7/1/19.
//

import DependencyContainerExtension
import Dip
import RxSwift
import UIKit

public final class ProfileIconComponent: UIBarButtonItem {
    
    private let bag = DisposeBag()

    @available(iOS, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(style: UIBarButtonItem.Style,
                target: AnyObject?,
                action: Selector) {

        super.init()
        
        let customView = UIButton(frame: .zero)
        customView.setImage(UIImage(named: "UserProfile"), for: .normal)
        customView.addTarget(target, action: action, for: .touchUpInside)
        self.customView = customView
    }
    
    public func updateIcon(_ image: UIImage?) {
        (customView as? UIButton)?.setImage(image ?? UIImage(named: "UserProfile"), for: .normal)
    }
}
