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
    var canRedo: Bool { true }
    
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
extension CanvasView {
    
    /// 合成图片
    /// 涂鸦操作过程中图片是以当前画板的`bounds`大小绘制上下文，目的是降低绘制中内存增耗
    /// 绘制完毕后，结合`history`存储的路径和缩放比例进行原图还原
    func compositeImage() -> UIImage? {
        return originalImage?.output(with: history, fromSize: bounds.size)
    }
    
    /// 返回笔迹图片
    /// - Parameter opaque: 是否为不透明，默认为画板背景色
    /// - Returns: 笔迹图片
    func brushImage(opaque: Bool = true, watermark: WaterMark = .none) -> UIImage? {
        return UIImage(layers: history, color: opaque ? backgroundColor : nil, size: bounds.size, watermark: watermark)
    }
}

fileprivate extension UIImage {
    
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
    
    /// 合成水印图片
    /// - Parameter word: 水印文字
    /// - Parameter layout: 水印布局
    /// - Returns: 水印图片
    func makeWatermark(word: WaterMark.Word, layout: WaterMark.Layout) -> UIImage {
        
        defer { UIGraphicsEndImageContext() }
        
        //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
        let sqrtLength = sqrt(size.width * size.width + size.height * size.height)
        //文字的属性
        let attr: [NSAttributedString.Key: Any] = [.font: word.font,
                                                   .foregroundColor: word.color ?? .lightGray]
        let attrStr = NSAttributedString(string: word.title, attributes: attr)
        let strWidth = attrStr.size().width
        let strHeight = attrStr.size().height
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        draw(in: CGRect(origin: .zero, size: size))
        
        let context = UIGraphicsGetCurrentContext()!
        
        //将绘制原点（0，0）调整到源image的中心
        context.concatenate(CGAffineTransform(translationX: size.width / 2, y: size.height / 2))
        //以绘制原点为中心旋转
        context.concatenate(CGAffineTransform(rotationAngle: layout.transformRotation))
        //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
        context.concatenate(CGAffineTransform(translationX: -size.width / 2, y: -size.height / 2))
        
        //计算需要绘制的列数和行数
        let horCount = sqrtLength / (strWidth + layout.horizontalSpace) + 1
        let verCount = sqrtLength / (strHeight + layout.verticalSpace) + 1
        
        //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
        let orignX = -(sqrtLength - size.width) / 2
        let orignY = -(sqrtLength - size.height) / 2
        
        //在每列绘制时X坐标叠加
        var tempOrignX = orignX
        //在每行绘制时Y坐标叠加
        var tempOrignY = orignY
        for i in 0..<(Int(horCount * verCount)) {
            let mark = word.title as NSString
            mark.draw(in: CGRect(x: tempOrignX, y: tempOrignY, width: strWidth, height: strHeight), withAttributes: attr)
            if i % Int(horCount) == 0, i != 0 {
                tempOrignX = orignX
                tempOrignY += (strHeight + layout.verticalSpace)
            } else {
                tempOrignX += (strWidth + layout.horizontalSpace)
            }
        }
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return self
        }
                
        return UIImage(cgImage: cgImage)
    }
    
    /// 绘制路径图片
    /// - Parameters:
    ///   - layers: 路径集合
    ///   - color: 背景颜色
    ///   - size: 返回绘制路径之后的原图尺寸图片
    convenience init(layers: [CAShapeLayer], color: UIColor?, size: CGSize, watermark: WaterMark) {
        defer { UIGraphicsEndImageContext() }
        
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        
        (color ?? UIColor(white: 0, alpha: 0)).setFill()
        UIRectFill(CGRect(origin: .zero, size: newSize))
        
        let context = UIGraphicsGetCurrentContext()!
        
        let transform: (CAShapeLayer) -> Void = { layer in
            let slayer = CAShapeLayer(layer: layer)
            let scaleX = newSize.width / size.width
            let scaleY = newSize.height / size.height
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
        
        if case .word(let word, let layout) = watermark {
            guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
                self.init()
                return
            }
            UIImage(cgImage: cgImage).makeWatermark(word: word, layout: layout).draw(in: CGRect(origin: .zero, size: newSize))
            layers.forEach(transform)
        } else {
            layers.forEach(transform)
        }

        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: cgImage)
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
