//
//  ViewController.swift
//  CustomCamera
//
//  Created by Howie C on 5/3/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cameraButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cameraButton = UIButton()
        if let cameraButton = cameraButton {
            cameraButton.setTitle("Camera", for: .normal)
            cameraButton.setTitleColor(UIColor.gray, for: .normal)
            cameraButton.setTitleColor(UIColor.lightGray, for: .highlighted)
            cameraButton.sizeToFit()
            cameraButton.layer.borderWidth = 1
            cameraButton.layer.cornerRadius = floor(cameraButton.frame.height / 5)
            cameraButton.layer.borderColor = UIColor.lightGray.cgColor
            cameraButton.frame.size.width += floor(cameraButton.frame.height * 1.5)
            view.addSubview(cameraButton)
            cameraButton.translatesAutoresizingMaskIntoConstraints = false
            cameraButton.widthAnchor.constraint(equalToConstant: cameraButton.frame.width).isActive = true
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            cameraButton.addTarget(self, action: #selector(presentCameraViewController), for: .touchUpInside)
            cameraButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraButton?.isHidden ?? true{
            present(CameraViewController(), animated: true) {
                self.cameraButton?.isHidden = false
            }
        }
    }
    
    @objc private func presentCameraViewController() {
        present(CameraViewController(), animated: true, completion: nil)
    }
}

