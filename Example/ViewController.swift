//
//  ViewController.swift
//  Example
//
//  Created by 刘志达 on 2020/3/28.
//  Copyright © 2020 joylife. All rights reserved.
//

import UIKit
import Canvas

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPickAction(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    @IBAction func onEditAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        print(image)
        let canvas = CanvasController(sourceImage: image, config: .init(fileURL: Bundle.main.url(forResource: "CanvasConfig", withExtension: "json")!))
        canvas.modalPresentationStyle = .custom
        present(canvas, animated: true)
    }
    
    @IBAction func onSignAction(_ sender: Any) {
        let canvas = SignatureController(config: .init(fileURL: Bundle.main.url(forResource: "CanvasConfig", withExtension: "json")!))
        canvas.modalPresentationStyle = .fullScreen
        canvas.exportOpaque = true
        canvas.watermark = .word(WaterMark.Word(title: "测试  10010", color: UIColor(white: 0, alpha: 0.15)), WaterMark.Layout())
        canvas.signatureResult = { [weak self] image in
            print(image)
            self?.imageView.image = image
        }
        present(canvas, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        imageView.image = (info[.originalImage] as? UIImage)
    }
}
