//
//  EnrollmentStatusPresenter.swift
//  EDocs
//
//  Created by Branden Smith on 1/6/20.
//

import Foundation
import ViewPresentable

struct EnrollmentStatusPresnter: ViewPresentable {
    private let statusText: String
    private let image: UIImage
    private let tintColor: UIColor?

    init(statusText: String, image: UIImage, tintColor: UIColor? = nil) {
        self.statusText = statusText
        self.image = image
        self.tintColor = tintColor
    }

    func createView() -> EnrollmentStatusView {
        return EDocsBundle
            .bundle
            .loadNibNamed("EnrollmentStatusView", owner: nil, options: [:])?
            .first as! EnrollmentStatusView
    }

    func configure(view: EnrollmentStatusView) {
        view.statusLabel.text = statusText
        view.imageView.image = image

        if let color = tintColor {
            view.imageView.tintColor = color
        }
    }
}
