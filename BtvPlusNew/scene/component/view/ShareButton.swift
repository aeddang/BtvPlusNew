
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
    @EnvironmentObject var repository:Repository
    var type:PageType = .btv
    var srisId:String? = nil
    var epsdId:String? = nil
    var body: some View {
        Button(action: {
            let epsdId = self.epsdId ?? ""
            let srisId = self.srisId ?? ""
            let link = ApiPath.getRestApiPath(.WEB) + SocialMediaSharingManage.sharinglink + "/" + srisId + "/" + epsdId
            self.repository.shareManager.share(
                Shareable(
                    link:link,
                    text: String.share.synopsis,
                    useDynamiclink:false
                )
            )
            
        }) {
            if self.type == .btv { 
                VStack(spacing:0){
               
                    Image(  Asset.icon.share)
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

