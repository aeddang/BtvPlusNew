//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePairing: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.connectBtv,
                        isBack : true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    InfinityScrollView( viewModel: self.infinityScrollModel ){
                        VStack(alignment:.leading , spacing:0) {
                            Text(String.pageText.pairingText1)
                                .modifier(MediumTextStyle( size: Font.size.bold ))
                                .padding(.top, Dimen.margin.light)
                            
                            ZStack{
                                Text(String.pageText.pairingText2_1)
                                    .font(.custom(Font.family.bold, size: Font.size.light))
                                    .foregroundColor(Color.brand.primary)
                                + Text(String.pageText.pairingText2_2)
                                    .font(.custom(Font.family.bold, size: Font.size.light))
                                    .foregroundColor(Color.app.whiteDeep)
                            }
                            .padding(.top, Dimen.margin.lightExtra)
                            Text(String.pageText.pairingText2_3)
                                .font(.custom(Font.family.bold, size: Font.size.light))
                                .foregroundColor(Color.app.whiteDeep)
                            Text(String.pageText.pairingText2_4)
                                .font(.custom(Font.family.bold, size: Font.size.light))
                                .foregroundColor(Color.app.whiteDeep)
                            
                            
                            MoreInfoButton(
                                title: String.pageText.pairingBtnGuide
                            ){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pairingGuide)
                                )
                            }
                            .padding(.top, Dimen.margin.regularExtra)
                        }.modifier(ContentHorizontalEdges())
                        
                        Text(String.pageText.pairingTitle1)
                            .modifier(MediumTextStyle(
                                size:Font.size.light,
                                color: Color.brand.primary
                            ))
                            .padding(.top, Dimen.margin.heavy)
                        
                        ConnectButton(
                            image: Asset.icon.pairingWifi,
                            title: String.pageText.pairingBtnWifi,
                            text: String.pageText.pairingBtnWifiSub
                        ){
                            self.requestPairing(type: .wifi)
                        }
                        .padding(.top, Dimen.margin.lightExtra)
                        
                        ConnectButton(
                            image: Asset.icon.pairingBtv,
                            title: String.pageText.pairingBtnBtvCertification,
                            text: String.pageText.pairingBtnBtvCertificationSub
                        ){
                            self.requestPairing(type: .btv)
                        }
                        .padding(.top, Dimen.margin.thin)
                        
                        Text(String.pageText.pairingTitle2)
                            .modifier(MediumTextStyle(
                                size:Font.size.light,
                                color: Color.brand.primary
                            ))
                            .padding(.top, Dimen.margin.lightExtra)
                        
                        ConnectButton(
                            image: Asset.icon.pairingUser,
                            title: String.pageText.pairingBtnUserCertification,
                            text: String.pageText.pairingBtnUserCertificationSub
                        ){
                            
                            self.requestPairing(type: .user(nil))
                        }
                        .padding(.vertical, Dimen.margin.lightExtra)
                    }
                    .modifier(ContentHorizontalEdges())
                    .modifier(MatchParent())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .pairingCompleted :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                default : do{}
                }
            }
            .onAppear{
               
            }
            
        }//geo
    }//body
    
    private func requestPairing(type:PairingRequest){
        switch type {
        case .wifi:
            if self.networkObserver.status != .wifi {
                self.appSceneObserver.alert = .connectWifi{ retry in
                    if retry { self.requestPairing(type: .wifi) }
                }
                return
            }
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.wifi)
            )
        case .btv:
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.btv)
            )
        case .user:
           self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.user(nil))
            )
            
        default: do{}
        }
        
    }

}

#if DEBUG
struct PagePairing_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairing().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
