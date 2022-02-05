//
//  BadgeOnMoreView.swift
//  ComponentKit
//
//  Created by Jose Torres on 9/30/20.
//

import UIKit
import Localization

public final class BadgeOnMoreView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textLabel: UILabel!
    private var count: String
    
    required init?(coder: NSCoder) {
        fatalError("BadgeOnMoreView.init(coder:) has not been implemented")
    }
    
    required init(l10nProvider: L10nProvider, type: BadgeMoreViewManagerType, count: String) {
        self.count = count
        super.init(frame: .zero)
        self.loadNib()
        self.loadLabel(l10nProvider, type)
        self.view.layer.cornerRadius = 5.0
    }
    
    private func loadLabel(_ l10nProvider: L10nProvider, _ type: BadgeMoreViewManagerType) {
        let l10nKey: String
        let l10nParameter: String
        switch type {
        case .messages:
            l10nKey = "nav.messages.badge"
            l10nParameter = "messagesCount"
        case .alerts:
            l10nKey = "nav.alerts.badge"
            l10nParameter = "alertsCount"
        case .approvals:
            l10nKey = "nav.approvals.badge"
            l10nParameter = "approvalsCount"
        }
        self.textLabel.text = l10nProvider.localize(l10nKey, parameterMap: [l10nParameter: self.count])
    }
        
    private func loadNib() {
        let view = ComponentKitBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        addSubview(view)
        view.makeMatch(view: self)
    }
}
