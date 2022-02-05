//
//  SelectAllCell.swift
//  EDocs
//
//  Created by Chris Carranza on 11/1/18.
//

import UIKit
import ComponentKit
import RxSwift

final class SelectAllCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var checkbox: UICheckboxComponent!
    @IBOutlet weak var titleLabel: UILabelComponent!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
