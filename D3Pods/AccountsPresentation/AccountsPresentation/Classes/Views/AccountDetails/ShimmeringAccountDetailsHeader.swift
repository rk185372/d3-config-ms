//
//  ShimmeringAccountDetailsHeader.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/23/18.
//

import Foundation
import Shimmer
import UIKit

final class ShimmeringAccountDetailsHeader: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("ShimmeringAccountDetailsHeader.init(coder:) has not been implemented")
    }

    private func loadNib() {
        let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        configureShimmeringViews(in: view)
        view.makeMatch(view: self)
    }

    private func configureShimmeringViews(in view: UIView) {
        view.subviews.forEach {
            guard let shimmerView = $0 as? FBShimmeringView else { return }
            guard let firstSubview = shimmerView.subviews.first else { return }
            shimmerView.contentView = firstSubview
            shimmerView.isShimmering = true
        }
    }
}
