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
    static private var isFirst:Bool = true
}

struct PageKidsIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @State var isPlay:Bool = false
    @State var isFirst:Bool = false
    @State var movePage:PageObject? = nil
    var body: some View {
        ZStack{
            Spacer().modifier(MatchParent())
            if self.isFirst{
                ImageAnimation(
                    images: Self.ani,
                    fps:Self.fps,
                    isLoof: true,
                    isRunning: self.$isPlay
                    )
                    .frame(
                        width: SystemEnvironment.isTablet ? 365 : 225,
                        height:  SystemEnvironment.isTablet ? 267 : 165)
            }
        }
        .modifier(PageFull(style:self.isFirst ? .kidsPupple : .kidsClear ))
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if self.isPlay {return}
                DispatchQueue.main.async {
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
        .onReceive(pairing.$event) { evt in
            guard let evt = evt else { return }
            
            switch evt {
            case .updatedKids :
                self.isKidsProfileCompleted = true
                self.kidsProfileEvent = evt
                self.completed()
            case .notFoundKid :
                self.isKidsProfileCompleted = true
                self.kidsProfileEvent = evt
                self.completed()
            case .updatedKidsError :
                self.error()
            default : break
            }
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != self.tag { return }
        }
        .onAppear{
            self.isFirst = Self.isFirst
            if Self.isFirst {
                Self.isFirst = false
            } else {
                self.isAnimationCompleted = true
            }
           
            if let obj = self.pageObject {
                if let data = obj.getParamValue(key: .data) as? PageObject {
                    self.movePage = data
                }
            }
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getGnbKids))
            if self.pairing.status == .pairing {
                self.pairing.requestPairing(.updateKids)
            } else {
                self.isKidsProfileCompleted = true
            }
        }
    }//body
    @State var isAnimationCompleted:Bool = false
    @State var isDataCompleted:Bool = false
    @State var isKidsProfileCompleted:Bool = false
    @State var kidsProfileEvent:PairingEvent? = nil
    
    @State var isCompleted:Bool = false
    func completed() {
        if !self.isAnimationCompleted {return}
        if !self.isDataCompleted {return}
        if !self.isKidsProfileCompleted {return}
        if self.isCompleted {return}
        self.isCompleted = true
        if let movePage = self.movePage {
            if movePage.isPopup {
                self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsHome))
                self.pagePresenter.openPopup(movePage)
            } else {
                self.pagePresenter.changePage(movePage)
            }
            
        } else {
            self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsHome))
        }
        
        if self.pairing.kid == nil {
            switch self.kidsProfileEvent {
            case .notFoundKid:
                self.appSceneObserver.alert = .confirm(nil, String.alert.kidsProfileNotfound ,nil) { isOk in
                    if isOk {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                }
            case .updatedKids:
                if pairing.kids.isEmpty {
                    
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
                    self.appSceneObserver.alert = .confirm(nil, String.alert.kidsProfileEmpty,nil) { isOk in
                        if isOk {
                            self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                        }
                    }
                } else {
                    self.appSceneObserver.alert = .confirm(nil, String.alert.kidsProfileSelect ,nil) { isOk in
                        if isOk {
                            self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                        }
                    }
                }
            default: break
            }
        }
    }
    
    func error() {
        self.appSceneObserver.alert = .alert(nil,  String.alert.kidsDisable, String.alert.kidsDisableTip){
            self.pagePresenter.goBack()
        }
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
