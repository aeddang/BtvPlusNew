//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
extension TopViewerKids {
    static let height:CGFloat = SystemEnvironment.isTablet ? 287 : 153
}


struct TopViewerKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var vsManager:VSManager
    var componentViewModel:SynopsisViewModel?
    var data:SynopsisPackageModel
   
    @State var isPairing:Bool? = nil
  
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment:.bottom) {
                KFImage(URL(string: self.data.image))
                    .resizable()
                    .placeholder {
                        Image(AssetKids.noImg16_9)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
                    .accessibility(hidden: true)
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height:0))
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(AssetKids.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.regularExtra,
                                   height: DimenKids.icon.regularExtra)
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.thin)
                    Spacer()
                    HStack{
                        Spacer()
                        if self.isPairing == false {
                            RectButtonKids(
                                text: String.button.connectBtv,
                                isSelected : true,
                                isFixSize : false
                            ){_ in
                            
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pairing)
                                        .addParam(key: PageParam.subType, value: "mob-com-popup")
                                )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                        } else if self.data.hasAuthority == true {
                            /// 시청가능시
                            
                        } else if self.data.purchaseWebviewModel != nil {
                            RectButtonKids(
                                text: String.button.purchas ,
                                trailText: self.data.salePrice ?? self.data.price,
                                strikeText: self.data.salePrice == nil ? nil : self.data.price,
                                isSelected : true,
                                isFixSize : false
                            ){_ in
                                
                                self.componentViewModel?.uiEvent = .purchase
                                guard let model = self.data.purchaseWebviewModel else {return}
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.purchase)
                                        .addParam(key: .data, value: model)
                                )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                        }
                    }
                }
                .modifier(MatchParent())
            }
            .onReceive(self.pairing.$status){stat in
                self.isPairing = stat == .pairing
            }
            .onAppear{
                
            }
        }
    }//body
}



#if DEBUG
struct TopViewerKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TopViewerKids(
                data:SynopsisPackageModel()
            )
         
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
            
        }.background(Color.blue)
    }
}
#endif

