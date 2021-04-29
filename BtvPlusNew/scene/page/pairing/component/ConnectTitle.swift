//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI
struct ConnectTitle: View {
    let title:String
    
   
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.tiny) {
            Spacer()
                .frame(width:  Dimen.icon.thinExtra, height: Dimen.line.light)
                .background(Color.brand.primary)
            Text(self.title)
                .modifier(BoldTextStyle(
                    size:Font.size.thin,
                    color: Color.brand.primary
                ))
        }
    }//body
}

