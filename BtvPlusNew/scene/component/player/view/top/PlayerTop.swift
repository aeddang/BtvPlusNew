//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine



struct PlayerTop: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var title:String? = nil
    var isSimple:Bool = false
    var type:PageType = .btv
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = false
    @State var isMute:Bool = false
    @State var isLock:Bool = false
    @State var textQuality:String? = nil
    @State var textRate:String? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading){
            if self.type == .btv{
                PlayerTopBody(
                    viewModel: self.viewModel,
                    title: self.title,
                    isSimple: self.isSimple,
                    isFullScreen: self.isFullScreen,
                    isShowing: self.isShowing,
                    isMute: self.isMute,
                    isLock: self.isLock,
                    textQuality: self.textQuality,
                    textRate: self.textRate)
            } else {
                PlayerTopBodyKids(
                    viewModel: self.viewModel,
                    title: self.title,
                    isSimple: self.isSimple,
                    isFullScreen: self.isFullScreen,
                    isShowing: self.isShowing,
                    isMute: self.isMute,
                    isLock: self.isLock)
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
