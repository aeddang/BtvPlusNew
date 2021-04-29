//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct MoreInfoButton: View {
    let title:String
    var textSize:CGFloat = Font.size.thin
    var image:String = Asset.icon.alertSmall
    let action: () -> Void
   
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(spacing:Dimen.margin.tiny){
                Image( self.image )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                Text(self.title)
                    .modifier(MediumTextStyle(size: self.textSize, color: Color.app.white))
                Image( Asset.icon.moreSmall )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.tinyExtra, height: Dimen.icon.tinyExtra)
            }
        }//btn
    }//body
}


#if DEBUG
struct MoreInfoButton_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            MoreInfoButton(
                title: "title"
            ){
                
            }
        }.background(Color.blue)
    }
}
#endif

