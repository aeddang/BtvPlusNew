
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct PlayInfoButton: PageView {
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    
    var body: some View {
        Button(action: {
            
        }) {
            Image(  AssetKids.icon.playInfo)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(
                    width: DimenKids.icon.light,
                    height: DimenKids.icon.light)
        }//btn
        
    }//body
}

#if DEBUG
struct PlayInfoButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PlayInfoButton()
            .environmentObject(Pairing())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

