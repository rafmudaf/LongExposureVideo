//
//  ViewController.swift
//  Laplace
//
//  Created by Rafael M Mudafort on 3/6/16.
//  Copyright © 2016 Rafael M Mudafort. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class ViewController: UIViewController {

    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var swapCameraButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    
    var glContext: EAGLContext?
    var ciContext: CIContext?
    var renderBuffer: GLuint = GLuint()
    var glView: GLKView?

    var cameraController: CameraController!

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraController = CameraController(delegate: self)
        
        let glContext = EAGLContext(api: .openGLES2)
        let glView = GLKView(frame: videoPreviewView.frame, context: glContext!)
        glView.backgroundColor = .black
        glView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        glView.frame = videoPreviewView.frame
        let ciContext = CIContext(eaglContext: glContext!)
        videoPreviewView.addSubview(glView)
        
        // set global variables
        self.glContext = glContext
        self.ciContext = ciContext
        self.glView = glView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraController.startRunning()
    }
    
    @IBAction func swapCameraButtonClicked(sender: AnyObject) {
        cameraController.switchCamera()
    }
    
    @IBAction func recordVideoButtonClicked(sender: AnyObject) {
        
        cameraController.captureStillImage { (image, metadata) in
            print(metadata)
        }
//        cameraController.toggleRecording()
    }
}

extension ViewController: CameraControllerDelegate {    
    func cameraController(cameraController: CameraController, didOutputImage image: CIImage) {
        if glContext != EAGLContext.current() {
            EAGLContext.setCurrent(glContext)
        }
        guard let glView = self.glView else {
            fatalError("glView not accessible")
        }
        
        glView.bindDrawable()
        ciContext?.draw(image, in: image.extent, from: image.extent)
        glView.display()
    }
}
