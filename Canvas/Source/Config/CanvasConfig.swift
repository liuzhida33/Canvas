//
//  CanvasConfig.swift
//  Canvas
//
//  Created by 刘志达 on 2020/4/1.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

/// 画板配置
public struct CanvasConfig: Codable {
    
    struct Brush: Codable {
        
        struct Degree: Codable {
            /// 笔刷粗细最小值
            var minimumValue: Float = 1
            /// 笔刷粗细最大值
            var maximumValue: Float = 10
            /// 默认值
            var defaultValue: Float = 3
        }
        
        /// 画笔粗细
        var degree: Degree = Degree()
        /// 颜色池
        var colors: [StringBacked<Color>] = Color.allCases.map { StringBacked($0) }
    }
    
    /// 笔刷样式
    let brush: Brush
    /// tintColor
    let tintColor: StringBacked<Color>
    /// 默认是否开启画笔状态, default is true
    var enableBrush: Bool = true
    
    public static let `default` = CanvasConfig()
    
    /// Initializes using a configuration JSON file.
    ///
    /// - parameters:
    ///   - fileURL: URL indicating the location of the configuration file.
    public init(fileURL: URL) {
        if let jsonString = (try? String(contentsOf: fileURL, encoding: .utf8)),
            let jsonData = jsonString.data(using: .utf8) {
            do {
                self = try JSONDecoder().decode(CanvasConfig.self, from: jsonData)
            } catch {
                assertionFailure(error.localizedDescription)
                self.init()
            }
        } else {
            self.init()
        }
    }
    
    public init() {
        self.brush = Brush()
        self.tintColor = StringBacked(.blue)
    }
}
