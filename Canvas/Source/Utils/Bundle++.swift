//
//  Bundle++.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/30.
//  Copyright © 2020 joylife. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var framework: Bundle {
        let bundle = Bundle(for: CanvasController.self)
        if let path = bundle.path(forResource: "Canvas", ofType: "bundle") {
            return Bundle(path: path)!
        } else {
            return bundle
        }
    }
}
