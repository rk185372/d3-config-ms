//
//  UITableViewModel+ShimmeringData.swift
//  ShimmeringData
//
//  Created by Chris Carranza on 11/13/17.
//

import Foundation
import UITableViewPresentation

extension UITableViewModel {
    public static var shimmeringDataModel: UITableViewModel {
        let presenter = ShimmeringDataPresenter<ShimmeringDataCell>(bundle: ShimmeringDataBundle.bundle)
        
        return [UITableViewSection(rows: [presenter], footer: .blank)]
    }
}
