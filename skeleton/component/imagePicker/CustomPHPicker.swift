//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

@available(iOS 14.0, *)
struct CustomPHPicker {
    @ObservedObject var viewModel:ImagePickerModel
    var sourceType:UIImagePickerController.SourceType
    var cameraDevice:UIImagePickerController.CameraDevice = .rear
    var cameraOverlayView:UIView? = nil
    func makeCoordinator() -> Coordinator { return Coordinator(viewModel:self.viewModel, sourceType: self.sourceType) }
    
    class Coordinator: PHPickerViewControllerDelegate{
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           
            //guard let unwrapImage = results[.max] as? UIImage else { return }
            //self.viewModel.pickImage = unwrapImage
            //self.viewModel.event = .takePicture
           // self.viewModel.reset()
        }
        
        @ObservedObject var viewModel:ImagePickerModel
        var sourceType:UIImagePickerController.SourceType
        init(viewModel:ImagePickerModel, sourceType:UIImagePickerController.SourceType){
            self.viewModel = viewModel
            self.sourceType = sourceType
        }
        
    }
}

@available(iOS 14.0, *)
extension CustomPHPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomPHPicker>) -> PHPickerViewController {
        self.viewModel.reset()
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<CustomPHPicker>) {
    }
}
