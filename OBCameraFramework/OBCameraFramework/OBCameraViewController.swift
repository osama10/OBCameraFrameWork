//
//  CameraViewController.swift
//  OBCameraFramework
//
//  Created by Osama Bin Bashir on 16/10/2018.
//  Copyright © 2018 Osama Bin Bashir. All rights reserved.
//

import UIKit
import AVFoundation

public protocol OBCameraControllerDelegate {
    func cancelButtonTapped(controller: OBCameraViewController)
    func stillImageCaptured(controller: OBCameraViewController, image: UIImage)
}

public enum CameraPosition {
    case front
    case back
}

public final class OBCameraViewController: UIViewController {
    fileprivate var camera: OBCamera?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var _cancelButton: UIButton?
    var cancelButton: UIButton {
        if let currentButton = _cancelButton {
            return currentButton
        }
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        _cancelButton = button
        return button
    }
    
    private var _shutterButton: UIButton?
    var shutterButton: UIButton {
        if let currentButton = _shutterButton {
            return currentButton
        }
        let button = UIButton()
        button.setImage(UIImage(named: "capture", in: Bundle(for: OBCameraViewController.self), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        _shutterButton = button
        return button
    }
    
    open var delegate: OBCameraControllerDelegate?
    
    open var position: CameraPosition = .back {
        didSet {
            guard let camera = self.camera else {
                return
            }
            camera.position = position
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let camera = OBCamera()
        camera.delegate = self
        self.camera = camera
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let camera = self.camera else {
            return
        }
        createUI()
        camera.update()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI(orientation: UIApplication.shared.statusBarOrientation)
        updateButtonFrames()
    }
    
    open class func getVersion() -> String? {
        let bundle = Bundle(for: OBCameraViewController.self)
        guard let info = bundle.infoDictionary else {
            return nil
        }
        guard let versionString = info["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return versionString
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: User Interface Creation

fileprivate extension OBCameraViewController {
    
    func createUI() {
        guard let camera = self.camera else {
            return
        }
        guard let previewLayer = camera.getPreviewLayer() else {
            return
        }
        previewLayer.frame = self.view.bounds
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(self.cancelButton)
        self.view.addSubview(self.shutterButton)
    }
    
    func updateUI(orientation: UIInterfaceOrientation) {
        guard let previewLayer = self.previewLayer, let connection = previewLayer.connection else {
            return
        }
        previewLayer.frame = self.view.bounds
        switch orientation {
        case .portrait:
            connection.videoOrientation = .portrait
            break
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
            break
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
            break
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
            break
        default:
            connection.videoOrientation = .portrait
            break
        }
    }
    
    func updateButtonFrames() {
        self.cancelButton.frame = CGRect(x: self.view.frame.minX + 10, y: self.view.frame.maxY - 50, width: 70, height: 30)
        self.shutterButton.frame = CGRect(x: self.view.frame.midX - 35, y: self.view.frame.maxY - 80, width: 70, height: 70)
    }
}

// MARK: UIButton Functions

fileprivate extension OBCameraViewController {
    @objc func cancelButtonTapped() {
        if let delegate = self.delegate {
            delegate.cancelButtonTapped(controller: self)
        }
    }
    
    @objc func shutterButtonTapped() {
        if let camera = self.camera {
            camera.captureStillImage()
        }
    }
}

// MARK: CameraDelegate Functions

extension OBCameraViewController: CameraDelegate {
    func stillImageCaptured(camera: OBCamera, image: UIImage) {
        if let delegate = self.delegate {
            delegate.stillImageCaptured(controller: self, image: image)
        }
    }
}
