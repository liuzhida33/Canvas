//
//  ColorPanel.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

// 选择画笔颜色、画笔粗细
final class ColorPanel: UIViewController {
    
    lazy var colorView = ColorView(config: config)
    lazy var degreeView = DegreeView(config: config)
    
    /// 当前配置
    private let config: CanvasConfig
    
    required init(config: CanvasConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private func setupUI() {
        
        let vStackView = UIStackView(arrangedSubviews: [colorView, degreeView])
        vStackView.spacing = 30
        vStackView.axis = .vertical
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            vStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
        ])
    }
}
