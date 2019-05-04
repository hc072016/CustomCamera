//
//  CameraViewController.swift
//  CustomCamera
//
//  Created by Howie C on 5/3/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewDelegate {
    static let compressionQuality:CGFloat = 1
    var imagePickerController: UIImagePickerController?
    var cameraOverlayView: CameraOverlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // MARK: - Setting up image picker controller using camera
            imagePickerController = UIImagePickerController()
            imagePickerController?.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController?.sourceType = .camera
            imagePickerController?.cameraDevice = .rear
            imagePickerController?.allowsEditing = false
            imagePickerController?.showsCameraControls = false
            
            if let imagePickerController = imagePickerController {
                // MARK: - Setting up custom camera overlay view
                cameraOverlayView = CameraOverlayView()
                cameraOverlayView?.frame = imagePickerController.view.bounds
                imagePickerController.cameraOverlayView = cameraOverlayView
                cameraOverlayView?.delegate = self
            }
        }
    }
    
    // in iOS 12, viewDidAppear(_:) is invoked after presentingViewController?.dismiss(animated: true, completion: nil)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // this conditional statemetn is for callback after dismissal
            if imagePickerController != nil {
                self.present(imagePickerController!, animated: false, completion: nil)
            } else {
                // print("dismissed")
                // print("\(isBeingDismissed)")
            }
        } else {
            let alertController = UIAlertController(title: "Warning", message: "Camera Not Available on This Device", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - UIImagePickerControllerDelegate Protocol
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        if info[.mediaMetadata] != nil {
            // print("it's a picture")
            cameraOverlayView?.previewImageView.image = selectedImage
            cameraOverlayView?.retakeButton.isHidden = false
            cameraOverlayView?.saveButton.isHidden = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if presentingViewController != nil {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - CameraOverlayViewDelegate Protocol
    func takePicture(sender: UIButton, forEvent event: UIEvent) {
        cameraOverlayView?.shutterButton.isHidden = true
        imagePickerController?.takePicture()
    }
    
    func retakePicture(sender: UIButton, forEvent event: UIEvent) {
        cameraOverlayView?.previewImageView.image = nil
        cameraOverlayView?.shutterButton.isHidden = false
        cameraOverlayView?.retakeButton.isHidden = true
        cameraOverlayView?.saveButton.isHidden = true
    }
    
    func savePicture(sender: UIButton, forEvent event: UIEvent) {
        if let previewCGImage = cameraOverlayView?.previewImageView.image?.cgImage?.copy() {
            // has to set the orientation explicitly
            let previewImage = UIImage(cgImage: previewCGImage, scale: (cameraOverlayView?.previewImageView.image?.scale)!, orientation: (cameraOverlayView?.previewImageView.image?.imageOrientation)!)
            if let frameCGImage = cameraOverlayView?.frameImageView.image?.cgImage?.copy() {
                let frameImage = UIImage(cgImage: frameCGImage)
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    // compose a frame on top of the taken image
                    UIGraphicsBeginImageContextWithOptions(previewImage.size, true, 1.0)
                    previewImage.draw(in: CGRect(x: 0.0, y: 0.0, width: previewImage.size.width, height: previewImage.size.height))
                    frameImage.draw(in: CGRect(x: 0.0, y: 0.0, width: previewImage.size.width, height: previewImage.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
                    let flattenedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    if let flattenedImage = flattenedImage {
                        if let compressedJPEGImageData = flattenedImage.jpegData(compressionQuality:CameraViewController.compressionQuality), let compressedJPEGImage = UIImage(data: compressedJPEGImageData) {
                            DispatchQueue.main.async {
                                UIImageWriteToSavedPhotosAlbum(compressedJPEGImage, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Warning", message: "Failed to Compress Picture", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.imagePickerController!.present(alertController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Warning", message: "Failed to Merge Picture", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.imagePickerController!.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                // not using a frame
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if let compressedJPEGImageData = previewImage.jpegData(compressionQuality:CameraViewController.compressionQuality), let compressedJPEGImage = UIImage(data: compressedJPEGImageData) {
                        DispatchQueue.main.async {
                            UIImageWriteToSavedPhotosAlbum(compressedJPEGImage, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                            // could also use Photos framework to save pictures with metadata
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Warning", message: "Failed to Compress Picture", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.imagePickerController!.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Warning", message: "Failed to Access Taken Picture Data", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            imagePickerController!.present(alertController, animated: true, completion: nil)
        }
        cameraOverlayView?.previewImageView.image = nil
        cameraOverlayView?.shutterButton.isHidden = false
        cameraOverlayView?.retakeButton.isHidden = true
        cameraOverlayView?.saveButton.isHidden = true
    }
    
    func closeCamera(sender: UIButton, forEvent event: UIEvent) {
        // it woudl seem that isBeingDismissed is set to false on the presented view controller(VC 1) of presenting view controlle(VC 0) on which dismiss(animated:completion:) is called; however, isBeingDismissed is set to true on all other view controllers(VC 2, VC 3...) which are presented by the presented view controller.
        imagePickerController = nil // somehow needed in iOS 12
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIImageWriteToSavedPhotosAlbum callback method
    @objc func image(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alertController = UIAlertController(title: "Warning", message: "Failed to Save Picture", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            imagePickerController!.present(alertController, animated: true, completion: nil)
        }
    }
}
