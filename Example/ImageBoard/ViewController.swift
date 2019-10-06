//
//  ViewController.swift
//  ImageBoard
//
//  Created by liuzhida33 on 10/03/2019.
//  Copyright (c) 2019 liuzhida33. All rights reserved.
//

import UIKit
import ImageBoard

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPickAction(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    @IBAction func onEditAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        let editVC = ImageBoardViewController()
        editVC.editImage = image
        editVC.modalPresentationStyle = .custom
        present(editVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        imageView.image = (info[.originalImage] as? UIImage)
    }
}
