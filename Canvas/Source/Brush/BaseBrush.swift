//
//  BaseBrush.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/28.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

class BaseBrush: BrushType {
    
    var beginPoint: CGPoint?
    var endPoint: CGPoint?
    var prePoint: CGPoint?
    var paths: [CGPath] = []
    
    var layer: CAShapeLayer?
    var path: CGMutablePath?
    
    var oncePath: CGPath {
        let mutablePath = CGMutablePath()
        paths.forEach { mutablePath.addPath($0) }
        return mutablePath
    }
    
    func apply(with style: BrushStyle) {
        assertionFailure("must implements in subclass.")
    }
}
