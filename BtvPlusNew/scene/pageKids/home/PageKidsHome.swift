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
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
  
    @State var useTracking:Bool = false
    
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
                    useBodyTracking:self.useTracking,
                    useTracking:false,
                    marginTop:KidsTop.height + DimenKids.margin.regular + self.sceneObserver.safeAreaTop,
                    marginBottom: self.sceneObserver.safeAreaBottom
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
           
            .onReceive(self.dataProvider.bands.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .updated:
                    self.reload()
                default: do{}
                }
            }
            .onReceive(self.pairing.$kid){ kid in
                self.reload()
                if kid != nil {
                    if self.pairing.kidStudyData == nil {
                        self.pairing.requestPairing(.updateKidStudy)
                    }
                }
            }
            .onReceive(self.pairing.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pairingCompleted : self.pairing.requestPairing(.updateKids)
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
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                   
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.reload()
                }
            }
            .onAppear{
                if let obj = self.pageObject {
                    self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                    self.openId = obj.getParamValue(key: .subId) as? String
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
    
    @State var menuId:String = ""
    @State var openId:String? = nil
    
    private func reload(){
        if self.pagePresenter.currentTopPage?.pageID == PageID.kidsHome {
            self.appSceneObserver.useGnb = true
        }
        guard let blockData = self.dataProvider.bands.kidsGnbModel.getGnbData(menuId: self.menuId) else { return }
        let isHome  = self.menuId == EuxpNetwork.MenuTypeCode.MENU_KIDS_HOME.rawValue
        if isHome {
            self.viewModel.updateKids(datas: blockData.blocks ?? [] , openId: self.openId)
        } else {
            self.viewModel.updateKids(data: blockData , openId: self.openId)
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

