//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupPossession: PageView {
    
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    var isInitate:Bool = false
    @State var isPossession:Bool = false
    @State var willPossession:Bool? = nil
    
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupPossession).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isPossession,
                    title: String.pageText.setupPossessionSet,
                    subTitle: String.pageText.setupPossessionSetText
                )
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isPossession].publisher ) { value in
            if !self.isInitate { return }
            if self.willPossession != nil { return }
            let originValue = self.setup.possession.isEmpty == false
            if !value {
                if originValue {
                    self.deletePossession()
                }
            } else {
                if !originValue {
                    self.setupPossession()
                }
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            switch evt.type {
            case .certification :
                if evt.id != "PageCertification" {return}
                if let cid = evt.data as? String {
                    self.setupPossessionCertificationCompleted(cid:cid)
                } else {
                    self.setupPossessionCancel()
                }
            case .selected :
                if let stb = evt.data as? StbData {
                    self.selectedStb(stb)
                } else {
                    self.setupPossessionCancel()
                }
            default : break
            }
        }
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getTerminateStbInfo : self.checkGetPossessionAble(res:res)
            case .connectTerminateStb(let type, _) :
                guard let data = res.data as? ConnectTerminateStb  else {
                    self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
                    self.setupPossessionCancel()
                    return
                }
                switch type {
                case .regist :
                    self.connectedStb(result: data)
                case .delete :
                    self.deletedPossession(result:data)
                case .info :
                    self.connectedInfoStb(result:data)
                }
            default: break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            switch err.type {
            case .getTerminateStbInfo : break
            default: break
            }
        }
        .onAppear(){
            self.isPossession = self.setup.possession.isEmpty == false
        }
    }//body
    
    @State var currentSelectedStb:StbData? = nil
    private func setupPossession(){
        self.willPossession = true
        self.appSceneObserver.alert = .needCertification( 
            String.alert.possession, String.alert.possessionText, String.alert.possessionInfo){
            self.setupPossessionCancel()
        }
    }
    
    private func setupPossessionCancel(){
        self.willPossession = nil
        self.currentSelectedStb = nil
        self.isPossession = (self.setup.possession.isEmpty == false)
        self.pagePresenter.closePopup(pageId: .terminateStb)
    }
    
    private func setupPossessionCertificationCompleted(cid:String){
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getTerminateStbInfo(cid)))
    }
    private func checkGetPossessionAble(res:ApiResultResponds){
        /*
        #if DEBUG
        self.dataProvider.requestData(
            q:.init(id: self.tag,
                    type: .connectTerminateStb(.regist, "{9F63AD24-46EB-11EA-91F5-9D29A492214E}")))
            return
        #endif
        */
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.alert = .alert(String.alert.possessionVodNone, String.alert.possessionStbNone)
            self.setupPossessionCancel()
            return
        }
        guard let stbs = data.data?.stb_infos else {
            self.appSceneObserver.alert = .alert(String.alert.possessionVodNone, String.alert.possessionStbNone)
            self.setupPossessionCancel()
            return
        }
        if stbs.isEmpty {
            self.appSceneObserver.alert = .alert(String.alert.possessionVodNone, String.alert.possessionStbNone)
            self.setupPossessionCancel()
            return
        }
        if stbs.count == 1 {
            self.selectedStb(StbData().setData(data: stbs.first!))
        } else {
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.terminateStb)
                    .addParam(key: .data, value: stbs)
            )
        }
    }
    
    private func selectedStb(_ stb:StbData){
        self.currentSelectedStb = stb
        self.dataProvider.requestData(
            q:.init(id: self.tag,
                    type: .connectTerminateStb(.info, stb.stbid)))
    }
    private func connectedInfoStb(result:ConnectTerminateStb){
        if result.result == ApiCode.success {
            if result.mbtv_key != nil {
                self.appSceneObserver.alert = .confirm(
                    String.alert.possession,
                    String.alert.possessionDiableAlreadyChange)
                { isOk in
                    if isOk {
                        self.dataProvider.requestData(
                            q:.init(id: self.tag,
                                    type: .connectTerminateStb(.delete, nil)))
                    } else {
                        self.setupPossessionCancel()
                    }
                }
            } else {
                self.dataProvider.requestData(
                    q:.init(id: self.tag,
                            type: .connectTerminateStb(.regist, self.currentSelectedStb?.stbid)))
            }
        } else {
            self.appSceneObserver.event = .toast( result.reason ?? String.alert.apiErrorServer )
            self.setupPossessionCancel()
        }
    }
    private func connectedStb(result:ConnectTerminateStb){
        if result.result == ApiCode.success && result.stb_id != nil {
            self.setupPossessionCompleted(result:result)
        } else {
            self.appSceneObserver.event = .toast( result.reason ?? String.alert.apiErrorServer )
            self.setupPossessionCancel()
        }
    }
    
    private func setupPossessionCompleted(result:ConnectTerminateStb){
        self.willPossession = nil
        self.currentSelectedStb = nil
        self.setup.possession = result.stb_id ?? ""
        self.appSceneObserver.event = .toast(
            String.alert.possessionComplete
        )
        self.pagePresenter.closePopup(pageId: .terminateStb)
        self.sendLog(category: String.pageText.setupPossessionSet, config: true)
    }
    
    private func deletePossession(){
        self.willPossession = false
        self.appSceneObserver.alert = .confirm(
            String.alert.possession, String.alert.possessionDeleteConfirm)
        { isOk in
            if isOk {
                self.dataProvider.requestData(
                    q:.init(id: self.tag,
                            type: .connectTerminateStb(.delete, nil)))
            } else {
                self.setupPossessionCancel()
            }
        }
    }
    private func deletedPossession(result:ConnectTerminateStb){
        if result.result == ApiCode.success {
            if willPossession == true {
                self.dataProvider.requestData(
                    q:.init(id: self.tag,
                            type: .connectTerminateStb(.regist, self.currentSelectedStb?.stbid)))
            } else {
                self.deletedPossessionCompleted()
            }
            self.sendLog(category: String.pageText.setupPossessionSet, config: false)
        } else {
            self.appSceneObserver.event = .toast( result.reason ?? String.alert.apiErrorServer )
            self.setupPossessionCancel()
        }
    }
    
    private func deletedPossessionCompleted(){
        self.willPossession = nil
        self.currentSelectedStb = nil
        self.setup.possession = ""
        self.appSceneObserver.event = .toast(
            String.alert.possessionDelete
        )
        self.pagePresenter.closePopup(pageId: .terminateStb)
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickConfigSelection, actionBody: actionBody)
    }
}

#if DEBUG
struct SetupPossession_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupPossession()
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
