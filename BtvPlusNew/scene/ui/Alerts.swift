//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct InfoAlert: PageView {
    let text:String
    var body: some View {
        HStack(alignment: .center, spacing: Dimen.margin.tinyExtra){
            Image(Asset.icon.alert)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
            Text(text)
                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
        }
    }//body
}

struct EmptyAlert: PageView {
    var text:String = String.alert.dataError
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Spacer().modifier(MatchHorizontal(height:0))
            Image(Asset.icon.alert)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
            Text(text)
                .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.regularExtra)
        }
        .padding(.all, Dimen.margin.medium)
    }//body
}


#if DEBUG
struct EmptyAlert_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            InfoAlert(
                text: "편성 종료 D-7"
            )
        }
        .frame(width: 320)
        .background(Color.brand.bg)
    }
}
#endif

