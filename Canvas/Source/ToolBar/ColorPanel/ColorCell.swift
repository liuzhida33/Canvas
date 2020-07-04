//
//  ColorCell.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

/// 颜色cell
final class ColorCell: UICollectionViewCell {
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [borderView, colorView].forEach(contentView.addSubview)
        
        NSLayoutConstraint.activate([
            borderView.widthAnchor.constraint(equalToConstant: 40.0),
            borderView.heightAnchor.constraint(equalToConstant: 40.0),
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 30.0),
            colorView.heightAnchor.constraint(equalToConstant: 30.0),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
