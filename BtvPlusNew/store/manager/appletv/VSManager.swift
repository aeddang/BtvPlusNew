//
//  VSsubscriptionManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/13.
//

import Foundation
import VideoSubscriberAccount
import Combine
enum VSFlag {
    case disconnect,
         disconnectTvProviderAndUnpairing, //TV프로바이더 로그아웃후 페어링해재
         disconnectAndSyncTvProvider, //언페어링후 TV프로바이더 로그인과 동기화
         syncTvProvider, //TV프로바이더 로그인과 동기화
         requestTvProvider, // TV프로바이더 모달콜
         unpairingTvProvider // TV프로바이더 로그인 해재 요청 -> 사용자직접
}

class VSManager:NSObject, ObservableObject, PageProtocol,  VSAccountManagerDelegate{
    private let pairing:Pairing
    private let dataProvider:DataProvider
    private var appSceneObserver:AppSceneObserver? = nil
    private var anyCancellable = Set<AnyCancellable>()
    private var redirectFlag:VSFlag? = nil
    
    @Published var isGranted:Bool = false
    private(set) var currentAccountId:String? = nil
    private(set) var currentAccountManagerPresent:UIViewController? = nil
    private var currentAccountManager:VSAccountManager = VSAccountManager()
    init(
        pairing:Pairing,
        dataProvider:DataProvider,
        appSceneObserver:AppSceneObserver? = nil) {
        
        self.pairing = pairing
        self.dataProvider = dataProvider
        self.appSceneObserver = appSceneObserver
        super.init()
        currentAccountManager.delegate = self
        self.setupPairing()
    }
    
    func accountManager(_ accountManager: VSAccountManager, present viewController: UIViewController) {
        DataLog.d( "accountManager present", tag:self.tag)
        let rootVC = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        guard let vc = rootVC else { return }
        vc.present(viewController, animated: true, completion: nil)
        self.currentAccountManagerPresent = viewController
    }
    func accountManager(_ accountManager: VSAccountManager, dismiss viewController: UIViewController) {
        DataLog.d( "accountManager dismiss", tag:self.tag)
        viewController.dismiss(animated: true, completion: nil)
        self.currentAccountManagerPresent = nil
    }
    private func removePresent() {
        DataLog.d( "removePresent", tag:self.tag)
        if let present = self.currentAccountManagerPresent {
            if present.parent != nil { present.dismiss(animated: true, completion: nil) }
        }
        self.currentAccountManagerPresent = nil
    }
    
    func checkAccessStatus(){
        
        self.currentAccountManager.checkAccessStatus(
            options: [VSCheckAccessOption.prompt: true],
            completionHandler: { (status, error) in
                DataLog.d( "status" + status.rawValue.description , tag:self.tag)
                DispatchQueue.main.async {
                    self.isGranted = status == .granted
                    if self.isGranted {
                        let isPairing = self.pairing.status == .pairing
                        self.checkSync(isInterruptionAllowed: !isPairing)
                    } else {
                        if self.pairing.pairingDeviceType == .apple {
                            self.accountPairingSynchronizationDenied()
                        }
                    }
                }
                
        })
    }
    func checkAccess(){
        self.checkAccessStatus()
    }
    
