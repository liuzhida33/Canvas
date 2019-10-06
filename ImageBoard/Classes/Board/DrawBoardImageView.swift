//
//  DrawBoardImageView.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/5.
//

import UIKit

/// 绘图模式
enum SketchMode {
    case none       /* 什么都不做 */
    case pencil     /* 画笔模式 */
}

/// 绘制进度
enum DrawingState {
    case none, began, moved, ended
}

/// 开始编辑，撤销按钮可以点击
typealias beginDrawClouse = () -> Void

/// 当撤销到第一张图片，撤销按钮不可点击
typealias undoUnableActionClouse = () -> Void

// 撤销到最后一张,重置按钮不可点击
typealias redoUnableActionClouse = () -> ()

final class DrawBoardImageView: UIImageView {
    
    var beginDraw: beginDrawClouse?
    var unableDraw: undoUnableActionClouse?
    var reableDraw: redoUnableActionClouse?
    
    /// 绘图状态
    private var drawingState: DrawingState = .none
    /// 线条颜色
    var strokeColor: UIColor = .black
    /// 线条宽度
    var strokeWidth: Float = 3.0
    /// 编辑模式
    var mode: SketchMode = .none {
        didSet {
            updateBrush()
        }
    }
    
    var canUndo: Bool { return scriptManager.canUndo }
    
    var canRedo: Bool { return scriptManager.canRedo }
    
    /// 当前编辑的图片
    var currentImage: UIImage? {
        didSet {
            realImage = currentImage
            if let newImage = currentImage {
                scriptManager.reset()
                scriptManager.addImage(newImage)
                image = newImage
            }
        }
    }
    
    /// 画笔
    private var brush: BaseBrush?
    
    //保存当前的图形
    private var realImage: UIImage?
    
    /// 图稿管理对象
    private lazy var scriptManager = ManuscriptManager()
    
    /// 更新画笔
    private func updateBrush() {
        switch mode {
        case .none: brush = nil
        case .pencil: brush = PencilBrush()
        }
    }
}

// MARK: Touch
extension DrawBoardImageView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.lastPoint = nil
        brush.beginPoint = touches.first?.location(in: self)
        brush.endPoint = brush.beginPoint
        drawingState = .began
        drawingImage()
        beginDraw?()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.endPoint = touches.first?.location(in: self)
        drawingState = .moved
        drawingImage()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.endPoint = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let brush = brush else { return }
        
        brush.endPoint = touches.first?.location(in: self)
        drawingState = .ended
        drawingImage()
    }
}

// MARK: 绘制图片
extension DrawBoardImageView {
    
    /// 绘制图片
    private func drawingImage() {
        
        /// 无画笔，不进行任何操作
        guard let brush = brush else { return }
        
        /// 1.开启一个新的ImageContext，为保存每次的绘图状态作准备
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        /// 2.初始化context，进行基本设置（画笔宽度、画笔颜色、画笔的圆润度等）
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.clear.setFill()
        UIRectFill(bounds)
        
        context?.setLineCap(.round)
        context?.setLineWidth(CGFloat(strokeWidth))
        context?.setStrokeColor(strokeColor.cgColor)
        
        /// 3.把之前保存的图片绘制进context中
        if let realimage = realImage {
            realimage.draw(in: bounds)
        }
        
        /// 4.设置brush的基本属性，以便子类更方便的绘图；调用具体的绘图方法，并最终添加到context中
        brush.strokeWidth = CGFloat(strokeWidth)
        brush.drawInContext(context!)
        context?.strokePath()
        
        /// 5.从当前的context中，得到Image, 如果是ended状态或者需要支持连续不断的绘图，则将Image保存到realImage中
        let previewImage = UIGraphicsGetImageFromCurrentImageContext()
        if drawingState == .ended || brush.supportedContinuousDrawing() {
            realImage = previewImage
        }
        
        /// 6.结束上下文
        UIGraphicsEndImageContext()
        
        /// 7.实时显示当前的绘制状态，并记录绘制的最后一个点
        self.image = previewImage
        
        /// 8.结束绘制时保存至步骤记录器
        if drawingState == .ended, let image = image {
            scriptManager.addImage(image)
        }
        
        brush.lastPoint = brush.endPoint
    }
}

// MARK: 数据源处理
extension DrawBoardImageView {
    
    /// 返回当前绘制的图片
    func takeImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        UIRectFill(bounds)
        
        image?.draw(in: bounds)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError()
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 撤销
    func undo() {
        guard canUndo else { return }
        
        self.image = scriptManager.imageForUndo()
        realImage = image
        
        /// 已经撤销到第一张图片
        if !scriptManager.canUndo {
            unableDraw?()
        }
    }
    
    /// 还原
    func redo() {
        guard canRedo else { return }
        
        self.image = scriptManager.imageForRedo()
        realImage = image
        
        /// 还原后无法再进行撤销
        unableDraw?()
    }
}
