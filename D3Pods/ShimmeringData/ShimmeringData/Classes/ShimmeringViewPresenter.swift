//
//  ShimmeringViewPresenter.swift
//  ShimmeringData
//
//  Created by Branden Smith on 1/28/19.
//

import ComponentKit
import Foundation
import Shimmer
import ViewPresentable

public final class ShimmeringViewPresenter<View: UIView>: ViewPresentable {
    private let bundle: Bundle
    private let styleKey: ViewStyleKey
    private let componentStyleProvider: ComponentStyleProvider

    /// Initializing a ShimmeringViewPresenter includes specifiying the type of view
    /// to be used with the shimmering view presenter and the bundle where that view's
    /// nib can be found. To initialize a shimmering view presenter, you can do:
    ///
    /// ```
    /// let presenter = ShimmeringViewPresenter<MyView>(bundle: bundleForMyView)
    /// ```
    ///
    /// - Parameter bundle: The bundle for the nib corresponding to the view type.
    public init(bundle: Bundle, styleKey: ViewStyleKey, componentStyleProvider: ComponentStyleProvider) {
        self.bundle = bundle
        self.styleKey = styleKey
        self.componentStyleProvider = componentStyleProvider
    }

    public func createView() -> View {
        return bundle
            .loadNibNamed(String(describing: View.self), owner: nil, options: [:])?
            .first as! View
    }

    public func configure(view: View) {
        setShimmeringForShimmerViews(in: view)
    }

    /// Recursively descends the view hirearchy looking for instances of FBShimmeringView
    /// then takes the first subview of the FBShimmeringView sets it as the FBShimmeringView's
    /// content view controller and calls shimmer.
    ///
    /// - Parameter view: The root view of the hirearchy you wish to descend.
    private func setShimmeringForShimmerViews(in view: UIView) {
        if let shimmerView = view as? FBShimmeringView {
            guard let firstSubview = view.subviews.first as? UIViewComponent else { return }

            let style: ViewStyle = componentStyleProvider[styleKey.rawValue]
            style.style(component: firstSubview)
            
            shimmerView.contentView = firstSubview
            shimmerView.isShimmering = true
            return
        }

        for view in view.subviews {
            setShimmeringForShimmerViews(in: view)
        }
    }
}

extension ShimmeringViewPresenter: Equatable {
    public static func ==(_ lhs: ShimmeringViewPresenter, _ rhs: ShimmeringViewPresenter) -> Bool {
        return true
    }
}
