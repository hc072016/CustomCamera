//
//  CameraOverlayView.swift
//  CustomCamera
//
//  Created by Howie C on 5/3/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

protocol CameraOverlayViewDelegate: AnyObject {
    func takePicture(sender: UIButton, forEvent event: UIEvent)
    func retakePicture(sender: UIButton, forEvent event: UIEvent)
    func savePicture(sender: UIButton, forEvent event: UIEvent)
    func closeCamera(sender: UIButton, forEvent event: UIEvent)
}

class CameraOverlayView: UIView {
    weak var delegate: CameraOverlayViewDelegate?
    let previewImageView = UIImageView()
    let frameImageView = UIImageView()
    let controlPanelView = UIView()
    let shutterButton = UIButton(type: .custom)
    let retakeButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        // MARK: - Setting up an image view for preview
        previewImageView.backgroundColor = UIColor.clear
        previewImageView.contentMode = .scaleAspectFill
        
        addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        let previewImageViewTopConstraint = NSLayoutConstraint(item: previewImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let previewImageViewLeadingConstraint = NSLayoutConstraint(item: previewImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let previewImageViewTrailingConstraint = NSLayoutConstraint(item: previewImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let previewImageViewAspectRatioConstraint = NSLayoutConstraint(item: previewImageView, attribute: .width, relatedBy: .equal, toItem: previewImageView, attribute: .height, multiplier: 3 / 4, constant: 0)
        NSLayoutConstraint.activate([previewImageViewTopConstraint, previewImageViewLeadingConstraint, previewImageViewTrailingConstraint, previewImageViewAspectRatioConstraint])
        
        // MARK: - Setting up an image view for frame
        frameImageView.backgroundColor = UIColor.clear
        frameImageView.contentMode = .scaleAspectFill
        // always use a good quality image the same pixel dimension as the biggest possible picture taken by the iPhone with best camera as the frame
        frameImageView.image = UIImage(named: "frame")
        
        self.addSubview(frameImageView)
        frameImageView.translatesAutoresizingMaskIntoConstraints = false
        let frameImageViewTopConstraint = NSLayoutConstraint(item: frameImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let frameImageViewLeadingConstraint = NSLayoutConstraint(item: frameImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let frameImageViewTrailingConstraint = NSLayoutConstraint(item: frameImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let frameImageViewAspectRatioConstraint = NSLayoutConstraint(item: frameImageView, attribute: .width, relatedBy: .equal, toItem: frameImageView, attribute: .height, multiplier: 3 / 4, constant: 0)
        NSLayoutConstraint.activate([frameImageViewTopConstraint, frameImageViewLeadingConstraint, frameImageViewTrailingConstraint, frameImageViewAspectRatioConstraint])
        
        // MARK: - Setting up the control panel
        controlPanelView.backgroundColor = UIColor.clear
        
        self.addSubview(controlPanelView)
        controlPanelView.translatesAutoresizingMaskIntoConstraints = false
        let controlPanelViewTopConstraint = NSLayoutConstraint(item: controlPanelView, attribute: .top, relatedBy: .equal, toItem: previewImageView, attribute: .bottom, multiplier: 1, constant: 0)
        let controlPanelViewBottomConstraint = NSLayoutConstraint(item: controlPanelView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let controlPanelViewLeadingContraint = NSLayoutConstraint(item: controlPanelView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let controlPanelViewTrailingConstrain = NSLayoutConstraint(item: controlPanelView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([controlPanelViewTopConstraint, controlPanelViewBottomConstraint, controlPanelViewLeadingContraint, controlPanelViewTrailingConstrain])
        
        // MARK: - Setting up a camera shutter button
        shutterButton.setImage(UIImage(named: "circle0"), for: .normal)
        shutterButton.setImage(UIImage(named: "circle2"), for: .highlighted)
        shutterButton.imageView?.contentMode = .scaleAspectFill
        shutterButton.sizeToFit()
        shutterButton.addTarget(self, action: #selector(takePicture(sender:forEvent:)), for: .touchUpInside)
        
        controlPanelView.addSubview(shutterButton)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        let shutterButtonHeightConstraint = NSLayoutConstraint(item: shutterButton, attribute: .height, relatedBy: .equal, toItem: controlPanelView, attribute: .height, multiplier: 0.5, constant: 0)
        let shutterButtonAspectRatioConstraint = NSLayoutConstraint(item: shutterButton, attribute: .width, relatedBy: .equal, toItem: shutterButton, attribute: .height, multiplier: 1, constant: 0)
        let shutterButtonCentreXConstraint = NSLayoutConstraint(item: shutterButton, attribute: .centerX, relatedBy: .equal, toItem: controlPanelView, attribute: .centerX, multiplier: 1, constant: 0)
        let shutterButtonCentreYConstraint = NSLayoutConstraint(item: shutterButton, attribute: .centerY, relatedBy: .equal, toItem: controlPanelView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([shutterButtonHeightConstraint, shutterButtonAspectRatioConstraint, shutterButtonCentreXConstraint, shutterButtonCentreYConstraint])
        
        // MARK: - Setting up a transparent white colour for two buttons
        let transparentWhite = UIColor(white: 1.0, alpha: 0.9)
        
        // MARK: - Setting up a retake button
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.setTitleColor(transparentWhite, for: .normal)
        retakeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        retakeButton.titleLabel?.textAlignment = NSTextAlignment.center
        retakeButton.layer.borderWidth = 1.0
        retakeButton.layer.cornerRadius = 5.0
        retakeButton.layer.borderColor = transparentWhite.cgColor
        retakeButton.sizeToFit()
        retakeButton.addTarget(self, action: #selector(retakePicture(sender:forEvent:)), for: .touchUpInside)
        retakeButton.isHidden = true
        
        // MARK: - Setting up a save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(transparentWhite, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        saveButton.titleLabel?.textAlignment = NSTextAlignment.center
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 5.0
        saveButton.layer.borderColor = transparentWhite.cgColor
        saveButton.sizeToFit()
        saveButton.addTarget(self, action: #selector(savePicture(sender:forEvent:)), for: .touchUpInside)
        saveButton.isHidden = true
        
        // MARK: - Make the two buttons the same size
        if retakeButton.frame.size.width > saveButton.frame.size.width {
            saveButton.frame.size.width = retakeButton.frame.size.width
        } else if retakeButton.frame.size.width < saveButton.frame.size.width {
            retakeButton.frame.size.width = saveButton.frame.size.width
        }
        
        // MARK: - Make frame of the buttons larger
        retakeButton.frame.size.width += retakeButton.frame.size.height * 1.5
        saveButton.frame.size.width += saveButton.frame.size.height * 1.5
        
        
        // MARK: - Add constraints for retake button
        controlPanelView.addSubview(retakeButton)
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        let retakeButtonWidthConstraint = NSLayoutConstraint(item: retakeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: retakeButton.frame.size.width)
        let retakeButtonHeightConstraint = NSLayoutConstraint(item: retakeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: retakeButton.frame.size.height)
        let retakeButtonTopConstraint = NSLayoutConstraint(item: retakeButton, attribute: .top, relatedBy: .equal, toItem: controlPanelView, attribute: .topMargin, multiplier: 1, constant: 0)
        let retakeButtonLeadingConstraint = NSLayoutConstraint(item: retakeButton, attribute: .leading, relatedBy: .equal, toItem: controlPanelView, attribute: .leadingMargin, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([retakeButtonWidthConstraint, retakeButtonHeightConstraint, retakeButtonTopConstraint, retakeButtonLeadingConstraint])
        
        // MARK: - Add constraints for save button
        controlPanelView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        let saveButtonWidthConstraint = NSLayoutConstraint(item: saveButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: saveButton.frame.size.width)
        let saveButtonHeightConstraint = NSLayoutConstraint(item: saveButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: saveButton.frame.size.height)
        let saveButtonTopConstraint = NSLayoutConstraint(item: saveButton, attribute: .top, relatedBy: .equal, toItem: controlPanelView, attribute: .topMargin, multiplier: 1, constant: 0)
        let saveButtonTrailingConstraint = NSLayoutConstraint(item: saveButton, attribute: .trailing, relatedBy: .equal, toItem: controlPanelView, attribute: .trailingMargin, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([saveButtonWidthConstraint, saveButtonHeightConstraint, saveButtonTopConstraint, saveButtonTrailingConstraint])
        
        // MARK: - Setting up the close button
        closeButton.setTitle("✖︎", for: .normal)
        closeButton.setTitleColor(transparentWhite, for: .normal)
        closeButton.sizeToFit()
        closeButton.addTarget(self, action: #selector(closeCamera(sender:forEvent:)), for: .touchUpInside)
        // make the frame of the button square
        if closeButton.frame.size.height > closeButton.frame.size.width {
            closeButton.frame.size.width = closeButton.frame.size.height
        } else if closeButton.frame.size.width > closeButton.frame.size.height {
            closeButton.frame.size.height = closeButton.frame.size.width
        }
        closeButton.layer.borderWidth = 2.0
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2.0
        closeButton.layer.borderColor = transparentWhite.cgColor
        
        
        self.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let closeButtonWidthConstraint = NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButton.frame.size.width)
        let closeButtonHeightConstraint = NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButton.frame.size.height)
        let closeButtonTopConstraint = NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1, constant: 20)
        let closeButtonLeadingConstraint = NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 20)
        NSLayoutConstraint.activate([closeButtonWidthConstraint, closeButtonHeightConstraint, closeButtonTopConstraint, closeButtonLeadingConstraint])
        
        // MARK: - Setting up custom camera overlay view (self)
        self.backgroundColor = UIColor.clear
    }
    
    @objc private func takePicture(sender: UIButton, forEvent event: UIEvent) {
        if delegate != nil {
            delegate?.takePicture(sender: sender, forEvent: event)
        }
    }
    
    @objc private func retakePicture(sender: UIButton, forEvent event: UIEvent) {
        if delegate != nil {
            delegate?.retakePicture(sender: sender, forEvent: event)
        }
    }
    
    @objc private func savePicture(sender: UIButton, forEvent event: UIEvent) {
        if delegate != nil {
            delegate?.savePicture(sender: sender, forEvent: event)
        }
    }
    
    @objc private func closeCamera(sender: UIButton, forEvent event: UIEvent) {
        if delegate != nil {
            delegate?.closeCamera(sender: sender, forEvent: event)
        }
    }
}
