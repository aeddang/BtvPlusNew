//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageAdultCertification: PageView {
    
    
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
    @State var eventId:String? = nil
    @State var movePage:PageObject? = nil
    @State var isAlert:Bool = false
    @State var isInfo:Bool = true
    @State var isfail:Bool = false
    @State var cid:String? = nil
    @State var marginBottom:CGFloat = Dimen.app.bottom
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: isfail ? String.alert.adultCertificationFail : String.alert.adultCertification,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack{
                        HStack(alignment: .top, spacing:0){
                            BtvWebView( viewModel: self.webViewModel)
                            Spacer().modifier(MatchVertical(width: 0))
                        }
                        .modifier(MatchParent())
                       //.background(Color.app.white)
                        if isInfo {
                            VStack(alignment:.leading , spacing:0) {
                                VStack(alignment:.leading , spacing:Dimen.margin.regular) {
                                    Text(String.pageText.adultCertificationText1)
                                        .modifier(MediumTextStyle( size: Font.size.bold ))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(String.pageText.adultCertificationText2)
                                        .modifier(MediumTextStyle( size: Font.size.light, color: Color.app.whiteDeep ))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(String.pageText.adultCertificationText3)
                                        .modifier(MediumTextStyle( size: Font.size.thin, color: Color.app.grey))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.top, Dimen.margin.medium)
                                .padding(.horizontal, Dimen.margin.regular)
                                Spacer()
                                FillButton(
                                    text: String.button.certification,
                                    isSelected: true
                                ){_ in
                                    withAnimation{
                                        self.isInfo = false
                                    }
                                    self.moveAdultCertification()
                                }
                            }
                            .background(Color.brand.bg)
                        }
                        if isfail {
                            VStack(alignment:.leading , spacing:0) {
                                AdultAlert(
                                    text: String.alert.adultCertificationNotAllowed,
                                    useCertificationBtn: false)
                                    .modifier(MatchParent())
                                FillButton(
                                    text: String.app.confirm ,
                                    isSelected: true
                                ){_ in
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                }
                            }
                            .background(Color.brand.bg)
                        
                        }
                    }
                }//vstack
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .opacity(self.isAlert ? 0.01 : 1)
            }//draging
            
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    if method == WebviewMethod.bpn_setIdentityVerfResult.rawValue {
                        if let jsonData = json?.parseJson() {
                            if let cid = (jsonData["ci"] as? String) {
                                withAnimation{
                                    if let isAdult = jsonData["adult"] as? Bool {
                                        self.isfail = !isAdult
                                    } else {
                                        self.isfail = true
                                    }
                                    self.isInfo = false
                                }
                                if self.isfail { return }
                                
                                self.cid = cid
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifySuccess, String.alert.identifySuccessAdult, nil)
                                
                                self.repository.updateAdultAuth(able:true)
                                if let page = self.movePage {
                                    if page.isPopup {
                                        self.pagePresenter.openPopup(page)
                                    } else {
                                        self.pagePresenter.changePage(page)
                                    }
                                }
                                self.pagePresenter.closePopup(self.pageObject?.id)
                                
                            }else{
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            }
                        }else{
                            self.appSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            
                        }
                    }
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                self.marginBottom = bottom
            }
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let eventId = obj.getParamValue(key: .id) as? String {
                    self.eventId = eventId
                }
                if let data = obj.getParamValue(key: .data) as? PageObject {
                    self.movePage = data
                }
                if let isAlert = obj.getParamValue(key: .isAlert) as? Bool {
                    self.isAlert = isAlert
                    if isAlert {
                        self.isInfo = false
                        self.appSceneObserver.alert = .confirm(
                            String.pageTitle.certificationAdult, String.alert.identifyAdultConfirm){ isOk in
                                if isOk {
                                    self.isInfo = true
                                    withAnimation{
                                        self.isAlert = false
                                    }
                                    
                                } else {
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                }
                            }
                    }
                }
            }
            .onDisappear{
                let result:PageEventType = self.cid == nil ? .cancel : .completed
                self.pagePresenter.onPageEvent(
                    self.pageObject, event: .init(id: self.eventId ?? "", type: result)
                )
            }
            
        }//geo
    }//body
    private func moveAdultCertification(){
        let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.identity
        self.webViewModel.request = .link(linkUrl)
    }
    
   
}

#if DEBUG
struct PageAdultCertification_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAdultCertification().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
