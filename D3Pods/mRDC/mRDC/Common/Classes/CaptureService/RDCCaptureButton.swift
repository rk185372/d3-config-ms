//
//  RDCCaptureButton.swift
//  D3 Banking
//
//  Created by Chris Carranza on 2/6/17.
//
//

import Foundation

@IBDesignable
final class RDCCaptureButton: UIControl {
    let buttonLens = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
    }
    
    func prepareView() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = frame
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)
        
        let lensFrame = CGRect(origin: CGPoint.zero, size: frame.size).insetBy(dx: 7, dy: 7)
        buttonLens.frame = lensFrame
        buttonLens.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        buttonLens.layerCornerRadius = lensFrame.size.height / 2
        buttonLens.isUserInteractionEnabled = false
        addSubview(buttonLens)
        
        borderColor = UIColor.white.withAlphaComponent(0.75)
        borderWidth = 4
        layerCornerRadius = frame.size.height / 2
        clipsToBounds = true
        
        backgroundColor = UIColor.clear
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        buttonLens.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        return super.beginTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        buttonLens.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
}
