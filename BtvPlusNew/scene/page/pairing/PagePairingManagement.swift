//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePairingManagement: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var vsManager:VSManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   

    @State var nick:String = ""
    @State var pairingDate:String = ""
    @State var macAdress:String = ""
    @State var modelNickName:String? = nil
    @State var modelName:String = ""
    @State var modelImage:String = Asset.noImg1_1
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment:.leading, spacing:0){
                    PageTab(
                        title: String.pageTitle.pairingManagement,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    VStack(alignment:.leading, spacing:0){
                        Text(String.pageText.myPairingInfo)
                            .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                            .padding(.top, Dimen.margin.medium)
                        VStack(alignment:.leading, spacing:Dimen.margin.thin){
                            Text(String.app.nickName + " : " + self.nick)
                                .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                            HStack{
                                Text(String.pageText.myPairingDate + " : " + self.pairingDate)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                                Spacer()
                            }
                        }
                        .padding(.vertical, SystemEnvironment.isTablet ? Dimen.margin.lightExtra : Dimen.margin.regular)
                        .padding(.horizontal, Dimen.margin.lightExtra)
                        .background(Color.app.blueLight)
                        .padding(.top, Dimen.margin.thinExtra)
                        
                        Text(String.pageText.myConnectedBtv)
                            .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                            .padding(.top,SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.medium)
                        VStack(spacing:Dimen.margin.light){
                            HStack(spacing:Dimen.margin.lightExtra){
                                Image(self.modelImage)
                                .renderingMode(.original)
                                .resizable()
                                .frame(
                                    width: ListItem.stb.size.width,
                                    height: ListItem.stb.size.height)
                                VStack(alignment:.leading, spacing:Dimen.margin.thin){
                                    HStack(spacing:Dimen.margin.tiny){
                                        if let nick = self.modelNickName {
                                            Text(nick)
                                                .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                                            Text("("+self.modelName+")")
                                                .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                                        } else {
                                            Text(self.modelName)
                                                .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                                        }
                                    }
                                    Text(String.app.macAdress + " : " + self.macAdress)
                                        .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                                    
                                }
                                Spacer()
                            }
                            HStack(spacing:Dimen.margin.thin){
                                if self.pairing.pairingStbType == .btv {
                                    FillButton(text: String.button.modifyNick, strokeWidth: 1){ _ in
                                        
                                        self.naviLogManager.actionLog(
                                            .clickReleaseButton,actionBody: .init( config: "B tv 닉네임 변경"))
                                        
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.confirmNumber)
                                                .addParam(key: .type, value: PageConfirmNumber.InputType.nickname)
                                        )
                                    }
                                }
                                FillButton(text: String.button.disConnectBtv, strokeWidth: 1){ _ in
                                    self.naviLogManager.actionLog(
                                        .clickReleaseButton,actionBody: .init( config: "B tv 연결해제"))
                                    
                                    if self.pairing.user?.pairingDeviceType == .apple {
                                        self.vsManager.accountUnPairingAlert()
                                        return
                                    }
                                    self.appSceneObserver.alert = .confirm(String.alert.disConnect, String.alert.disConnectText){ isOk in
                                        
                                        self.naviLogManager.actionLog(
                                            .clickReleasePopupButton,actionBody: .init( config: isOk ? "해제하기" : "취소"))
                                        
                                        if isOk {
                                            self.pairing.requestPairing(.unPairing)
                                        }
                                    }
                                }
                                
                            }
                        }
                        .padding(.vertical, SystemEnvironment.isTablet ? Dimen.margin.lightExtra : Dimen.margin.regular)
                        .padding(.horizontal, Dimen.margin.lightExtra)
                        .background(Color.app.blueLight)
                        .padding(.top, Dimen.margin.thinExtra)
                        
                        FillButton(
                            text: String.pageText.myinviteFammly
                        ){_ in
                            
                            self.naviLogManager.actionLog(.clickInviteButton)
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.snsShare)
                                    .addParam(key: .type, value: PageSnsShare.ShareType.familyInvite(type: "mob-invite"))
                            )
                        }
                        .padding(.top, Dimen.margin.light)
                        if self.sceneOrientation == .portrait {
                            VStack(alignment:.center, spacing:Dimen.margin.tiny){
                                Text(String.pageText.myinviteFammlyText1)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyMedium))
                                Text(String.pageText.myinviteFammlyText2)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyMedium))
                                Spacer().modifier(MatchParent())
                            }
                            .padding(.top, Dimen.margin.thin)
                        } else {
                            VStack(alignment: .center, spacing: 0){
                                Text(String.pageText.myinviteFammlyText1 + " " + String.pageText.myinviteFammlyText2)
    
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyMedium))
                                    .padding(.top, Dimen.margin.thin)
                                Spacer().modifier(MatchHorizontal(height: 0))
                            }
                        }
                    }
                    .modifier(ContentHorizontalEdgesTablet())
                    Spacer()
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .disConnected :
                    // self.pagePresenter.closePopup(self.pageObject?.id)
                    self.pagePresenter.closeAllPopup()
                default : break
                }
            }
            .onReceive(self.pairing.$user){ user in
                guard let user = user else {return}
                self.nick = user.nickName
                if let date = user.pairingDate {
                    self.pairingDate =  date.count > 10 ? date.subString(start: 0, len: 10) : date
                }
            }
            .onReceive(self.pairing.$hostNickName){ host in
                guard let host = host else {return}
                self.modelNickName = self.pairing.getCurrentHostInfoData(host)?.joined_nickname
                
            }
            .onReceive(self.pairing.$hostDevice){ device in
                guard let device = device else {return}
                if let adress = device.macAdress {
                    self.macAdress = ApiUtil.getDecyptedData(
                        forNps: adress,
                        npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
                }
                self.modelName = device.modelViewName ?? String.app.defaultStb
                self.modelImage = Pairing.getSTBImage(stbModel: self.modelName)
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.pairing.hostNickName == nil {
                        self.pairing.requestPairing(.hostNickNameInfo())
                    }
                }
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                
            }
            
        }//geo
    }//body
    
    

}

#if DEBUG
struct PagePairingManagement_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingManagement().contentBody
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
