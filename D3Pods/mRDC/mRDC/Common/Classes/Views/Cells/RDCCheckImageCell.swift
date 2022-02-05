//
//  RDCCheckImageCell.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import UIKit
import ComponentKit
import RxSwift

final class RDCCheckImageCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var stackedMenuView: StackedMenuView!
    @IBOutlet weak var amountTextField: RDCCurrencyEntryTextField!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var frontImageView: UIImageViewComponent!
    @IBOutlet weak var backImageView: UIImageViewComponent!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
