
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct BookMarkButton: PageView {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    var type:PageType = .btv
    var componentViewModel:SynopsisViewModel? = nil
    var data:SynopsisData
    var isSimple:Bool = false
    @Binding var isBookmark:Bool?
    var isActive:Bool = true
    var action: ((_ ac:Bool) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            if !self.isActive {return}
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
            }
            else{
                if self.isBookmark == false {
                    self.componentViewModel?.uiEvent = .bookMark(true)
                    self.add() }
                else if self.isBookmark == true {
                    self.componentViewModel?.uiEvent = .bookMark(false)
                    self.delete()
                }
            }
        }) {
            if !self.isSimple{
                if self.type == .btv {
                    VStack(spacing:0){
                        Image( self.isBookmark == true ? Asset.icon.heartOn : Asset.icon.heartOff )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width: Dimen.icon.regular,
                                height: Dimen.icon.regular)
                        
                        Text(String.button.heart)
                        .modifier(MediumTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.greyLight
                        ))
                        .fixedSize(horizontal: true, vertical: false)
                    }
                } else{
                    Image( self.isBookmark == true
                            ? AssetKids.icon.heartOn : AssetKids.icon.heartOff )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(
                            width: DimenKids.icon.light,
                            height: DimenKids.icon.light)
                    
                }
            } else {
                if self.type == .btv {
                    Image( self.isBookmark == true ? Asset.icon.heartSmallOn : Asset.icon.heartSmallOff )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(
                            width: Dimen.icon.regularExtra,
                            height: Dimen.icon.regularExtra)
                } else {
                    Image( self.isBookmark == true
                            ? AssetKids.icon.heartOn : AssetKids.icon.heartOff )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(
                            width: DimenKids.icon.medium,
                            height: DimenKids.icon.medium)
                }
            }
        }//btn
        .opacity(self.isActive ? 1.0 : 0.5)
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            guard let epsdId = self.data.epsdId else { return }
            if !res.id.hasPrefix(epsdId) { return }
            
            guard let result = res.data as? UpdateMetv else {
                self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
                self.isBusy = false
                return
            }
            if result.result != ApiCode.success {
                self.appSceneObserver.event = .toast(result.reason ?? String.alert.apiErrorServer)
                self.isBusy = false
                return
            }
            
            switch res.type {
            case .postBookMark : self.added(res)
            case .deleteBookMark : self.deleted(res)
            default: do{}
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            guard let epsdId = self.data.epsdId else { return }
            if !err.id.hasPrefix(epsdId) { return }
            switch err.type {
                case .postBookMark : self.error(err)
                case .deleteBookMark : self.error(err)
                default: do{}
            }
        }
        
    }//body
    
    @State var isBusy:Bool = false
    func add(){
        if self.isBusy {return}
        guard let epsdId = self.data.epsdId else { return }
        self.isBusy = true
        self.dataProvider.requestData(q: .init(id: epsdId, type: .postBookMark(self.data)))
    }
    
    func delete(){
        if self.isBusy {return}
        guard let epsdId = self.data.epsdId else { return }
        self.isBusy = true
        self.dataProvider.requestData(q: .init(id: epsdId, type: .deleteBookMark(self.data)))
    }
    
    func added(_ res:ApiResultResponds){
        self.isBookmark = true
        action?(true)
        self.isBusy = false
        self.appSceneObserver.event = .toast(String.alert.registBookmark)
        
    }
    
    func deleted(_ res:ApiResultResponds){
        self.isBookmark = false
        action?(false)
        self.isBusy = false
        self.appSceneObserver.event = .toast(String.alert.deleteBookmark)
       
    }
    
    func error(_ err:ApiResultError){
       self.isBusy = false
    }
}

#if DEBUG
struct BookMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BookMarkButton(
                data:SynopsisData(),
                isBookmark: .constant(true)
            ){ ac in
                
            }
            .environmentObject(DataProvider())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

