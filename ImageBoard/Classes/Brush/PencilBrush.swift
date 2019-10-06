//
//  PencilBrush.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/4.
//

/// 普通画笔
class PencilBrush: BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        if let lastPoint = lastPoint {
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: (endPoint?.y ?? 0)))
        } else {
            context.move(to: CGPoint(x: (beginPoint?.x ?? 0), y: ( beginPoint?.y ?? 0)))
            context.addLine(to: CGPoint(x: (endPoint?.x ?? 0), y: ( endPoint?.y ?? 0 )))
        }
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}
