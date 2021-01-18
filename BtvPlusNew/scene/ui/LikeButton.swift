
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
    var id:String
    @Binding var isLike:Bool?
    var action: ((_ ac:Bool) -> Void)? = nil
    
    
    var body: some View {
        Button(action: {
            let status = self.pairing.status
            if status != .pairing {
                self.pageSceneObserver.alert = .needPairing
            }
            else{
                
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
            //ComponentLog.d("onReceive " + res.id , tag: self.tag)
            //ComponentLog.d("onReceive self.apiId " + self.apiId , tag: self.tag)
            /*
            if !res.id.hasPrefix(self.apiId) { return }
            switch res.type {
            case .heartDelete(let type, _): self.deleted(res, type:type)
            case .heartAdd(let type, _): self.added(res, type:type)
            default: do{}
            }
            */
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            /*
            if !err.id.hasPrefix(self.apiId) { return }
            switch err.type {
                case .heartDelete(let type, _): self.error(err, type:type)
                case .heartAdd(let type, _): self.error(err, type:type)
                default: do{}
            }
             */
        }
        
    }//body
    
    @State var isBusy:Bool = true
    func add(){
        self.isBusy = true
        
    }
    
    func delete(){
        self.isBusy = true
        
    }
    
    func added(_ res:ApiResultResponds, type:ApiValue){
        self.isLike = true
        action?(true)
    }
    
    func deleted(_ res:ApiResultResponds, type:ApiValue){
        self.isLike = true
        action?(false)
    }
    
    func error(_ err:ApiResultError, type:ApiValue){
       self.isBusy = false
    }
}

#if DEBUG
struct LikeButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            LikeButton(
                id:"",
                isLike:.constant(true)
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

