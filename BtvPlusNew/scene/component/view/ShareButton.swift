
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct ShareButton: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    var type:PageType = .btv
    var srisId:String? = nil
    var epsdId:String? = nil
    var isRecommand:Bool? = nil
    var body: some View {
        Button(action: {
            self.share()
            
        }) {
            if self.type == .btv {
                VStack(spacing:0){
                    Image( Asset.icon.share)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(
                            width: Dimen.icon.regular,
                            height: Dimen.icon.regular)
                    
                    Text(String.button.share)
                        .modifier(MediumTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.greyLight
                        ))
                        .fixedSize(horizontal: true, vertical: false)
                }
                
            } else {
                Image(  AssetKids.icon.share)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: DimenKids.icon.light,
                        height: DimenKids.icon.light)
            }
            
        }//btn
        
    }//body
    
    
    func share(){
        let epsdId = self.epsdId ?? ""
        let srisId = self.srisId ?? ""
        
        if self.isRecommand == true && self.pairing.status == .pairing {
            let data = SynopsisData(srisId: srisId, epsdId: epsdId)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.recommand)
                    .addParam(key: .data, value:data)
            )
            
        } else {
            let link = ApiPath.getRestApiPath(.WEB)
                + SocialMediaSharingManage.sharinglink + "/" + srisId + "/" + epsdId + "?from=share"
            self.repository.shareManager.share(
                Shareable(
                    link:link,
                    text: String.share.synopsis,
                    useDynamiclink:false
                )
            )
        }
        
        
    }
}


struct RecommandTip: PageView {
    var body: some View {
        ZStack{
            Image( Asset.shape.recommandTip)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchParent())
            HStack(spacing: 0){
                Image( Asset.icon.cateBCash)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: SystemEnvironment.isTablet ? Dimen.icon.tinyExtra : Dimen.icon.tiny,
                        height: SystemEnvironment.isTablet ? Dimen.icon.tinyExtra : Dimen.icon.tiny)
                Text(String.app.recivePoint)
                .modifier(BoldTextStyle(
                    size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.tiny,
                    color: Color.app.white
                ))
            }
            .padding(.top, SystemEnvironment.isTablet ? -5 : 0 )
        }
        .frame(
            width: SystemEnvironment.isTablet ? 94 : 88,
            height: SystemEnvironment.isTablet ? 31 : 22)
        
    }//body
}

#if DEBUG
struct ShareButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            ShareButton(
              
            )
            .environmentObject(Repository())
        }
    }
}
#endif

