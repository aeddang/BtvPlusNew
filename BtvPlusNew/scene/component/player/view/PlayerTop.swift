//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
extension PlayerTop{
    static let strokeButtonText = TextModifier(
        family: Font.family.bold,
        size: Font.size.tinyExtra,
        color: Color.app.greyLight,
        activeColor: Color.app.white
    )
    static let strokeButtonTextFull = TextModifier(
        family: Font.family.bold,
        size: Font.size.thinExtra,
        color: Color.app.greyLight,
        activeColor: Color.app.white
    )
}


struct PlayerTop: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var title:String? = nil
    var isSimple:Bool = false
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = false
    @State var isMute:Bool = false
    @State var isLock:Bool = false
    @State var textQuality:String? = nil
    @State var textRate:String? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(alignment :.trailing, spacing:Dimen.margin.light){
                HStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.light){
                    if !self.isSimple{
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
                    }
                    if self.isFullScreen && self.title != nil {
                        VStack(alignment: .leading){
                            Text(self.title!)
                                .modifier(MediumTextStyle(
                                        size: Font.size.mediumExtra,
                                        color: Color.app.white)
                                )
                                .lineLimit(1)
                            Spacer().modifier(MatchHorizontal(height: 0))
                        }
                        .modifier(MatchHorizontal(height: Font.size.mediumExtra))
                    } else{
                        Spacer().modifier(MatchHorizontal(height: 1))
                    }
                    
                    if !self.isLock {
                        ImageButton(
                            defaultImage: Asset.player.volumeOn,
                            activeImage: Asset.player.volumeOff,
                            isSelected: self.isMute,
                            size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                        ){ _ in
                            if self.isMute {
                                if self.viewModel.volume == 0 {
                                    self.viewModel.event = .volume(0.5)
                                }else{
                                    self.viewModel.event = .mute(false)
                                }
                            } else {
                                self.viewModel.event = .mute(true)
                            }
                        }
                        if !self.isSimple{
                            if self.textQuality != nil {
                                StrokeRectButton(
                                    text: self.textQuality!,
                                    isSelected: false,
                                    textModifier: self.isFullScreen ? Self.strokeButtonTextFull :  Self.strokeButtonText,
                                    size: self.isFullScreen ? Dimen.button.regularRect : Dimen.button.lightRect
                                    ){ _ in
                                    
                                    self.viewModel.selectFunctionType = .quality
                                }
                            }
                            if self.textRate != nil {
                                StrokeRectButton(
                                    text: self.textRate!,
                                    isSelected: false,
                                    textModifier: self.isFullScreen ? Self.strokeButtonTextFull :  Self.strokeButtonText,
                                    size: self.isFullScreen ? Dimen.button.regularRect : Dimen.button.lightRect
                                    ){ _ in
                                    
                                    self.viewModel.selectFunctionType = .rate
                                    
                                }
                            }
                        }
                    }
                    if !self.isSimple{
                        ImageButton(
                            defaultImage: Asset.player.more,
                            activeImage: Asset.player.lock,
                            isSelected: self.isLock,
                            size: CGSize(width:Dimen.icon.light,height:Dimen.icon.light)
                        ){ _ in
                            if self.isLock {
                                self.viewModel.isLock = false
                            } else {
                                self.viewModel.btvUiEvent = .more
                            }
                        }
                    }
                }
                PlayerMoreBox( viewModel: self.viewModel )
                Spacer()
                
            }
        }
        .modifier(MatchParent())
        .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.isShowing = true
                default : self.isShowing = false
                }
            }
        }
        .onReceive(self.viewModel.$rate) { r in
            self.textRate = "x" + r.description
        }
        .onReceive(self.viewModel.$isMute) { mute in
            self.isMute = mute
        }
        .onReceive(self.viewModel.$isLock) { lock in
            withAnimation{ self.isLock = lock }
            self.pagePresenter.orientationLock(isLock: lock)
        }
        .onReceive(self.viewModel.$currentQuality) { quality in
            guard let quality = quality else{
                self.textQuality = nil
                return
            }
            self.textQuality = quality.name
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
            
    }//body
    
    
   
    
}


#if DEBUG
struct PlayerTop_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerTop(
                title:"test"
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
