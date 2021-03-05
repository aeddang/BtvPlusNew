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
    var url:String?
    var contentMode:ContentMode  = .fill
    var noImg:String? = nil
    @State var img:UIImage? = nil
    var body: some View {
        Image(uiImage:
                (self.img ?? self.imageLoader.image(url: self.url))
                ?? ( noImg != nil ? UIImage(named: self.noImg!)! : UIImage.from(color: Color.transparent.clear.uiColor() ) )
            )
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .onReceive(self.imageLoader.$event) { evt in
                guard let  evt = evt else { return }
                switch evt {
                case .complete(let img) : self.img = img
                case .error :
                    self.img = noImg != nil ? UIImage(named: self.noImg!)! : UIImage.from(color: Color.transparent.clear.uiColor() )
                    DataLog.d("error " + (self.img?.description ?? "") , tag:self.tag)
                }
            }
            .onDisappear(){
                //DataLog.d("onDisappear " + (self.url ?? "") , tag:self.tag)
                //self.img = UIImage(named: self.noImg)
            }
    }
}


struct DynamicImageView : View, PageProtocol {
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    var url:String?
    var contentMode:ContentMode = .fit
    var noImg:String = Asset.noImg1_1
    
    var body: some View {
        Image(uiImage: self.imageLoader.image(url: self.url) ?? UIImage(named: self.noImg)! )
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
    }
}
