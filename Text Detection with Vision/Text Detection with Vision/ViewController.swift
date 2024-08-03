//
//  ViewController.swift
//  Text Detection with Vision
//
//  Created by 이승준 on 8/3/24.
//

import UIKit
import Vision
import VisionKit

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
    
    private lazy var getEnglishFromImage: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get English from image", for: .normal)
        button.addTarget(self, action: #selector(recognizeEnglish), for: .touchUpInside)
        return button
    }()
    
    private lazy var getKoreanAndEnglishFromImage: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get English and Korean from image", for: .normal)
        button.addTarget(self, action: #selector(recognizeEnglishAndKorean), for: .touchUpInside)
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
        self.view.addSubview(getEnglishFromImage)
        self.view.addSubview(getKoreanAndEnglishFromImage)
        self.view.addSubview(labelVw)
        
        NSLayoutConstraint.activate([
            imageVw.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageVw.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            imageVw.heightAnchor.constraint(equalToConstant: 300),
            imageVw.widthAnchor.constraint(equalToConstant: 300),
            
            getEnglishFromImage.topAnchor.constraint(equalTo: imageVw.bottomAnchor, constant: 20),
            getEnglishFromImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            getKoreanAndEnglishFromImage.topAnchor.constraint(equalTo: getEnglishFromImage.bottomAnchor, constant: 20),
            getKoreanAndEnglishFromImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            labelVw.topAnchor.constraint(equalTo: getKoreanAndEnglishFromImage.bottomAnchor, constant: 20),
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
    
    @objc private func recognizeEnglish() {
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
    
    @objc private func recognizeEnglishAndKorean() {
        let request = VNRecognizeTextRequest{ (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let text = recognizedStrings.joined(separator: "\n")
            self.labelVw.text = text
            print(text)
        }
        
        if let image = imageVw.image {
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            request.recognitionLanguages = ["ko-KR"]
            /// 정확도와 속도 중 어느 것을 중점적으로 처리할 것인지
            request.recognitionLevel = .accurate
            /// 언어를 인식하고 수정하는 과정을 거침.
            request.usesLanguageCorrection = true
            try? handler.perform([request])
        }
    }

    
}

