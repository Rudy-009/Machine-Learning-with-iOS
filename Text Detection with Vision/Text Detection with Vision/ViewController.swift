//
//  ViewController.swift
//  Text Detection with Vision
//
//  Created by 이승준 on 8/3/24.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    private lazy var imageVw: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill // 변경: 이미지가 뷰에 맞게 비율을 유지하도록 설정
        image.clipsToBounds = true // 변경: true로 설정하여 이미지가 클립되도록 설정
        return image
    }()
    
    private lazy var getTextBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Text from image", for: .normal)
        button.addTarget(self, action: #selector(recognizeText), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelVw: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 10
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        self.layout()
        self.navigationBar()
    }
    
    private func navigationBar() {
        let photoItem = UIBarButtonItem(image: UIImage(systemName: "photo"),
                                        style: .plain, target: self,
                                        action: #selector(upload_photo))
        self.navigationItem.rightBarButtonItems = [photoItem]
    }
    
    @objc private func upload_photo() {
        self.present(picker, animated: true)
    }
    
    private func layout() {
        self.view.addSubview(imageVw)
        self.view.addSubview(getTextBtn)
        self.view.addSubview(labelVw)
        
        NSLayoutConstraint.activate([
            imageVw.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageVw.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            imageVw.heightAnchor.constraint(equalToConstant: 300),
            imageVw.widthAnchor.constraint(equalToConstant: 300),
            
            getTextBtn.topAnchor.constraint(equalTo: imageVw.bottomAnchor, constant: 20),
            getTextBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            labelVw.topAnchor.constraint(equalTo: getTextBtn.bottomAnchor, constant: 20),
            labelVw.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            labelVw.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let editedImage = UIImagePickerController.InfoKey.editedImage
        
        if let editedImage = info[editedImage] as? UIImage {
            self.imageVw.image = editedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func recognizeText() {
        let request = VNRecognizeTextRequest{ (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let text = recognizedStrings.joined(separator: "\n")
            self.labelVw.text = text
            print(text)
        }
        if let image = imageVw.image {
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            try? handler.perform([request])
        }
    }
    
}

