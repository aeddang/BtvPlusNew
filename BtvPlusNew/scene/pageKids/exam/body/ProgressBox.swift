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
    @ObservedObject var viewModel:KidsExamModel = KidsExamModel()
    
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
                    if self.hold >= 0 {
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
        .onReceive(self.viewModel.$event){evt in
            switch evt {
            case .ready(let max):
                self.max = max
            case .quest(let step, _ ) :
                withAnimation{
                    self.hold = -1
                    self.progress = step
                }
            case .hold(let count) :
                withAnimation{
                    self.hold = count
                }
            default : break
            }
        }
    }
    @State var progress:Int = 0
    @State var max:Int = 0
    @State var hold:Int = -1
}

#if DEBUG
struct ProgressBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ProgressBox(
               progress: 1, max: 2
            )
        }
    }
}
#endif
