//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageView : View, PageProtocol {
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @Binding var url:String?
    @State var img:UIImage?
    let contentMode:ContentMode
    init(
        url:String? = nil,
        contentMode:ContentMode = .fit
    ){
        self._url = .constant(url)
        self.contentMode = contentMode
    }
    init(
        url:Binding<String?>,
        contentMode:ContentMode = .fit
    ){
        self._url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
    
        Image(uiImage: self.img ?? self.imageLoader.image(url: self.url))
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .onReceive(self.imageLoader.$image) { img in
                guard let img = img else { return }
                //DataLog.d("onReceive " + (self.url ?? "") , tag:self.tag)
                self.img = img
            }
            .onDisappear(){
                //DataLog.d("onDisappear " + (self.url ?? "") , tag:self.tag)
                self.img = nil
            }
        
    }
}


struct DynamicImageView : View, PageProtocol {
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @Binding var url:String?
    let contentMode:ContentMode
    init(
        url:String? = nil,
        contentMode:ContentMode = .fit
    ){
        self._url = .constant(url)
        self.contentMode = contentMode
    }
    init(
        url:Binding<String?>,
        contentMode:ContentMode = .fit
    ){
        self._url = url
        self.contentMode = contentMode
    }
    var body: some View {
        Image(uiImage: self.imageLoader.image(url: self.url))
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
    }
}
