//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct ThumbImageViewerKids: PageView{
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    var isFullScreen:Bool = false
    var body: some View {
        ZStack{
            if self.contentMode == .fit {
                if let bg = self.imgBg  {
                    ImageView(url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 240, height: 0), convType: .blur) ?? "",
                              contentMode: .fill, noImg: Asset.noImg16_9)
                        .modifier(MatchParent())
                        .blur(radius: 4)
                        
                }
                Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                if let bg = self.imgBg {
                    ImageView(
                        imageLoader : self.imageLoader,
                        url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 90, height: 0), convType: .none) ?? "",
                                        contentMode: .fit, noImg: Asset.noImg9_16)
                        .modifier(MatchParent())
                        .padding(.all, DimenKids.margin.heavyExtra)
                }
            }else{
                if let bg = self.imgBg {
                    ImageView(
                        imageLoader : self.imageLoader,
                        url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 240, height: 0), convType: .none) ?? "",
                              contentMode: .fill, noImg: Asset.noImg16_9)
                        .modifier(MatchParent())
                        
                }
                Spacer().modifier(MatchParent()).background(Color.transparent.black45)
            }
            if !self.isLoaded {
                ZStack{
                    Image(AssetKids.player.noImg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: self.isFullScreen
                                ? SystemEnvironment.isTablet ? 726 : 382
                                : SystemEnvironment.isTablet ? 378 :  208,
                            height: self.isFullScreen
                                ? SystemEnvironment.isTablet ? 274 : 143
                                : SystemEnvironment.isTablet ? 143 : 78
                        )
                }
                .background(Color.app.blackMedium)
                .modifier(MatchParent())
            }
        }
        .modifier(MatchParent())
        .clipped()
        .onReceive(self.imageLoader.$event) { evt in
            self.onImageEvent(evt: evt)
        }
    }//body
    
    @State var isLoaded:Bool = false
    private func onImageEvent(evt:ImageLoaderEvent?){
        guard let  evt = evt else { return }
        switch evt {
        case .reset : break
        case .complete :
            withAnimation{ self.isLoaded = true }
        case .error :
            withAnimation{ self.isLoaded = false }
        }
    }
}



#if DEBUG
struct ThumbImageViewerKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ThumbImageViewerKids(
               
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

