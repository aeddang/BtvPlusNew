//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupHappySenior: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupHappySenior).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupHappySeniorPicture,
                    subTitle: String.pageText.setupHappySeniorPictureText,
                    more:{
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.webview)
                                .addParam(key: .data, value: BtvWebView.happySenior)
                                .addParam(key: .title , value: String.pageText.setupHappySeniorPicture)
                        )
                        
                        //AppUtil.openURL(ApiPath.getRestApiPath(.WEB) + BtvWebView.happySenior)
                    }
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupHappySenior_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupHappySenior()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
