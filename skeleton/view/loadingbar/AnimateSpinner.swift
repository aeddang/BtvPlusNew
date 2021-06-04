//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct AnimateSpinner: PageView {
    @Binding var isAnimating: Bool
    var body: some View {
        ImageAnimation(
            images: AssetKids.ani.loading,
            isRunning: self.$isAnimating
            )
            .modifier(MatchParent())
    }//body
    

}

#if DEBUG
struct AnimateSpinner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            AnimateSpinner(isAnimating: .constant(true)).contentBody
               
                .frame(width: 227, height: 276, alignment: .center)
        }
    }
}
#endif
