//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

struct EmptyDiagnosticView: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var type:DiagnosticReportType = .english
    var kid:Kid = Kid()
    var action: ((DiagnosticReportType) -> Void)? = nil
    var body: some View {
        VStack(spacing:DimenKids.margin.mediumUltra){
            HStack(spacing:DimenKids.margin.thin){
                Image( self.type.startImage)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame( height: SystemEnvironment.isTablet ? 148 : 91)
                    .padding(.top, DimenKids.margin.thin)
                VStack(alignment: .leading, spacing:DimenKids.margin.tiny){
                    Text(self.type.startText.replace(self.kid.nickName))
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.light, color: Color.app.brownDeep))
                    Text(self.type.startReport)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                        .padding(.top, DimenKids.margin.micro)
                }
            }
            RectButtonKids(
                text: (self.type.name ?? "") + " " + String.kidsText.kidsMyReportStart,
                isSelected: true,
                textModifier: TextModifierKids(
                    family:Font.familyKids.bold,
                    size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin,
                    color: Color.app.brownDeep,
                    activeColor: Color.app.white
                ),
                size: DimenKids.button.mediumRectUltra,
                isFixSize: true
            ){ _ in
                self.action?(self.type)
            }
        }
        
    }//body
}


#if DEBUG
struct EmptyDiagnosticView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            EmptyDiagnosticView()
            .environmentObject(PagePresenter())
        }.background(Color.app.ivory)
    }
}
#endif

