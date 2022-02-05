//
//  WebComponentCell.swift
//  Web
//
//  Created by Andrew Watt on 8/20/18.
//

import UIKit
import ComponentKit
import RxSwift

final class WebComponentCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet var stackedMenuView: StackedMenuView!
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
