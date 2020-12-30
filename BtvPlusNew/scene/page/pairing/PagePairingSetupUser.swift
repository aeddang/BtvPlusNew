//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePairingSetupUser: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var title:String? = nil
    @State var pairingType:PairingRequest = .wifi
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.$title,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ScrollView{
                        VStack(alignment:.leading , spacing:0) {
                            VStack(alignment:.leading , spacing:0) {
                                Text(String.pageText.pairingText1)
                                    .modifier(MediumTextStyle( size: Font.size.bold ))
                                    .padding(.top, Dimen.margin.light)
                                
                                ZStack{
                                    Text(String.pageText.pairingText2_1)
                                        .font(.custom(Font.family.bold, size: Font.size.light))
                                        .foregroundColor(Color.brand.primary)
                                    + Text(String.pageText.pairingText2_2)
                                        .font(.custom(Font.family.bold, size: Font.size.light))
                                        .foregroundColor(Color.app.whiteDeep)
                                }
                                .padding(.top, Dimen.margin.lightExtra)
                                Text(String.pageText.pairingText2_3)
                                    .font(.custom(Font.family.bold, size: Font.size.light))
                                    .foregroundColor(Color.app.whiteDeep)
                                Text(String.pageText.pairingText2_4)
                                    .font(.custom(Font.family.bold, size: Font.size.light))
                                    .foregroundColor(Color.app.whiteDeep)
                                

                            }.modifier(ContentHorizontalEdges())
                            
            
                        }
                    }
                    .modifier(ContentHorizontalEdges())
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
                guard let obj = self.pageObject  else { return }
                self.pairingType = (obj.getParamValue(key: .type) as? PairingRequest) ?? self.pairingType
                
                switch self.pairingType {
                case .btv : self.title = String.pageTitle.connectCertificationBtv
                case .user : self.title = String.pageTitle.connectCertificationUser
                default : self.title = String.pageTitle.connectWifi
                }
                
                
            }
            .onDisappear{
                pairing.requestPairing(.cancel)
            }
            
        }//geo
    }//body

}

#if DEBUG
struct PagePairingSetupUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingSetupUser().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
