//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PlayerWaiting: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    @State var isFullScreen:Bool = false

    var body: some View {
        ZStack{
            ThumbImageViewer(imgBg: self.imgBg, contentMode: self.contentMode)
            VStack(spacing:0){
                HStack(spacing:self.isFullScreen ? PlayerUI.fullScreenSpacing : PlayerUI.spacing){
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
            
            VStack(spacing:Dimen.margin.regular){
                ImageButton(
                    defaultImage: Asset.player.resume,
                    size: CGSize(width:Dimen.icon.heavyExtra,height:Dimen.icon.heavyExtra)
                ){ _ in
                    self.viewModel.btvUiEvent = .initate
                    self.viewModel.isUserPlay = true
                }
                if self.viewModel.playInfo != nil  {
                    Text(self.viewModel.playInfo!)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
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
struct PlayerWaiting_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerWaiting(
               
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

