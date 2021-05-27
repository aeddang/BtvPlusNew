//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupChildren: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var isInitate:Bool = false
    var isPairing:Bool = false
    
    //var more: () -> Void
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupChildren).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupChildrenHabit,
                    subTitle: String.pageText.setupChildrenHabitText,
                    more:{
                        //self.more()
                        self.setupWatchHabit()
                    }
                )
            }
            .background(Color.app.blueLight)
        }
        
    }//body
    
    
    private func setupWatchHabit(){
        if self.isPairing == false {
            self.appSceneObserver.alert = .needPairing()
            return
        }
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
}

#if DEBUG
struct SetupChildren_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupChildren()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
