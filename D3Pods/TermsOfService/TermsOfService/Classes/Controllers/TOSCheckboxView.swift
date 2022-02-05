//
//  TOSCheckboxView.swift
//  TermsOfService
//
//  Created by Pablo Pellegrino on 02/12/2021.
//

import Foundation
import ComponentKit
import SnapKit
import SimpleMarkdownParser

private struct TOSCheckboxInfo {
    let title: String
    let checkboxText: String
    let checkboxErrorText: String
}
class TOSCheckboxView: UIView {
    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var checkboxTextLabel: UILabelComponent!
    @IBOutlet weak var checkbox: UICheckboxComponent!
    @IBOutlet weak var checkboxErrorLabel: UILabelComponent!
    
    private let errorText: String
    init(title: String,
         checkboxText: String,
         checkboxErrorText: String) {
        errorText = checkboxErrorText
        super.init(frame: .zero)
        
        let contentView = TermsOfServiceBundle.bundle.loadNibNamed("TOSCheckboxView", owner: self, options: nil)?.first as! UIView
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        titleLabel.attributedText = SimpleMarkdownConverter.toAttributedString(defaultFont: titleLabel.font,
                                                                               markdownText: title)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.areLinksEnabled = true
        checkboxTextLabel.attributedText = SimpleMarkdownConverter.toAttributedString(defaultFont: checkboxTextLabel.font,
                                                                                      markdownText: checkboxText)
        checkboxTextLabel.isUserInteractionEnabled = true
        checkboxTextLabel.areLinksEnabled = true
        showError(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showError(_ show: Bool) {
        checkboxErrorLabel.text = show ? errorText : ""
        checkboxErrorLabel.isHidden = !show
    }
    
    var isChecked: Bool {
        return checkbox.checkState == .checked
    }
}
