//
//  Segue+StoryboardSegueType.swift
//  D3 Banking
//
//  Created by Chris Carranza on 6/9/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Perform

extension Segue {
    init<T: SegueType>(segue: T) where T.RawValue == String {
        self.init(identifier: segue.rawValue)
    }
}
