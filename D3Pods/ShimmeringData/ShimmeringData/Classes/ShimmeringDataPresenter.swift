//
//  ShimmeringDataPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/11/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UITableViewPresentation
import Shimmer

public final class ShimmeringDataPresenter<TableViewCell: UITableViewCell>: UITableViewPresentable {
    let bundle: Bundle

    /// Initializing a ShimmeringDataPresenter includes specifiying the type of cell
    /// to be used with the shimmering data presenter and the bundle where that cell's
    /// nib can be found. To initialize a shimmering data presenter, you can do:
    ///
    /// ```
    /// let presenter = ShimmeringDataPresenter<MyCell>(bundle: bundleForMyCell)
    /// ```
    ///
    /// - Parameter bundle: The bundle for the nib corresponding to the cell type.
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    public func configure(cell: TableViewCell, at indexPath: IndexPath) {
        setShimmeringForShimmerViews(in: cell.contentView)
    }

    /// Recursively descends the view hirearchy looking for instances of FBShimmeringView
    /// then takes the first subview of the FBShimmeringView sets it as the FBShimmeringView's
    /// content view controller and calls shimmer.
    ///
    /// - Parameter view: The root view of the hirearchy you wish to descend.
    private func setShimmeringForShimmerViews(in view: UIView) {
        if let shimmerView = view as? FBShimmeringView {
            guard let firstSubview = view.subviews.first else { return }
            shimmerView.contentView = firstSubview
            shimmerView.isShimmering = true
            return
        }

        for view in view.subviews {
            setShimmeringForShimmerViews(in: view)
        }
    }
}

extension ShimmeringDataPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: bundle)
    }
}

extension ShimmeringDataPresenter: Equatable {
    public static func ==(lhs: ShimmeringDataPresenter, rhs: ShimmeringDataPresenter) -> Bool {
        return true
    }
}
