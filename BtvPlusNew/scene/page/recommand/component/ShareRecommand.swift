import Foundation
//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI

extension ShareRecommand {
    static var benifitMe:String? = nil
    static var benifitFriend:String? = nil
}

struct ShareRecommand: PageComponent {
    
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
   
    var synopsisData:SynopsisData? = nil
    @State var benifitMe:String = ""
    @State var benifitFriend:String = ""
    var close: () -> Void
    var body: some View {
        VStack(spacing:0){
            VStack(alignment: .leading, spacing:SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular){
                ZStack() {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(String.share.synopsisRecommandBenefitText1)
                            .modifier(BoldTextStyle(size: Font.size.medium, color: Color.app.black))
                            .multilineTextAlignment(.leading)
                            .fixedSize()
                        Text(String.share.synopsisRecommandBenefitText2)
                            .modifier(BoldTextStyle(size: Font.size.medium, color: Color.brand.primary))
                            .fixedSize()
                            .padding(.top, Dimen.margin.tinyExtra)
                    }
                    HStack{
                        Spacer()
                        Image( Asset.image.recommendPopup )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width: SystemEnvironment.isTablet ? 132 : 102,
                                height: SystemEnvironment.isTablet ? 126 : 98
                            )
                    }
                }
                Text(String.share.synopsisRecommandBenefitText3)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.black))
                    .multilineTextAlignment(.leading)
                
                Spacer().modifier(LineHorizontal(height: Dimen.line.light, color: Color.app.black))
                
                HStack(spacing:0){
                    RecommandBenefitCard(
                        title: String.share.synopsisRecommandBenefitFriend,
                        text1: String.share.synopsisRecommandVodLeading,
                        text2: self.benifitFriend,
                        tip: String.share.synopsisRecommandVodTip)
                    Spacer()
                    RecommandBenefitCard(
                        title: String.share.synopsisRecommandBenefitMe,
                        text1: String.share.synopsisRecommandPurchaseLeading,
                        text2: self.benifitMe,
                        tip: String.share.synopsisRecommandPurchaseTip)
                }
                Spacer().modifier(LineHorizontal(height: Dimen.line.light, color: Color.app.black))
                Text(String.share.synopsisRecommandTip)
                    .kerning(Font.kern.thin)
                    .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.grey))
                    .multilineTextAlignment(.leading)
            }
            .padding(.all, SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular)
            HStack(spacing:0){
                FillButton(
                    text: String.app.close,
                    isSelected: true ,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    bgColor:Color.brand.secondary
                ){_ in
                    self.sendLog(category: String.app.close)
                    self.close()
                }
                FillButton(
                    text: String.share.synopsisRecommandButton,
                    isSelected: true,
                    textModifier: TextModifier(
                        family: Font.family.bold,
                        size: Font.size.lightExtra,
                        color: Color.app.white,
                        activeColor: Color.app.white
                    ),
                    size: Dimen.button.regular,
                    margin: 0,
                    bgColor:Color.brand.primary
                ){_ in
                    
                    self.sendLog(category: String.share.synopsisRecommandButton)
                    self.getRecommandCode()
                }
            }
        }
        .background(Color.app.white)
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getRecommendBenefit :
                guard let benefit = res.data as? RecommandBenefit else { return }
                if let benifitMe = benefit.bpoint {
                    let str = benifitMe + String.share.synopsisRecommandVodTrailing
                    Self.benifitMe = str
                    self.benifitMe = str
                }
                if let benifitFriend = benefit.coupon_val{
                    let str = benifitFriend + String.share.synopsisRecommandPurchaseTrailing
                    Self.benifitFriend = str
                    self.benifitFriend = str
                }
            case .registRecommend :
                guard let recommandId = res.data as? RecommandId else {
                    self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
                    return
                }
                if let mgmId = recommandId.mgm_id {
                    self.share(mgmId: mgmId)
                } else {
                    self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
                }
                
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getRecommendBenefit : break
            default: break
            }
        }
        .onAppear(){
            if let benifitFriend = Self.benifitFriend, let benifitMe = Self.benifitMe {
                self.benifitFriend = benifitFriend
                self.benifitMe = benifitMe
            } else {
                self.dataProvider.requestData(q: .init(type: .getRecommendBenefit))
            }
        }
    }//body
    
    private func getRecommandCode(){
        guard let user = self.pairing.user else {return}
        guard let data = self.synopsisData else {return}
        self.dataProvider.requestData(q: .init(type: .registRecommend(user, data)))
    }
    
    private func share(mgmId:String){
        let epsdId = self.synopsisData?.epsdId ?? ""
        let srisId = self.synopsisData?.srisId ?? ""
        let link = ApiPath.getRestApiPath(.WEB)
            + SocialMediaSharingManage.sharinglink + "/" + srisId + "/" + epsdId
            + "?from=mgm&created="
            + self.getCreated()
            + "&rcmd_id=" + mgmId
            + "&rcmd_nickname=" + (self.pairing.user?.nickName ?? "")
        self.repository.shareManager.share(
            Shareable(
                link:link,
                text: String.share.synopsisRecommand,
                useDynamiclink:false
            )
        ){ isComplete in
            
            self.close()
        }
    }
    
    private func getCreated() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmm"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: Date())
    }
    
    private func sendLog(category:String){
       
        var actionBody = MenuNaviActionBodyItem()
        actionBody.category = category
        self.naviLogManager.popupLog(action: .clickPopupButton, actionBody: actionBody)
    }
}


struct RecommandBenefitCard: PageView {
    var title:String
    var text1:String
    var text2:String
    var tip:String
   
    var body: some View {
        VStack(spacing:Dimen.margin.thinExtra){
            Text(title)
                .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.black))
            ZStack(alignment: .center) {
                Image( Asset.shape.recommendPopupTicket )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .modifier(MatchParent())
                VStack(spacing:Dimen.margin.micro){
                    Text(text1)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.black))
                    Text(text2)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
                    Text(tip)
                        .modifier(BoldTextStyle(size: Font.size.tiny, color: Color.app.grey))
                        .padding(.top, Dimen.margin.micro)
                }
            }
            .frame(
                width: SystemEnvironment.isTablet ? 196 : 136,
                height: SystemEnvironment.isTablet ? 109 : 76
            )
        }
        
        
    }//body
    
    
}



#if DEBUG
struct ShareRecommand_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            ShareRecommand(){
                
            }
        }
        .environmentObject(PagePresenter())
        .environmentObject(DataProvider())
        .environmentObject(Pairing())
        .frame(width: 360)
        .background(Color.brand.bg)
    }
}
#endif
