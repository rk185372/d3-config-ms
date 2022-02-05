//
//  LoadingView.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/21/18.
//

import Foundation
import UIKit

final class ADALoadingView: UIView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("LoadingView.init(coder:) is not implemented")
    }

    private func loadNib() {
        let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)
        view.makeMatch(view: self)
    }
}
