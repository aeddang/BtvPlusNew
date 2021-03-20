//
//  ImageView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage
struct ImageView : View, PageProtocol {
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    let url:String
    var key:String = ""
    var contentMode:ContentMode  = .fill
    var noImg:String? = nil
    @State var image:UIImage? = nil
    @State var opacity:Double = 0.4
    var body: some View {
        Image(uiImage:
            self.image ?? self.getNoImage()
        )
        .renderingMode(.original)
        .resizable()
        .aspectRatio(contentMode: self.contentMode)
        .opacity( self.opacity )
        .onReceive(self.imageLoader.$event) { evt in
            guard let  evt = evt else { return }
            switch evt {
            case .reset :
                self.imageLoader.load(url: self.url, key: self.key)
                break
            case .complete(let img) :
                self.image = img
                withAnimation{self.opacity = 1.0}
                self.clearAutoReload()
            case .error :
                if !key.isEmpty {
                    DataLog.d("error " + key , tag:"ImageView")
                }
                self.clearAutoReload()
                break
            }
        }
        .onAppear(){
            self.imageLoader.load(url: self.url, key: self.key)
            self.creatAutoReload()
        }
        .onDisappear(){
            self.clearAutoReload()
        }
    }
    
    func getNoImage() -> UIImage {
        return (self.noImg != nil) ? UIImage(named: self.noImg!)! : UIImage.from(color: Color.transparent.clear.uiColor())
    }
    
    @State var autoReloadSubscription:AnyCancellable?
    func creatAutoReload() {
        var count = 0
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                DataLog.d("autoReload " + count.description , tag:self.tag)
                count += 1
                self.imageLoader.reload(url: self.url, key: self.key)
                if count == 5 {
                    self.clearAutoReload()
                }
            }
    }
    func clearAutoReload() {
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = nil
    }
}



