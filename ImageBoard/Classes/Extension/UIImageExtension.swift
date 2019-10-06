//
//  UIImageExtension.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/4.
//

import Foundation

extension UIImage {

    /// Create UIImage from color and size.
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    convenience init(color: UIColor, size: CGSize = CGSize(width: 30, height: 30)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).addClip()
        
        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }
}
