//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension ProgressBox {
    static let infoTextWidth:CGFloat = SystemEnvironment.isTablet ? 150 : 100
}

struct ProgressBox: PageComponent{
    var progress:Int = 0
    var max:Int = 0
    var hold:Int = 2
    var move:((Int) -> Void)? = nil
    
    var body: some View {
        VStack(spacing:0){
            HStack(alignment: .bottom, spacing: 0){
                Image(AssetKids.exam.graphic1)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(height: SystemEnvironment.isTablet ? 123 : 59)
                Spacer()
                Image(AssetKids.exam.graphic2)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(height: SystemEnvironment.isTablet ? 103 : 49)
            }
            .padding(.horizontal, DimenKids.margin.regular)
            HStack(spacing: DimenKids.margin.thin){
                if let move = self.move {
                    Button(action: {
                        if self.progress == 0 {return}
                        move(-1)
                        
                    }) {
                        Image(AssetKids.exam.prev)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width: DimenKids.icon.mediumExtra,
                                height: DimenKids.icon.mediumExtra)
                            .opacity(self.progress == 0 ? 0.5 : 1.0 )
                           
                    }
                }
                Text(self.progress == self.max
                        ? String.kidsText.kidsExamLastQuestion
                        : (self.max-self.progress).description + " " + String.kidsText.kidsExamRemainQuestion
                )
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.tinyExtra,
                            color:  Color.app.brownDeep))
                .frame(width: Self.infoTextWidth ,alignment: .leading)
                
                ExamProgress(value:  Float(progress+1) / Float(max+1))
                    .frame(height:ExamProgress.height)
                Text((progress+1).description + "/" + (max+1).description)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.tinyExtra,
                                color:  Color.app.brownDeep.opacity(0.7)))
                   
                if let move = self.move {
                    Button(action: {
                        move(1)
                    }) {
                        Image(self.progress == self.max ?  AssetKids.exam.exit : AssetKids.exam.next)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width: DimenKids.icon.mediumExtra,
                                height: DimenKids.icon.mediumExtra)
                           
                    }
                } else {
                    if self.hold > 0 {
                        Image(self.progress == self.max
                                ? AssetKids.exam.timerResult[self.hold]
                                : AssetKids.exam.timerNext[self.hold])
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width: DimenKids.icon.mediumExtra,
                                height: DimenKids.icon.mediumExtra)
                    } else {
                        Spacer()
                            .frame(
                                width: DimenKids.icon.mediumExtra,
                                height: DimenKids.icon.mediumExtra)
                    }
                }
            }
            .padding(.vertical, DimenKids.margin.tinyExtra)
            .padding(.horizontal, DimenKids.margin.light)
            .background(Color.app.ivoryDeep)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
        }
    }
}

#if DEBUG
struct ProgressBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ProgressBox(
               progress: 0, max: 2
            )
        }
    }
}
#endif
