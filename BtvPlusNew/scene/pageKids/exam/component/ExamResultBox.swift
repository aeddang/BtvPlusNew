//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension ExamResultBox {
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 390, height: 142) : CGSize(width: 240, height: 88)

}

struct ExamResultBox: PageComponent{
    var right:Int = -1
    var answer:Int = -1
    
    var body: some View {
        ZStack(){
            if self.answer == -1 || self.right == -1 {
                Spacer()
            } else if self.right == self.answer {
                ImageAnimation(
                    images: AssetKids.ani.answer,
                    isLoof: false,
                    isRunning: .constant( true ))
                    .modifier(MatchParent())
            } else {
                ImageAnimation(
                    images: AssetKids.ani.answerWrong,
                    isLoof: false,
                    isRunning: .constant( true ))
                    .modifier(MatchParent())
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }
}

#if DEBUG
struct ExamResultBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ExamResultBox(
                right:2,
                answer:1
            )
        }
    }
}
#endif
