//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

struct CommentBox: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var icon:String = AssetKids.image.resultDiagnostic
    var text:String? = nil
    var comment:String? = nil
    var comments:[CommentData] = []
    var action: () -> Void
   
    var body: some View {
        VStack(spacing:0){
            Image( self.icon )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(
                    width: DimenKids.item.reportComment.width,
                    height:  DimenKids.item.reportComment.height)
            if let text = self.text {
                Text(text)
                    .modifier(BoldTextStyleKids(
                        size: SystemEnvironment.isTablet ? Font.sizeKids.tinyExtra : Font.sizeKids.tiny,
                        color:  Color.app.brownDeep))
                    .padding(.top, DimenKids.margin.tiny)
            } else if let text = self.comment {
                Text(text)
                    .modifier(BoldTextStyleKids(
                        size: SystemEnvironment.isTablet ? Font.sizeKids.thinExtra : Font.sizeKids.lightExtra,
                        color:  Color.app.brownDeep))
                    .padding(.top, DimenKids.margin.tiny)
            } else if let text = self.comments.first?.text {
                Text(text)
                    .modifier(BoldTextStyleKids(
                        size: SystemEnvironment.isTablet ? Font.sizeKids.thinExtra : Font.sizeKids.lightExtra,
                        color:  Color.app.brownDeep))
                    .padding(.top, DimenKids.margin.tiny)
            }
            RectButtonKids(
                text: String.kidsText.kidsMyResultCommentView,
                isSelected: true,
                textModifier: BoldTextStyleKids(
                    size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.lightExtra,
                    color: Color.app.white).textModifier,
                size: SystemEnvironment.isTablet ? DimenKids.button.regularUltra : DimenKids.button.mediumRect,
                isFixSize: false){_ in
                
                    self.action()
                    let datas:[TabInfoData] = comments.map{
                        TabInfoData(title: $0.title, text: $0.text)
                    }
                    self.pagePresenter.openPopup(
                        PageKidsProvider
                            .getPageObject(.tabInfo)
                            .addParam(key: .datas, value: datas)
                            .addParam(key: .selected, value: 0)
                    )
                
            }
            .padding(.top, DimenKids.margin.light)
        }
        .padding(.all, DimenKids.margin.thin)
    }
}

#if DEBUG
struct CommentBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CommentBox(){
                
            }
        }
    }
}
#endif