    func accountUnPairingAlert(){
        self.redirectFlag = .disconnectTvProviderAndUnpairing
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountForbiddenUnpairing,
            String.vs.accountTip
        )
    }
    
    private func setupPairing(){
        /*
        self.pairing.$request.sink(receiveValue: { request in
            switch request {
            case .unPairing :
                self.accountUnPairingCheck()
            default: break
            }
        }).store(in: &anyCancellable)
        */
        self.pairing.$event.sink(receiveValue: { evt in
            if self.redirectFlag == nil {return}
            guard let evt = evt else { return }
            switch evt{
            case .pairingRequest :
                DataLog.d("Btv pairingRequest", tag:self.tag)
                SystemEnvironment.tvUserId = nil
                self.currentAccountId = nil
                
            case .pairingCompleted :
                DataLog.d("Btv pairingCompleted", tag:self.tag)
                self.checkSync(isInterruptionAllowed:false)
                
            case .disConnected :
                DataLog.d("Btv disConnected", tag:self.tag)
                self.checkSync(isInterruptionAllowed:false)
                
            case .ready :
                DataLog.d("ready", tag:self.tag)
                self.checkSync(isInterruptionAllowed:false)
           
            default: break
            }
        }).store(in: &anyCancellable)
    }
    
    private func checkSync(isInterruptionAllowed:Bool){
        if !isGranted {return}
        DataLog.d( "checkSync " + self.redirectFlag.debugDescription, tag:self.tag)
        let flag = self.redirectFlag
        self.redirectFlag = nil
        var isPairing = self.pairing.status == .pairing
        if flag == .disconnect && !isPairing {
            DataLog.d( "disconnect Sync completed", tag:self.tag)
            return
        }
        if flag == .unpairingTvProvider && !isPairing {
            DataLog.d( "sync  unpairingTvProvider ", tag:self.tag)
            self.accountUnPairing()
            return
        }
        if flag == .syncTvProvider && !isPairing && self.currentAccountId != nil{
            DataLog.d( "syncTvProvider fail", tag:self.tag)
            self.accountPairingSyncFail()
            return
        }
        
        if flag == .disconnectAndSyncTvProvider{
            DataLog.d( "disconnectAndSyncTvProvider", tag:self.tag)
        }
        
        self.requestVSAccountMetadata(
            isInterruptionAllowed: isInterruptionAllowed ,
            completionHandler: { meta , error in
            DispatchQueue.main.async {
                isPairing = self.pairing.status == .pairing
                self.removePresent()
                if let meta = meta {
                    if let expireDate = meta.authenticationExpirationDate {
                        let now = Date()
                        if expireDate.timeIntervalSince1970 < now.timeIntervalSince1970 {
                            self.accountExpire()
                            DataLog.d( "accountExpire ", tag:self.tag)
                            return
                        }
                    }
                    guard let pair = self.checkMetaData(meta) else {

                        if isPairing {
                            self.accountPairingSynchronization()
                        } else {
                            self.accountPairingMetaError() 
                        }
                        DataLog.d( "error MetaData ", tag:self.tag)
                        return
                    }
                    self.currentAccountId = pair.0
                    if !isPairing {
                        DataLog.d( "accountAutoPairing ", tag:self.tag)
                        self.accountAutoPairing(pairingId:pair.1)
                    } else {
                        DataLog.d( "accountPairingCheck ", tag:self.tag)
                        self.accountPairingCheck(pairingId:pair.1)
                    }
                    
                } else {
                    if isPairing {
                        if flag == .disconnectTvProviderAndUnpairing {
                            self.accountPairingSynchronizationDenied()
                        } else {
                            self.accountPairingSynchronization()
                        }
                       
                    }
                }
            }
        })
        
    }
    
    private func requestVSAccountMetadata(isInterruptionAllowed:Bool, completionHandler:@escaping (VSAccountMetadata?, Error?)->Void){
        let request = VSAccountMetadataRequest()
        request.includeAccountProviderIdentifier = true;
        request.includeAuthenticationExpirationDate = true;
        request.attributeNames = ["appLevelAuth"];
        request.supportedAuthenticationSchemes = [.api];
        request.isInterruptionAllowed = isInterruptionAllowed
        request.supportedAccountProviderIdentifiers = [Bundle.main.bundleIdentifier ?? ""]
        currentAccountManager.enqueue(request,completionHandler: completionHandler)
    }
    
    private func checkMetaData(_ meta:VSAccountMetadata) -> (String, String)?{
        //DataLog.d( "meta " + meta.debugDescription, tag:self.tag)
        let data = meta.accountProviderResponse
        guard let jsonString = data?.body else { return nil }
        guard let json = AppUtil.getJsonParam(jsonString: jsonString) else { return nil }
        guard let userId:String = json["userid"] as? String else { return nil }
        guard let pairingId:String = json["pairingid"] as? String else { return nil }
        return (userId, pairingId)
    }
    
    private func accountExpire(){
        let isPairing = self.pairing.status == .pairing
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountExpirationDate,
            String.vs.accountTip,
            confirmText: isPairing ? String.vs.pairingDisconnect : String.app.confirm){
            if isPairing {
                self.redirectFlag = .disconnect
                self.pairing.requestPairing(.unPairing)
            }
        }
    }
    private func accountPairingSynchronization(){
        //"TV프로바이더 로그인정보와/n현제 페어링 정보가 다릅니다./nTV프로바이더에서 다시 로그인 해주세요"
        self.appSceneObserver?.alert = .confirm(
            String.vs.account,
            String.vs.accountSynchronizationFail,
            String.vs.accountTipDenied,
            confirmText: String.vs.pairingRequestTvProvider,
            cancelText: String.vs.pairingDisconnect
        ){ isOk in
            if isOk {
                self.redirectFlag = .requestTvProvider
                self.checkSync(isInterruptionAllowed:true)
            } else {
                self.redirectFlag = .disconnect
                self.pairing.requestPairing(.unPairing)
            }
        }
    }
    private func accountPairingSynchronizationDifferentStb(){
        //"TV프로바이더 로그인정보와/n현제 페어링 정보가 다릅니다./nTV프로바이더에서 다시 로그인 하거나/nTV프로바이더와 동기화해주세요.";
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountSynchronizationFailDifferentStb,
            String.vs.accountTip,
            confirmText: String.vs.pairingMaintain
        ){
            self.redirectFlag = .disconnectAndSyncTvProvider
            self.pairing.requestPairing(.unPairing)
        }
    }
    
    private func accountPairingSynchronizationDenied(){
        //"TV프로바이더와 연결된/n페어링이 해재됩니다./nTV프로바이더와 다시 연결하시려면/nTV프로바이더 로그인을/n실행해주세요";
        let isPairing = self.pairing.status == .pairing
        if !isPairing {return}
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountSynchronizationDenied,
            String.vs.accountTip,
            confirmText: String.vs.pairingDisconnect
        ){
            self.redirectFlag = .unpairingTvProvider
            self.pairing.requestPairing(.unPairing)
        }
    }
    
    private func accountUnPairing(){
        //"TV프로바이더와 동기화를 위해\n페어링을 해재합니다";
        SystemEnvironment.tvUserId = nil
        self.redirectFlag = .disconnect
        self.appSceneObserver?.event = .toast(String.vs.accountUnPairing)
        self.appSceneObserver?.event = .appReset
    }
    
    private func accountAutoPairing(pairingId:String){
        SystemEnvironment.tvUserId = self.currentAccountId
        self.redirectFlag = .syncTvProvider
        DispatchQueue.main.async {
            self.appSceneObserver?.event = .toast(String.vs.accountAutoPairing)
            self.appSceneObserver?.event = .appReset
        }
    }
    private func accountPairingSyncFail(){
        //"TV프로바이더와 동기화에\n실패했습니다.\nTV프로바이더에서 로그아웃, 재 로그인 후\n다시 시도 해주세요.";
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountAutoPairingFail,
            String.vs.accountTipRetry
        )
    }
    
    private func accountPairingMetaError(){
        //"TV프로바이더와\n동기화에 실패했습니다. 동기화 상태를 확인하시고 다시 시도해주세요."
        self.appSceneObserver?.alert = .alert(
            String.vs.account,
            String.vs.accountAutoPairingError,
            String.vs.accountTipError
        )
    }
    
    private func accountPairingCheck(pairingId:String){
        //"TV프로바이더와 동기화에\n실패했습니다.\nTV프로바이더에서 로그아웃 하거나\n다시 페어링 해주세요.";
        if pairingId != NpsNetwork.pairingId {
            DataLog.d("accountPairingSynchronizationDifferentStb")
            self.accountPairingSynchronizationDifferentStb()
        } else {
            DataLog.d("TvProvider pairing completed")
        }
    }
    
    
    
    
    func registSubscription(){
        /*
        let subscription = VSSubscription()
        subscription.expirationDate = Date.distantFuture
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(subscription)
        */
    }

    func unregistSubscription(){
        /*
        let registrationCenter = VSSubscriptionRegistrationCenter.default()
        registrationCenter.setCurrentSubscription(nil)*/
    }
    
}
