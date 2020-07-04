//
//  ToolBar.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/31.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

/// 画笔工具栏
final class ToolBar: UIView {
    
    enum SketchMode {
        case idle       /* 空闲模式 */
        case pencil     /* 画笔模式 */
    }
    
    var onStrokeColorChange: ((UIColor) -> Void)?
    var onStrokeDegreeChange: ((Float) -> Void)?
    var onSketchModeChange: ((SketchMode) -> Void)?
    var onRedoAction: (() -> Void)?
    var onUndoAction: (() -> Void)?
    var currentColor: UIColor { colorPanel.colorView.currentColor }
    var currentDegree: CGFloat { CGFloat(colorPanel.degreeView.currentDegree) }
    var canUndo: Bool = false {
        didSet {
            undoButton.isEnabled = canUndo
            undoButton.tintColor = canUndo ? config.tintColor.value.rawValue : .lightGray
        }
    }
    var canRndo: Bool = false {
        didSet {
            redoButton.isEnabled = canRndo
            redoButton.tintColor = canRndo ? config.tintColor.value.rawValue : .lightGray
        }
    }
    /// 当前绘图模式，默认空闲
    private(set) var sketchMode: SketchMode {
        didSet {
            brushButton.tintColor = sketchMode == .pencil ? config.tintColor.value.rawValue : .lightGray
            onSketchModeChange?(sketchMode)
        }
    }
    
    required init(config: CanvasConfig) {
        self.config = config
        self.sketchMode = config.enableBrush ? .pencil : .idle
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        
        colorPanel.colorView.onColorChange = { [weak self] color in
            self?.onStrokeColorChange?(color)
            self?.colorButton.backgroundColor = color
        }
        
        colorPanel.degreeView.onStrokeDegreeChange = { [weak self] degree in
            self?.onStrokeDegreeChange?(degree)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 当前配置
    private let config: CanvasConfig
    
    /// 选择颜色
    private lazy var colorButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didColorClick(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 画笔
    private lazy var brushButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didBrushClick(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 撤销上一步
    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "undo", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(didUndoAction(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 重做
    private lazy var redoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "redo", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(didRedoAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var colorPanel: ColorPanel = {
        let popver = ColorPanel(config: config)
        return popver
    }()
}

private extension ToolBar {
    
    func setupUI() {
        
        let hStackView = UIStackView(arrangedSubviews: [colorButton, brushButton, redoButton, undoButton])
        hStackView.spacing = 30
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStackView)
        
        brushButton.setImage(UIImage(named: "pencil", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        colorButton.backgroundColor = currentColor
        
        NSLayoutConstraint.activate([
            redoButton.widthAnchor.constraint(equalToConstant: 30),
            undoButton.widthAnchor.constraint(equalToConstant: 30),
            brushButton.widthAnchor.constraint(equalToConstant: 30),
            colorButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        NSLayoutConstraint.activate([
            hStackView.heightAnchor.constraint(equalToConstant: 30),
            hStackView.leftAnchor.constraint(equalTo: leftAnchor),
            hStackView.rightAnchor.constraint(equalTo: rightAnchor),
            hStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @objc func didBrushClick(_ sender: UIButton) {
        switch sketchMode {
        case .idle: sketchMode = .pencil
        case .pencil: sketchMode = .idle
        }
    }
    
    @objc func didColorClick(_ sender: UIButton) {
        
        colorPanel.preferredContentSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 150)
        colorPanel.modalPresentationStyle = .popover
        colorPanel.popoverPresentationController?.sourceView = sender
        colorPanel.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sender.bounds.width, height: 0)
        colorPanel.popoverPresentationController?.permittedArrowDirections = .down
        colorPanel.popoverPresentationController?.delegate = self
        
        UIApplication.topViewController()?.present(colorPanel, animated: true)
    }
    
    @objc func didRedoAction(_ sender: UIButton) {
        onRedoAction?()
    }
    
    @objc func didUndoAction(_ sender: UIButton) {
        onUndoAction?()
    }
}

extension ToolBar: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ToolBar.SketchMode {
    
    /// 当前模式笔刷
    var brush: BaseBrush? {
        switch self {
        case .idle: return nil
        case .pencil: return PencilBrush()
        }
    }
    
    /// 是否正在编辑中
    var isEditing: Bool {
        switch self {
        case .idle: return false
        default: return true
        }
    }
}
