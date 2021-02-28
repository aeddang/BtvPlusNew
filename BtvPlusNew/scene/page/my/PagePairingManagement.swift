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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   

    @State var nick:String = ""
    @State var pairingDate:String = ""
    @State var macAdress:String = ""
    @State var modelName:String = ""
    @State var modelImage:String = Asset.noImg1_1
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
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
                            Text(String.app.nickName + ":" + self.nick)
                                .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                            HStack{
                                Text(String.pageText.myPairingDate + ":" + self.pairingDate)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                                Spacer()
                            }
                        }
                        .padding(.vertical, Dimen.margin.regular)
                        .padding(.horizontal, Dimen.margin.lightExtra)
                        .background(Color.app.blueLight)
                        .padding(.top, Dimen.margin.thinExtra)
                        
                        Text(String.pageText.myConnectedBtv)
                            .modifier(MediumTextStyle(size: Font.size.regular, color: Color.app.white))
                            .padding(.top, Dimen.margin.medium)
                        HStack(spacing:Dimen.margin.lightExtra){
                            Image(self.modelImage)
                            .renderingMode(.original)
                            .resizable()
                            .frame(
                                width: ListItem.stb.size.width,
                                height: ListItem.stb.size.height)
                            
                            VStack(alignment:.leading, spacing:Dimen.margin.thin){
                                Text(self.modelName)
                                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
    
                                Text(String.app.macAdress + ":" + self.macAdress)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                                
                            }
                            Spacer()
                            TextButton(
                                defaultText: String.button.disConnect,
                                textModifier: TextModifier( family: Font.family.bold,
                                    size: Font.size.thinExtra, color:Color.app.white),
                                image: Asset.icon.more) { _ in
                                    self.pairing.requestPairing(.unPairing)
                                }
                            
                        }
                        .padding(.vertical, Dimen.margin.regular)
                        .padding(.horizontal, Dimen.margin.lightExtra)
                        .background(Color.app.blueLight)
                        .padding(.top, Dimen.margin.thinExtra)
                        
                        FillButton(
                            text: String.pageText.myinviteFammly
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.pairing)
                            )
                        }
                        .padding(.top, Dimen.margin.light)
                        VStack(alignment:.center){
                            Text(String.pageText.myinviteFammlyText1)
                                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                            Text(String.pageText.myinviteFammlyText2)
                                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                            Spacer().modifier(MatchParent())
                        }
                        .padding(.top, Dimen.margin.thin)
                        
                    }
                    .modifier(ContentHorizontalEdges())
                }
                
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
                .modifier(PageFull())
                
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .disConnected : self.pagePresenter.closePopup(self.pageObject?.id)
                default : do{}
                }
            }
            .onReceive(self.pairing.$user){ user in
                guard let user = user else {return}
                self.nick = user.nickName
                self.pairingDate = user.pairingDate ?? "i don't know"
            }
            .onReceive(self.pairing.$hostDevice){ device in
                guard let device = device else {return}
                if let adress = device.macAdress {
                    self.macAdress = ApiUtil.getDecyptedData(
                        forNps: adress,
                        npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
                }
                self.modelName = device.modelName ?? String.app.defaultStb
                self.modelImage = Pairing.getSTBImage(stbModel: self.modelName)
            }
            .onAppear{
               
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
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
