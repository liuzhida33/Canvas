//
//  BrushColorView.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/3.
//

import UIKit

// 选择画笔颜色
final class BrushColorView: UIView {
    
    /// 颜色集合
    var colors: [UIColor] = []
    
    /// 点击选择颜色
    var onClickEditingColor: ((UIColor) -> Void)?
    
    /// 当前使用的颜色
    var currentColor: UIColor?
    
    required init(colors: [UIColor]) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.colors = colors
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
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(BrushColorCell.self, forCellWithReuseIdentifier: "Cell")
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
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension BrushColorView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? BrushColorCell else { fatalError() }
        cell.colorView.backgroundColor = colors[indexPath.item]
        cell.borderView.isHidden = colors[indexPath.item] != currentColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        currentColor = colors[indexPath.item]
        collectionView.reloadData()
        if let currentColor = currentColor {
            onClickEditingColor?(currentColor)
        }
    }
}

/// 颜色枚举cell
fileprivate final class BrushColorCell: UICollectionViewCell {
    
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
        view.layer.borderColor = UIColor.systemBlue.cgColor
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
