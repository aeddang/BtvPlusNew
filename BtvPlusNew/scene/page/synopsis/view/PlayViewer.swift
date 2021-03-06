//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PlayViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var title:String? = nil
    var textInfo:String? = nil
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    var isActive:Bool = false
   
    @State var isFullScreen:Bool = false
    @State var isPageOn:Bool = false
    var body: some View {
        ZStack{
            ThumbImageViewer(imgBg: self.imgBg, contentMode: self.contentMode)
            if self.isActive {
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
                        if self.isFullScreen && self.title != nil {
                            Text(self.title!)
                                .modifier(MediumTextStyle(
                                    size: Font.size.mediumExtra,
                                    color: Color.app.white)
                                )
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
            }
            VStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.tiny) {
                Image(Asset.brand.logoWhite)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 87,
                           height: 52)
                if self.textInfo != nil {
                    Text(self.textInfo!)
                        .modifier(BoldTextStyle(
                            size: self.isFullScreen ? Font.size.lightExtra :Font.size.thin ))
                }
            }
            .opacity(self.isActive ? 1.0 : 0.5)
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
struct PlayViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayViewer(
                textInfo: "sjknkjdfndnfkds"
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

