//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct ConnectButton: View {
    let image:String
    let title:String
    let text:String
    var tip:String? = nil
    let action: () -> Void
   
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(spacing:0){
                Image( self.image )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                    .padding(.leading, Dimen.margin.lightExtra)
                VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                    Text(self.title)
                        .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.white))
                        
                    Text(self.text)
                        .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.greyLightExtra))
                    if let tip = self.tip {
                        Text(tip)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.grey))
                            .padding(.top,  Dimen.margin.tinyExtra)
                    }
                }
                .padding(.horizontal, Dimen.margin.lightExtra)
                Spacer()
                Image( Asset.icon.more )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
            }
        }//btn
        .modifier( MatchHorizontal(height: Dimen.button.heavy + ( self.tip == nil ? 0 : (Dimen.margin.regular))) )
        .background(Color.app.blueLightExtra.opacity(0.2))
        .overlay(
            Rectangle().strokeBorder(Color.app.blueLightExtra,lineWidth: 2)
        )
    }//body
}

struct ConnectButtonTablet: View {
    let image:String
    let title:String
    let text:String
    var tip:String? = nil
    let action: () -> Void
   
    var body: some View {
        VStack(alignment: .leading , spacing: Dimen.margin.tinyExtra){
            Button(action: {
                self.action()
            }) {
                VStack(alignment: .leading, spacing:0){
                    Image( self.image )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                       
                    Spacer().modifier(MatchHorizontal(height: Dimen.margin.thin))
                    HStack(spacing:Dimen.margin.tinyExtra){
                        Text(self.title)
                            .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.white))
                        Image( Asset.icon.more )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                    Text(self.text)
                        .modifier(BoldTextStyle(size: Font.size.micro, color: Color.app.greyLightExtra))
                        .padding(.top,  Dimen.margin.tinyExtra)
                    
                }
                .padding(.all, Dimen.margin.thin)
            }//btn
            .frame(width: 242, height: 180)
            .background(Color.app.blueLightExtra.opacity(0.2))
            .overlay(
                Rectangle().stroke(Color.app.blueLightExtra,lineWidth: 2)
            )
            if let tip = self.tip {
                Text(tip)
                    .modifier(MediumTextStyle(size: Font.size.microExtra, color: Color.app.grey))
                    .padding(.top,  Dimen.margin.tinyExtra)
            }
        }
    }//body
}


#if DEBUG
struct ConnectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ConnectButton(
                image: Asset.test,
                title: "title",
                text: "test"
            ){
                
            }
            .frame( width: 300)
        }
    }
}
#endif

