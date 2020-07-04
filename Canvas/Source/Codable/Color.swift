//
//  Color.swift
//  Canvas
//
//  Created by 刘志达 on 2020/4/1.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit.UIColor

struct Color: RawRepresentable, CaseIterable {
    var rawValue: UIColor

    init(rawValue: UIColor) {
        self.rawValue = rawValue
    }
    
    static let black = Color(rawValue: .black)
    static let red = Color(rawValue: .red)
    static let yellow = Color(rawValue: .yellow)
    static let blue = Color(rawValue: .systemBlue)
    static let green = Color(rawValue: .green)
    static let gray = Color(rawValue: .gray)
    static let cyan = Color(rawValue: .cyan)
    static let magenta = Color(rawValue: .magenta)
    static let orange = Color(rawValue: .orange)
    static let purple = Color(rawValue: .purple)
    static let brown = Color(rawValue: .brown)
    
    static var allCases: [Color] {
        return [.black, .red, .yellow, .blue, .green, .gray, .cyan, .magenta, .orange, .purple, .brown]
    }
}

extension Color: StringRepresentable {
    
    init?(_ value: String) {
        if let color = UIColor(hexString: value) {
            self.init(rawValue: color)
        } else {
            return nil
        }
    }
    
    var description: String { rawValue.hexString }
}
