//
//  RDCDividerView.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/13/18.
//

import UIKit

final class RDCDividerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
    
    private func initCommon() {
        backgroundColor = .lightGray
    }

}
