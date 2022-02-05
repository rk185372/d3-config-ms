//
//  NoItemsView.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/14/18.
//

import Foundation
import UIKit

public final class NoItemsView: UIView {
    @IBOutlet public weak var infoLabel: UILabelComponent!
    @IBOutlet public weak var refreshIcon: UIImageView!
    @IBOutlet public weak var tryAgainButton: UIButtonComponent!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    public func makeBlendWithBackground() {
        makeBackgroundClear(of: self)
    }

    private func loadNib() {
        guard let view = ComponentKitBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as? UIView else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
    }

    private func makeBackgroundClear(of view: UIView) {
        view.backgroundColor = .clear
        view.subviews.forEach({ subView in makeBackgroundClear(of: subView) })
    }
}
