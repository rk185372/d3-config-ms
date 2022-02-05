//
//  NoItemsViewController.swift
//  ComponentKit
//
//  Created by Jose Torres on 12/3/20.
//

import UIKit

public final class NoItemsViewController: UIViewController {
    @IBOutlet weak var noItemsView: NoItemsView!
    private let componentStyleProvider: ComponentStyleProvider
    private var message: String?
    private var actionHandler: (() -> Void)?

    public init(componentStyleProvider: ComponentStyleProvider, text: String, action:(() -> Void)?) {
        self.componentStyleProvider = componentStyleProvider
        self.message = text
        self.actionHandler = action
        super.init(
            nibName: String(describing: type(of: self)),
            bundle: ComponentKitBundle.bundle
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.noItemsView.infoLabel.text = message

        let style: ButtonStyle = componentStyleProvider[ButtonStyleKey.buttonOnPrimary]
        style.style(component: self.noItemsView.tryAgainButton)
        self.noItemsView.tryAgainButton.addTarget(
            self,
            action: #selector(self.action(sender:)),
            for: .touchUpInside
        )
    }

    @IBAction func action(sender: Any) {
        actionHandler?()
    }
}
