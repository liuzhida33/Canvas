//
//  CanvasController.swift
//  Canvas
//
//  Created by 刘志达 on 2020/3/30.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit

public final class CanvasController: UIViewController {
    
    public typealias AlertAction = (UIImage) -> UIAlertAction
    
    public enum DimMode {
        case color(color: UIColor)
        case blur(style: UIBlurEffect.Style, alpha: CGFloat)
    }
    
    public var menuAlertActions: [AlertAction] = []
    public var dimMode: DimMode = .blur(style: .light, alpha: 1.0)
    public var intentView: UIView { canvasView }
    
    public init(sourceImage: UIImage, config: CanvasConfig = .default) {
        self.sourceImage = sourceImage
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 画板的容器
    private lazy var scrollView: UIScrollView = UIScrollView()
    // 视图容器
    private lazy var containerView: UIStackView = UIStackView()
    // 画板
    private lazy var canvasView: CanvasView = CanvasView()
    // 画板顶部菜单栏
    private lazy var menuToolBar: UIToolbar = UIToolbar()
    // 画板底部工具栏
    private lazy var toolBar: ToolBar = ToolBar(config: config)
    // 背景视图
    private lazy var maskingView: MaskingView = MaskingView()
    // 进度指示器
    private lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    // 菜单按钮
    private lazy var menuButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didMenuAction(_:)))
    private lazy var exitButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(didExitAction(_:)))
    // 原始图片
    private let sourceImage: UIImage
    // 配置
    private let config: CanvasConfig
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        install()
        view.layoutIfNeeded()
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let size: CGSize
        let imageSize = sourceImage.size
        let containerSize = scrollView.bounds.size
        if containerSize.width > containerSize.height {
            size = CGSize(width: floor(containerSize.height * imageSize.width / imageSize.height), height: floor(containerSize.height) )
        } else {
            size = CGSize(width: floor(containerSize.width), height: floor(containerSize.width * imageSize.height / imageSize.width) )
        }
        canvasView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = size
        centerIfNeeded()
        canvasView.image = sourceImage
    }
}

// MARK: - Layout
private extension CanvasController {
    
    func install() {
        
        func installMaskingView() {
            
            switch dimMode {
            case .color(let color):
                maskingView.backgroundColor = color
            case .blur(let style, let alpha):
                let blurView = UIVisualEffectView(effect: nil)
                blurView.alpha = alpha
                blurView.effect = UIBlurEffect(style: style)
                maskingView.backgroundView = blurView
            }
            
            maskingView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(maskingView)
            
            NSLayoutConstraint.activate([
                maskingView.leftAnchor.constraint(equalTo: view.leftAnchor),
                maskingView.rightAnchor.constraint(equalTo: view.rightAnchor),
                maskingView.topAnchor.constraint(equalTo: view.topAnchor),
                maskingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        func installContainerView() {
            
            containerView.axis = .vertical
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            maskingView.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.leftAnchor.constraint(equalTo: maskingView.safeAreaLayoutGuide.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: maskingView.safeAreaLayoutGuide.rightAnchor),
                containerView.topAnchor.constraint(equalTo: maskingView.safeAreaLayoutGuide.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: maskingView.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
        
        func installMenuToolBar() {
            
            menuToolBar.setBackgroundImage(UIImage(color: .clear), forToolbarPosition: .any, barMetrics: .default)
            menuToolBar.setShadowImage(UIImage(color: .clear), forToolbarPosition: .any)
            menuToolBar.items = [exitButtonItem, UIBarButtonItem.flexibleSpace(), menuButtonItem]
            
            containerView.addArrangedSubview(menuToolBar)
        }
        
        func installCanvasView() {
            
            canvasView.beginDraw = { [weak self] in
                self?.toolBar.canRndo = true
                self?.toolBar.canUndo = true
            }
            canvasView.unableDraw = { [weak self] in
                self?.toolBar.canUndo = false
            }
            
            canvasView.clipsToBounds = true
            canvasView.contentMode = .scaleAspectFit
            canvasView.isUserInteractionEnabled = true
            
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 3
            
            scrollView.addSubview(canvasView)
            containerView.addArrangedSubview(scrollView)
        }
        
        func installToolBar() {
            
            toolBar.onStrokeColorChange = { [weak self] color in
                self?.canvasView.color = color
            }
            
            toolBar.onStrokeDegreeChange = { [weak self] degree in
                self?.canvasView.degree = CGFloat(degree)
            }
            
            toolBar.onSketchModeChange = { [weak self] mode in
                self?.canvasView.brush = mode.brush
                self?.scrollView.isScrollEnabled = !mode.isEditing
            }
            
            toolBar.onRedoAction = { [weak self] in
                self?.canvasView.redo()
            }
            
            toolBar.onUndoAction = { [weak self] in
                self?.canvasView.undo()
            }
            
            canvasView.color = toolBar.currentColor
            canvasView.degree = toolBar.currentDegree
            canvasView.brush = toolBar.sketchMode.brush
            scrollView.isScrollEnabled = !toolBar.sketchMode.isEditing
            
            let vStackView = UIStackView(arrangedSubviews: [toolBar])
            vStackView.alignment = .center
            vStackView.axis = .vertical
            
            containerView.addArrangedSubview(vStackView)
            
            NSLayoutConstraint.activate([
                vStackView.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        func installIndicatorView() {
            
            if #available(iOS 13.0, *) {
                indicatorView.style = .large
            } else {
                indicatorView.style = .whiteLarge
            }
            indicatorView.color = config.tintColor.value.rawValue
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicatorView)
            
            NSLayoutConstraint.activate([
                indicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                indicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
        }
        
        view.backgroundColor = .clear
        
        installMaskingView()
        installMenuToolBar()
        installCanvasView()
        installToolBar()
        installContainerView()
        installIndicatorView()
    }
    
    func centerIfNeeded() {
        var inset: UIEdgeInsets = .zero
        let height = scrollView.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        let width = scrollView.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        if scrollView.contentSize.height < height {
            let insetV = (height - scrollView.contentSize.height) / 2
            inset.top += insetV
            inset.bottom = insetV
        }
        if scrollView.contentSize.width < width {
            let insetV = (width - scrollView.contentSize.width) / 2
            inset.left = insetV
            inset.right = insetV
        }
        scrollView.contentInset = inset
    }
}

// MARK: - Action
private extension CanvasController {
    
    @objc func didMenuAction(_ sender: Any) {
        
        indicatorView.startAnimating()
        
        DispatchQueue.main.async {
            guard let image = self.canvasView.image else { return }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let saveAction = UIAlertAction(title: NSLocalizedString("Save to Album", comment: "Save to Album"), style: .default, handler: { [weak self] _ in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self?.dismiss(animated: true)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            self.menuAlertActions.map { $0(image) }.forEach(alertController.addAction)
            [saveAction, cancelAction].forEach(alertController.addAction)
            self.present(alertController, animated: true)
            self.indicatorView.stopAnimating()
        }
    }
    
    @objc func didExitAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension CanvasController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerIfNeeded()
    }
}
