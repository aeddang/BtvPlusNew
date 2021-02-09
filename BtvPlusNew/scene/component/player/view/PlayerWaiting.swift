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
    @State var isFullScreen:Bool = false
    @State var isPageOn:Bool = false
    var body: some View {
        ZStack{
            if self.imgBg != nil {
                ImageView(url: self.imgBg!, contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
            }
            Spacer()
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                
            VStack(spacing:0){
                HStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.light){
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
                    self.viewModel.event = .resume
                }
                if self.viewModel.playInfo != nil  {
                    Text(self.viewModel.playInfo!)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                }
            }.opacity(self.isPageOn ? 1.0 : 0)
        }
        .modifier(MatchParent())
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

