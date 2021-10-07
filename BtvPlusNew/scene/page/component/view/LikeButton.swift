
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

enum LikeStatus :String {
    case like, unlike, unkowned
    
    var boolType: Bool? {
        switch self {
        case .like : return true
        case .unlike : return false
        default: return nil
        }
    }
}


struct LikeButton: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @EnvironmentObject var pairing:Pairing
    var playBlockModel:PlayBlockModel? = nil
    var componentViewModel:SynopsisViewModel? = nil
    var srisId:String
    @Binding var isLike:LikeStatus?
    var useText:Bool = true
    var isThin:Bool = false
    var isActive:Bool = true
    var isPreview:Bool = false
    var action: ((_ ac:LikeStatus?) -> Void)? = nil
    var body: some View {
        Button(action: {
            if !self.isActive {return}
            let status = self.pairing.status
            if status != .pairing {
                self.appSceneObserver.alert = .needPairing()
            }
            else{
                self.appSceneObserver.alert = .like(self.srisId, self.isLike?.boolType, isPreview:self.isPreview)
                self.playBlockModel?.logEvent = .like(nil)
                self.componentViewModel?.uiEvent = .like("")
            }
        }) {
            VStack(spacing:0){
                Image(self.isLike == nil || self.isLike == .unkowned
                        ? self.isThin ? Asset.icon.likeThin : Asset.icon.like
                        : self.isLike == .like ? Asset.icon.likeOn : Asset.icon.likeOff )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                if self.useText {
                    Text(String.button.like)
                    .modifier(MediumTextStyle(
                        size: Font.size.tiny,
                        color: Color.app.greyLight
                    ))
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }//btn
        .opacity(self.isActive ? 1.0 : 0.5)
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.srisId) { return }
            switch res.type {
            case .registLike: self.regist(res)
            case .getLike: self.setup(res)
            default: break
            }
            
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            self.error(err)
        }
        .onReceive(self.pairing.$status){stat in
            if !self.isInit { return }
            switch stat {
            case .pairing:
                ComponentLog.d("self.pairing.$status " + self.isLike.debugDescription, tag:self.tag)
                if self.isLike == nil { self.load() }
            default:
                ComponentLog.d("self.unpairing.$status " + self.isLike.debugDescription, tag:self.tag)
                self.isLike = nil
            }
        }
        .onAppear{
            if self.pairing.status == .pairing {
                ComponentLog.d("onAppear " + self.isLike.debugDescription, tag:self.tag)
                if self.isLike == nil { self.load() }
            }
            self.isInit = true
        }
        
    }//body
        
    @State var isInit:Bool = false
    func load(){
        self.isLike = nil
        self.dataProvider.requestData(
            q: .init(
                id: self.srisId,
                type: .getLike(self.srisId, self.pairing.hostDevice),
            isOptional: true)
        )
    }
        
   
    func setup(_ res:ApiResultResponds){
        guard let data = res.data as? Like else { return }
        if data.like == "1" { self.isLike = .like }
        else if data.dislike == "1" { self.isLike = .unlike }
        else { self.isLike = .unkowned }
        action?(self.isLike)
    }
    
    func regist(_ res:ApiResultResponds){
        guard let data = res.data as? RegistLike else {
            self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
            return
        }
        if data.result != ApiCode.ok {
            self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
            return
        }
        
        if data.like_action == "1" {
            self.isLike = .like
            action?(self.isLike)
            self.playBlockModel?.logEvent = .like(true)
            self.componentViewModel?.uiEvent = .like("like")
        }
        else if data.like_action == "2" {
            self.isLike = .unlike
            action?(self.isLike)
            self.playBlockModel?.logEvent = .like(false)
            self.componentViewModel?.uiEvent = .like("dislike")
        }else{
            self.isLike = .unkowned
            action?(self.isLike)
            self.playBlockModel?.logEvent = .like(nil)
            self.componentViewModel?.uiEvent = .like("-")
        }
    }
    
    func error(_ err:ApiResultError){
       
    }
}

#if DEBUG
struct LikeButton_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            LikeButton (
                srisId: "",
                isLike: .constant(.like)
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

