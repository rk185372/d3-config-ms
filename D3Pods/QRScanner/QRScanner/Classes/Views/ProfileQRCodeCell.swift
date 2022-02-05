//
//  ProfileQRCodeCell.swift
//  QRScanner
//
//  Created by Pablo Pellegrino on 20/12/2021.
//

import UIKit
import ComponentKit

struct ProfileQRCodeCellModel {
    let profilePic: UIImage?
    let username: String
    let userId: String
    let qrImage: UIImage?
    let shareAction: () -> Void
}

class ProfileQRCodeCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabelComponent!
    @IBOutlet weak var userIdLabel: UILabelComponent!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    private var shareAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.clipsToBounds = false
        bgView.layer.cornerRadius = 8
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = .zero
        bgView.layer.shadowRadius = 6
        bgView.layer.shadowOpacity = 0.3
    }

    func configure(with model: ProfileQRCodeCellModel) {
        profileImageView.image = model.profilePic
        usernameLabel.text = model.username
        userIdLabel.text = model.userId
        qrImageView.image = model.qrImage
        shareAction = model.shareAction
    }
    
    @IBAction private func sharePressed() {
        shareAction?()
    }
}
