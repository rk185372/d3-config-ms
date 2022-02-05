//
//  NotPresentViewController.swift
//  Accounts-iOS
//
//  Created by Jose Torres on 9/4/20.
//

import UIKit

public final class NotPresentViewController: UIViewController {
 
    public struct ActionKey: RawRepresentable {
            
        public typealias RawValue = String
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public let actionKey: ActionKey
    
    public init(actionKey: ActionKey) {
        self.actionKey = actionKey
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Unsupported initialize for NotPresentViewController")
    }
}
