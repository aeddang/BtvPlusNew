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
    let url:String?
    var contentMode:ContentMode  = .fill
    var noImg:String? = nil
    @State var image:UIImage? = nil
    @State var opacity:Double = 0.3
    
    var body: some View {
       
        Image(uiImage: self.image ?? self.getNoImage())
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .opacity( self.opacity )
            .onReceive(self.imageLoader.$event) { evt in
                self.onImageEvent(evt: evt)
            }
            .onAppear(){
                self.imageLoader.cash(url: self.url)
                self.creatAutoReload()
            }
            .onDisappear(){
                self.clearAutoReload()
                
            }
        
    }
    
    func getNoImage() -> UIImage {
        return (self.noImg != nil) ? UIImage(named: self.noImg!)! : UIImage.from(color: Color.transparent.clear.uiColor())
    }
    
    @State var anyCancellable = Set<AnyCancellable>()
    func resetImage(){
        self.clearAutoReload()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1 ) {
            let loader = ImageLoader()
            loader.$event.sink(receiveValue: { evt in
                self.onImageEvent(evt: evt)
            }).store(in: &anyCancellable)
            loader.reload(url: self.url)
        }
    }
    
    private func onImageEvent(evt:ImageLoaderEvent?){
        guard let  evt = evt else { return }
        switch evt {
        case .reset :
            self.resetImage()
            break
        case .complete(let img) :
            self.image = img
            withAnimation{self.opacity = 1.0}
            self.clearAutoReload()
        case .error :
            self.clearAutoReload()
            break
        }
    }
    
    @State var autoReloadSubscription:AnyCancellable?
    func creatAutoReload() {
        var count = 0
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = Timer.publish(
            every: count == 0 ? 0.3 : 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                count += 1
                self.imageLoader.reload(url: self.url)
                if count == 5 {
                    DataLog.d("autoReload fail " + (self.url ?? " nil") , tag:self.tag)
                    self.resetImage()
                }
            }
    }
    func clearAutoReload() {
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = nil
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
    }
}



