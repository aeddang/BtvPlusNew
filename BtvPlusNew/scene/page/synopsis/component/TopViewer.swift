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
    static let height:CGFloat = 580
}


struct TopViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var sceneObserver:PageSceneObserver

    var data:SynopsisPackageModel
   
    @State var isPairing:Bool? = nil
    var body: some View {
        ZStack(alignment:.bottom) {
            KFImage(URL(string: self.data.image))
                .resizable()
                .placeholder {
                    Image(Asset.noImg9_16)
                        .resizable()
                }
                .cancelOnDisappear(true)
                .loadImmediately()
                .aspectRatio(contentMode: .fit)
                .modifier(MatchParent())
                
            VStack(alignment: .leading, spacing:0){
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
                Spacer()
                if self.isPairing == false {
                    FillButton(
                        text: String.button.connectBtv
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairing)
                        )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                } else if self.data.hasAuthority == true {
                    HStack{
                        Text(String.app.watchAble)
                            .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                    }
                    .padding(.horizontal,  Dimen.margin.thin)
                    .modifier( MatchHorizontal(height:Dimen.button.medium))
                    .overlay(Rectangle().stroke( Color.app.greyExtra , lineWidth: 1 ))
                    
                } else if self.data.purchaseWebviewModel != nil {
                    FillButton(
                        text: String.button.purchas ,
                        trailText: self.data.salePrice ?? self.data.price,
                        strikeText: self.data.salePrice == nil ? nil : self.data.price
                    ){_ in
                        guard let model = self.data.purchaseWebviewModel else {return}
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.purchase)
                                .addParam(key: .data, value: model)
                        )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                }
                /*
                Text(String.app.watchAble)
                    .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                    .padding(.top, Dimen.margin.tinyExtra)
                */
            }
            .modifier(MatchParent())
            .modifier(ContentHorizontalEdges())
        }
        .frame(height:Self.height)
        .onReceive(self.pairing.$status){stat in
            self.isPairing = stat == .pairing
        }
        .onAppear{
           
        }
    }//body
    
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

