
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct AlramButton: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    var srisId:String
    @Binding var isAlram:Bool?
    var action: ((_ ac:Bool) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            let status = self.pairing.status
            if status != .pairing {
                self.pageSceneObserver.alert = .needPairing()
            }
            else{
                
            }
        }) {
            VStack(spacing:0){
                Image( self.isAlram == true ? Asset.icon.alarmOn
                        : Asset.icon.alarmOff )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                
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
            if !self.isInit { return }
            switch stat {
            case .pairing:
                if self.isAlram == nil { self.load() }
            default:
                self.isAlram = false
            }
        }
        .onAppear{
            if self.pairing.status == .pairing {
                if self.isAlram == nil { self.load() }
            }
            self.isInit = true
        }
        
    }//body
        
    @State var isInit:Bool = false
    func load(){
        /*
        self.dataProvider.requestData(
            q: .init(
                id: self.srisId,
                type: .getLike(self.srisId, self.pairing.hostDevice),
            isOptional: true)
        )
        */
    }
        
   
    func setup(_ res:ApiResultResponds){
        /*
        guard let data = res.data as? Like else { return }
        if data.like == "1" { self.isLike = .like }
        else if data.dislike == "1" { self.isLike = .unlike }
        else { self.isLike = .unkowned }
        */
    }
    
    func regist(_ res:ApiResultResponds){
        guard let data = res.data as? RegistLike else {
            return
        }
        
    }
    
    func error(_ err:ApiResultError){
       
    }
}

#if DEBUG
struct AlramButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            AlramButton (
                srisId: "",
                isAlram: .constant(true)
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

