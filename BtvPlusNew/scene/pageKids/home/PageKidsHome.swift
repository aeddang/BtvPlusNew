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
    
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel(logType: .home)
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
                //if self.pairing.status != .pairing { return }
                //self.pairing.requestPairing(.updateKids)
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
                if self.pairing.status == .pairing {
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
                if !self.isUiInit  {return}
                guard let evt = evt else {return}
                self.checkProfileStatus(evt:evt)
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
                        if self.pagePresenter.currentTopPage == self.pageObject {
                            if self.pairing.status != .pairing { return }
                            self.pairing.requestPairing(.updateKids)
                        }
                    }
                }
            }
            .onAppear{
                self.marginTop = KidsTop.height + DimenKids.margin.regular + self.sceneObserver.safeAreaTop
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
                if let obj = self.pageObject {
                    var menu:KidsGnbItemData? = nil
                    var openId:String? = nil
                    
                    if let openLink = obj.getParamValue(key: .link) as? String {
                        let links = openLink.contains("/") == true
                            ? openLink.components(separatedBy: "/")
                            : openLink.components(separatedBy: "|")
                        
                        if let tuple = self.dataProvider.bands.kidsGnbModel.getGnbData(links:links) {
                            menu = tuple.0
                            openId = openLink.replace(tuple.1, with: "")
                        }
                    } else if let cid = obj.getParamValue(key: .cid) as? String {
                        if let findMenu = self.dataProvider.bands.kidsGnbModel.getGnbData(menuCode: cid) {
                            menu = findMenu
                        }
                    } else if let title = obj.getParamValue(key: .title) as? String {
                        if let findMenu = self.dataProvider.bands.kidsGnbModel.getGnbData(title: title) {
                            menu = findMenu
                        }
                    }
                    
                    if let findMenu = menu {
                        self.menuId = findMenu.menuId ?? ""
                    } else {
                        self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                    }
                    self.openId = openId ?? obj.getParamValue(key: .subId) as? String
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
        self.appSceneObserver.kidsGnbMenuTitle = blockData.title
        self.appSceneObserver.kidsGnbMenuId = self.menuId
        if blockData.isHome {
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
    
    private func checkProfileStatus(evt:PairingEvent){
        if self.pairing.status != .pairing {return}
        if self.pairing.kid == nil {
            if pairing.kids.isEmpty {
                switch evt {
                case .notFoundKid:
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileNotfound ,nil) {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.editKid))
                    }
                case .updatedKids:
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileSelect ,nil) {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.editKid))
                    }
                default: break
                }
            } else {
                switch evt {
                case .notFoundKid:
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileNotfound ,nil) {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                case .updatedKids:
                    self.appSceneObserver.alert = .alert(nil, String.alert.kidsProfileSelect ,nil) {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                default: break
                }
            }
        }
    }
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

