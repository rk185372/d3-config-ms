//
//  SearchRadiusPopupViewController.swift
//  Locations
//
//  Created by Andrew Watt on 7/30/18.
//

import Locations
import UIKit
import Localization

final class SearchRadiusPopupViewController: UIViewController {
    private let radii = SearchRadius.allCases.sorted()
    private let animationDuration: TimeInterval = 0.2
    private var l10nProvider: L10nProvider!

    weak var delegate: SearchRadiusPopupViewControllerDelegate?

    private func sizeFitting(width: CGFloat) -> CGSize {
        var targetSize = UIView.layoutFittingCompressedSize
        targetSize.width = width
        return view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        slideOut()
    }
    
    func popOver(parentViewController: UIViewController, l10nProvider: L10nProvider) {
        parentViewController.addChild(self)
        
        self.l10nProvider = l10nProvider
        let parentSize = parentViewController.view.bounds.size
        let size = sizeFitting(width: parentSize.width)
        let startFrame = CGRect(origin: CGPoint(x: 0, y: parentSize.height), size: size)
        let endFrame = startFrame.offsetBy(dx: 0, dy: -size.height)
        
        view.frame = startFrame
        parentViewController.view.addSubview(view)
        
        UIView.animate(
            withDuration: animationDuration,
            animations: { [weak self] in
                self?.view.frame = endFrame
            },
            completion: { [weak self] (_) in
                self?.didMove(toParent: parentViewController)
            }
        )
    }
    
    func slideOut() {
        willMove(toParent: nil)
        
        let endFrame = view.frame.offsetBy(dx: 0, dy: view.bounds.height)

        UIView.animate(
            withDuration: animationDuration,
            animations: { [weak self] in
                self?.view.frame = endFrame
            },
            completion: { [weak self] (_) in
                self?.view.removeFromSuperview()
                self?.removeFromParent()
            }
        )
    }
}

extension SearchRadiusPopupViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radii.count
    }
}

extension SearchRadiusPopupViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let parameterMap = ["miles": radii[row].rawValue]
        
        return l10nProvider.localize("location.searchradius.miles", parameterMap: parameterMap)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.searchRadiusPopupViewController(self, selectedRadius: radii[row])
    }
}

protocol SearchRadiusPopupViewControllerDelegate: class {
    func searchRadiusPopupViewController(_ viewController: SearchRadiusPopupViewController, selectedRadius radius: SearchRadius)
}
