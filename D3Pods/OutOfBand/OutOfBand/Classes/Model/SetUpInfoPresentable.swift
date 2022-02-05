//
//  SetUpInfoPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 1/1/21.
//

import Foundation
import UITableViewPresentation

struct SetUpInfoPresentable: UITableViewPresentable {
    func configure(cell: SetUpInfoCell, at indexPath: IndexPath) {}
}

extension SetUpInfoPresentable: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}
