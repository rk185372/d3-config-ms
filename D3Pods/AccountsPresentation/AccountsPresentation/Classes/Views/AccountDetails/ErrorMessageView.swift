//
//  ErrorMessageView.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/3/18.
//

import Foundation
import UIKit
import ComponentKit

final class ErrorMessageView: UIView {
    @IBOutlet weak var messageLabel: UILabelComponent!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    private func loadNib() {
        let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
        .first as! UIView

        addSubview(view)
        view.makeMatch(view: self)
    }
}
