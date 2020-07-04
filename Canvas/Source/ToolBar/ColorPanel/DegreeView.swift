//
//  DegreeView.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

final class DegreeView: UIView {
    
    /// 滑块滑动值（画笔粗细）
    var onStrokeDegreeChange: ((Float) -> Void)?
    /// 当前画笔粗细
    private(set) var currentDegree: Float
    /// 当前配置
    private let config: CanvasConfig
    
    required init(config: CanvasConfig) {
        self.config = config
        self.currentDegree = config.brush.degree.defaultValue
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.slider.value = currentDegree
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 线条宽度图标
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "degree", in: Bundle.framework, compatibleWith: nil)
        return imageView
    }()
    
    /// 线条宽度slider
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = config.brush.degree.maximumValue
        slider.minimumValue = config.brush.degree.minimumValue
        slider.minimumTrackTintColor = config.tintColor.value.rawValue
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(strokeDegreeValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private func setupUI() {
        
        let hStackView = UIStackView(arrangedSubviews: [imageView, slider])
        hStackView.spacing = 15
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            hStackView.leftAnchor.constraint(equalTo: leftAnchor),
            hStackView.rightAnchor.constraint(equalTo: rightAnchor),
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    @objc private func strokeDegreeValueChanged(_ slider: UISlider) {
        onStrokeDegreeChange?(slider.value)
    }
}
