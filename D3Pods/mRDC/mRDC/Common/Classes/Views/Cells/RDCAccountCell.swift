//
//  RDCAccountCell.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import UIKit
import ComponentKit
import RxSwift

final class RDCAccountCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var accountNameLabel: UILabelComponent!
    @IBOutlet weak var accountNumberLabel: UILabelComponent!
    @IBOutlet weak var accountBalanceLabel: UILabelComponent!
    @IBOutlet weak var checkbox: UICheckboxComponent!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
