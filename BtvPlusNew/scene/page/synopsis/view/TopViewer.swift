//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI




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
                    
                } else if self.data.hasAuthority == false {
                    HStack{
                        Text(String.app.watchAble)
                            .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                    }
                    .padding(.horizontal,  Dimen.margin.thin)
                    .modifier( MatchHorizontal(height:Dimen.button.medium))
                    .overlay(Rectangle().stroke( Color.app.greyExtra , lineWidth: 1 ))
                    
                } else {
                    FillButton(
                        text: String.button.purchas + " " + (self.data.salePrice ?? "")
                    ){_ in
                        
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                }
                Text(String.app.watchAble)
                    .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                    .padding(.top, Dimen.margin.tinyExtra)
            }
            .modifier(ContentHorizontalEdges())
        }
        .frame(height:580)
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

