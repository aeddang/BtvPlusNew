//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageKidsMy {
    static let recentlyWatchCode:String = "514"
}

struct PageKidsMy: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var diagnosticReportModel:DiagnosticReportModel = DiagnosticReportModel()
    @ObservedObject var monthlyReportModel:MonthlyReportModel = MonthlyReportModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    @State var isPairing:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                VStack (alignment: .center, spacing:0){
                    PageKidsTab(
                        title:String.kidsTitle.kidsMy,
                        isBack: true,
                        isSetting: true)
                    if self.isDataReady {
                        if self.isPairing {
                            PairingKidsView(
                                pageObservable: self.pageObservable,
                                pageDragingModel: self.pageDragingModel,
                                tabNavigationModel: self.tabNavigationModel,
                                infinityScrollModel: self.infinityScrollModel,
                                diagnosticReportModel: self.diagnosticReportModel,
                                monthlyReportModel: self.monthlyReportModel)
                        } else {
                            NeedPairingInfo(
                                title: String.kidsText.kidsMyNeedPairing,
                                text: String.kidsText.kidsMyNeedPairingSub)
                                .modifier(MatchParent())
                        }
                    } else {
                        Spacer()
                    }
                }
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        .opacity(self.isPairing ? 0 : 1)
                )
                .modifier(PageFullScreen(style:.kids))
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted:
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : break
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
                if self.isPairing {
                    self.pairing.requestPairing(.updateKids)
                }
            }
            .onReceive(pairing.$event) { evt in
                guard let evt = evt else { return }
                if self.pairing.kid != nil {return}
                self.checkProfileStatus(evt: evt)
                switch evt {
                case .updatedKidsError :
                    self.appSceneObserver.alert = .alert(nil,  String.alert.kidsDisable, String.alert.kidsDisableTip){
                        self.pagePresenter.goBack()
                    }
                default : break
                }
                
            }
            .onReceive(self.pairing.$kid){kid in
                if kid == nil {
                    
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
                    self.isDataReady = true
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
            .onAppear{
                if self.dataProvider.bands.kidsGnbModel.getMyDatas() == nil {
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getGnbKids))
                } else {
                    self.isDataReady = true
                }
            }
        }//geo
    }//body

    @State var isDataReady:Bool = false
    private func error() {
        self.appSceneObserver.alert = .alert(nil,  String.alert.kidsDisable, String.alert.kidsDisableTip){
            self.pagePresenter.goBack()
        }
    }
    
    @State var isInit:Bool = true
    private func checkProfileStatus(evt:PairingEvent){
        if self.pairing.status != .pairing {return}
        if self.isInit {
            self.isInit = false
            return
        }
        
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
struct PageKidsMy_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsMy().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
