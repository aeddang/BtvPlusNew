//
//  ImagePicker.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
open class ImagePickerModel: ComponentObservable {
    @Published var pickImage:UIImage? = nil
    @Published var event:ImagePickerEvent? = nil
    
    func reset() {
        pickImage = nil
        event = nil
    }
}

enum ImagePickerEvent {
    case takePicture , cancel
}
