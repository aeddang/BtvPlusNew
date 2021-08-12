//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PlayViewerKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var viewModel: BtvPlayerModel? = nil
    var title:String? = nil
    var textInfo:String? = nil
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    var isActive:Bool = false
   
    @State var isFullScreen:Bool = false
    @State var isPageOn:Bool = false
    var body: some View {
        ZStack{
            ThumbImageViewerKids(imgBg: self.imgBg, contentMode: self.contentMode)
            if self.isActive {
                VStack(spacing:0){
                    HStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.light){
                        if self.isFullScreen {
                            Button(action: {
                                
                                self.viewModel?.btvPlayerEvent = .close
                                
                            }) {
                                Image(AssetKids.player.back)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: self.isFullScreen
                                            ? KidsPlayerUI.iconFullScreen.width : KidsPlayerUI.icon.width,
                                        height: self.isFullScreen
                                            ? KidsPlayerUI.iconFullScreen.height : KidsPlayerUI.icon.height)
                            }
                            if let title = self.title {
                                Text(title)
                                    .modifier(MediumTextStyleKids(
                                        size: Font.sizeKids.mediumExtra,
                                        color: Color.app.white)
                                    )
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
            }
            VStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.tiny) {
                Image(Asset.brand.logo)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SystemEnvironment.isTablet ? 102 : 50,
                           height: SystemEnvironment.isTablet ? 69 : 35)
                if let info = self.textInfo {
                    Text(info)
                        .modifier(BoldTextStyleKids(
                                    size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny,
                                    color: Color.app.white))
                }
            }
            .opacity(self.isActive ? 1.0 : 0.5)
        }
        .modifier(MatchParent())
        .background(Color.app.grey)
        .clipped()
        
        .onReceive(self.pagePresenter.$isFullScreen){ fullScreen in
            withAnimation{ self.isFullScreen = fullScreen }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                withAnimation{ self.isPageOn = true }
            }
        }
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct PlayViewerKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayViewerKids(
                textInfo: "sjknkjdfndnfkds"
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

