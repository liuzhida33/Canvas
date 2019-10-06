//
//  ManuscriptManager.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/4.
//

import UIKit

/// 绘图步骤记录器
final class ManuscriptManager: NSObject {
    
    /// 是否能返回
    var canUndo: Bool { return images.count > 1 }
    
    /// 能否重做
    var canRedo: Bool { return originalImage != nil }
    
    /// 原始照片
    private var originalImage: UIImage?

    /// 稿图数组
    private var images = [UIImage]()
    
    /// 重置
    func reset() {
        originalImage = nil
        images.removeAll()
    }
    
    /// 添加图片
    func addImage(_ image: UIImage) {
        /// 添加之前先判断是不是还原到最初的状态
        if images.isEmpty {
            originalImage = image
        }
        
        /// 如果images已缓存超过20条记录，删除最先缓存的记录
        if images.count >= 20 {
            images.removeFirst(1)
        }
        images.append(image)
    }
    
    /// 上一步图片
    func imageForUndo() -> UIImage? {
        if images.count > 1 {
            images.removeLast(1)
        }
        return images.last
    }
    
    /// 还原图片
    func imageForRedo() -> UIImage? {
        if images.count > 1  {
            images.removeLast(images.count - 1)
        }
        return originalImage
    }
}
