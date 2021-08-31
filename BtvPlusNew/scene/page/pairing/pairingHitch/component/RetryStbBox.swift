//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI


struct RetryStbBox: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    var datas:[StbData]? = nil
    var info:PairingInfo? = nil
    var selected:StbData? = nil
    let select: (StbData) -> Void
    let action: (StbData) -> Void
    let close: () -> Void
    var body: some View {
        VStack(spacing: 0){
            VStack(spacing: Dimen.margin.micro){
                Text(String.pairingHitch.fullTop)
                    .modifier( BoldTextStyle(
                            size: Font.size.regular,
                            color: Color.app.blackExtra)
                    )
                HStack( spacing: 0){
                    Text(String.pairingHitch.fullLeading)
                        .modifier( BoldTextStyle(
                                size: Font.size.regular,
                                color: Color.app.blackExtra)
                        )
                    Text((info?.count?.description ?? "??") + String.pairingHitch.fullCenter)
                        .modifier( BoldTextStyle(
                                size: Font.size.regular,
                                color: Color.brand.primary)
                        )
                    Text(String.pairingHitch.fullTrailing)
                        .modifier( BoldTextStyle(
                                size: Font.size.regular,
                                color: Color.app.blackExtra)
                        )
                }
            }
            .padding(.top, Dimen.margin.medium)
            Text(String.pairingHitch.full.replace(info?.count?.description ?? "??"))
                .modifier( MediumTextStyle(
                        size: Font.size.thin,
                        color: Color.app.blackExtra)
                )
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.light)
            if let datas = self.datas {
                HStack( spacing: Dimen.margin.tiny){
                    ForEach( datas[0..<min(datas.count,3)]) { data in
                        HitchStbItem(
                            data: data,
                            isSelected:self.selected?.id == data.id)
                        .frame(
                            width: SystemEnvironment.isTablet ? 122 : 96,
                            height: SystemEnvironment.isTablet ? 122 : 96)
                        .onTapGesture {
                            self.select(data) 
                        }
                    }
                }
                .padding(.top, Dimen.margin.regularExtra)
            }
            HStack(spacing:0){
                FillButton(
                    text: String.app.cancel,
                    isSelected: true ,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    bgColor:Color.brand.secondary
                ){_ in
                    self.close()
                }
                FillButton(
                    text: String.app.confirm,
                    isSelected: true,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    margin: 0,
                    bgColor:Color.brand.primary
                ){_ in
                    guard let sel = self.selected  else {return}
                    self.action(sel)
                }
            }
            .padding(.top, Dimen.margin.regularExtra)
        }
        
    }//body
}


#if DEBUG
struct RetryStbBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RetryStbBox(
                datas: [StbData()],
                select: { _ in
                    
                },
                action:{ _ in
                    
                },
                close:{
                    
                }
            )
            .frame( width: 300)
        }
    }
}
#endif

