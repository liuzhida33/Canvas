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
