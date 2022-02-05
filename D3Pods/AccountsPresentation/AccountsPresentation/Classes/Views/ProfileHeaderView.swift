//
//  ProfileHeaderView.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/8/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UIKit
import ComponentKit

final class ProfileHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var nameLabel: UILabelComponent!
    @IBOutlet weak var profilePic: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    private func loadNib() {
        guard let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as? UIView else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
    }
}
