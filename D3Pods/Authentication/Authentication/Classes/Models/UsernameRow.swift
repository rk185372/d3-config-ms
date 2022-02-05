//
//  UsernameRow.swift
//  Authentication
//
//  Created by Elvin Bearden on 12/2/20.
//

import Foundation
import UITableViewPresentation

protocol UsernamerowDelegate: class {
    func rowDeleted(at delete: UIButton)
}

class UsernameRow: UITableViewPresentable, UITableViewEditableRow {
    var isEditable: Bool = false
    func editActions() -> [UITableViewRowAction]? {
        return nil
    }

    let username: String
    private weak var delegate: UsernamerowDelegate?

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    init(username: String, delegate: UsernamerowDelegate) {
        self.username = username
        self.delegate = delegate
    }

    func configure(cell: UsernameCell, at indexPath: IndexPath) {
        cell.titleLabel.text = username.masked()
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTouched(_sender:)), for: .touchUpInside )
    }
    
   @objc func deleteBtnTouched(_sender: UIButton) {
    delegate?.rowDeleted(at: _sender)
    }
}

extension UsernameRow: Equatable {
    static func == (lhs: UsernameRow, rhs: UsernameRow) -> Bool {
        return lhs.username == rhs.username
    }
}

extension UsernameRow: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AuthenticationBundle.bundle)
    }
}
