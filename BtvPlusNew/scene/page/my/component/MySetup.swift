//
//  ValueInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/19.
//

import Foundation
import SwiftUI
struct MySetup: View {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.thinExtra){
            Text(String.pageText.mySetup).modifier(BlockTitle())
            HStack(spacing: 0){
                Button(action: {
                   
                    self.sendLog(action: .clickSimpleSetup, actionBody: .init(config:"시청 습관 관리"))
                    self.setupWatchHabit()
                }) {
                    Text(String.pageText.setupChildrenHabit)
                        .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                }
                .modifier(MatchParent())
                Spacer().modifier(LineVertical())
                    .frame(height:Dimen.button.lightExtra)
                Button(action: {
                    self.sendLog(action: .clickSimpleSetup, actionBody: .init(config:"가족사진 등록"))
                    
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: BtvWebView.happySenior)
                            .addParam(key: .title , value: String.pageText.setupHappySeniorPicture)
                    )
                }) {
                    VStack(spacing:Dimen.margin.thinExtra){
                        Text(String.pageText.setupHappySeniorPicture)
                            .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                        Image(Asset.icon.btvliteFamily)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SystemEnvironment.isTablet ? 114 : 87,
                                   height: SystemEnvironment.isTablet ? 26 : 22)
                    }
                }
                .modifier(MatchParent())
            }
            .background(Color.app.blueLight)
            .frame(height:SystemEnvironment.isTablet ? Dimen.tab.heavyExtra : Dimen.tab.heavy)
        }
        
    }//body
    
    
    private func setupWatchHabit(){
        if !SystemEnvironment.isAdultAuth {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.adultCertification)
            )
            return
        }
        let move = PageProvider.getPageObject(.watchHabit)
        move.isPopup = true
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .data, value:move)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
        )
    }
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil) {
        self.naviLogManager.actionLog(action , actionBody: actionBody)
    }

}


#if DEBUG
struct MySetup_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            MySetup()
        }
    }
}
#endif
