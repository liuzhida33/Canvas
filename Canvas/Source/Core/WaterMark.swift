//
//  WaterMark.swift
//  Canvas
//
//  Created by 刘志达 on 2022/5/12.
//  Copyright © 2022 joylife. All rights reserved.
//

import Foundation
import UIKit

public enum WaterMark {
    
    public struct Word {
        public var title: String
        public var font: UIFont = .systemFont(ofSize: 12)
        /// 默认图片主色调
        public var color: UIColor?
        
        public init(title: String, font: UIFont = .systemFont(ofSize: 12), color: UIColor? = nil) {
            self.title = title
            self.font = font
            self.color = color
        }
    }
    
    public struct Layout {
        public var horizontalSpace: CGFloat = 30
        public var verticalSpace: CGFloat = 50
        public var transformRotation: CGFloat = -Double.pi / 6
        
        public init(horizontalSpace: CGFloat = 30, verticalSpace: CGFloat = 50, transformRotation: CGFloat = -Double.pi / 6) {
            self.horizontalSpace = horizontalSpace
            self.verticalSpace = verticalSpace
            self.transformRotation = transformRotation
        }
    }
    
    case none
    case word(Word, Layout)
    case picture
}
