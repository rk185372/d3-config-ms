//
//  NewUsernameRow.swift
//  Authentication
//
//  Created by Elvin Bearden on 12/3/20.
//

import Foundation
import RxCocoa
import RxSwift
import UITableViewPresentation

class NewUsernameRow: UITableViewPresentable {
    let usernameRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    private let bag = DisposeBag()
    private let placeholder: String

    init(placeholder: String) {
        self.placeholder = placeholder
    }

    func configure(cell: NewUsernameCell, at indexPath: IndexPath) {
        cell.textField.placeholder = placeholder
        cell.textField.rx.controlEvent(.editingDidEndOnExit).bind {
            self.usernameRelay.accept(cell.textField.text)
        }.disposed(by: bag)
    }
}

extension NewUsernameRow: Equatable {
    static func == (lhs: NewUsernameRow, rhs: NewUsernameRow) -> Bool {
        return false
    }
}

extension NewUsernameRow: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AuthenticationBundle.bundle)
    }
}
