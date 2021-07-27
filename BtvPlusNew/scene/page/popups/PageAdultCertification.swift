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
    @State var useTracking:Bool = false
    @State var movePage:PageObject? = nil
    @State var isInfo:Bool = true
    @State var isfail:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: isfail ? String.alert.adultCertificationFail : String.alert.adultCertification,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .web(isDragEnd: true),
                            isRecycle:false,
                            useTracking:self.useTracking
                        ){
                            BtvWebView( viewModel: self.webViewModel )
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    self.webViewHeight = geometry.size.height
                                        - Dimen.app.top
                                        - self.sceneObserver.safeAreaTop
                                        - self.sceneObserver.safeAreaBottom
                                }
                        }
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
                                    let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.identity
                                    self.webViewModel.request = .link(linkUrl)
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
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                    .modifier(MatchParent())
                    
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :
                            self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pullCancel(geometry)
                        default : do{}
                        }
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    if method == WebviewMethod.bpn_setIdentityVerfResult.rawValue {
                        if let jsonData = json?.parseJson() {
                            if (jsonData["ci"] as? String) != nil {
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifySuccess, String.alert.identifySuccessMe, nil)
                                
                                withAnimation{
                                    if let isAdult = jsonData["adult"] as? Bool {
                                        self.isfail = !isAdult
                                    } else {
                                        self.isfail = true
                                    }
                                    self.isInfo = false
                                }
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
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? PageObject {
                    self.movePage = data
                }
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
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
