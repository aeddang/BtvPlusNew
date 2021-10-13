//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingBody: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter

    let infinityScrollModel: InfinityScrollModel
    var requestPairing:(_ type:PairingRequest) -> Void
    var body: some View {
        InfinityScrollView( viewModel: self.infinityScrollModel ){
            ZStack(alignment: .topLeading){
                HStack{
                    Spacer()
                    Image(Asset.image.pairingCharacter)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 134)
                }
                .padding(.top, 45)
                
                VStack(alignment:.leading , spacing:0) {
                    Text(String.pageText.pairingText)
                        .modifier(MediumTextStyle( size: Font.size.bold ))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Text(String.pageText.pairingText1)
                        .font(.custom(Font.family.medium, size: Font.size.lightExtra))
                        .lineSpacing(Font.spacing.regular)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.app.greyLight)
                        .padding(.top, Dimen.margin.lightExtra)
                    
                    
                    MoreInfoButton(
                        title: String.pageText.pairingBtnGuide
                    ){
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairingGuide)
                        )
                    }
                    .padding(.top, Dimen.margin.mediumExtra)
                }
                
            }
            .modifier(ContentHorizontalEdges())
            .padding(.top, Dimen.margin.light)
            
            Text(String.pageText.pairingTitle1)
                .modifier(MediumTextStyle(
                    size:Font.size.light,
                    color: Color.brand.primary
                ))
                .padding(.top, Dimen.margin.heavy)
            
            ConnectButton(
                image: Asset.icon.pairingWifi,
                title: String.pageText.pairingBtnWifi,
                text: String.pageText.pairingBtnWifiSub,
                tip: String.pageText.pairingBtnWifiSubTip
            ){
                self.requestPairing( .wifi() )
            }
            .padding(.top, Dimen.margin.lightExtra)
            
            ConnectButton(
                image: Asset.icon.pairingBtv,
                title: String.pageText.pairingBtnBtvCertification,
                text: String.pageText.pairingBtnBtvCertificationSub
            ){
                self.requestPairing( .btv)
            }
            .padding(.top, Dimen.margin.thin)
            
            Text(String.pageText.pairingTitle2)
                .modifier(MediumTextStyle(
                    size:Font.size.light,
                    color: Color.brand.primary
                ))
                .padding(.top, Dimen.margin.medium)
            
            ConnectButton(
                image: Asset.icon.pairingUser,
                title: String.pageText.pairingBtnUserCertification,
                text: String.pageText.pairingBtnUserCertificationSub
            ){
                
                self.requestPairing(.user(nil))
            }
            .padding(.vertical, Dimen.margin.lightExtra)
        }
        .modifier(ContentHorizontalEdges())
        .modifier(MatchParent())
        
    }//body
}


struct PagePairingBodyTablet: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    let infinityScrollModel: InfinityScrollModel
    var requestPairing:(_ type:PairingRequest) -> Void
    var body: some View {
        InfinityScrollView( viewModel: self.infinityScrollModel ){
            HStack{
                VStack(alignment:.leading , spacing:0) {
                    Text(String.pageText.pairingText)
                        .modifier(MediumTextStyle( size: Font.size.bold ))
                        
                
                    Text(String.pageText.pairingText1Tablet)
                        .font(.custom(Font.family.medium, size: Font.size.tiny))
                        .foregroundColor(Color.app.greyLight)
                        .padding(.top, Dimen.margin.lightExtra)
                  
                    MoreInfoButton(
                        title: String.pageText.pairingBtnGuide,
                        textSize: Font.size.tiny
                    ){
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairingGuide)
                        )
                    }
                    .padding(.top, Dimen.margin.regularExtra)
                }
                Image(Asset.image.pairingCharacter)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 218, height: 241)
            }
            .padding(.top, Dimen.margin.mediumExtra)
            
            HStack(alignment: .top, spacing: 0){
                ConnectTitle(title: String.pageText.pairingTitle1Tablet)
                    .frame(width: 175, alignment: .topLeading)
                ConnectButtonTablet(
                    image: Asset.icon.pairingWifi,
                    title: String.pageText.pairingBtnWifi,
                    text: String.pageText.pairingBtnWifiSubTablet,
                    tip: String.pageText.pairingBtnWifiSubTip
                ){
                    self.requestPairing( .wifi() )
                }
                .padding(.leading, Dimen.margin.thinExtra)
                ConnectButtonTablet(
                    image: Asset.icon.pairingBtv,
                    title: String.pageText.pairingBtnBtvCertification,
                    text: String.pageText.pairingBtnBtvCertificationSubTablet
                ){
                    self.requestPairing( .btv)
                }
                .padding(.leading, Dimen.margin.thinExtra)
            }
            .padding(.top, Dimen.margin.medium)
            
            HStack(alignment: .top, spacing: 0){
                ConnectTitle(title: String.pageText.pairingTitle2Tablet)
                    .frame(width: 170, alignment: .topLeading)
                ConnectButtonTablet(
                    image: Asset.icon.pairingUser,
                    title: String.pageText.pairingBtnUserCertification,
                    text: String.pageText.pairingBtnUserCertificationSubTablet
                ){
                    
                    self.requestPairing(.user(nil))
                }
                .padding(.leading, Dimen.margin.thinExtra)
            }
            .padding(.top, Dimen.margin.medium)
        }
        .modifier(ContentHorizontalEdges())
        .modifier(MatchParent())
    }//body
}

