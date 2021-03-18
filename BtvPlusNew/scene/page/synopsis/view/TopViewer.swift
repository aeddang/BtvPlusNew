//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

extension TopViewer {
    static let height:CGFloat = 580
}


struct TopViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var sceneObserver:SceneObserver

    var data:SynopsisPackageModel
   
    @State var isPairing:Bool? = nil
    var body: some View {
        ZStack(alignment:.bottom) {
            ImageView(url:self.data.image, contentMode: .fill, noImg: Asset.noImg9_16)
                .modifier(MatchParent())
            VStack(alignment: .leading, spacing:0){
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
            .environmentObject(SceneObserver())
            .environmentObject(Pairing())
            
        }.background(Color.blue)
    }
}
#endif

