//
//  UIBarButtonItem++.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/30.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    static func flexibleSpace() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    static func fixedSpace(width: CGFloat = 15.0) -> UIBarButtonItem {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        buttonItem.width = width
        return buttonItem
    }
}
