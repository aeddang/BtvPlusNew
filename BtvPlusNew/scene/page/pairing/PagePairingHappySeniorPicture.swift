import Foundation
import SwiftUI


struct PagePairingHappySeniorPicture: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    
    @State var title:String? = nil
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
                        title: String.pageText.setupHappySeniorPicture,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    BtvWebView( viewModel: self.webViewModel)
                        .modifier(MatchParent())
                        
                }
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, _, _) :
                    switch method {
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.goBack()
                        break
                    default : break
                    }
                    
                default : break
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                guard let resData = res.data as? NuguPairing else {return}
                var subscriber: Bool = false
                if resData.snr_pairing_yn?.toBool() == true || resData.single_signup_yn?.toBool() == true {
                    if resData.stb_info?.first(where: {$0.recv_snr_gft_yn?.toBool() == true}) != nil {
                        subscriber = true
                    }
                    if !subscriber {
                        if resData.tgt_stb_info?.first(where: {$0.recv_snr_gft_yn?.toBool() == true}) != nil {
                            subscriber = true
                        }
                    }
                }
                if !subscriber {
                    let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.happySeniorUseInfo
                    self.webViewModel.request = .link(linkUrl)
                } else {
                    let deviceId = SystemEnvironment.deviceId
                    let stbId = NpsNetwork.hostDeviceId ?? ""
                    let macAddress = self.pairing.hostDevice?.macAdress ?? ApiConst.defaultMacAdress
                    let time = Date().toDateFormatter(dateFormat: "yyyyMMddHHmmss")
                    let pcid = self.repository.namedStorage?.getPcid() ?? ""
                    let sessionid = self.repository.namedStorage?.getSessionId() ?? ""
                    let appReleaseVersion = SystemEnvironment.bundleVersion
                    let deviceModel = SystemEnvironment.model
                    let clientIp = AppUtil.getIPAddress() ?? "0.0.0.0"
                    let nickname = self.pairing.user?.nickName ?? ""
                    let rawString = "stb_id=\(stbId)&mac_addr=\(macAddress)&pcid=\(pcid)&session_id=\(sessionid)&app_release_version=\(appReleaseVersion)&device_model=\(deviceModel)&manufacturer=Apple&client_ip=\(clientIp)&nickname=\(nickname)"
                
                    guard let key = ApiUtil.shAx("Mobile B tv Application\(deviceId)\(time)") else { return }
                    let iv = Data.init(bytes: key.bytes, count: 16)
                    guard let encString = ApiUtil.getEncyptedString(rawString, key: key, iv: iv) else { return }
                    let prefix = !SystemEnvironment.isStage ? "http://mobilebtv.com:8000" : "http://58.123.205.82:8000"
                    let path = "\(prefix)/?vid=\(encString)&device_id=\(deviceId)&time=\(time)"
                    
                    AppUtil.openURL(path)
                    self.pagePresenter.closePopup(self.pageObject?.id)
                }
            }
            .onReceive(dataProvider.$error) { err in
                if err?.id != self.tag { return }
                
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                self.marginBottom = bottom
                
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.dataProvider.requestData(q: .init(
                        id: self.tag,
                        type: .checkNuguPairing(self.pairing.hostDevice?.convertMacAdress ?? ""), isOptional: false))
                }
            }
            .onAppear{
                self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
                //guard let obj = self.pageObject  else { return }
                //let pushId = obj.getParamValue(key: .pushId) as? String ?? ""
            
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
}

#if DEBUG
struct PagePairingHappySeniorPicture_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingHappySeniorPicture().contentBody
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
