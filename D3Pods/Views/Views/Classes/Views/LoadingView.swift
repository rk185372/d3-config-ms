//
//  LoadingView.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/14/18.
//

import Foundation
import UIKit
import SnapKit

public final class LoadingView: UIView {
    
    public var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    public init(activityIndicatorColor: UIColor = .white, backgroundColor: UIColor = .clear) {
        super.init(frame: .zero)
        setupViews(activityIndicatorColor: activityIndicatorColor, backgroundColor: backgroundColor)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    private func setupViews(activityIndicatorColor: UIColor, backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        spinner.color = activityIndicatorColor
        
        addSubview(spinner)
        
        spinner.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
}
