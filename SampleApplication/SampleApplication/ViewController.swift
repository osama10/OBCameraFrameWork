//
//  ViewController.swift
//  SampleApplication
//
//  Created by Osama Bin Bashir on 16/10/2018.
//  Copyright © 2018 Osama Bin Bashir. All rights reserved.
//

import UIKit
import OBCameraFramework

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Framework Version: \(OBCameraViewController.getVersion()!)")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonTapped(sender : UIButton) {
        let camera = OBCameraViewController.init()
        camera.delegate = self
        camera.position = .back
        present(camera, animated: true, completion: nil)
    }
    
}

extension ViewController: OBCameraControllerDelegate {
  
    
    func stillImageCaptured(controller: OBCameraViewController, image: UIImage) {
        self.imageView.image = image
        controller.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonTapped(controller: OBCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
