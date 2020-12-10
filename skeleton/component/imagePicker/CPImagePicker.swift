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
struct CPImagePicker : PageComponent {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:ImagePickerModel = ImagePickerModel()
    var sourceType:UIImagePickerController.SourceType = .savedPhotosAlbum
   
    var body: some View {
        ZStack{
            CustomImagePicker(viewModel:viewModel, sourceType: sourceType)
        }
    }
}


#if DEBUG
struct CPImagePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPImagePicker()
            .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif

