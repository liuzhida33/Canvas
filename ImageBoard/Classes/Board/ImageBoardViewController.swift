//
//  ImageBoardViewController.swift
//  ImageBoard
//
//  Created by 刘志达 on 2019/10/5.
//

import UIKit

public final class ImageBoardViewController: UIViewController {
    
    public typealias ImageBoardAction = (UIImage) -> UIAlertAction
    
    /// 点击`完成`时附加操作
    public var completeActions: [ImageBoardAction] = []
    
    /// 编辑的图片
    public var editImage: UIImage? {
        didSet {
            guard let newImage = editImage else { return }
            drawBoardImageView.currentImage = newImage
            undoButtonItem.isEnabled = false
            redoButtonItem.isEnabled = false
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    /// 图片画板
    public var boardImageView: UIImageView { return drawBoardImageView }
    
    /// 顶部工具栏
    private lazy var topBar: UIToolbar = {
        let bar = UIToolbar()
        bar.setBackgroundImage(UIImage(color: .clear), forToolbarPosition: .any, barMetrics: .default)
        bar.setShadowImage(UIImage(color: .clear), forToolbarPosition: .any)
        bar.delegate = self
        return bar
    }()
    
    /// 画板
    private lazy var drawBoardImageView: DrawBoardImageView = {
        let view = DrawBoardImageView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    /// 底部工具栏
    private lazy var boardToolBar: BoardToolBar = {
        let bar = BoardToolBar(frame: .zero)
        bar.delegate = self
        return bar
    }()
    
    /// 图片父视图
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        return scrollView
    }()
    
    /// 模糊背景
    private lazy var effectView: UIVisualEffectView = {
        let effect: UIBlurEffect
        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemMaterial)
        } else {
            effect = UIBlurEffect(style: .light)
        }
        return UIVisualEffectView(effect: effect)
    }()
    
    private lazy var bundle: Bundle = {
        var bundle = Bundle(for: ImageBoardViewController.classForCoder())
        if let resourcePath = bundle.path(forResource: "ImageBoard", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        return bundle
    }()
    
    private lazy var saveButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(onSaveAction(_:)))
    private lazy var redoButtonItem = UIBarButtonItem(image: UIImage(named: "redo", in: bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(onRedoAction(_:)))
    private lazy var undoButtonItem = UIBarButtonItem(image: UIImage(named: "undo", in: bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(onUndoAction(_:)))
    private lazy var flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private lazy var fixedSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        effectView.frame = view.bounds
        if #available(iOS 11.0, *) {
            topBar.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: 44)
            boardToolBar.frame = CGRect(x: 0, y: view.bounds.height - view.safeAreaInsets.bottom - 44, width: view.bounds.width, height: 44)
        } else {
            topBar.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: 44)
            boardToolBar.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
        }
        scrollView.frame = CGRect(x: 0, y: topBar.frame.maxY, width: view.bounds.width, height: boardToolBar.frame.minY - topBar.frame.maxY)
        
        let size: CGSize
        if let image = editImage {
            let containerSize = scrollView.bounds.size
            if containerSize.width > containerSize.height {
                size = CGSize(width: floor(containerSize.height * image.size.width / image.size.height), height: floor(containerSize.height) )
            } else {
                size = CGSize(width: floor(containerSize.width), height: floor(containerSize.width * image.size.height / image.size.width) )
            }
        } else {
            size = scrollView.bounds.size
        }
        drawBoardImageView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = size
        centerIfNeeded()
    }
    
    private func centerIfNeeded() {
        var inset: UIEdgeInsets = .zero
        if scrollView.contentSize.height < scrollView.bounds.height {
            let insetV = (scrollView.bounds.height - scrollView.contentSize.height) / 2
            inset.top += insetV
            inset.bottom = insetV
        }
        if scrollView.contentSize.width < scrollView.bounds.width {
            let insetV = (scrollView.bounds.width - scrollView.contentSize.width) / 2
            inset.left = insetV
            inset.right = insetV
        }
        scrollView.contentInset = inset
    }
    
    private func setupUI() {
        
        view.backgroundColor = .clear
        view.addSubview(effectView)
        fixedSpaceButtonItem.width = 15.0
        effectView.contentView.addSubview(topBar)
        effectView.contentView.addSubview(scrollView)
        effectView.contentView.addSubview(boardToolBar)
        scrollView.addSubview(drawBoardImageView)
        topBar.items = [saveButtonItem, flexibleSpaceButtonItem, undoButtonItem, fixedSpaceButtonItem, redoButtonItem]
        
        drawBoardImageView.beginDraw = { [weak self] in
            self?.undoButtonItem.isEnabled = true
            self?.redoButtonItem.isEnabled = true
        }
        drawBoardImageView.unableDraw = { [weak self] in
            self?.undoButtonItem.isEnabled = false
        }
        drawBoardImageView.reableDraw = { [weak self] in
            self?.redoButtonItem.isEnabled = false
        }
        
        drawBoardImageView.strokeColor = boardToolBar.strokeColor
        drawBoardImageView.strokeWidth = boardToolBar.strokeWidth
        drawBoardImageView.mode = boardToolBar.mode
        switch boardToolBar.mode {
        case .none:
            scrollView.isScrollEnabled = true
        case .pencil:
            scrollView.isScrollEnabled = false
        }
    }
    
    @objc private func onSaveAction(_ sender: Any) {
        let image = drawBoardImageView.takeImage()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "存储到“照片”", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.dismiss(animated: true)
        })
        let deleteAction = UIAlertAction(title: "删除图片", style: .destructive, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        completeActions.map { $0(image) }.forEach(alertController.addAction)
        [saveAction, deleteAction, cancelAction].forEach(alertController.addAction)
        present(alertController, animated: true)
    }
    
    @objc private func onRedoAction(_ sender: Any) {
        drawBoardImageView.redo()
        redoButtonItem.isEnabled = drawBoardImageView.canRedo
    }
    
    @objc private func onUndoAction(_ sender: Any) {
        drawBoardImageView.undo()
        undoButtonItem.isEnabled = drawBoardImageView.canUndo
    }
}

extension ImageBoardViewController: UIToolbarDelegate {
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension ImageBoardViewController: BoardToolBarDelegate {
    
    func didChange(strokeWidth: Float) {
        drawBoardImageView.strokeWidth = strokeWidth
    }
    
    func didSelect(strokeColor: UIColor) {
        drawBoardImageView.strokeColor = strokeColor
    }
    
    func didSelect(mode: SketchMode) {
        switch mode {
        case .none:
            scrollView.isScrollEnabled = true
        case .pencil:
            scrollView.isScrollEnabled = false
        }
        drawBoardImageView.mode = mode
    }
}

extension ImageBoardViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawBoardImageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerIfNeeded()
    }
}
