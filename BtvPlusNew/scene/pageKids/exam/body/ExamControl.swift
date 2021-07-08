//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension ExamControl {
    static let bgSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 223, height: 667) : CGSize(width: 138, height: 365)
    
    static let bodySize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 223, height: 667) : CGSize(width: 138, height: 307)

}

struct ExamControl: PageComponent{
   
    var body: some View {
        ZStack(alignment: .topLeading){
            Image( AssetKids.exam.answerBg)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: Self.bgSize.width, height: Self.bgSize.height)
                .padding(.top ,Self.bodySize.height - Self.bgSize.height)
            VStack( spacing: DimenKids.margin.light ){
                SoundBox()
                    .padding(.trailing, SystemEnvironment.isTablet ? 28 : 32)
                AnswerBox(right: 0, answer: 1, exNum: 3){ answer in
                    
                }
                
            }
            .frame(width: Self.bodySize.width, height: Self.bodySize.height)
            ExamResultBox(right: 0, answer: 1)
                .padding(.leading ,
                         Self.bodySize.width - ExamResultBox.size.width
                         - (SystemEnvironment.isTablet ? 28 : 32)
                )
        }
        .frame(width: Self.bodySize.width, height: Self.bodySize.height)
    }
}

#if DEBUG
struct ExamControl_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ExamControl(
               
            )
            .frame(width: 400, height: 700)
        }
    }
}
#endif
