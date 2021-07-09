//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI



struct AnswerBox: PageComponent{
    var right:Int = -1
    var answer:Int = -1
    var submit:Int = -1
    var exNum:Int = 3
    var select:((Int) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DimenKids.margin.micro){
            HStack(spacing: DimenKids.margin.micro){
                Image(AssetKids.exam.check)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.microExtra, height: DimenKids.icon.microExtra)
                    .opacity(self.answer == -1 ? 1 : 0)
                
                Text( String.kidsText.kidsExamSelectExample)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.tinyExtra,
                                color:  Color.app.brownDeep.opacity(0.7)))
                    .opacity(self.answer == -1 ? 1 : 0)
            }
            .frame( height: DimenKids.tab.thin)
              
            ForEach(0..<self.exNum) { index in
                if let select = self.select {
                    Button(action: {
                        select(index)
                    }) {
                        AnswerItem(
                            index: index,
                            right: self.right,
                            answer: self.answer,
                            submit: self.submit
                        )
                    }
                } else {
                    AnswerItem(
                        index: index,
                        right: self.right,
                        answer: self.answer,
                        submit: self.submit
                    )
                }
                
            }
            
        }
    }
}

extension AnswerItem {
    static let stroke:CGFloat = DimenKids.stroke.mediumExtra
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 157, height: 103) : CGSize(width: 97, height: 45)
    static let boxSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 173, height: 123) : CGSize(width: 107, height: 57)
    
}

struct AnswerItem: PageComponent{
    var index:Int = 0
    var right:Int = -1
    var answer:Int = -1
    var submit:Int = -1
   
    var body: some View {
        ZStack(alignment: .bottomLeading){
            Image(AssetKids.exam.answer[index])
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                .frame(width: Self.size.width, height: Self.size.height)
                .padding(.all, Self.stroke)
                .opacity(
                    self.submit == -1
                        ? 1.0
                        : self.submit == index ? 1.0 : 0.5)
            if index == self.answer {
                Image(self.right == self.answer ? AssetKids.exam.answerRight : AssetKids.exam.answerWrong)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                    .modifier(MatchParent())
            } else if self.right == index {
                Image(AssetKids.exam.answerRight)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                    .modifier(MatchParent())
            } else {
                Spacer()
                    .frame(width: Self.size.width, height: Self.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: DimenKids.radius.light)
                            .stroke(Color.app.ivoryLight, lineWidth: Self.stroke)
                    )
                    .padding(.all, Self.stroke)
            }
            Spacer().modifier(MatchParent())
        }
        .frame(width: Self.boxSize.width, height: Self.boxSize.height)
    }
}

#if DEBUG
struct AnswerBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            AnswerBox(
                right:-1,
                answer:-1
            )
        }
    }
}
#endif
