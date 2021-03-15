//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
extension Footer{
    static let height:CGFloat = 50
    static let expandHeight:CGFloat = 270
    
    static let privacy = "https://m.skbroadband.com/Page.do?menu_id=F02000000"
    static let businessRegistration = "https://www.ftc.go.kr/bizCommPop.do?wrkr_no=2148618758"
    static let serviceTerms = ApiPath.getRestApiPath(.WEB) + "/view/v3.0/terms"
}
struct Footer: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var isExpand = false
    var body: some View {
        VStack(alignment: .center, spacing: Dimen.margin.thin){
            HStack(spacing: Dimen.margin.thinExtra){
                TextButton(
                    defaultText:String.pageTitle.privacy,
                    textModifier: MediumTextStyle(size: Font.size.tiny , color: Color.app.grey).textModifier
                ){ _ in
                    AppUtil.openURL(Self.privacy)
                }
                Text("・")
                    .modifier(MediumTextStyle(size: Font.size.tiny , color: Color.app.grey))
                TextButton(
                    defaultText:String.pageTitle.serviceTerms,
                    textModifier: MediumTextStyle(size: Font.size.tiny , color: Color.app.grey).textModifier
                ){ _ in
                    
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: Self.serviceTerms)
                            .addParam(key: .title , value: String.pageTitle.privacy)
                    )
                    
                }
            }
            Button(action: {
                withAnimation{
                    self.isExpand.toggle()
                }
            }) {
                HStack( spacing: Dimen.margin.micro){
                    Text(String.button.broadband)
                        .modifier(MediumTextStyle(size: Font.size.tiny , color: Color.app.grey))
                    Image(Asset.icon.down)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                        .rotationEffect(.degrees(self.isExpand ? 180 : 0))
                        .opacity(0.8)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            if self.isExpand {
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    Text(String.footer.text)
                        .lineSpacing(Dimen.margin.thinExtra)
                        .modifier(MediumTextStyle(size: Font.size.tiny , color: Color.app.grey))
                    TextButton(
                        defaultText:String.footer.button,
                        textModifier: MediumTextStyle(size: Font.size.tiny , color: Color.app.grey).textModifier,
                        isUnderLine: true
                    ){ _ in
                        AppUtil.openURL(Self.businessRegistration)
                    }
                    .padding(.top, Dimen.margin.thinExtra)
                }
                .padding(.all, Dimen.margin.regular)
                .background(Color.app.blueDeep)
            }
        }
        .modifier(MatchHorizontal(height: self.isExpand ? Self.expandHeight : Self.height))
    }
}
  
#if DEBUG
struct Footer_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            Footer()
            .frame(width:375, height: 477, alignment: .center)
                .background(Color.brand.bg)
        }
    }
}
#endif

