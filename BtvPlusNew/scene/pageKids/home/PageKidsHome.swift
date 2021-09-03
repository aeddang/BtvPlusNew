//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageKidsHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel(limitedScrollIndex: 1)
      
    @State var marginTop:CGFloat = DimenKids.margin.regular
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                pageObservable:self.pageObservable,
                viewModel : self.viewModel
            ){
                MultiBlockBody (
                    pageObservable: self.pageObservable,
                    viewModel: self.viewModel,
                    infinityScrollModel: self.infinityScrollModel,
                    useBodyTracking:true,
                    useTracking:false,
                    marginTop:self.marginTop,
                    marginBottom: self.marginBottom
                    )
            }
            .background(
                Image(AssetKids.image.homeBg)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .modifier(MatchParent())
                    
            )
            .modifier(PageFullScreen(style:.kids))
            .onReceive(self.pagePresenter.$currentTopPage){ topPage in
                if self.pagePresenter.currentTopPage?.pageID != self.pageID {return}
                if !self.isUiInit { return }
                if self.pairing.status != .pairing { return }
                self.pairing.requestPairing(.updateKids)
            }
            .onReceive(self.dataProvider.bands.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .updated:
                    if !self.isUiInit { return }
                    self.reload()
                default: break
                }
            }
            .onReceive(self.pairing.$kid){ kid in
                
                if let current = self.currentKid {
                    if current.id == kid?.id { return }
                }
                if kid != nil && self.pairing.status == .pairing {
                    if self.pairing.kidStudyData == nil {
                        self.pairing.requestPairing(.updateKidStudy)
                    }
                }
                if !self.isUiInit { return }
                DispatchQueue.main.async {
                    self.reload()
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ updated in
                if updated {
                    self.marginTop = KidsTop.height + DimenKids.margin.regular + self.sceneObserver.safeAreaTop
                    self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
                }
            }
            .onReceive(self.pairing.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pairingCompleted : self.pairing.requestPairing(.updateKids)
                case .notFoundKid :
                    if self.pagePresenter.currentTopPage?.pageID != self.pageID {return}
                    self.appSceneObserver.alert = .confirm(nil, String.alert.kidsProfileNotfound ,nil) { isOk in
                        if isOk {
                            if self.pagePresenter.currentTopPage?.pageID == .kidsProfileManagement { return }
                            self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                        }
                    }
                default : break
                }
            }
           
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                if self.pagePresenter.currentTopPage?.pageID == .kidsHome {
                    switch evt {
                    case .top : self.appSceneObserver.useGnb = true
                    case .down : self.appSceneObserver.useGnb = false
                    default : break
                    }
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isUiInit { return }
                    DispatchQueue.main.async {
                        self.reload()
                        self.isUiInit = true
                    }
                }
            }
            .onAppear{
                self.marginTop = KidsTop.height + DimenKids.margin.regular + self.sceneObserver.safeAreaTop
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
                if let obj = self.pageObject {
                    self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                    self.openId = obj.getParamValue(key: .subId) as? String
                    self.openPage = obj.getParamValue(key: .data) as? PageObject
                }
                if self.menuId.isEmpty {
                    self.menuId = self.dataProvider.bands.kidsGnbModel.home?.menuId ?? ""
                }
            }
            .onDisappear{
                //self.appSceneObserver.useGnb = true
            }
        }//geo
    }//body
    @State var isUiInit:Bool = false
    @State var menuId:String = ""
    @State var openId:String? = nil
    @State var openPage:PageObject? = nil
    @State var currentKid:Kid? = nil
    private func reload(){
        self.currentKid = self.pairing.kid
        if self.pagePresenter.currentTopPage?.pageID == PageID.kidsHome {
            self.appSceneObserver.useGnb = true
        }
        guard let blockData = self.dataProvider.bands.kidsGnbModel.getGnbData(menuId: self.menuId) else {
            self.menuId = self.dataProvider.bands.kidsGnbModel.home?.menuId ?? ""
            if !self.menuId.isEmpty { self.reload() }
            return
        }
        let isHome  = self.menuId == EuxpNetwork.MenuTypeCode.MENU_KIDS_HOME.rawValue
        if isHome {
            self.viewModel.updateKids(datas: blockData.blocks ?? [] , openId: self.openId)
        } else {
            self.viewModel.updateKids(data: blockData , openId: self.openId)
        }
        if let pop = self.openPage {
            self.pagePresenter.openPopup(pop)
            self.openPage = nil
        }
    }
    //Block init
    
}


#if DEBUG
struct PageKidsHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

