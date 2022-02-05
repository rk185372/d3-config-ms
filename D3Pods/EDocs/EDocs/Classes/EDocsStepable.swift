//
//  EDocsStepable.swift
//  EDocs
//
//  Created by Branden Smith on 12/11/19.
//

import Foundation

protocol EDocsStepable: UIViewController {
    var edocsFlowDelegate: EDocsFlowDelegate? { get set }
}
