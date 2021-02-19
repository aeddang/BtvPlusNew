
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct BtvButton: PageView {
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var id:String
    
    var body: some View {
        Button(action: {
            if self.pairing.status != .pairing {
                self.pageSceneObserver.alert = .needPairing()
            }
            else{
                
            }
        }) {
            VStack(spacing:0){
                Image(  Asset.icon.watchBTv)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                
                Text(String.button.watchBtv)
                .modifier(MediumTextStyle(
                    size: Font.size.tiny,
                    color: Color.app.greyLight
                ))
                
            }
        }//btn
        
    }//body
}

#if DEBUG
struct BtvButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            BtvButton(
                id:""
            )
            .environmentObject(Pairing())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

