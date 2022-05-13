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
    
    /// 图片主色调
    var mostColor: UIColor? {
        let bitmapInfo = CGBitmapInfo(rawValue: 0).rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let thumbSize = CGSize(width: 50, height: 50)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: Int(thumbSize.width), height: Int(thumbSize.height), bitsPerComponent: 8, bytesPerRow: Int(thumbSize.width) * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        
        let drawRect = CGRect(x: 0, y: 0, width: thumbSize.width, height: thumbSize.height)
        
        context.draw(self.cgImage!, in: drawRect)
        
        // 取每个点的像素值
        
        if context.data == nil { return nil }
        
        let countedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height))
        
        for x in 0 ..< Int(thumbSize.width) {
            
            for y in 0 ..< Int(thumbSize.height) {
                
                let offset = 4 * x * y
                
                let red = context.data!.load(fromByteOffset: offset, as: UInt8.self)
                
                let green = context.data!.load(fromByteOffset: offset+1, as: UInt8.self)
                
                let blue = context.data!.load(fromByteOffset: offset+2, as: UInt8.self)
                
                let alpha = context.data!.load(fromByteOffset: offset+3, as: UInt8.self)
                
                // 过滤掉透明的，基本白色的，基本黑色的
                
                if alpha > 0 && (red < 250 && blue < 250 && green < 250) && (red > 5 && green > 5 && blue > 5) {
                    let array = [red,green,blue,alpha]
                    countedSet.add(array)
                }
            }
        }
        
        // 找到出现次数最多的颜色
        
        let enmurator = countedSet.objectEnumerator()
        
        var maxColor: [Int] = []
        
        var maxCount = 0
        
        while let currentColor = enmurator.nextObject() as? [Int] {
            let tmpCount = countedSet.count(for: currentColor)
            if tmpCount < maxCount { continue }
            
            maxCount = tmpCount
            maxColor = currentColor
        }
        
        let color = UIColor(red: CGFloat(maxColor[0]) / 255.0, green: CGFloat(maxColor[1]) / 255.0, blue: CGFloat(maxColor[2]) / 255.0, alpha: CGFloat(maxColor[3]) / 255.0)
        return color
    }
}
