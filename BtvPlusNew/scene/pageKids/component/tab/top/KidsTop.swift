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
    static let height:CGFloat = Self.marginTop + DimenKids.app.gnbTop + DimenKids.app.top
}
struct KidsTop: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var positionTop:CGFloat = 0
    @State var useGnb:Bool = true
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            KidsTopTab()
                .frame( height: DimenKids.app.top)
            KidsGnb()
                .frame( height: self.useGnb ? DimenKids.app.gnbTop : 0)
                .opacity(self.useGnb ? 1 : 0)
        }
        .modifier(ContentHorizontalEdgesKids())
        .padding(.top, Self.marginTop + self.positionTop)
        .background(Color.app.white)
        .onReceive (self.appSceneObserver.$useGnb) { use in
            withAnimation{
                self.useGnb = use
            }
           
        }
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
