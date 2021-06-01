//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageKidsIntro {
    static let fps:Double = 0.05
    static let ani:[String] = AssetKids.ani.splash
}

struct PageKidsIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    @State var isPlay:Bool = false
    var body: some View {
        ZStack{
            ImageAnimation(
                images: Self.ani,
                fps:Self.fps,
                isLoof: false,
                isRunning: self.$isPlay
                )
                .modifier(MatchParent())
        }
        .padding(.all, DimenKids.margin.medium)
        .modifier(PageFull(style:.kids))
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isPlay = ani
                let duration = Double(Self.ani.count) * Self.fps
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + duration) {
                    DispatchQueue.main.async {
                        self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsHome))
                    }
                }
            }
        }
        .onAppear{
            
        }
    }//body
    

}

#if DEBUG
struct PageKidsIntro_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsIntro().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
