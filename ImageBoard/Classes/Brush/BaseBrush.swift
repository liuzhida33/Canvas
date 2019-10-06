//
//  BaseBrush.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/4.
//

import UIKit

// 画笔工具协议
protocol BrushProtocol {
    
    // 表示是否是连续绘图
    func supportedContinuousDrawing() -> Bool
    
    // 基于Context的绘图
    func drawInContext(_ context: CGContext)
    
}

// 画笔基类
class BaseBrush: NSObject, BrushProtocol {

    var beginPoint: CGPoint?
    
    var endPoint: CGPoint?
    
    var lastPoint: CGPoint?
    
    // 线的粗细
    var strokeWidth: CGFloat?
    
    // 表示是否是连续绘图
    func supportedContinuousDrawing() -> Bool {
        return false
    }
    
    // 基于Context的绘图
    func drawInContext(_ context: CGContext) {
        assert(false, "must implements in subclass.")
    }
}
