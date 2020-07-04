//
//  UIImage++.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/30.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).addClip()
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: cgImage)
    }
}
