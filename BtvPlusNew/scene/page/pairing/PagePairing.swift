//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct PagePairing: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    
    
    var body: some View {
        VStack(){
            PageTab(title: .constant("B tv 연결하기"))
                .padding(.top, self.sceneObserver.safeAreaTop)
            ConnectButton(
                image: Asset.test, title: "WIFI", text: "wify"
            ){
                pairing.requestPairing(.wifi)
            }
            Spacer()
        }
        .modifier(PageFull())
        .onAppear{
           
        }
        .onDisappear{
            pairing.requestPairing(.cancel)
        }
        
    }//body

}
