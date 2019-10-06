//
//  BoardToolBar.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/4.
//

import UIKit

protocol BoardToolBarDelegate: NSObject {
    
    /// 选择编辑颜色
    /// - Parameter strokeColor: 已选颜色
    func didSelect(strokeColor: UIColor)
    
    /// 选择绘图模式
    /// - Parameter mode: 绘图模式
    func didSelect(mode: SketchMode)
    
    /// 线条宽度变化
    /// - Parameter strokeWidth: 线条宽度
    func didChange(strokeWidth: Float)
}

/// 画笔工具栏
final class BoardToolBar: UIView {
    
    weak var delegate: BoardToolBarDelegate?
    
    /// 线条颜色
    private var strokeColor: UIColor = .black {
        didSet {
            colorButton.setImage(UIImage(color: strokeColor), for: .normal)
            delegate?.didSelect(strokeColor: strokeColor)
        }
    }
    
    /// 线条宽度
    private var strokeWidth: Float = 3.0 {
        didSet {
            delegate?.didChange(strokeWidth: strokeWidth)
        }
    }
    
    /// 当前绘图模式，默认什么都不做
    private var mode: SketchMode = .none {
        didSet {
            delegate?.didSelect(mode: mode)
        }
    }
    
    private lazy var toolBar: UIToolbar = {
        let bar = UIToolbar()
        return bar
    }()
    
    /// 选择颜色
    private lazy var colorButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(color: .lightGray), for: .disabled)
        button.addTarget(self, action: #selector(onColorClick(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 画笔
    private lazy var strokeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(onStrokeClick(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var colors: [UIColor] = [.black, .blue, .cyan, .green, .red, .orange, .yellow, .purple, .brown, .gray, .lightGray]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        toolBar.frame = bounds
    }
    
    private func initialize() {
        
        addSubview(toolBar)
        
        var bundle = Bundle(for: BoardToolBar.classForCoder())
        if let resourcePath = bundle.path(forResource: "ImageBoard", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        
        strokeButton.setImage(UIImage(named: "pencil", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        colorButton.setImage(UIImage(color: colors.first ?? UIColor.red), for: .normal)
        
        toolBar.items = [createFlexibleSpaceItem(),
                         UIBarButtonItem(customView: colorButton),
                         createFixedSpaceItem(),
                         UIBarButtonItem(customView: strokeButton),
                         createFlexibleSpaceItem()]
    }
    
    private func createFlexibleSpaceItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    private func createFixedSpaceItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = 30
        return item
    }
    
    @objc private func onStrokeClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? .systemBlue : .lightGray
        mode = sender.isSelected ? .pencil : .none
    }
    
    @objc private func onColorClick(_ sender: UIButton) {
        let popver = BrushColorViewController(colors: colors,
                                              strokeColor: strokeColor,
                                              strokeWidth: strokeWidth)
        popver.preferredContentSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 150)
        popver.modalPresentationStyle = .popover
        popver.popoverPresentationController?.delegate = self
        popver.popoverPresentationController?.sourceView = sender
        popver.popoverPresentationController?.permittedArrowDirections = .down
        popver.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sender.bounds.width, height: 0)
        popver.editingStrokeColor = { color in
            self.strokeColor = color
        }
        popver.editingStrokeWidth = { width in
            self.strokeWidth = width
        }
        
        UIApplication.topViewController()?.present(popver, animated: true)
    }
}

extension BoardToolBar: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

/// 画笔样式调整弹出窗口
fileprivate final class BrushColorViewController: UIViewController {
    
    var editingStrokeColor: ((UIColor) -> Void)?
    var editingStrokeWidth: ((Float) -> Void)?
    
    /// 选择颜色
    private lazy var colorView: BrushColorView = {
        return BrushColorView(colors: colors)
    }()
    
    /// 线条宽度slider
    private lazy var strokeSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 10.0
        slider.value = strokeWidth ?? 3.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(onStrokeWidthValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    /// 线条宽度图标
    private lazy var strokeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 编辑颜色
    private let colors: [UIColor]
    /// 画笔颜色
    private let strokeColor: UIColor?
    /// 线条宽度
    private let strokeWidth: Float?
    
    /// 创建选择颜色与调整线条宽度的popver View
    /// - Parameter colors: 编辑颜色
    /// - Parameter strokeWidth: 线条宽度
    required init(colors: [UIColor],
                  strokeColor: UIColor?,
                  strokeWidth: Float?) {
        self.colors = colors
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        var bundle = Bundle(for: BrushColorViewController.classForCoder())
        if let resourcePath = bundle.path(forResource: "ImageBoard", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        
        strokeImageView.image = UIImage(named: "bold", in: bundle, compatibleWith: nil)
        
        colorView.currentColor = strokeColor
        colorView.onClickEditingColor = { [weak self] color in
            self?.editingStrokeColor?(color)
        }
        
        addConstraints()
    }
    
    @objc private func onStrokeWidthValueChanged(_ sender: UISlider) {
        editingStrokeWidth?(sender.value)
    }
    
    private func addConstraints() {
        
        [colorView, strokeImageView, strokeSlider].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            colorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            colorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            colorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            colorView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            strokeImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            strokeImageView.widthAnchor.constraint(equalToConstant: 25),
            strokeImageView.heightAnchor.constraint(equalToConstant: 25),
            strokeImageView.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 15),
        ])
        
        NSLayoutConstraint.activate([
            strokeSlider.leftAnchor.constraint(equalTo: strokeImageView.rightAnchor, constant: 15),
            strokeSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            strokeSlider.centerYAnchor.constraint(equalTo: strokeImageView.centerYAnchor),
        ])
    }
}
