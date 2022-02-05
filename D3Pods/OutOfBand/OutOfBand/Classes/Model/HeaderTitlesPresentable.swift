//
//  HeaderTitlesPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/31/20.
//

import Foundation
import UITableViewPresentation

struct HeaderTitlesPresentable: UITableViewHeaderFooterPresentable {
    private let title: String
    private let subtitle: String
    var viewReuseIdentifier: String {
        return "HeaderTitlesCell"
    }
    
    init(title: String,subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    func  configure(view: HeaderTitlesCell, for section: Int) {
        view.backgroundColor = UIColor.white
        view.titleLabel.text = title
        view.subtitleLabel.text = subtitle
        view.titleLabel.backgroundColor = UIColor.white
        view.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }
}

extension HeaderTitlesPresentable: UITableViewHeaderFooterNibRegistrable {
    var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}
