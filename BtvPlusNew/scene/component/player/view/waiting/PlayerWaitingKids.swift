//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PlayerWaitingKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    @State var isFullScreen:Bool = false

    var body: some View {
        ZStack{
            ThumbImageViewerKids(
                imgBg: self.imgBg, contentMode: self.contentMode, isFullScreen: self.isFullScreen)
            if self.isFullScreen {
                VStack(spacing:0){
                    HStack(spacing:self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing){
                        Button(action: {
                            self.pagePresenter.goBack()
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
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
            }
            VStack(spacing:DimenKids.margin.regular){
                ImageButton(
                    defaultImage: AssetKids.player.resume,
                    size: self.isFullScreen
                    ? CGSize(width:DimenKids.icon.heavy,height:DimenKids.icon.heavy)
                    : CGSize(width:DimenKids.icon.medium,height:DimenKids.icon.medium)
                ){ _ in
                    self.viewModel.btvUiEvent = .initate
                }
                if self.viewModel.playInfo != nil  {
                    Text(self.viewModel.playInfo!)
                        .modifier(BoldTextStyleKids(
                                    size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny,
                                    color: Color.app.white))
                }
            }
        }
        .modifier(MatchParent())
        .background(Color.app.black)
        .clipped()
        .onReceive(self.pagePresenter.$isFullScreen){ fullScreen in
            withAnimation{ self.isFullScreen = fullScreen }
        }
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct PlayerWaitingKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerWaitingKids(
               
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

