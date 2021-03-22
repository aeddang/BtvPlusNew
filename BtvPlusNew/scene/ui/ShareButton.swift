
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct ShareButton: PageView {
    var id:String
    
    var body: some View {
        Button(action: {
            
        }) {
            VStack(spacing:0){
                Image(  Asset.icon.share)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimen.icon.regular,
                        height: Dimen.icon.regular)
                
                Text(String.button.share)
                .modifier(MediumTextStyle(
                    size: Font.size.tiny,
                    color: Color.app.greyLight
                ))
                
            }
        }//btn
        
    }//body
}

#if DEBUG
struct ShareButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ShareButton(
                id:""
            )
            .environmentObject(AppSceneObserver())
        }
    }
}
#endif

