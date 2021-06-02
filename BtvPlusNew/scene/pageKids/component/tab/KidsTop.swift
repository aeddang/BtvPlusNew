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
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            KidsTopTab()
                .frame( height: DimenKids.app.top)
                .modifier(KidsContentHorizontalEdges())
            KidsGnb()
                .frame( height: DimenKids.app.gnbTop)
                .modifier(KidsContentHorizontalEdges())
        }
        .padding(.top, Self.marginTop)
        .padding(.leading, self.sceneObserver.safeAreaStart)
        .padding(.trailing,self.sceneObserver.safeAreaEnd)
        .background(Color.app.white)
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidsTop_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsTop().environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
