//
//  MiSnapSDKViewControllerUX2Provider.swift
//  Pods
//
//  Created by Branden Smith on 2/15/19.
//

import Foundation
import MiSnap

final class MiSnapSDKViewControllerUX2Provider: MiSnapViewControllerProvider {
    func viewController(forSide side: RDCCaptureSide, withDelegate delegate: MiSnapViewControllerDelegate) -> UIViewController {
        let vc = UIStoryboard
            .init(
                name: "MiSnapUX2",
                bundle: Bundle(for: MiSnapSDKViewControllerUX2.self)
            )
            .instantiateViewController(withIdentifier: "MiSnapSDKViewControllerUX2") as! MiSnapSDKViewControllerUX2
        let params = (side == .front)
            ? MiSnapSDKViewControllerUX2.defaultParametersForCheckFront()
            : MiSnapSDKViewControllerUX2.defaultParametersForCheckBack()
        vc.delegate = delegate
        vc.setupMiSnap(withParams: params as? [AnyHashable: Any])
        vc.shouldDissmissOnSuccess = false

        return vc
    }
}
