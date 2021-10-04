
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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    
    
    var componentViewModel:SynopsisViewModel? = nil
    var type:PageType = .btv
    var srisId:String? = nil
    var epsdId:String? = nil
    var isRecommand:Bool? = nil
    var isActive:Bool = true
    var body: some View {
        Button(action: {
            if !self.isActive {return}
            self.componentViewModel?.uiEvent = .share(isRecommand: isRecommand == true)
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
        .opacity(self.isActive ? 1.0 : 0.5)
        
    }//body
    
    
    func share(){
        let epsdId = self.epsdId ?? ""
        let srisId = self.srisId ?? ""
        
        if self.isRecommand == true && self.pairing.status == .pairing {
            let data = SynopsisData(srisId: srisId, epsdId: epsdId, synopType: .none)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.recommand)
                    .addParam(key: .data, value:data)
            )
            
        } else {
            let shareFullpath = ApiPath.getRestApiPath(.WEB)
            guard  let shareHost = shareFullpath.toUrl()?.host else {return}
            let domain = shareFullpath.hasPrefix("https://") ? "https://" : "http://"
            let link = domain + shareHost + SocialMediaSharingManage.sharinglink + "/" + srisId + "/" + epsdId  + "?from=share"
           
            self.repository.shareManager.share(
                Shareable(
                    link:link,
                    text: String.share.synopsis,
                    useDynamiclink:true
                )
            ){ isComplete in
                self.appSceneObserver.event = .toast(isComplete ? String.share.complete : String.share.fail)
            }
        }
        
        
    }
}
extension RecommandTip{
    static let height:CGFloat = SystemEnvironment.isTablet ? 31 : 22
}

struct RecommandTip: PageView {
    var funtionLayout:Axis = .vertical
    var body: some View {
        ZStack{
            Image( self.funtionLayout == .horizontal ? Asset.shape.recommandTipHorizontal : Asset.shape.recommandTip)
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
            .padding(.top, self.funtionLayout == .horizontal ? -5 : 0 )
        }
        .frame(
            width: SystemEnvironment.isTablet ? 94 : 88,
            height: Self.height)
        
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

