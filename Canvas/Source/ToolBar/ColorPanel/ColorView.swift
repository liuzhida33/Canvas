//
//  ColorView.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

// 选择画笔颜色
final class ColorView: UIView {
    
    /// 点击选择颜色
    var onColorChange: ((UIColor) -> Void)?
    /// 颜色集合
    private(set) var colors: [UIColor]
    /// 当前使用的颜色
    private(set) var currentColor: UIColor
    /// 当前配置
    private let config: CanvasConfig
    
    required init(config: CanvasConfig) {
        self.config = config
        self.colors = config.brush.colors.map(\.value.rawValue)
        self.currentColor = colors.first ?? .red
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func setupUI() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension ColorView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ColorCell else { fatalError() }
        cell.colorView.backgroundColor = colors[indexPath.item]
        cell.borderView.isHidden = colors[indexPath.item] != currentColor
        cell.borderView.layer.borderColor = config.tintColor.value.rawValue.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        currentColor = colors[indexPath.item]
        collectionView.reloadData()
        onColorChange?(currentColor)
    }
}
