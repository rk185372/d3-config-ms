//
//  L10NStringDisplayRow.swift
//  Authentication-Authentication
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 8/18/21.
//

import Foundation
import UITableViewPresentation

final class L10NStringDisplayRow: UITableViewPresentable {
    
    let l10nString: String
    
    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    init(l10nString: String) {
        self.l10nString = l10nString
    }
    func configure(cell: L10NStringDisplayView, at indexPath: IndexPath) {
        cell.l10nStringLabel.text = l10nString
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
    }
}
extension L10NStringDisplayRow: Equatable {
    static func == (lhs: L10NStringDisplayRow, rhs: L10NStringDisplayRow) -> Bool {
        return lhs.l10nString == rhs.l10nString
    }
}

extension L10NStringDisplayRow: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AuthenticationBundle.bundle)
    }
}
