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
struct CustomImagePicker {
    @ObservedObject var viewModel:ImagePickerModel
    var sourceType:UIImagePickerController.SourceType
    var cameraDevice:UIImagePickerController.CameraDevice = .rear
    var cameraOverlayView:UIView? = nil
    func makeCoordinator() -> Coordinator { return Coordinator(viewModel:self.viewModel, sourceType: self.sourceType) }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
        @ObservedObject var viewModel:ImagePickerModel
        var sourceType:UIImagePickerController.SourceType
        init(viewModel:ImagePickerModel, sourceType:UIImagePickerController.SourceType){
            self.viewModel = viewModel
            self.sourceType = sourceType
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
            let key = self.sourceType == .camera
                ? UIImagePickerController.InfoKey.originalImage
                : UIImagePickerController.InfoKey.originalImage
            
            guard let unwrapImage = info[key] as? UIImage else { return }
            self.viewModel.pickImage = unwrapImage
            self.viewModel.event = .takePicture
            self.viewModel.reset()
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.viewModel.event = .cancel
            self.viewModel.event = nil
            picker.dismiss(animated: true)
        }
    }
}


extension CustomImagePicker: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomImagePicker>) -> UIImagePickerController {
        self.viewModel.reset()
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        if self.sourceType == .camera {
            picker.cameraOverlayView = self.cameraOverlayView
            picker.cameraDevice = self.cameraDevice
            picker.allowsEditing = false
            
        }
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CustomImagePicker>) {
    }
}
