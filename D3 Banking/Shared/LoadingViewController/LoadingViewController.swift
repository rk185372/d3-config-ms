//
//  LoadingViewController.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/2/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import UIKit

final class LoadingViewController: UIViewController {
    
    typealias LoadingBlock = (LoadingViewController) -> Void
    
    private let loadingBlock: LoadingBlock?
    
    init(loadingBlock: LoadingBlock? = nil) {
        self.loadingBlock = loadingBlock
        super.init(nibName: "LoadingViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingBlock?(self)
    }
}
