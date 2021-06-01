//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI



struct PageKidsHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var body: some View {
        VStack{
            KidsTopTab()
                .modifier(MatchHorizontal(height: 100))
            Spacer().modifier(MatchParent())
        }
        .padding(.all, DimenKids.margin.medium)
        .modifier(PageFull(style:.kids))
        .onAppear{
        
        }
    }//body
    

}

#if DEBUG
struct PageKidsHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
