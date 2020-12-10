//
//  CustomCaptureSession.swift
//  Valla
//
//  Created by KimJeongCheol on 2020/11/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI


struct CustomCaptureSession {
    @ObservedObject var viewModel:ImagePickerModel
    var sourceType:UIImagePickerController.SourceType
    var cameraDevice:UIImagePickerController.CameraDevice = .rear
    var cameraOverlayView:UIView? = nil
    
    class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
        private var captureSession: AVCaptureSession = AVCaptureSession()
        private let videoDataOutput = AVCaptureVideoDataOutput()
        private func addCameraInput() {
            guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .back).devices.first else {
                    fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
            }
            let cameraInput = try! AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.addCameraInput() // add this line
            self.getFrames()
            self.captureSession.startRunning()
        }
        
        func captureOutput(
            _ output: AVCaptureOutput,
            didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection) {
            // here we can process the frame
            print("did receive frame")
        }
        
        private func getFrames() {
            videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing.queue"))
            self.captureSession.addOutput(videoDataOutput)
            guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
                connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = .portrait
        }
    }
}


extension CustomCaptureSession: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomCaptureSession>) -> ViewController {
        self.viewModel.reset()
        let picker = ViewController()
        return picker
    }
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<CustomCaptureSession>) {
    }
}

