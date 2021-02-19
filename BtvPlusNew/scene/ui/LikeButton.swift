
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct LikeButton: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    var srisId:String
    @State var isLike:Bool?
    var action: ((_ ac:Bool?) -> Void)? = nil
    var body: some View {
        Button(action: {
            let status = self.pairing.status
            if status != .pairing {
                self.pageSceneObserver.alert = .needPairing()
            }
            else{
                self.pageSceneObserver.alert = .like(self.srisId, self.isLike)
            }
        }) {
            VStack(spacing:0){
                Image(self.isLike == nil ? Asset.icon.like
                    : self.isLike == true ? Asset.icon.likeOn : Asset.icon.likeOff )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                
                Text(String.button.like)
                .modifier(MediumTextStyle(
                    size: Font.size.tiny,
                    color: Color.app.greyLight
                ))
                
            }
        }//btn
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.srisId) { return }
            switch res.type {
            case .registLike: self.regist(res)
            case .getLike: self.setup(res)
            default: do{}
            }
            
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            self.error(err)
        }
        .onReceive(self.pairing.$status){stat in
            switch stat {
            case .pairing: self.load()
            default: do{}
            }
        }
        .onAppear{
            
        }
        
    }//body
        
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
        if data.like == "1" { self.isLike = true }
        else if data.dislike == "1" { self.isLike = false }
        else { self.isLike = nil }
    }
    
    func regist(_ res:ApiResultResponds){
        guard let data = res.data as? RegistLike else {
            return
        }
        if data.like_action == "1" {
            self.isLike = true
            action?(true)
        }
        else if data.like_action == "2" {
            self.isLike = false
            action?(false)
        }else{
            self.isLike = nil
            action?(nil)
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
                srisId: ""
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

