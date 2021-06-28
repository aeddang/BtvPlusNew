//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension KidsTop {
    static let marginTop:CGFloat = DimenKids.margin.thin
}
struct KidsTop: PageComponent{
   
    @EnvironmentObject var sceneObserver:PageSceneObserver
  
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            KidsTopTab()
                .frame( height: DimenKids.app.top)
            KidsGnb()
                .frame( height: DimenKids.app.gnbTop)
        }
        .modifier(ContentHorizontalEdgesKids())
        .padding(.top, Self.marginTop)
        .background(Color.app.white)
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidsTop_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsTop().environmentObject(PageSceneObserver()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
