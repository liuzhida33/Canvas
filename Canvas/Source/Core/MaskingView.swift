//
//  MaskingView.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/30.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

class MaskingView: UIView {
    
    weak var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = backgroundView {
                view.isUserInteractionEnabled = false
                view.frame = bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(view)
                sendSubviewToBack(view)
            }
        }
    }
}
