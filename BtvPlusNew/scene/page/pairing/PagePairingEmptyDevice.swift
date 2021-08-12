//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import CoreLocation

struct PagePairingEmptyDevice: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
   
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
    @State var title:String = String.pageTitle.connectWifi
    @State var info:String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    VStack(alignment:.leading , spacing:0) {
                        Text(String.alert.connectNotFound)
                            .modifier(MediumTextStyle( size: Font.size.bold ))
                            .padding(.top, Dimen.margin.regular)
                            .padding(.horizontal, Dimen.margin.regular )
                            .fixedSize(horizontal: false, vertical:true)
                        if let info = self.info {
                            Text(info)
                                .modifier(MediumTextStyle( size: Font.size.light , color: Color.app.greyLight))
                                .padding(.top, Dimen.margin.regular)
                                .padding(.horizontal, Dimen.margin.regular )
                                .fixedSize(horizontal: false, vertical:true)
                        }
                        Image(Asset.image.deviceEmpty)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .modifier(MatchParent())
                            .padding(.vertical, Dimen.margin.thin)
                        FillButton(
                            text: String.app.close,
                            isSelected: true
                        ){_ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.bottom, self.sceneObserver.safeAreaBottom)
                    }
                    .modifier(MatchParent())
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key:.title ) as? String ?? self.title
                self.info = obj.getParamValue(key:.text ) as? String
            }
        }//geo
    }//body
    
    
    
}



#if DEBUG
struct PagePairingEmptyDevice_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingEmptyDevice().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(LocationObserver())
                .environmentObject(Pairing())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
