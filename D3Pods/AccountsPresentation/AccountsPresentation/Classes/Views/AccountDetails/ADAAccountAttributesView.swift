//
//  ADAAccountAttributesView.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/4/18.
//

import Foundation
import UIKit
import ComponentKit

final class ADAAccountAttributesView: UIView, AccountAttributesView {
    @IBOutlet weak var attributeLabel: UILabelComponent!
    @IBOutlet weak var valueLabel: UILabelComponent!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    func loadNib() {
        let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as! UIView

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.makeMatch(view: self)
    }
}
