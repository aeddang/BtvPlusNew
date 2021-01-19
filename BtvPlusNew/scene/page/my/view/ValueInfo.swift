//
//  ValueInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/19.
//

import Foundation
import SwiftUI
struct ValueInfo: View {
    var key:String
    var value:String
    var body: some View {
        VStack(spacing:Dimen.margin.tinyExtra){
            Text(self.key)
                .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
            Text(self.value)
                .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
        }
    }//body
}


#if DEBUG
struct ValueInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            ValueInfo(
                key: "key", value: "value"
            )
        }
    }
}
#endif
