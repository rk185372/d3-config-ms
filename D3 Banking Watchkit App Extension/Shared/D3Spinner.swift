//
//  D3Spinner.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/22/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import WatchKit

final class D3Spinner: NSObject {

    func startSpinner(_ image: WKInterfaceImage!) {
        image.setImageNamed("spinner")
        image.startAnimatingWithImages(in: NSMakeRange(1, 42), duration: 1.41, repeatCount: -1)
        image.setHidden(false)
    }

    func stopSpinner(_ image: WKInterfaceImage!) {
        image.stopAnimating()
        image.setHidden(true)
    }
}
