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
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(){
                    PageTab(title: .constant("B tv 연결하기"))
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    ScrollView{
                        VStack{
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                            ConnectButton(
                                image: Asset.test, title: "WIFI", text: "wify"
                            ){
                                pairing.requestPairing(.wifi)
                            }
                        }
                    }
                    .modifier(MatchParent())
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .modifier(PageFull())
            }
            .onAppear{
               
            }
            .onDisappear{
                pairing.requestPairing(.cancel)
            }
            
        }//geo
    }//body

}
