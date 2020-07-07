//
//  CanvasView.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/28.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

final class CanvasView: UIImageView {
    
    // 绘制状态
    enum State {
        case idle, began, moved, ended
    }
    
    var brush: BaseBrush?
    var color: UIColor!
    var degree: CGFloat!
    var beginDraw: (() -> Void)?
    var unableDraw: (() -> Void)?
    
    override var image: UIImage? {
        set { render(newValue) }
        get { compositeImage() }
    }
    /// 是否能返回
    var canUndo: Bool { history.count > 0 }
    
    /// 能否重做
    var canRedo: Bool { originalImage != nil }
    
    // 绘图状态
    private var state: State = .idle
    // 历史记录
    private var history: [CAShapeLayer] = []
    // 原始图片
    private var originalImage: UIImage?
    // 样式
    private var style: BrushStyle { BrushStyle(strokeColor: color, strokeWidth: degree) }
}

// MARK: - Action
extension CanvasView {
    
    /// 撤销
    func undo() {
        guard canUndo else { return }
                
        history.last?.removeFromSuperlayer()
        history.removeLast()
        
        /// 已经撤销到第一张图片
        if !canUndo {
            unableDraw?()
        }
    }
    
    /// 还原
    func redo() {
        guard canRedo else { return }
        
        history.forEach { $0.removeFromSuperlayer() }
        history.removeAll()
        unableDraw?()
    }
}

// MARK: - Private
private extension CanvasView {
    
    /// 将图片渲染到画板上
    /// - Parameter image: 图片资源
    func render(_ image: UIImage?) {
        originalImage = image
        history.removeAll()
        
        super.image = image?.scaled(toSize: bounds.size)
    }
}

// MARK: - Touch
extension CanvasView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush, let point = touches.first?.location(in: self) else { return }
        
        let path = CGMutablePath()
        let slayer = CAShapeLayer()
        path.move(to: point)
        slayer.path = path
        brush.path = path
        brush.layer = slayer
        brush.apply(with: style)
        history.append(slayer)
        layer.addSublayer(slayer)
        
        beginDraw?()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush,
            let path = brush.path,
            let point = touches.first?.location(in: self) else { return }
        
        path.addLine(to: point)
        brush.layer?.path = path
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.path = nil
        brush.layer = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.path = nil
        brush.layer = nil
    }
}

// MARK: - Draw
private extension CanvasView {
    
    /// 合成图片
    /// 涂鸦操作过程中图片是以当前画板的`bounds`大小绘制上下文，目的是降低绘制中内存增耗
    /// 绘制完毕后，结合`history`存储的路径和缩放比例进行原图还原
    func compositeImage() -> UIImage? {
        return originalImage?.output(with: history, fromSize: bounds.size)
    }
}

extension UIImage {
    
    /// 绘制图片，根据画板预览大小和原始图片尺寸计算缩放比例，并针对画笔路径进行形变后重新绘图
    /// - Parameters:
    ///   - layers: 路径集合
    ///   - fromSize: 画板尺寸
    /// - Returns: 返回绘制路径之后的原图尺寸图片
    func output(with layers: [CAShapeLayer], fromSize: CGSize) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let context = UIGraphicsGetCurrentContext()!
        
        let transform: (CAShapeLayer) -> Void = { layer in
            let slayer = CAShapeLayer(layer: layer)
            let scaleX = newSize.width / fromSize.width
            let scaleY = newSize.height / fromSize.height
            let oldPath = layer.path
            let oldWidth = layer.lineWidth
            var scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
            slayer.lineCap = .round
            slayer.lineJoin = .round
            slayer.fillColor = UIColor.clear.cgColor
            slayer.strokeColor = layer.strokeColor
            slayer.lineWidth = oldWidth * scaleX
            slayer.path = oldPath?.copy(using: &scale)
            slayer.render(in: context)
        }
        layers.forEach(transform)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// 缩放图片
    /// - Parameter toSize: 指定缩放后的大小
    /// - Returns: 返回缩放后的图片
    func scaled(toSize: CGSize) -> UIImage? {
        
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(toSize, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
