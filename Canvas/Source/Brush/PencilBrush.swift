//
//  PencilBrush.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/28.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

class PencilBrush: BaseBrush {
    
    override func apply(with style: BrushStyle) {
        guard let layer = layer else { return }
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.lineWidth = style.strokeWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = style.strokeColor.cgColor
    }
}
