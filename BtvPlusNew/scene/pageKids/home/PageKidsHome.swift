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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
     
    var body: some View {
        ZStack{
            Spacer().modifier(MatchParent())
        }
        .modifier(PageFull(style:.kids))
        .onAppear{
            
            /*
            self.appSceneObserver.alert = .confirm(
                "TITLE",
                "TITLETITLETITLETITLETITLETITLETITLETITLETITLETITLETITLE",
                "TITLE"){ _ in
                
            }
           
            self.appSceneObserver.select =
                .select((self.tag , ["시즌 1", "시즌 1", "시즌 3"]), 1)
            */
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
