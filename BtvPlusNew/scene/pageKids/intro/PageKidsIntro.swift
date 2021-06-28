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
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
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
                        self.isAnimationCompleted = true
                        self.completed()
                    }
                }
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            case .getGnbKids :
                guard let data = res.data as? GnbBlock  else {
                    self.error()
                    return
                }
                self.dataProvider.bands.setDataKids(data)
                self.isDataCompleted = true
                self.completed()
            default : break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .getGnbKids : self.error()
            default : break
            }
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != self.tag { return }
        }
        .onAppear{
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getGnbKids))
            
        }
    }//body
    @State var isAnimationCompleted:Bool = false
    @State var isDataCompleted:Bool = false
    func completed() {
        if !self.isAnimationCompleted {return}
        if !self.isDataCompleted {return}
        self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsHome))
        if !self.pairing.kids.isEmpty {return}
        let prevDateKey = self.setup.kidsRegistUnvisibleDate
        if !prevDateKey.isEmpty,
           let prevDate = prevDateKey.toDate(dateFormat: Setup.dateFormat)
        {
            let diffTime = abs(prevDate.timeIntervalSinceNow)
            let diffDay = diffTime / (24 * 60 * 60 * 1000)
            if diffDay < 7 {
                return
            }
        }
        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
    }
    
    func error() {
       
        
    }
    

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
