//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI
struct ResultReportBottom: PageComponent{
    var date:String
    var retryCount:String
    
    var body: some View {
        HStack(spacing:DimenKids.margin.tiny){
            Text(String.kidsText.kidsMyDiagnosticReportDate)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color:  Color.app.brownDeep))
            Text(self.date)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color:  Color.kids.primaryLight))
            Spacer().modifier(LineVertical(width: 1, color: Color.app.brownDeep, opacity: 0.6))
                .frame(height:Font.sizeKids.thin)
            
            Text(String.kidsText.kidsMyResultRetryCount)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color:  Color.app.brownDeep))
            Text(self.retryCount)
                .modifier(BoldTextStyleKids(
                            size: Font.sizeKids.thin,
                            color:  Color.kids.primaryLight))
            Spacer()
            RectButtonKids(
                text: String.kidsText.kidsMyResultRecommandView,
                icon: AssetKids.icon.medal,
                isSelected: false,
                size: CGSize(width: 0, height: DimenKids.button.regular),
                isFixSize: false){_ in
                
            }
        }
        .modifier(MatchHorizontal(height: DimenKids.button.regular))
    }
}
