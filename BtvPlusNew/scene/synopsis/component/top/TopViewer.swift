//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
extension TopViewer {
    static let height:CGFloat = SystemEnvironment.isTablet ? 824 : 560
    static let imgRatio:CGFloat = 1016/750
    static let bottomHeight:CGFloat = Dimen.button.medium + Dimen.margin.thin//  하단 사이즈
}

struct TopViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var vsManager:VSManager
    var componentViewModel:SynopsisViewModel?
    var data:SynopsisPackageModel
   
    @State var isPairing:Bool? = nil
  
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment:.top) {
                if SystemEnvironment.isTablet {
                    ZStack{
                        KFImage(URL(string: self.data.bg))
                            .resizable()
                            .placeholder {
                                Image(Asset.noImg9_16)
                                    .resizable()
                            }
                            .cancelOnDisappear(true)
                            .aspectRatio(contentMode: .fill)
                            .modifier(MatchParent())
                            .clipped()
                        VStack(spacing:0){
                            Spacer()
                            LinearGradient(
                                gradient:Gradient(colors: [Color.app.blueDeep.opacity(0), Color.app.blueDeep]),
                                startPoint: .top, endPoint: .bottom)
                                .modifier(MatchHorizontal(height: 100))
                        }
                        .allowsHitTesting(false)
                    }
                    .accessibility(hidden: true)
                }
                
                KFImage(URL(string: self.data.image))
                    .resizable()
                    .placeholder {
                        Image(Asset.noImg9_16)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .accessibility(hidden: true)
                    .aspectRatio(contentMode: SystemEnvironment.isTablet ? .fit : .fill)
                    .modifier(MatchParent())
                    .padding(.bottom, self.data.hasAuthority
                                ? 0
                                : SystemEnvironment.isTablet ? Dimen.button.regular : Self.bottomHeight)
                    
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height:0))
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .modifier(ContentHorizontalEdges())
                    Spacer()
                    if self.data.hasAuthority == false {
                        VStack(alignment: .leading, spacing:0){
                            if self.isPairing == false {
                                FillButton(
                                    text: String.button.connectBtv
                                ){_ in
                                
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.pairing)
                                            .addParam(key: PageParam.subType, value: "mob-com-popup")
                                    )
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                            } else if self.data.purchaseWebviewModel != nil {
                                FillButton(
                                    text: String.button.purchas ,
                                    trailText: self.data.salePrice ?? self.data.price,
                                    strikeText: self.data.salePrice == nil ? nil : self.data.price
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
                        .padding(.horizontal, SystemEnvironment.isTablet
                                    ? self.getContententMargin(geo: geometry) : Dimen.margin.thin)
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
    
    func getContententMargin(geo:GeometryProxy) -> CGFloat {
        let contententHeight:CGFloat = geo.size.height
            - (SystemEnvironment.isTablet ? Dimen.button.regular : 0)
        let contententWidth:CGFloat = contententHeight / Self.imgRatio
        
        return round((geo.size.width - contententWidth) / 2)
    }
    
}



#if DEBUG
struct TopViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TopViewer(
                data:SynopsisPackageModel()
            )
         
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
            
        }.background(Color.blue)
    }
}
#endif

