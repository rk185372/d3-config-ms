//
//  UIImage+RDC.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/16/18.
//

import Foundation
import UIKit

let RDCMaxSize: CGFloat = 1600.0

extension UIImage {
    
    /**
     Returns the data for the specified image in JPEG format.
     
     - Parameter compressionQuality: The quality of the resulting JPEG image, expressed as a value from 0.0 to
     1.0. The value 0.0 represents the maximum compression (or lowest quality) while
     the value 1.0 represents the least compression (or best quality).
     - Returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return
     nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
     */
    func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        return jpegData(compressionQuality: compressionQuality)
    }
    
    /**
     Returns the data for the specified image in JPEG format. This will use the jpegQuality from the FI config file
     otherwise it will default to a quality of 0.8.
     
     - Returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil
     if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
     */
    func jpegRepresentationForRDC() -> Data? {
        return jpegRepresentation(compressionQuality: 80 / 100)
    }
    
    /**
     Resizes an image to a given size
     
     - Note: This method will resize using a scale factor of 1.0, this may not be desired in all circumstances
     - Parameter size: The target size of the image.
     - Returns: Resized image
     
     */
    func resizedImage(toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? self
    }
    
    /**
     Resizes an image to the RDCMaxSize constant
     
     - Note: This method will resize using a scale factor of 1.0, this may not be desired in all circumstances
     - Returns: Resized image
     
     */
    func resizedImageForRDC() -> UIImage {
        let (width, height) = (size.width, size.height)
        
        guard max(width, height) > RDCMaxSize else {
            return self
        }
        
        var newSize: CGSize
        
        if width > height {
            let ratio: CGFloat = width / RDCMaxSize
            newSize = CGSize(width: width / ratio, height: height / ratio)
            
        } else {
            let ratio: CGFloat = height / RDCMaxSize
            newSize = CGSize(width: width / ratio, height: height / ratio)
        }
        
        return resizedImage(toSize: newSize)
    }
    
    /**
    Rotates an image to a given angle
    
    - Parameter radians: The degree in radians you want to rotate the image
    - Note: .pi / 2 is 90 degrees clockwise. -.pi / 2 is 90 degrees counter-clockwise
    - Returns: Rotated image
    
    */
    func rotate(radians: Float) -> UIImage? {
        guard radians != 0 else { return self }
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(
            x: -self.size.width / 2,
            y: -self.size.height / 2,
            width: self.size.width,
            height: self.size.height
            )
        )
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
