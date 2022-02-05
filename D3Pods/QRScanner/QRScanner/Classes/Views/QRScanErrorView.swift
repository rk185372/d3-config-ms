//
//  QRScanErrorView.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 21/12/2021.
//

import UIKit

class QRScanErrorView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scanAgainButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var retryAction: (() -> Void)!
    private var cancelAction: (() -> Void)!
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard let contentView = QRScannerBundle.bundle.loadNibNamed("QRScanErrorView", owner: self, options: nil)?.first as? UIView else {
            fatalError("Could not load nib QRScanErrorView")
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.makeMatch(view: self)
    }
    
    func configure(withTitle title: String,
                   description: String,
                   retryAction: @escaping () -> Void,
                   cancelAction: @escaping () -> Void) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.retryAction = retryAction
        self.cancelAction = cancelAction
    }
    
    @IBAction private func retryPressed() {
        retryAction()
    }
    
    @IBAction private func cancelPressed() {
        cancelAction()
    }
}