struct PagePairingBodyTabletHorizontal: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    let infinityScrollModel: InfinityScrollModel
    var requestPairing:(_ type:PairingRequest) -> Void
    var body: some View {
        InfinityScrollView( viewModel: self.infinityScrollModel ){
            VStack(alignment:.leading , spacing:0) {
                HStack( spacing: Dimen.margin.mediumExtra ){
                    Image(Asset.image.pairingCharacter)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 218, height: 241)
                    VStack(alignment:.leading , spacing:0) {
                        Text(String.pageText.pairingText)
                            .modifier(MediumTextStyle( size: Font.size.bold ))
                        
                        Text(String.pageText.pairingText1Tablet)
                            .font(.custom(Font.family.medium, size: Font.size.tiny))
                            .foregroundColor(Color.app.greyLight)
                            .padding(.top, Dimen.margin.thin)
                       
                        MoreInfoButton(
                            title: String.pageText.pairingBtnGuide,
                            textSize: Font.size.tiny
                        ){
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.pairingGuide)
                            )
                        }
                        .padding(.top, Dimen.margin.regularExtra)
                    }
                    Spacer()
                }
                HStack(alignment: .top, spacing: Dimen.margin.regular){
                    VStack(alignment: .leading, spacing: 0){
                        ConnectTitle(title: String.pageText.pairingTitle1)
                        HStack(alignment:.top , spacing:0) {
                            ConnectButtonTablet(
                                image: Asset.icon.pairingWifi,
                                title: String.pageText.pairingBtnWifi,
                                text: String.pageText.pairingBtnWifiSubTablet,
                                tip: String.pageText.pairingBtnWifiSubTip
                            ){
                                self.requestPairing( .wifi() )
                            }
                            ConnectButtonTablet(
                                image: Asset.icon.pairingBtv,
                                title: String.pageText.pairingBtnBtvCertification,
                                text: String.pageText.pairingBtnBtvCertificationSubTablet
                            ){
                                self.requestPairing( .btv)
                            }
                            .padding(.leading, Dimen.margin.thinExtra)
                        }
                        .padding(.top, Dimen.margin.thin)
                    }
                    VStack(alignment: .leading, spacing: 0){
                        ConnectTitle(title: String.pageText.pairingTitle2)
                        ConnectButtonTablet(
                            image: Asset.icon.pairingUser,
                            title: String.pageText.pairingBtnUserCertification,
                            text: String.pageText.pairingBtnUserCertificationSubTablet
                        ){
                            
                            self.requestPairing(.user(nil))
                        }
                        .padding(.top, Dimen.margin.thin)
                    }
                }
                .padding(.top, Dimen.margin.mediumExtra)
            }
            .padding(.top, Dimen.margin.heavyExtra)
            .padding(.horizontal, Dimen.margin.medium)
            
        }
        .modifier(MatchParent())
    }//body
}




struct PagePairing: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var vsManager:VSManager
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
   
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var pairingInType:String? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.connectBtv,
                        isBack : true,
                        style:.dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    if SystemEnvironment.isTablet {
                        if self.sceneOrientation == .portrait {
                            PagePairingBodyTablet(
                                infinityScrollModel: self.infinityScrollModel){ type in
                                self.requestPairing(type: type)
                            }
                        } else {
                            PagePairingBodyTabletHorizontal(
                                infinityScrollModel: self.infinityScrollModel){ type in
                                self.requestPairing(type: type)
                            }
                        }
                    } else {
                        PagePairingBody(
                            infinityScrollModel: self.infinityScrollModel){ type in
                            self.requestPairing(type: type)
                        }
                    }
                }
                .modifier(PageFull(style:.dark))
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
            .onReceive(self.vsManager.$isGranted){ isGranted in
                if isGranted == false {
                    self.onBtvPairing()
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                guard let obj = self.pageObject  else { return }
                self.pairingInType = obj.getParamValue(key: .subType) as? String ?? "mob-my"
            }
            
        }//geo
    }//body
    
    private func requestPairing(type:PairingRequest){
        switch type {
        case .wifi:
            self.naviLogManager.actionLog(
                .clickConnectSelection, actionBody: .init(config:PairingType.wifi.logPageConfig))
            
            if self.networkObserver.status != .wifi {
                self.appSceneObserver.alert = .connectWifi
                return
            }
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.wifi)
                    .addParam(key: PageParam.subType, value: self.pairingInType)
            )
        case .btv:
            self.naviLogManager.actionLog(
                .clickConnectSelection, actionBody: .init(config:PairingType.btv.logPageConfig))
            if self.vsManager.isGranted != false {
                self.vsManager.checkAccessStatus(isInterruptionAllowed:true)
                return
            }
            self.onBtvPairing()
           
        case .user:
            self.naviLogManager.actionLog(
                .clickConnectSelection, actionBody: .init(config:PairingType.user.logPageConfig))
           self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.user(nil))
                    .addParam(key: PageParam.subType, value: self.pairingInType)
                
            )
            
        default: break
        }
        
    }
    
    private func onBtvPairing(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.pairingSetupUser)
                .addParam(key: PageParam.type, value: PairingRequest.btv)
                .addParam(key: PageParam.subType, value: self.pairingInType)
        )
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
