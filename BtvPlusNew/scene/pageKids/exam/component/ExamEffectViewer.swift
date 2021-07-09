//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension ExamEffectViewer {
    static let aniSize:CGSize = SystemEnvironment.isTablet
        ? CGSize(width: 282, height: 282) : CGSize(width: 174, height: 174)
    static let size:CGSize = SystemEnvironment.isTablet
        ? CGSize(width: 539, height: 198) : CGSize(width: 292, height: 111)

    static let topMargin:CGFloat = SystemEnvironment.isTablet
        ? 168 : 104
    static let textMargin:CGFloat = SystemEnvironment.isTablet
        ? 112 : 69
}

struct ExamEffectViewer: PageComponent{
    var type:DiagnosticReportType = .english
    var text:String? = nil
    var isComplete:Bool = false
    var completed:(()->Void)? = nil
    var body: some View {
        ZStack(alignment: .center){
            ZStack(alignment: .top){
                Image( self.isComplete ? self.type.completeBg : self.type.startBg)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
                if let text = self.text {
                    Text(text)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.thin,
                                    color:  Color.app.black))
                        .padding(.top, Self.textMargin )
                }
                ImageAnimation(
                    images:  self.isComplete ? AssetKids.ani.testEnd : AssetKids.ani.testStart,
                    isLoof: false,
                    isRunning: .constant( true )){
                    
                    completed?()
                }
                .frame(width: Self.aniSize.width, height: Self.aniSize.height)
                .padding(.top, -Self.topMargin )
                
            }
            .frame(width: Self.size.width, height: Self.size.height)
        }
        .modifier(MatchParent())
        .background(Color.transparent.black70)
    }
}

#if DEBUG
struct ExamEffectViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SoundBox(
               isPlay: true
            )
        }
    }
}
#endif
