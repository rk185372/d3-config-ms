//
//  ContentViewController.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/17/19.
//

import Foundation

public typealias FeatureTourContentViewController = UIViewController & ContentViewController

public protocol ContentViewController: class {
    var delegate: ContentViewDelegate? { get set }
}
