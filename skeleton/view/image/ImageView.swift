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
    var key:String = ""
    var contentMode:ContentMode  = .fill
    var noImg:String? = nil
    @State var image:UIImage? = nil
    @State var opacity:Double = 0.4
    @State var isOn:Bool = true
    var body: some View {
        if self.url != nil && self.isOn {
            Image(uiImage: self.image ?? self.getNoImage())
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: self.contentMode)
            .opacity( self.opacity )
            .onReceive(self.imageLoader.$event) { evt in
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
                    if !key.isEmpty {
                        DataLog.d("error " + key , tag:"ImageView")
                    }
                    self.clearAutoReload()
                    break
                }
            }
            .onAppear(){
                self.creatAutoReload()
            }
            .onDisappear(){
                self.clearAutoReload()
            }
        } else {
            Image(uiImage: self.getNoImage())
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
                .opacity( self.opacity )
        }
    }
    
    func getNoImage() -> UIImage {
        return (self.noImg != nil) ? UIImage(named: self.noImg!)! : UIImage.from(color: Color.transparent.clear.uiColor())
    }
    
    func resetImage(){
        self.clearAutoReload()
        self.isOn = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1 ) {
            self.isOn = true
            DataLog.d("image reset" , tag:self.tag)
        }
    }
    
    @State var autoReloadSubscription:AnyCancellable?
    func creatAutoReload() {
        var count = 0
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = Timer.publish(
            every: count == 0 ? 0.1 : 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                count += 1
                self.imageLoader.reload(url: self.url, key: self.key)
                if count == 3 {
                    DataLog.d("autoReload fail " + (self.url ?? " nil") , tag:self.tag)
                    self.resetImage()
                }
            }
    }
    func clearAutoReload() {
        self.autoReloadSubscription?.cancel()
        self.autoReloadSubscription = nil
    }
}



