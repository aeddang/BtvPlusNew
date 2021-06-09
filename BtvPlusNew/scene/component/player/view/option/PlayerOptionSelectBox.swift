//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
import AVKit

extension PlayerOptionSelectBox{
    static let rates:[Float] = [
        0.8,1.0,1.2,1.5,2.0
    ]
    static let ratios:[VideoGravity] = [
        VideoGravity(name:String.button.ratioOrigin, gravity: .resizeAspect),
        VideoGravity(name:String.button.ratioFill, gravity: .resize),
        VideoGravity(name:String.button.ratioFit, gravity: .resizeAspectFill)
    ]
    
    struct VideoGravity {
        let name:String
        let gravity:AVLayerVideoGravity
    }
    
    struct BtnData:Identifiable{
        let id = UUID.init()
        let title:String
        let index:Int
        var value:Any? = nil
    }
    
   
}


struct PlayerOptionSelectBox: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var type:PageType = .btv
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = false
    @State var btns:[BtnData] = []
    @State var buttonSize:CGSize = Dimen.button.mediumRect
    
    @State var selectedIdx:Int = -1
    var body: some View {
        ZStack(){
            VStack{
                HStack{
                    Spacer()
                    Button(action: {
                        self.viewModel.selectFunctionType = nil
                    }) {
                        if self.type == .btv{
                            Image(Asset.icon.close)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.regular,
                                       height: Dimen.icon.regular)
                                .padding(.all, self.isFullScreen
                                            ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                        } else {
                            Image(AssetKids.player.close )
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: self.isFullScreen
                                        ? KidsPlayerUI.iconFullScreen.width : KidsPlayerUI.icon.width,
                                    height: self.isFullScreen
                                        ? KidsPlayerUI.iconFullScreen.height : KidsPlayerUI.icon.height)
                                .padding(.all, self.isFullScreen
                                            ? KidsPlayerUI.paddingFullScreen : KidsPlayerUI.padding)
                        }
                    }
                }
                Spacer()
            }
            
            if self.type == .btv {
                PlayerOptionSelectList(
                    viewModel: self.viewModel,
                    isFullScreen: self.isFullScreen,
                    btns: self.btns,
                    buttonSize: self.buttonSize,
                    selectedIdx: self.selectedIdx)
            } else {
                PlayerOptionSelectListKids(
                    viewModel: self.viewModel,
                    isFullScreen: self.isFullScreen,
                    btns: self.btns,
                    selectedIdx: self.selectedIdx)
            }
        }
        .background(Color.transparent.black45)
        .modifier(MatchParent())
        .opacity(self.isShowing ? 1 : 0)
       
        .onReceive(self.viewModel.$selectFunctionType) { type in
            guard let type  = type else{
                withAnimation{
                    self.isShowing = false
                }
                return
            }
            self.viewModel.playerUiStatus = .hidden
            self.selectedIdx = -1
            switch type {
            case .quality :
                self.btns = zip(0...self.viewModel.qualitys.count, self.viewModel.qualitys).map{ idx, q in
                    if self.viewModel.currentQuality?.name == q.name {
                        self.selectedIdx = idx
                    }
                    return BtnData(title: q.name, index: idx, value: q)
                }
                self.buttonSize = Dimen.button.mediumExtraRect
                   
            case .rate :
                self.btns = zip(0...Self.rates.count, Self.rates).map{ idx, r in
                    if self.viewModel.rate == r {
                        self.selectedIdx = idx
                    }
                    return BtnData(title: "x" + r.description , index: idx, value: r)
                }
                self.buttonSize = Dimen.button.mediumExtraRect
                
            case .ratio :
                self.btns = zip(0...Self.ratios.count, Self.ratios).map{ idx, r in
                    if self.viewModel.screenGravity == r.gravity{
                        self.selectedIdx = idx
                    }
                    return BtnData(title: r.name , index: idx, value: r.gravity )
                }
                self.buttonSize = Dimen.button.mediumRect
                
            }
            withAnimation{
                self.isShowing = true
            }
            
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
            
    }//body
    
    
   
    
}


#if DEBUG
struct PlayerOptionSelectBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerOptionSelectBox()
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
