//
//  EmptySerchList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
import SwiftUI

struct EmptySearchResultKids: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var image:String
    var text:String
    var body: some View {
        VStack(alignment: .leading, spacing:DimenKids.margin.tiny){
            Image(self.image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: SystemEnvironment.isTablet ? 416 : 257,
                       height: SystemEnvironment.isTablet ? 220 : 136)
            
            Text( self.text)
                .modifier(BoldTextStyleKids(size: Font.sizeKids.regular, color:Color.app.brownDeep) )
                .multilineTextAlignment(.center)
            
        }
    }//body
}
