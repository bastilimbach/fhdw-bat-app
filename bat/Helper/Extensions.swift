//
//  Extensions.swift
//  bat
//
//  Created by Sebastian Limbach on 01.11.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

extension UIColor {
    /// FHDW accent color
    class var fhdwOrange: UIColor {
        return UIColor.init(red: 241/255, green: 145/255, blue: 37/255, alpha: 1)
    }

    /// FHDW primary color
    class var fhdwBlue: UIColor {
        return UIColor.init(red: 36/255, green: 57/255, blue: 104/255, alpha: 1)
    }

    /// FHDW secondary color
    class var fhdwLightBlue: UIColor {
        return UIColor.init(red: 60/255, green: 111/255, blue: 193/255, alpha: 1)
    }
}

extension UIImage {
    func image(ofSize proposedSize: CGSize) -> UIImage? {
        let scale = min(size.width/proposedSize.width, size.height/proposedSize.height)
        let newSize = CGSize(width: size.width/scale, height: size.height/scale)
        let newOrigin = CGPoint(x: (proposedSize.width - newSize.width)/2, y: (proposedSize.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(proposedSize, false, 0)
        draw(in: thumbRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    func resizeImage(withNewHeight newHeight: CGFloat) -> UIImage? {
        let scale = newHeight / size.height
        let newWidth = size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

