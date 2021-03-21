//
//  CameraController.swift
//  InstagramFirebase
//
//  Created by 平尾健太 on 2021/02/13.
//

import UIKit
import AVFoundation

class CameraController: UIViewController,AVCapturePhotoCaptureDelegate,UIViewControllerTransitioningDelegate {
    
    let capturePhotoButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        return button
    }()
    
    let previewArea = UIView()
    
    @objc func handleCapturePhoto(){
        print("capture")
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
        settings.previewPhotoFormat =  [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)

    }
    
    let dismissButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "multiply"), for: .normal)
        button.addTarget(self, action: #selector(handleDissmiss), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        return button
    }()
    
    @objc func handleDissmiss(){
        dismiss(animated: true, completion: nil)
    }
    
    let inOutButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        button.addTarget(self, action: #selector(handleInOut), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .white
        
        return button
    }()
    
    @objc func handleInOut(sender:UITapGestureRecognizer){
        print("insideout")
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        let imageData = photo.fileDataRepresentation()
        let previewImage = UIImage(data: imageData!)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             left: view.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor,
                             paddingTop: 0,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: 0,
                             height: 0)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        transitioningDelegate = self//
        
        view.addSubview(previewArea)
        
       
        
        setupCaputureSession()
        setupHUD()
        
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    fileprivate func setupHUD(){
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil,
                                  left: nil,
                                  bottom: view.bottomAnchor,
                                  right: nil,
                                  paddingTop: 0,
                                  paddingLeft: 0,
                                  paddingBottom: -10,
                                  paddingRight: 0,
                                  width: 80,
                                  height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor,
                             left: nil,
                             bottom: nil,
                             right: view.rightAnchor,
                             paddingTop: 20,
                             paddingLeft: 0,
                             paddingBottom: 0,
                             paddingRight: 22,
                             width: 25,
                             height: 25)
        
        view.addSubview(inOutButton)
        inOutButton.anchor(top: nil,
                           left: nil,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           right: view.rightAnchor,
                           paddingTop: 0,
                           paddingLeft: 0,
                           paddingBottom: 0,
                           paddingRight: 20,
                           width: 35,
                           height: 35)
    }
    
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaputureSession(){
        let captureSession = AVCaptureSession()
        
        //1. setup inputs
        guard let caputureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do{
            let input = try AVCaptureDeviceInput(device: caputureDevice)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
        }catch let err{
            print("Could not setup Camera input :",err)
        }
        
        //2. setup outputs
        
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        //3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
}
