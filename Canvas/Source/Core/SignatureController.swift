//
//  SignatureController.swift
//  Canvas
//
//  Created by 刘志达 on 2022/5/12.
//  Copyright © 2022 joylife. All rights reserved.
//

import UIKit

/// 电子签名
public final class SignatureController: UIViewController {
    
    /// 签名结果
    public var signatureResult: ((UIImage) -> Void)?
    /// 水印风格
    public var watermark: WaterMark = .none
    /// 导出图片是否不透明
    public var exportOpaque: Bool = true
    
    public init(config: CanvasConfig = .default) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 视图容器
    private lazy var containerView: UIStackView = UIStackView()
    // 背景视图
    private lazy var maskingView: MaskingView = MaskingView()
    // 画板
    private lazy var canvasView: CanvasView = CanvasView()
    // 底部工具栏
    private lazy var toolView: UIStackView = UIStackView()
    // 画板顶部菜单栏
    private lazy var menuToolBar: UIToolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: containerView.bounds.width, height: 44)))
    private lazy var exitButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(didExitAction(_:)))
    // 重写
    private lazy var redoButton: UIButton = UIButton(type: .system)
    // 确定
    private lazy var confirmButton: UIButton = UIButton(type: .system)
    // 进度指示器
    private lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    // 配置
    private let config: CanvasConfig
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        install()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    public override var shouldAutorotate: Bool { true }
    
    public override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}

private extension SignatureController {
    
    func install() {
        
        func installMaskingView() {
            
            maskingView.backgroundColor = .white
            maskingView.translatesAutoresizingMaskIntoConstraints = false
                        
            view.addSubview(maskingView)
            
            NSLayoutConstraint.activate([
                maskingView.leftAnchor.constraint(equalTo: view.leftAnchor),
                maskingView.rightAnchor.constraint(equalTo: view.rightAnchor),
                maskingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                maskingView.topAnchor.constraint(equalTo: view.topAnchor)
                ])
        }
        
        func installContainerView() {
            
            containerView.axis = .vertical
            containerView.distribution = .fill
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            maskingView.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                ])
        }
        
        func installMenuToolBar() {
                        
            menuToolBar.setBackgroundImage(UIImage(color: .clear), forToolbarPosition: .any, barMetrics: .default)
            menuToolBar.setShadowImage(UIImage(color: .clear), forToolbarPosition: .any)
            menuToolBar.items = [exitButtonItem, UIBarButtonItem.flexibleSpace()]
            
            containerView.addArrangedSubview(menuToolBar)
        }
        
        func installCanvasView() {
            
            canvasView.clipsToBounds = true
            canvasView.contentMode = .scaleAspectFit
            canvasView.isUserInteractionEnabled = true
            canvasView.color = .black
            canvasView.backgroundColor = .white
            canvasView.degree = 8
            canvasView.brush = PencilBrush()
            canvasView.beginDraw = { [weak self] in
                self?.confirmButton.isEnabled = true
            }
            canvasView.unableDraw = { [weak self] in
                self?.confirmButton.isEnabled = false
            }
            
            containerView.addArrangedSubview(canvasView)
        }
        
        func installToolView() {
            
            toolView.axis = .vertical
            toolView.alignment = .trailing
            
            redoButton.setTitle(NSLocalizedString("Canvas.Rewrite", value: "Rewrite", comment: ""), for: .normal)
            redoButton.layer.borderColor = UIColor(hexString: "#EFEFEF")?.cgColor
            redoButton.layer.borderWidth = 1.0
            redoButton.layer.cornerRadius = 5
            redoButton.setTitleColor(config.tintColor.value.rawValue, for: .normal)
            redoButton.addTarget(self, action: #selector(didRedoAction(_:)), for: .touchUpInside)
            confirmButton.setTitle(NSLocalizedString("Canvas.Confirm", value: "Confirm", comment: ""), for: .normal)
            confirmButton.layer.cornerRadius = 5
            confirmButton.clipsToBounds = true
            confirmButton.isEnabled = false
            confirmButton.setTitleColor(.white, for: .normal)
            confirmButton.setBackgroundImage(UIImage(color: config.tintColor.value.rawValue), for: .normal)
            confirmButton.setBackgroundImage(UIImage(color: UIColor.lightGray), for: .disabled)
            confirmButton.addTarget(self, action: #selector(didConfirmAction(_:)), for: .touchUpInside)
            
            let hContainer = UIStackView(arrangedSubviews: [redoButton, confirmButton])
            hContainer.axis = .horizontal
            hContainer.alignment = .center
            hContainer.spacing = 15
            hContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let vContainer = UIStackView(arrangedSubviews: [hContainer])
            vContainer.axis = .vertical
            vContainer.alignment = .center
            vContainer.translatesAutoresizingMaskIntoConstraints = false
            
            toolView.addArrangedSubview(vContainer)
            containerView.addArrangedSubview(toolView)
            
            NSLayoutConstraint.activate([
                vContainer.widthAnchor.constraint(equalToConstant: 190),
                hContainer.heightAnchor.constraint(equalToConstant: 60),
                redoButton.widthAnchor.constraint(equalToConstant: 80),
                redoButton.heightAnchor.constraint(equalToConstant: 45),
                confirmButton.widthAnchor.constraint(equalToConstant: 80),
                confirmButton.heightAnchor.constraint(equalToConstant: 45)
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
        installContainerView()
        installToolView()
        installIndicatorView()
    }
}

// MARK: - Action
private extension SignatureController {
    
    @objc func didExitAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func didRedoAction(_ sender: Any) {
        canvasView.redo()
    }
    
    @objc func didConfirmAction(_ sender: Any) {
        indicatorView.startAnimating()
        DispatchQueue.main.async {
            guard let image = self.canvasView.brushImage(opaque: self.exportOpaque, watermark: self.watermark) else {
                self.showAlert(NSLocalizedString("Canvas.FailedToExportImage", value: "Failed to export image.", comment: ""))
                return
            }
            self.signatureResult?(image)
            self.dismiss(animated: true)
            self.indicatorView.stopAnimating()
        }
    }
    
    private func showAlert(_ message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Canvas.Error", value: "Error", comment: ""), message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Canvas.OK", value: "OK", comment: ""), style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
